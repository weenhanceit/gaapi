# frozen_string_literal: true

require "test_helper"

class RunnerTest < Test
  def setup
    ARGV.clear
  end

  QUERY = <<~QUERY
    {
      "reportRequests": [{
        "viewId": "3114200",
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
    stub_request(:any, "https://analyticsreporting.googleapis.com/v4/reports:batchGet")
      .with(body: /endDate/, headers: { "Authorization" => "Bearer not_the_right_token" })
      .to_return(body: "Authorization failed", status: 401)
    ARGV.concat(%w[-a not_the_right_token 888888])
    begin
      $stdin = StringIO.new(QUERY)
      status = GAAPI::Main.call
      refute status.zero?
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
      status = GAAPI::Main.call
      assert status.zero?
    ensure
      $stdin = STDIN
    end
  end
end
