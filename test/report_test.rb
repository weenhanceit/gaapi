# frozen_string_literal: true

require "test_helper"

class ReportTest < Test
  RESPONSE_WITH_TOTALS = {
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

  def test_report_as_json
    report = GAAPI::Report.new(RESPONSE_WITH_TOTALS) # GAAPI::Query.new(REQUEST_FOR_TOTALS, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    assert_equal RESPONSE_WITH_TOTALS, report.report
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

  def test_report_as_string
    report = GAAPI::Report.new(RESPONSE_WITH_TOTALS.to_json) # GAAPI::Query.new(REQUEST_FOR_TOTALS, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    assert_equal RESPONSE_WITH_TOTALS, report.report
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
end
