# frozen_string_literal: true

# Run tests like this: ruby -Itest:lib test/query_test.rb [--seed 12345]
require "test_helper"

class QueryTest < Test
  QUERY_STRING = <<~QUERY
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

  EXPECTED_REQUEST = "https://analyticsreporting.googleapis.com/v4/reports:batchGet"

  # Need this because gaapi doesn't put whitespace in query.
  EXPECTED_RESPONSE = QUERY_STRING.gsub(/\s+/, "")

  def setup
    stub_request(:post, EXPECTED_REQUEST)
      .with(body: QUERY_STRING, headers: {
              "Authorization": "Bearer test_token"
            })
      .to_return(body: EXPECTED_RESPONSE, status: 200)
  end

  def test_query_as_a_string
    GAAPI::Query.new(QUERY_STRING, "000000", "test_token", "2017-10-01", "2017-10-31")
  end

  def test_query_as_a_hash_string_keys
    query =
      {
        "reportRequests" => [{
          "viewId" => "000000",
          "dimensions" => [{ "name" => "ga:date" }],
          "dateRanges" => [{
            "startDate" => "2017-10-01",
            "endDate" => "2017-10-31"
          }],
          "metrics" => [{ "expression" => "ga:sessions" }],
          "includeEmptyRows" => true,
          "hideTotals" => false,
          "hideValueRanges" => true
        }]
      }
    GAAPI::Query.new(query, "000000", "test_token", "2017-10-01", "2017-10-31")
  end

  def test_query_as_a_hash_symbol_keys
    query =
      {
        reportRequests: [{
          viewId: "000000",
          dimensions: [{ name: "ga:date" }],
          dateRanges: [{
            startDate: "2017-10-01",
            endDate: "2017-10-31"
          }],
          metrics: [{ expression: "ga:sessions" }],
          includeEmptyRows: true,
          hideTotals: false,
          hideValueRanges: true
        }]
      }
    GAAPI::Query.new(query, "000000", "test_token", "2017-10-01", "2017-10-31")
  end

  def test_query_as_a_json
    query = JSON.parse(QUERY_STRING)
    # NOTE: JSON.parse returns a Hash.
    assert query.is_a?(Hash)
    GAAPI::Query.new(query, "000000", "test_token", "2017-10-01", "2017-10-31")
  end
end
