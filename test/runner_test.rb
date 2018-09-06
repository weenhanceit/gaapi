# frozen_string_literal: true

require "test_helper"

class RunnerTest < Test
  def setup
    ARGV.clear
  end

  QUERY = <<~QUERY
    {
      "reportRequests": [{
        "viewId": "000000",
        "dimensions": [{"name": "ga:date"}],
        "dateRanges": [{
          "startDate": "2017-10-01",
          "endDate": "2017-10-31"
        }],
        "metrics": [{ "expression": "ga:sessions" }],
        "includeEmptyRows": true,
        "hideTotals": false,
        "hideValueRanges": true
      }]
    }
  QUERY

  def test_no_view
    assert_output "", /gaapi: You must provide a view ID./ do
      status = GAAPI::Main.call
      refute status.zero?
    end
  end

  def test_empty_query
    ARGV.concat(%w[-a asldkjfalkdfj --dry-run 888888])
    assert_output "", /unexpected token at ''/ do
      begin
        $stdin = StringIO.new("")
        status = GAAPI::Main.call
        refute status.zero?
      ensure
        $stdin = STDIN
      end
    end
  end

  def test_authorization_failure
    body = <<~BODY
      {
        "error": {
          "code": 401,
          "message": "Request had invalid authentication credentials. Expected OAuth 2 access token, login cookie or other valid authentication credential. See https://developers.google.com/identity/sign-in/web/devconsole-project.",
          "status": "UNAUTHENTICATED"
        }
      }
    BODY
    stub_request(:any, "https://analyticsreporting.googleapis.com/v4/reports:batchGet")
      .with(body: /endDate/, headers: { "Authorization" => "Bearer not_the_right_token" })
      .to_return(body: body, status: 401)
    ARGV.concat(%w[-a not_the_right_token 888888])
    begin
      $stdin = StringIO.new(QUERY)
      assert_output body do
        status = GAAPI::Main.call
        refute status.zero?
      end
    ensure
      $stdin = STDIN
    end
  end

  def test_simple_command_line
    stub_request(:any, "https://analyticsreporting.googleapis.com/v4/reports:batchGet")
      .with(body: /endDate/, headers: { "Authorization" => "Bearer asldkjfalkdfj" })
      .to_return(body: "{}", status: 200)
    ARGV.concat(%w[-a asldkjfalkdfj 888888])
    begin
      $stdin = StringIO.new(QUERY)
      assert_output "{\n}\n" do
        status = GAAPI::Main.call
        assert status.zero?
      end
    ensure
      $stdin = STDIN
    end
  end

  def test_credential_file_missing
    ARGV.concat(%w[-c daves_not_here_man.json 888888])
    assert_output "", /No such file or directory @ rb_stat_init - daves_not_here_man.json/ do
      status = GAAPI::Main.call
      refute status.zero?
    end
  end
end
