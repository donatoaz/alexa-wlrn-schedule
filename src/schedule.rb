require 'json'
require 'aws-sdk-s3'
require 'aws-sdk-sqs'
require 'aws-sdk-sns'
require 'aws-sdk-dynamodb'

require 'httparty'

REGION = 'us-east-1'.freeze
CACHE = 'CACHE_TABLE'.freeze
MIAMI_TZ = '-05:00'.freeze
DATE_FORMAT = '%Y-%m-%d'.freeze

def handler(event:, context:)
  request = event['request']
  intent = Intent.new

  case request['type']
  when 'LaunchRequest'
    intent.launch
  when 'IntentRequest'
    case request['intent']['name']
    when 'Schedule'            then intent.schedule(event, context)
    when 'NextOn'              then intent.schedule_next(event, context)
    when 'AMAZON.HelpIntent'   then intent.help
    when 'AMAZON.CancelIntent' then intent.cancel
    when 'AMAZON.StopIntent'   then intent.stop
    end
  end
end

class Intent
  def schedule(event, context)
    sqs = Aws::SQS::Client.new(region: REGION)
    sqs.send_message(queue_url: ENV.fetch('DEBUG_QUEUE_URL'),
                     message_body: { event: event, context: context }.to_json)

    now = Time.now.getlocal(MIAMI_TZ)
    response = nil

    # Try and load response from cache
    cache = Aws::DynamoDB::Client.new(region: REGION)
    params = {
      table_name: ENV.fetch(CACHE),
      key: {
        date: now.strftime(DATE_FORMAT)
      }
    }
    begin
      cached = cache.get_item(params)
      response = cached.item['response'] unless cached.item.nil?

      # logging
      if response.nil?
        puts "[INFO] Cache miss for #{now.strftime(DATE_FORMAT)}"
      else
        puts "[INFO] Cache hit for #{now.strftime(DATE_FORMAT)}"
      end
    rescue Aws::DynamoDB::Errors::ServiceError => error
      warn "[ERROR] Error reading DynamoDB: #{error}"
      return error_reading_cache
    end

    # in case of cache miss, we'll fetch it from NPR's API
    #  and notify the NewRequestSNSTopic
    if response.nil?
      response = request_schedule(now)

      # Notify NewRequest sns topic (used for caching and analytics)
      sns = Aws::SNS::Resource.new(region: REGION)
      topic_arn = ENV.fetch('NEW_REQUEST_SNS_TOPIC_ARN')
      topic = sns.topic(topic_arn)
      topic.publish(message: response)
    end

    return failed_to_get_response_from_npr unless response

    # parse response
    schedule = parse_response_for_schedule(response)
    current_program = get_program_by_time(schedule, now)

    JSON.generate(
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: "<speak>#{current_program[:program]['name']} is playing now " \
                "until <say-as interpret-as=\"time\">#{current_program[:end_time]}</say-as></speak>"
        },
        shouldEndSession: true
      }
    )
  end

  def launch
    JSON.generate(
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>Welcome to WLRN schedule. You can ask me things like: what is playing now? Or ask me what will play next.</speak>'
        },
        shouldEndSession: false
      }
    )
  end

  def error_message(message)
    JSON.generate(
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: "<speak>#{message}</speak>"
        },
        shouldEndSession: true
      }
    )
  end

  def failed_to_get_response_from_npr
    error_message('Sorry, there was a problem requesting the schedule from NPR. Please try again later.')
  end

  def error_reading_cache
    error_message('Sorry, there was an error. The lazy developer has been notified and will fix it ASAP.')
  end

  def schedule_next(event, context)
    JSON.generate(
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>This works</speak>'
        },
        shouldEndSession: true
      }
    )
  end

  def help
    JSON.generate(
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>This skill is say hello.</speak>'
        },
        shouldEndSession: false
      }
    )
  end

  def cancel
    JSON.generate(
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>Cancel the skill.</speak>'
        },
        shouldEndSession: true
      }
    )
  end

  def stop
    JSON.generate(
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>Stop the skill.</speak>'
        },
        shouldEndSession: true
      }
    )
  end

  def request_schedule(time)
    default_url = 'https://api.composer.nprstations.org/v1/widget/5187f4c7e1c8a450fdefbbd8/day?format=json&date='
    url = ENV.fetch('WLRN_URL', default_url) + time.strftime(DATE_FORMAT)

    response = HTTParty.get(url)
    return nil unless response.code == 200

    response.body
  end

  def parse_response_for_schedule(body)
    events = JSON.parse(body)['onToday']

    events.reduce({}) do |schedule, event|
      schedule.merge(
        event['start_time'] => {
          end_time: event['end_time'],
          program: event['program']
        }
      )
    end
  end

  def get_program_by_time(sch, time)
    hour, minute = time.strftime('%H %m').split.map(&:to_i)
    show_times = sch.keys.sort
    show_times.each do |start_time|
      start_hour, start_minute = start_time.split(':').map(&:to_i)
      end_hour, end_minute = sch[start_time][:end_time].split(':').map(&:to_i)

      if start_hour == end_hour
        return sch[start_time] if time == start_hour &&
                                  minute.between?(start_minute, end_minute)
      end

      return sch[start_time] if hour.between?(start_hour, end_hour - 1) ||
                                (hour == end_hour && minute <= end_minute)
    end

    nil
  end
end
