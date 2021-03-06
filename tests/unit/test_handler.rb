require 'json'
require 'test/unit'
require 'mocha/test_unit'

require_relative '../../src/schedule'

class ScheduleTest < Test::Unit::TestCase
  def event
    JSON.parse(File.read('./tests/fixtures/launch_intent_input.json'))
  end

  def schedule_event
    JSON.parse(File.read('./tests/fixtures/whatsplayingnow_input.json'))
  end

  def schedule_next_event
    JSON.parse(File.read('./tests/fixtures/whatsnext_input.json'))
  end

  def mock_response
    Object.new.tap do |mock|
      mock.expects(:code).returns(200)
      mock.expects(:body).returns(fake_wlrn_schedule)
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

  def mock_sns
    mock_item = Object.new.tap do |mock|
      mock.expects(:publish).returns(nil)
    end

    Object.new.tap do |mock|
      mock.expects(:topic).returns(mock_item)
    end
  end

  def fake_wlrn_schedule
    "{\"onToday\":[{\"_id\":\"5bf8e22abf5b942bd7879cc6\",\"event_id\":\"52814c2f7d97d3c74d003c2d\",\"program_id\":\"5187f4cce1c8a450fdefbbed\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 00:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 06:00:00 GMT-0500 (EST)\",\"start_time\":\"00:00\",\"end_time\":\"06:00\",\"day\":\"Sun\",\"program\":{\"program_id\":\"5187f4cce1c8a450fdefbbed\",\"parentID\":\"5170591c9de8e95a46000145\",\"national_program_id\":\"13\",\"isParent\":false,\"name\":\"BBC World Service \",\"program_desc\":\"\",\"program_format\":\"News/Information\",\"program_link\":\"http://wlrn.org/programs/bbc-world-service-wlrn\",\"twitter\":\"\",\"facebook\":\"\",\"station_id\":\"station_wlrn_52\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[]},\"conflict_edited\":1398715340000,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 00:00\",\"fullend\":\"2019-11-24 06:00\",\"conflicts\":[\"5bf8e22abf5b942bd7879cc6\"],\"playlist\":null},{\"_id\":\"5bf8e22abf5b942bd7879cc4\",\"event_id\":\"52814c2f7d97d3c74d003c12\",\"program_id\":\"51f144d22b42327e7100061f\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 06:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 07:00:00 GMT-0500 (EST)\",\"start_time\":\"06:00\",\"end_time\":\"07:00\",\"day\":\"Sun\",\"program\":{\"program_id\":\"51f144d22b42327e7100061f\",\"parentID\":null,\"national_program_id\":\"\",\"isParent\":false,\"name\":\"The Steve Pomeranz Show\",\"program_desc\":\"\",\"program_format\":\"News/Information\",\"program_link\":\"http://www.stevepomeranz.com/\",\"twitter\":\"stevepomeranz\",\"facebook\":\"TheStevePomeranzShow\",\"station_id\":\"\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[]},\"conflict_edited\":1543037482789,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 06:00\",\"fullend\":\"2019-11-24 07:00\",\"conflicts\":[\"5bf8e22abf5b942bd7879cc4\"],\"playlist\":null},{\"_id\":\"5bf8e22abf5b942bd7879cd0\",\"event_id\":\"52814c2f7d97d3c74d003c1e\",\"program_id\":\"5187f4cce1c8a450fdefbbeb\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 07:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 08:00:00 GMT-0500 (EST)\",\"start_time\":\"07:00\",\"end_time\":\"08:00\",\"day\":\"Sun\",\"program\":{\"program_id\":\"5187f4cce1c8a450fdefbbeb\",\"parentID\":null,\"national_program_id\":\"0\",\"isParent\":false,\"name\":\"On Being\",\"program_desc\":\"\",\"program_format\":\"Other\",\"program_link\":\"http://www.onbeing.org/\",\"twitter\":\"\",\"facebook\":\"\",\"station_id\":\"station_wlrn_52\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[]},\"conflict_edited\":1460054800503,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 07:00\",\"fullend\":\"2019-11-24 08:00\",\"conflicts\":[\"5bf8e22abf5b942bd7879cd0\"],\"playlist\":null},{\"_id\":\"5bf8e22abf5b942bd7879ccc\",\"event_id\":\"52814c2f7d97d3c74d003c3f\",\"program_id\":\"5187f4cce1c8a450fdefbbe8\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 08:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 10:00:00 GMT-0500 (EST)\",\"start_time\":\"08:00\",\"end_time\":\"10:00\",\"day\":\"Sun\",\"program\":{\"program_id\":\"5187f4cce1c8a450fdefbbe8\",\"parentID\":\"517059449de8e95a46000234\",\"national_program_id\":\"86\",\"isParent\":false,\"name\":\"Weekend Edition\",\"program_desc\":\"\",\"program_format\":\"News/Information\",\"program_link\":\"http://wlrn.org/programs/weekend-edition-wlrn\",\"twitter\":\"\",\"facebook\":\"\",\"station_id\":\"station_wlrn_52\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[]},\"conflict_edited\":1543037482918,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 08:00\",\"fullend\":\"2019-11-24 10:00\",\"conflicts\":[\"5bf8e22abf5b942bd7879ccc\"],\"playlist\":null},{\"_id\":\"5bf8e22abf5b942bd7879cce\",\"event_id\":\"52814c2f7d97d3c74d003c2a\",\"program_id\":\"5187f4cde1c8a450fdefbbff\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 10:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 11:00:00 GMT-0500 (EST)\",\"start_time\":\"10:00\",\"end_time\":\"11:00\",\"day\":\"Sun\",\"program\":{\"program_id\":\"5187f4cde1c8a450fdefbbff\",\"parentID\":\"517059439de8e95a46000227\",\"national_program_id\":\"79\",\"isParent\":false,\"name\":\"This American Life\",\"program_desc\":\"\",\"program_format\":\"News/Information\",\"program_link\":\"http://wlrn.org/programs/american-life\",\"twitter\":\"\",\"facebook\":\"\",\"station_id\":\"station_wlrn_52\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[]},\"conflict_edited\":1543037482933,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 10:00\",\"fullend\":\"2019-11-24 11:00\",\"conflicts\":[\"5bf8e22abf5b942bd7879cce\"],\"playlist\":null},{\"_id\":\"5bf8e22bbf5b942bd7879cd6\",\"event_id\":\"59c55df6a8e1b019c8efed2a\",\"program_id\":\"59c55df6a8e1b019c8efed2b\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 11:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 12:00:00 GMT-0500 (EST)\",\"start_time\":\"11:00\",\"end_time\":\"12:00\",\"day\":\"Sun\",\"program\":{\"program_id\":\"59c55df6a8e1b019c8efed2b\",\"parentID\":\"5170592b9de8e95a46000199\",\"national_program_id\":\"\",\"isParent\":false,\"name\":\"Freakonomics Radio\",\"program_desc\":\"\",\"program_format\":\"News/Information\",\"program_link\":\"https://www.wnyc.org/shows/freakonomics-radio/episodes\",\"twitter\":\"wnyc\",\"facebook\":\"wnyc\",\"station_id\":\"\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[]},\"conflict_edited\":1506106870032,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 11:00\",\"fullend\":\"2019-11-24 12:00\",\"conflicts\":[\"5bf8e22bbf5b942bd7879cd6\"],\"playlist\":null},{\"_id\":\"5bf8e22bbf5b942bd7879cd8\",\"event_id\":\"5b3fa7fa8107846b8526042d\",\"program_id\":\"5b3fa7fa8107846b8526042e\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 12:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 13:00:00 GMT-0500 (EST)\",\"start_time\":\"12:00\",\"end_time\":\"13:00\",\"day\":\"Sun\",\"program\":{\"program_id\":\"5b3fa7fa8107846b8526042e\",\"parentID\":\"59d3d1a713734b6bf6b05701\",\"national_program_id\":\"\",\"isParent\":false,\"name\":\"Hidden Brain\",\"program_desc\":\"\",\"program_format\":\"World\",\"program_link\":\"https://www.npr.org/series/423302056/hidden-brain\",\"twitter\":\"HiddenBrain\",\"facebook\":\"HiddenBrain\",\"station_id\":\"\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[]},\"conflict_edited\":1530898426120,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 12:00\",\"fullend\":\"2019-11-24 13:00\",\"conflicts\":[\"5bf8e22bbf5b942bd7879cd8\"],\"playlist\":null},{\"_id\":\"5bf8e22abf5b942bd7879cca\",\"event_id\":\"5b3fa84bd94d0b0a4880f7c7\",\"program_id\":\"5187f4cee1c8a450fdefbc00\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 13:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 14:00:00 GMT-0500 (EST)\",\"start_time\":\"13:00\",\"end_time\":\"14:00\",\"day\":\"Sun\",\"program\":{\"program_id\":\"5187f4cee1c8a450fdefbc00\",\"parentID\":null,\"national_program_id\":\"0\",\"isParent\":false,\"name\":\"Wait Wait... Don't Tell Me!\",\"program_desc\":\"\",\"program_format\":\"Entertainment\",\"program_link\":\"http://wlrn.org/programs/wait-wait-dont-tell-me\",\"twitter\":\"\",\"facebook\":\"\",\"station_id\":\"station_wlrn_52\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[]},\"conflict_edited\":1530898507744,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 13:00\",\"fullend\":\"2019-11-24 14:00\",\"conflicts\":[\"5bf8e22abf5b942bd7879cca\"],\"playlist\":null},{\"_id\":\"5bf8e22abf5b942bd7879cc8\",\"event_id\":\"52814c2f7d97d3c74d003c40\",\"program_id\":\"5187f4cbe1c8a450fdefbbdd\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 14:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 17:00:00 GMT-0500 (EST)\",\"start_time\":\"14:00\",\"end_time\":\"17:00\",\"day\":\"Sun\",\"program\":{\"program_id\":\"5187f4cbe1c8a450fdefbbdd\",\"parentID\":null,\"national_program_id\":\"0\",\"isParent\":false,\"name\":\"Folk & Acoustic Music with Michael Stock\",\"program_desc\":\"\",\"program_format\":\"Folk\",\"program_link\":\"http://wlrn.org/radio/programs/folk-acoustic-music\",\"twitter\":\"\",\"facebook\":\"\",\"station_id\":\"station_wlrn_52\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[]},\"conflict_edited\":1543037482866,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 14:00\",\"fullend\":\"2019-11-24 17:00\",\"conflicts\":[\"5bf8e22abf5b942bd7879cc8\"],\"playlist\":null},{\"_id\":\"5bf8e22abf5b942bd7879cd2\",\"event_id\":\"52814c2f7d97d3c74d003c31\",\"program_id\":\"5187f4cbe1c8a450fdefbbe1\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 17:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 18:00:00 GMT-0500 (EST)\",\"start_time\":\"17:00\",\"end_time\":\"18:00\",\"day\":\"Sun\",\"program\":{\"program_id\":\"5187f4cbe1c8a450fdefbbe1\",\"parentID\":\"517059399de8e95a460001ea\",\"national_program_id\":\"5\",\"isParent\":false,\"name\":\"All Things Considered\",\"program_desc\":\"\",\"program_format\":\"News/Information\",\"program_link\":\"http://wlrn.org/programs/all-things-considered-wlrn\",\"twitter\":\"\",\"facebook\":\"\",\"station_id\":\"station_wlrn_52\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[]},\"conflict_edited\":1543037482997,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 17:00\",\"fullend\":\"2019-11-24 18:00\",\"conflicts\":[\"5bf8e22abf5b942bd7879cd2\"],\"playlist\":null},{\"_id\":\"5bf8e22bbf5b942bd7879cda\",\"event_id\":\"5b894b75822b214628bc0c1b\",\"program_id\":\"5b894b75822b214628bc0c1c\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 18:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 19:00:00 GMT-0500 (EST)\",\"start_time\":\"18:00\",\"end_time\":\"19:00\",\"day\":\"Sun\",\"program\":{\"program_id\":\"5b894b75822b214628bc0c1c\",\"parentID\":null,\"national_program_id\":\"\",\"isParent\":false,\"name\":\"How I Built This\",\"program_desc\":\"\",\"program_format\":\"News/Information\",\"program_link\":\"https://www.npr.org/podcasts/510313/how-i-built-this\",\"twitter\":\"\",\"facebook\":\"\",\"station_id\":\"\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[{\"name\":\"Guy Raz\"}]},\"conflict_edited\":1535724405248,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 18:00\",\"fullend\":\"2019-11-24 19:00\",\"conflicts\":[\"5bf8e22bbf5b942bd7879cda\"],\"playlist\":null},{\"_id\":\"5bf8e22bbf5b942bd7879cd4\",\"event_id\":\"5727c2f8b2611bbb6526908d\",\"program_id\":\"52cac7f420b4a67b6e000002\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 19:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 20:00:00 GMT-0500 (EST)\",\"start_time\":\"19:00\",\"end_time\":\"20:00\",\"day\":\"Sun\",\"program\":{\"program_id\":\"52cac7f420b4a67b6e000002\",\"parentID\":\"517059339de8e95a460001cd\",\"national_program_id\":\"\",\"isParent\":false,\"name\":\"TED Radio Hour\",\"program_desc\":\"\",\"program_format\":\"News/Information\",\"program_link\":\"http://www.npr.org/programs/ted-radio-hour/\",\"twitter\":\"TEDRadioHour\",\"facebook\":\"\",\"station_id\":\"\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[]},\"conflict_edited\":1462223608302,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 19:00\",\"fullend\":\"2019-11-24 20:00\",\"conflicts\":[\"5bf8e22bbf5b942bd7879cd4\"],\"playlist\":null},{\"_id\":\"5bf8e22abf5b942bd7879cc2\",\"event_id\":\"52814c2f7d97d3c74d003c42\",\"program_id\":\"5187f4cbe1c8a450fdefbbdb\",\"date\":\"2019-11-24\",\"start_utc\":\"Sun Nov 24 2019 20:00:00 GMT-0500 (EST)\",\"end_utc\":\"Sun Nov 24 2019 23:59:00 GMT-0500 (EST)\",\"start_time\":\"20:00\",\"end_time\":\"23:59\",\"day\":\"Sun\",\"program\":{\"program_id\":\"5187f4cbe1c8a450fdefbbdb\",\"parentID\":null,\"national_program_id\":\"0\",\"isParent\":false,\"name\":\"The Night Train\",\"program_desc\":\"\",\"program_format\":\"Jazz\",\"program_link\":\"http://wlrn.org/programs/night-train\",\"twitter\":\"\",\"facebook\":\"\",\"station_id\":\"station_wlrn_52\",\"ucs\":\"5187f4c7e1c8a450fdefbbd8\",\"hosts\":[{\"name\":\"Ted Grossman\"},{}]},\"conflict_edited\":1417630792162,\"widget_config\":{\"custom_fields\":true,\"episode_notes\":true,\"host_display\":true,\"host_allow\":true,\"catalog_number\":true,\"label\":true,\"album_art\":true,\"customized\":false},\"fullstart\":\"2019-11-24 20:00\",\"fullend\":\"2019-11-24 23:59\",\"conflicts\":[\"5bf8e22abf5b942bd7879cc2\"],\"playlist\":null}],\"affiliate\":{\"amazon\":null,\"itunes\":null,\"arkiv\":null},\"params\":{\"format\":\"json\",\"date\":\"2019-11-24\"}}"
  end

  def expected_schedule_result
    {
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>This American Life is playing now until <say-as interpret-as="time">11:00 am</say-as> Miami time</speak>'
        },
        shouldEndSession: true
      }
    }.to_json
  end

  def expected_schedule_next_result
    {
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>Freakonomics Radio will be on, starting at <say-as interpret-as="time">11:00 am</say-as> Miami time</speak>'
        },
        shouldEndSession: true
      }
    }.to_json
  end

  def expected_schedule_result_escaped_characters
    {
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>Folk and Acoustic Music with Michael Stock is playing now until <say-as interpret-as="time">05:00 pm</say-as> Miami time</speak>'
        },
        shouldEndSession: true
      }
    }.to_json
  end

  def expected_launch_result
    {
      version: 1.0,
      response: {
        outputSpeech: {
          type: 'SSML',
          ssml: '<speak>Welcome to WLRN schedule. I can tell you what is playing now or you  can ask me what will play next.</speak>'
        },
        shouldEndSession: false
      }
    }.to_json
  end

  def test_lambda_launch_handler
    assert_equal(expected_launch_result, handler(event: event, context: ''))
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

  def test_schedule_handler
    url = ENV.fetch('WLRN_URL') + '2019-11-24'
    HTTParty.expects(:get).with(url).returns(mock_response)
    Time.expects(:now).at_least_once.returns(ten_am_in_miami)

    Aws::DynamoDB::Client.expects(:new).with(region: REGION).returns(mock_dynamo)
    Aws::SNS::Resource.expects(:new).with(region: REGION).returns(mock_sns)

    assert_equal(expected_schedule_result, handler(event: schedule_event, context: ''))
  end

  def test_schedule_next_handler
    url = ENV.fetch('WLRN_URL') + '2019-11-24'
    HTTParty.expects(:get).with(url).returns(mock_response)
    Time.expects(:now).at_least_once.returns(ten_am_in_miami)

    Aws::DynamoDB::Client.expects(:new).with(region: REGION).returns(mock_dynamo)
    Aws::SNS::Resource.expects(:new).with(region: REGION).returns(mock_sns)

    assert_equal(expected_schedule_next_result, handler(event: schedule_next_event, context: ''))
  end

  def test_schedule_invalid_character
    url = ENV.fetch('WLRN_URL') + '2019-11-24'
    HTTParty.expects(:get).with(url).returns(mock_response)
    Time.expects(:now).at_least_once.returns(one_pm_in_miami)

    Aws::DynamoDB::Client.expects(:new).with(region: REGION).returns(mock_dynamo)
    Aws::SNS::Resource.expects(:new).with(region: REGION).returns(mock_sns)
    
    assert_equal(expected_schedule_result_escaped_characters, handler(event: schedule_event, context: ''))
  end
end
