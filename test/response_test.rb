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

  RESPONSE_WITHOUT_TOTALS = {
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
    report = result.reports[0]
    assert_equal RESPONSE_WITH_TOTALS["reports"][0], report.report
    assert_equal %w[ga:nthWeek ga:medium ga:source] + %w[ga:sessions ga:sessionDuration ga:users],
      report.headers
    assert_equal %w[0001 (none) (direct)] + %w[408 2 369], report.rows[0].to_a
    assert_equal %w[0001 cpc google] + %w[515 1 464], report.rows[1].to_a
    assert_equal [nil, nil, nil] + %w[923 3 833], report.totals
    assert_equal "0001", report.rows[0].nth_week
    assert_equal "0001", report.rows[1].nth_week
    assert_equal "(none)", report.rows[0].medium
    assert_equal "(direct)", report.rows[0].source
    assert_equal 408, report.rows[0].sessions
    assert_equal 2, report.rows[0].session_duration
    assert_equal 369, report.rows[0].users
  end

  # Issue #9.
  def test_empty_report
    empty_response = {
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
          "isDataGolden" => false
        }
      }]
    }.freeze

    stub_request(:post, GA_REQUEST_URI)
      .with(headers: {
              "Authorization": "Bearer test_token"
            })
      .to_return(body: empty_response.to_json, status: 200)

    result = GAAPI::Query.new(REQUEST_FOR_TOTALS, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    # TODO: This might be bad.
    REQUEST_FOR_TOTALS["reportRequests"][0]["pageSize"] = 10_000
    assert_requested(:post, GA_REQUEST_URI, body: REQUEST_FOR_TOTALS)
    assert_equal empty_response.to_json, result.body
    report = result.reports[0]
    assert_equal empty_response["reports"][0], report.report
    assert_equal %w[ga:nthWeek ga:medium ga:source] + %w[ga:sessions ga:sessionDuration ga:users],
      report.headers
    assert_equal 0, report.rows.size
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

  def test_csv_without_totals
    expected_csv = <<~CSV
      ga:nthWeek,ga:medium,ga:source,ga:sessions,ga:sessionDuration,ga:users
      0001,(none),(direct),408,2,369
      0001,cpc,google,515,1,464
    CSV

    stub_request(:post, GA_REQUEST_URI)
      .with(headers: {
              "Authorization": "Bearer test_token"
            })
      .to_return(body: RESPONSE_WITHOUT_TOTALS.to_json, status: 200)
    result = GAAPI::Query.new(REQUEST_FOR_TOTALS, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    assert_equal expected_csv, result.csv
  end

  def test_all_metric_types
    request = <<~REQUEST
      {
        "reportRequests":
        [
          {
            "viewId": "XXXX",
            "dateRanges": [{"startDate": "2014-11-01", "endDate": "2014-11-30"}],
            "metrics": [{"expression": "ga:users"},
              {"expression": "ga:sessionDuration"},
              {"expression": "ga:bounceRate"},
              {"expression": "ga:goalValueAll"},
              {"expression": "ga:pageViewsPerSession"}
            ]
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
              },
              {
                "name": "ga:sessionDuration",
                "type": "TIME"
              },
              {
                "name": "ga:bounceRate",
                "type": "PERCENT"
              },
              {
                "name": "ga:goalValueAll",
                "type": "CURRENCY"
              },
              {
                "name": "ga:pageViewsPerSession",
                "type": "FLOAT"
              }
            ]
          }
        },
        "data": {
          "rows": [{
            "metrics": [{
              "values": [
                "44",
                "35740.0",
                "43.63636363636363",
                "0.0",
                "5.454545454545454"
              ]
            }]
          }],
          "totals": [{
            "values": [
              "44",
              "35740.0",
              "43.63636363636363",
              "0.0",
              "5.454545454545454"
            ]
          }],
          "rowCount": 1,
          "minimums": [{
            "values": [
              "44",
              "35740.0",
              "43.63636363636363",
              "0.0",
              "5.454545454545454"
            ]
          }],
          "maximums": [{
            "values": [
              "44",
              "35740.0",
              "43.63636363636363",
              "0.0",
              "5.454545454545454"
            ]
          }],
          "isDataGolden": true
        }
      }]
    }
    RESPONSE

    stub_request(:post, GA_REQUEST_URI)
      .with(headers: {
              "Authorization": "Bearer test_token"
            })
      .to_return(body: response, status: 200)
    result = GAAPI::Query.new(request, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    assert_equal 44, result.reports.first.rows.first.users
    assert_equal 35_740.0, result.reports.first.rows.first.session_duration
    assert_equal 43.63636363636363, result.reports.first.rows.first.bounce_rate
    assert_equal 0.0, result.reports.first.rows.first.goal_value_all
    assert_equal 5.454545454545454, result.reports.first.rows.first.page_views_per_session
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
