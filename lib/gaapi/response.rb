# frozen_string_literal: true

module GAAPI
  # Holds the result of a Google Analytics query, and provides some methods to
  # present the result in useful ways.
  class Response
    attr_reader :response

    # Raw body of the response, possibly only for transition purposes.
    def body
      response.body
    end

    # Raw code of the response, possibly only for transition purposes.
    def code
      response.code
    end

    # Convert a response from Google Analytics into a comma-separated values
    # format file.
    # @return [String] The result of the query formatted as a comma-separated
    #   values string.
    def csv
      result = JSON.parse(to_s)
      CSV.generate do |csv|
        result["reports"].each do |report|
          # puts report.column_header.dimensions.inspect
          # puts report.column_header.metric_header.metric_header_entries.map(&:name).inspect
          csv << csv_header_row(report)
          report["data"]["rows"].each do |row|
            csv << csv_data_row(row["dimensions"], row["metrics"])
          end
          csv << csv_data_row("Totals", report["data"]["totals"]) if report["data"]["totals"]
        end
      end
    end

    def initialize(response)
      @response = response
    end

    # Return the JSON result in a readable format.
    # @return [String] The JSON result formatted in a human-readable way.
    def pp
      JSON.pretty_generate(JSON.parse(to_s))
    end

    def status
      code
    end

    def success?
      code == "200"
    end

    def to_s
      response.body
    end

    private

    def csv_data_row(row_headers, metrics)
      (Array(row_headers) || []) + metrics[0]["values"]
    end

    def csv_header_row(report)
      (report["columnHeader"]["dimensions"] || []) + report["columnHeader"]["metricHeader"]["metricHeaderEntries"].map do |entry|
        entry["name"]
      end
    end
  end
end
