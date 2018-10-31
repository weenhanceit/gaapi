# frozen_string_literal: true

require "test_helper"

class ResponseTest < Test
  def test_single_report
    response = {
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
    }

    request = {
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
    }

    stub_request(:post, GA_REQUEST_URI)
      .with(headers: {
              "Authorization": "Bearer test_token"
            })
      .to_return(body: response.to_json, status: 200)

    result = GAAPI::Query.new(request, "000000", "test_token", "2017-10-01", "2017-10-31").execute
    request["reportRequests"][0]["pageSize"] = 10_000
    assert_requested(:post, GA_REQUEST_URI, body: request)
    assert_equal response.to_json, result.body
    assert_equal response["reports"][0], result.reports[0].report
  end
end
# {
#   "reports": [{
#     "columnHeader": {
#       "dimensions": [ "ga:nthWeek", "ga:medium", "ga:source", "ga:adDistributionNetwork", "ga:hasSocialSourceReferral", "ga:channelGrouping" ],
#       "metricHeader": {
#         "metricHeaderEntries": [
#           { "name": "ga:avgSessionDuration", "type": "TIME" },
#           { "name": "ga:newUsers", "type": "INTEGER" },
#           { "name": "ga:pageviews", "type": "INTEGER" },
#           { "name": "ga:pageviewsPerSession", "type": "FLOAT" },
#           { "name": "ga:sessions", "type": "INTEGER" },
#           { "name": "ga:sessionDuration", "type": "INTEGER" },
#           { "name": "ga:users", "type": "INTEGER" }
#         ]
#       }
#     },
#     "data": {
#       "rows": [{
#           "dimensions": [ "0001", "(none)", "(direct)", "(not set)", "No" ],
#           "metrics": [{
#             "values": [ "195.45098039215685", "271", "2", "2.627450980392157", "408", "2", "369" ]
#           }]
#         },
#         {
#           "dimensions": [ "0001", "cpc", "google", "(not set)", "No" ],
#           "metrics": [{
#             "values": [ "145.90873786407766", "371", "3", "2.4446601941747574", "515", "1", "464" ]
#           }]
#         }
#       ],
#       "rowCount": 2,
#       "isDataGolden": false
#     }
#   }]
# }
