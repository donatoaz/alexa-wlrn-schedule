require 'json'
require 'test/unit'
require 'mocha/test_unit'

require_relative '../../src/schedule'

class CacheTest < Test::Unit::TestCase
  def event
    {
      Records: [
        {
          messageId: "19dd0b57-b21e-4ac1-bd88-01bbb068cb78",
          receiptHandle: "MessageReceiptHandle",
          body: wlrn_schedule_payload,
          attributes: {
            ApproximateReceiveCount: "1",
            SentTimestamp: "1523232000000",
            SenderId: "123456789012",
            ApproximateFirstReceiveTimestamp: "1523232000001"
          },
          messageAttributes: {},
          md5OfBody: "7b270e59b47ff90a553787216d55d91d",
          eventSource: "aws:sqs",
          eventSourceARN: "arn:aws:sqs:us-east-1:123456789012:MyQueue",
          awsRegion: "us-east-1"
        }
      ]
    }
  end

  def wlrn_schedule_payload
    "Test message"
  end

  def mock_response
    Object.new.tap do |mock|
      mock.expects(:code).returns(200)
      mock.expects(:body).returns('1.1.1.1')
    end
  end

  def expected_result
    {
      statusCode: 200,
      body: {
        message: 'Hello World!',
        location: '1.1.1.1'
      }.to_json
    }
  end

  def test_lambda_handler
    # HTTParty.expects(:get).with('http://checkip.amazonaws.com/').returns(mock_response)
    # assert_equal(lambda_handler(event: event, context: ''), expected_result)
  end
end
