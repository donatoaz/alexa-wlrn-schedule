require 'json'
require 'test/unit'
require 'mocha/test_unit'

require_relative '../../src/daily'

class DailyTest < Test::Unit::TestCase
  def test_daily_handler
    default_wlrn_url = "https://api.composer.nprstations.org/v1/widget/5187f4c7e1c8a450fdefbbd8/day?format=json&date="
    fake_sns_topic_arn = 'fake_sns_topic_arn'
    fake_response = 'fake_response'

    Time.expects(:now).at_least_once.returns(one_pm_in_miami)
    HTTParty.expects(:get).with(default_wlrn_url + '2019-11-24').returns(mock_response(fake_response))

    ENV.expects(:fetch).with('CACHE_TABLE').returns('foo_table')
    ENV.expects(:fetch).with('NEW_REQUEST_SNS_TOPIC_ARN').returns(fake_sns_topic_arn)
    ENV.expects(:fetch).with('WLRN_URL', default_wlrn_url).returns(default_wlrn_url)

    Aws::DynamoDB::Client.expects(:new).with(region: REGION).returns(mock_dynamo)
    Aws::SNS::Resource.expects(:new).with(region: REGION).returns(mock_sns(fake_sns_topic_arn, fake_response))

    handler(event: {}, context: {})
    assert_equal(1, 1)
  end

  private

  def mock_response(response)
    Object.new.tap do |mock|
      mock.expects(:code).returns(200)
      mock.expects(:body).returns(response)
    end
  end

  def mock_dynamo
    mock_item = Object.new.tap do |mock|
      mock.expects(:item).returns(nil)
    end

    Object.new.tap do |mock|
      mock.expects(:get_item).returns(mock_item)
    end
  end

  def mock_sns(arn, response)
    mock_item = Object.new.tap do |mock|
      mock.expects(:publish).with(message: response).returns(nil)
    end

    Object.new.tap do |mock|
      mock.expects(:topic).with(arn).returns(mock_item)
    end
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
end