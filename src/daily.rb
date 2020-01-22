require 'json'
require 'time'
require 'httparty'
require 'aws-sdk-sns'
require 'aws-sdk-dynamodb'

REGION = 'us-east-1'.freeze
CACHE = 'CACHE_TABLE'.freeze
MIAMI_TZ = '-05:00'.freeze
DATE_FORMAT = '%Y-%m-%d'.freeze

# TODO: reduce DRY by extracting common behavior in daily.rb and schedule.rb into specialized class
def handler(event:, context:)
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
  return unless response.nil?

  response = request_schedule(now)

  # Notify NewRequest sns topic (used for caching and analytics)
  sns = Aws::SNS::Resource.new(region: REGION)
  topic_arn = ENV.fetch('NEW_REQUEST_SNS_TOPIC_ARN')
  topic = sns.topic(topic_arn)
  topic.publish(message: response)
end

def request_schedule(time)
  default_url = 'https://api.composer.nprstations.org/v1/widget/5187f4c7e1c8a450fdefbbd8/day?format=json&date='
  url = ENV.fetch('WLRN_URL', default_url) + time.strftime(DATE_FORMAT)

  response = HTTParty.get(url)
  return nil unless response.code == 200

  response.body
end