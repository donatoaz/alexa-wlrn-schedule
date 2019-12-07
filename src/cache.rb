require 'json'
require 'aws-sdk-dynamodb' # v2: require 'aws-sdk'

REGION = 'us-east-1'.freeze
CACHE = 'CACHE_TABLE'.freeze
SHOWS = 'SHOWS_TABLE'.freeze
MIAMI_TZ = '-05:00'.freeze
DATE_FORMAT = '%Y-%m-%d'.freeze

def handler(event:, context:)
  puts "[INFO] RECEIVED EVENT: #{event.to_json} WITH CONTEXT: #{context.to_json}"

  message = event['Records'][0]['Sns']['Message']
  dynamodb = Aws::DynamoDB::Client.new(region: REGION)

  store_response_in_cache(dynamodb, message)
end

def store_response_in_cache(dynamodb, message)
  now = Time.now.getlocal(MIAMI_TZ)

  item = { date: now.strftime(DATE_FORMAT), response: message }
  params = { table_name: ENV.fetch(CACHE), item: item }

  begin
    dynamodb.put_item(params)
    puts '[INFO] Added cache item'
  rescue Aws::DynamoDB::Errors::ServiceError => error
    warn '[ERROR] Unable to add cache entry:'
    warn error.message
  end
end
