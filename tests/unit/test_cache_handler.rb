require 'json'
require 'test/unit'
require 'mocha/test_unit'

require_relative '../../src/cache'

class CacheTest < Test::Unit::TestCase
  def test_cache_handler
    Time.expects(:now).at_least_once.returns(one_pm_in_miami)
    ENV.expects(:fetch).with('CACHE_TABLE').returns(fake_table_name)
    Aws::DynamoDB::Client.expects(:new)
                         .with(region: REGION)
                         .returns(mock_dynamo(
                                    table_name: fake_table_name,
                                    item: {
                                      date: one_pm_in_miami.strftime('%F'),
                                      response: fake_message
                                    }
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
    { foo: 'bar' }
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

  def mock_dynamo(table_name:, item:)
    Object.new.tap do |mock|
      mock.expects(:put_item).with(table_name: table_name, item: item).once.returns(nil)
    end
  end
end
