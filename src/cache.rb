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

  begin
    add_to_shows_db(dynamodb, message)
  rescue StandardError
    warn '[ERROR] adding shows'
  end
end

def convert_full_utc_string_to_datetime(string)
  # Time.strptime("Sun Nov 24 2019 10:00:00 GMT-0500 (EST)", "%a %b %d %Y %T %z %Z")
  Time.strptime(string, '%a %b %d %Y %T GMT%z')
end

def convert_full_utc_string_to_iso8601(string); end

def build_items(message)
  message['onToday'].map do |show|
    show_time = convert_full_utc_string_to_datetime(show['start_utc'])

    {
      put_request: {
        show_name: show['program']['name'].downcase,
        start_time_iso8601: show_time.iso8601,
        ttl: show_time.to_i + 432_000 # five days
      }
    }
  end
end

def batch_write_to_ddb_table(table_name:, items:)
  dynamodb.batch_write_item(
    request_items: { # required
      table_name => items
    },
    return_consumed_capacity: 'INDEXES', # accepts INDEXES, TOTAL, NONE
    return_item_collection_metrics: 'SIZE', # accepts SIZE, NONE
  )
end

def add_to_shows_db(dynamodb, message)
  shows_table_name = ENV.fetch(SHOWS)
  items = build_items(message)

  resp = batch_write_to_ddb_table(shows_table_name, items)
  puts resp.inspect
end

def store_response_in_cache(dynamodb, message)
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
