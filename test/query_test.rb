# frozen_string_literal: true

# Run tests like this: ruby -Itest:lib test/query_test.rb [--seed 12345]
require "test_helper"

class QueryTest < Test
  EXPECTED_REQUEST_BODY = <<~QUERY
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
        "hideValueRanges": true,
        "pageSize": 10000
      }]
    }
  QUERY
                          .gsub(/\s+/, "")

  # Need this because gaapi doesn't put whitespace in query.
  QUERY_STRING = EXPECTED_REQUEST_BODY.gsub(/("pageSize":\s*100000)/, "")

  def setup
    stub_request(:post, GA_REQUEST_URI)
      .with(body: EXPECTED_REQUEST_BODY, headers: {
              "Authorization": "Bearer test_token"
            })
      .to_return(status: 200)
  end

  def test_query_as_a_string
    # stub_token_request
    GAAPI::Query.new(QUERY_STRING, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    assert_requested(:post, GA_REQUEST_URI, body: EXPECTED_REQUEST_BODY)
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
    GAAPI::Query.new(query, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    assert_requested(:post, GA_REQUEST_URI, body: EXPECTED_REQUEST_BODY)
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
    GAAPI::Query.new(query, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    assert_requested(:post, GA_REQUEST_URI, body: EXPECTED_REQUEST_BODY)
  end

  def test_query_as_a_json
    query = JSON.parse(QUERY_STRING)
    # NOTE: JSON.parse returns a Hash.
    assert query.is_a?(Hash)
    GAAPI::Query.new(query, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    assert_requested(:post, GA_REQUEST_URI, body: EXPECTED_REQUEST_BODY)
  end

  def test_query_with_page_size
    query = JSON.parse(QUERY_STRING)
    query["reportRequests"][0]["pageSize"] = 9_999

    stub_request(:post, GA_REQUEST_URI)
      .with(body: query, headers: {
              "Authorization": "Bearer test_token"
            })
      .to_return(status: 200)

    GAAPI::Query.new(query, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    assert_requested(:post, GA_REQUEST_URI, body: query)
  end
end
