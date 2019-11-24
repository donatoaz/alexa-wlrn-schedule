require 'json'
require 'aws-sdk-s3'

def handler(event:, context:)
  request = event['request']
  intent = Intent.new

  case request['type']
  when 'LaunchRequest'
    intent.launch
  when 'IntentRequest'
    case request['intent']['name']
    when 'Schedule'         then intent.schedule
    when 'AMAZON.HelpIntent'   then intent.help
    when 'AMAZON.CancelIntent' then intent.cancel
    when 'AMAZON.StopIntent'   then intent.stop
    end
  end
end

class Intent  
  def launch
    JSON.generate({
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>Welcome to WLRN schedule. You can ask me things like: what is playing now? Or ask me what will play next.</speak>'
        },
        shouldEndSession: false
      }
    })
  end

  def schedule
    JSON.generate({
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>This works</speak>'
        },
        shouldEndSession: true
      }
    })
  end
  
  def playing now
      JSON.generate({
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>This works</speak>'
        },
        shouldEndSession: true
      }
    })
  end

  def help
    JSON.generate({
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>This skill is say hello.</speak>'
        },
        shouldEndSession: false
      }
    })
  end

  def cancel
    JSON.generate({
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>Cancel the skill.</speak>'
        },
        shouldEndSession: true
      }
    })
  end

  def stop
    JSON.generate({
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>Stop the skill.</speak>'
        },
        shouldEndSession: true
      }
    })
  end
end