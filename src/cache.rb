require 'json'
require 'aws-sdk-dynamodb' # v2: require 'aws-sdk'

REGION = 'us-east-1'.freeze
CACHE = 'CACHE_TABLE'.freeze
MIAMI_TZ = '-05:00'.freeze
DATE_FORMAT = '%Y-%m-%d'.freeze

def handler(event:, context:)
  puts "[INFO] RECEIVED EVENT: #{event.to_json} WITH CONTEXT: #{context.to_json}"

  message = event['Records'][0]['Sns']['Message']
  now = Time.now.getlocal(MIAMI_TZ)
  dynamodb = Aws::DynamoDB::Client.new(region: REGION)

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
