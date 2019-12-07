require 'json'
require 'aws-sdk-dynamodb' # v2: require 'aws-sdk'

REGION = 'us-east-1'.freeze
CACHE = 'CACHE_TABLE'.freeze
MIAMI_TZ = '-05:00'.freeze
DATE_FORMAT = '%Y-%m-%d'.freeze

def handler(event:, context:)
  puts "[INFO] RECEIVED EVENT: #{event.to_json} WITH CONTEXT: #{context.to_json}"

  message = JSON.parse(event['Records'][0]['Sns']['Message'])
  dynamodb = Aws::DynamoDB::Client.new(region: REGION)

  begin
    add_to_shows_db(dynamodb, message)
  rescue StandardError => e
    warn "[ERROR] adding shows #{e}"
  end
end

def add_to_shows_db(dynamodb, message)
  shows_table_name = ENV.fetch(CACHE)
  items = build_items(message)

  resp = batch_write_to_ddb_table(dynamodb, table_name: shows_table_name, items: items)
  puts resp.inspect
end

def batch_write_to_ddb_table(dynamodb, table_name:, items:)
  request = {
    request_items: {
      table_name => items
    }
  }

  puts "[INFO] going to batch_write to dynamo: #{request}"
  dynamodb.batch_write_item(request)
end

def build_items(message)
  message['onToday'].map do |show|
    show_time = convert_full_utc_string_to_datetime(show['start_utc'])

    {
      put_request: {
        item: {
          'show_name' => show['program']['name'].downcase.strip,
          'start_time_iso8601' => show_time.iso8601,
          'ttl' => show_time.to_i + 864_000 # ten days
        }
      }
    }
  end
end

def convert_full_utc_string_to_datetime(string)
  # Time.strptime("Sun Nov 24 2019 10:00:00 GMT-0500 (EST)", "%a %b %d %Y %T %z %Z")
  Time.strptime(string, '%a %b %d %Y %T GMT%z')
end
