# frozen_string_literal: true

module GAAPI
  # A single report from a query to Google Analytics, with convenient methods
  # to access the dimensions and metrics returned.
  class Report
    # An array of the dimensions, in the order that they appear in the report.
    def dimensions
      report["columnHeader"]["dimensions"] || []
    end

    # @return [Boolean] True if dimensions were returned.
    def dimensions?
      !report["columnHeader"]["dimensions"].nil?
    end

    # An array of the dimensions first and then the metrics, in the order that
    # they appear in the report.
    def headers
      dimensions + metrics
    end

    # Initialize a new Report.
    # @param report [JSON source, Hash] If a Hash, assume it's a valid report
    #   from a Google Analytics query, and use it as the report.
    #   Otherwise, attempt to parse it with `JSON.parse`.
    #   No checking is done on the input to ensure that it's a valid response
    #   from a Google Analytics query, so subsequent calls to the methods on the
    #   object returned from `Report.new` may fail in spectacular ways.
    def initialize(report)
      @report = report.is_a?(Hash) ? report : JSON.parse(report)
    end
    # The report as a Ruby Hash, with String keys. It's typically much more
    # convenient to use the `#rows` method, and the methods on `Row` on each
    # instance of the a Row.
    attr_reader :report

    # Return if the data is golden, meaning it won't change if the query is re-run
    # at a later time. The is a lag between the end of a date period and when
    # Google Analytics has completely consolidated all the tracking data.
    def is_data_golden
      report["data"]["isDataGolden"]
    end

    # The metric type of the i'th metric in the report.
    def metric_type(i)
      report["columnHeader"]["metricHeader"]["metricHeaderEntries"][i]["type"]
    end

    # An array of the metric names, in the order that they appear in the report.
    def metrics
      report["columnHeader"]["metricHeader"]["metricHeaderEntries"].map { |metric| metric["name"] }
    end

    # Return the nextPageToken, if any, indicating that the query exceeded
    # the maximum number of rows allowed in a single response, and that the client
    # has to ask for the rest of the data.
    def next_page_token
      report["nextPageToken"]
    end

    # The data rows in the report.
    def rows
      report["data"]["rows"].map { |row| Row.new(self, row) }
    end

    # The totals in the report, if there were any.
    def totals
      Array.new(dimensions.size) + report["data"]["totals"][0]["values"]
    end

    # @return [Boolean] True if there totals were returned from the query.
    def totals?
      report["data"]["totals"]
    end
  end
end
