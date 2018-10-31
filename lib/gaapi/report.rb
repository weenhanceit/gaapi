# frozen_string_literal: true

module GAAPI
  # A single report from a query to Google Analytics
  class Report
    # An array of the dimensions, in the order that they appear in the response.
    def dimensions
      report["columnHeader"]["dimensions"] || []
    end

    # @return [Boolean] True if dimensions were returned.
    def dimensions?
      !report["columnHeader"]["dimensions"].nil?
    end

    # An array of the dimensions first and then the metrics, in the order that
    # they appear in the response.
    def headers
      dimensions + metrics
    end

    def initialize(response, report)
      @response = response
      @report = report
    end
    attr_reader :report

    # An array of the metric names, in the order that they appear in the response.
    def metric_type(i)
      report["columnHeader"]["metricHeader"]["metricHeaderEntries"][i]["type"]
    end

    # An array of the metric names, in the order that they appear in the response.
    def metrics
      report["columnHeader"]["metricHeader"]["metricHeaderEntries"].map { |metric| metric["name"] }
    end

    # The data rows in the report.
    def rows
      report["data"]["rows"].map { |row| Row.new(self, row) }
    end

    # The totals, if there were any.
    def totals
      Array.new(dimensions.size) + report["data"]["totals"][0]["values"]
    end

    # @return [Boolean] True if there totals were returned from the query.
    def totals?
      report["data"]["totals"]
    end

    private

    attr_reader :response
  end
end
