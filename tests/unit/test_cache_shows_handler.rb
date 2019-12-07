require 'json'
require 'test/unit'
require 'mocha/test_unit'

require_relative '../../src/cache_shows'

class CacheTest < Test::Unit::TestCase
  def test_cache_handler
    # Time.expects(:now).at_least_once.returns(one_pm_in_miami)
    ENV.expects(:fetch).with('CACHE_TABLE').returns(fake_table_name)
    Aws::DynamoDB::Client.expects(:new)
                         .with(region: REGION)
                         .returns(mock_dynamo(
                                    table_name: fake_table_name,
                                    items: [
                                      {
                                        put_request: {
                                          item: {
                                            'show_name' => 'foo program',
                                            'start_time_iso8601' => '2019-11-24T00:00:00-05:00',
                                            'ttl' => 1_575_003_600
                                          }
                                        }
                                      }
                                    ]
                         ))

    handler(event: fake_event(fake_message), context: {})
  end

  private

  def fake_table_name
    'foo'
  end

  def fake_event(message)
    # ['Records'][0]['Sns']['Message']
    {
      'Records' => [
        {
          'Sns' => {
            'Message' => message
          }
        }
      ]
    }
  end

  def fake_message
    {
      'onToday' => [
        {
          'start_utc' => 'Sun Nov 24 2019 00:00:00 GMT-0500 (EST)',
          'program' => {
            'name' => 'Foo Program '
          }
        }
      ]
    }.to_json
  end

  def miami_time_for_utc_hour(hour)
    Time.utc(2019, 11, 24, hour, 15).getlocal('-05:00')
  end

  def ten_am_in_miami
    miami_time_for_utc_hour(15)
  end

  def one_pm_in_miami
    miami_time_for_utc_hour(19)
  end

  def mock_dynamo(table_name:, items:)
    Object.new.tap do |mock|
      mock.expects(:batch_write_item)
          .with(request_items: { # required
                  table_name => items
                })
          .once
          .returns(nil)
    end
  end
end
