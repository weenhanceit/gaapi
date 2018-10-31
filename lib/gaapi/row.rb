# frozen_string_literal: true

module GAAPI
  # A single row from a query to Google Analytics
  class Row
    # An array of the dimension values, in the order that they appear in the
    # dimension headers.
    def dimensions
      row["dimensions"]
    end

    def initialize(response, row)
      @response = response
      @row = row
    end

    # An array of the metric values, in the order that they appear in the
    # metric headers.
    def metrics
      # FIXME: Why is there a 0 here?
      row["metrics"][0]["values"]
    end

    # Return the data from the row as an Array, ordered by:
    #   Headers first, in the order that they appear in the Report#headers array.
    #   Metrics next, in the order that they appear in the Rport#metrics array.
    def to_a
      (dimensions || []) + metrics
    end

    private

    attr_reader :response, :row
  end
end
