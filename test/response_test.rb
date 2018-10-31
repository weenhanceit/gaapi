# frozen_string_literal: true

require "test_helper"

class ResponseTest < Test
  RESPONSE_WITH_TOTALS = {
    "reports" => [{
      "columnHeader" => {
        "dimensions" => %w[ga:nthWeek ga:medium ga:source],
        "metricHeader" => {
          "metricHeaderEntries" => [
            { "name" => "ga:sessions", "type" => "INTEGER" },
            { "name" => "ga:sessionDuration", "type" => "INTEGER" },
            { "name" => "ga:users", "type" => "INTEGER" }
          ]
        }
      },
      "data" => {
        "rows" => [
          {
            "dimensions" => %w[0001 (none) (direct)],
            "metrics" => [{ "values" => %w[408 2 369] }]
          },
          {
            "dimensions" => %w[0001 cpc google],
            "metrics" => [{ "values" => %w[515 1 464] }]
          }
        ],
        "totals" => [{ "values" => %w[923 3 833] }],
        "rowCount" => 2,
        "isDataGolden" => false
      }
    }]
  }.freeze

  REQUEST_FOR_TOTALS = {
    "reportRequests" => [{
      "viewId" => "000000",
      "dimensions" => [{ "name" => "ga:nthWeek" }, { "name" => "ga:medium" }, { "name" => "ga:source" }],
      "dateRanges" => [{
        "startDate" => "2017-10-01",
        "endDate" => "2017-10-31"
      }],
      "metrics" => [
        { "expression" => "ga:sessions" },
        { "expression" => "ga:sessionDuration" },
        { "expression" => "ga:users" }
      ],
      "includeEmptyRows" => true,
      "hideTotals" => false,
      "hideValueRanges" => true
    }]
  }.freeze

  def test_single_report
    stub_request(:post, GA_REQUEST_URI)
      .with(headers: {
              "Authorization": "Bearer test_token"
            })
      .to_return(body: RESPONSE_WITH_TOTALS.to_json, status: 200)

    result = GAAPI::Query.new(REQUEST_FOR_TOTALS, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    # TODO: This might be bad.
    REQUEST_FOR_TOTALS["reportRequests"][0]["pageSize"] = 10_000
    assert_requested(:post, GA_REQUEST_URI, body: REQUEST_FOR_TOTALS)
    assert_equal RESPONSE_WITH_TOTALS.to_json, result.body
    assert_equal RESPONSE_WITH_TOTALS["reports"][0], result.reports[0].report
    assert_equal %w[ga:nthWeek ga:medium ga:source] + %w[ga:sessions ga:sessionDuration ga:users],
      result.reports[0].headers
    assert_equal %w[0001 (none) (direct)] + %w[408 2 369], result.reports[0].rows[0].to_a
    assert_equal %w[0001 cpc google] + %w[515 1 464], result.reports[0].rows[1].to_a
    assert_equal [nil, nil, nil] + %w[923 3 833], result.reports[0].totals
  end

  def test_csv_with_totals
    expected_csv = <<~CSV
      ga:nthWeek,ga:medium,ga:source,ga:sessions,ga:sessionDuration,ga:users
      0001,(none),(direct),408,2,369
      0001,cpc,google,515,1,464
      Totals,,,923,3,833
    CSV

    stub_request(:post, GA_REQUEST_URI)
      .with(headers: {
              "Authorization": "Bearer test_token"
            })
      .to_return(body: RESPONSE_WITH_TOTALS.to_json, status: 200)
    result = GAAPI::Query.new(REQUEST_FOR_TOTALS, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    assert_equal expected_csv, result.csv
  end

  def test_csv_with_totals_no_dimensions
    request = <<~REQUEST
      {
        "reportRequests":
        [
          {
            "viewId": "XXXX",
            "dateRanges": [{"startDate": "2014-11-01", "endDate": "2014-11-30"}],
            "metrics": [{"expression": "ga:users"}]
          }
        ]
      }
    REQUEST

    response = <<~RESPONSE
      {
        "reports": [{
          "columnHeader": {
            "metricHeader": {
              "metricHeaderEntries": [{
                "name": "ga:users",
                "type": "INTEGER"
              }]
            }
          },
          "data": {
            "rows": [{
              "metrics": [{
                "values": [
                  "44"
                ]
              }]
            }],
            "totals": [{
              "values": [
                "44"
              ]
            }],
            "rowCount": 1,
            "isDataGolden": true
          }
        }]
      }
    RESPONSE

    expected_csv = <<~CSV
      ,ga:users
      ,44
      Totals,44
    CSV

    stub_request(:post, GA_REQUEST_URI)
      .with(headers: {
              "Authorization": "Bearer test_token"
            })
      .to_return(body: response, status: 200)
    result = GAAPI::Query.new(request, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    assert_equal expected_csv, result.csv
  end
end
