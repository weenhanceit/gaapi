# frozen_string_literal: true

module GAAPI
  # A single report from a query to Google Analytics
  class Report
    def dimensions
      report["columnHeader"]["dimensions"]
    end

    def headers
      (dimensions || []) + metrics
    end

    def initialize(response, report)
      @response = response
      @report = report
    end
    attr_reader :report

    def metrics
      report["columnHeader"]["metricHeader"]["metricHeaderEntries"].map { |metric| metric["name"] }
    end
  end
end
