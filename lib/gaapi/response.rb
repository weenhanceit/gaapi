# frozen_string_literal: true

module GAAPI
  # Holds the result of a Google Analytics query, and provides some methods to
  # present the result in useful ways.
  class Response
    attr_reader :response

    # Raw body of the response. Typically only used for diagnostic purposes.
    # @return [String] The unformatted body of the response.
    def body
      response.body
    end

    # Raw HTTP status code of the response. Typically only used for diagnostic purposes.
    # @return [String] The HTTP response code.
    def code
      response.code
    end

    # Convert a response from Google Analytics into a comma-separated values
    # format file.
    # @return [String] The result of the query formatted as a comma-separated
    #   values string.
    def csv
      @csv ||= CSV.generate do |csv|
        reports.each(&:report).each do |report|
          # If there are no dimensions, but totals, we need to put an extra
          # column at the start for the word "Total".
          # I don't see how totals will be different than the metrics if you
          # don't specify dimensions, but whatever.
          totals_column = report.totals? && !report.dimensions? ? [nil] : []
          csv << totals_column + report.headers
          report.rows.each { |row| csv << totals_column + row.to_a }
          csv << ["Totals"] + if report.totals? && !report.dimensions?
                                report.totals
                              else
                                report.totals[1..-1]
                              end
        end
      end
    end

    def initialize(response)
      @response = response
    end

    # Return the JSON result in a readable format.
    # @return [String] The JSON result formatted in a human-readable way.
    def pp
      @pp ||= JSON.pretty_generate(to_json)
    end

    # The array of reports returned by the query.
    # @return [Array] An array of reports.
    def reports
      @reports ||= if success?
                     to_json["reports"].map do |report|
                       Report.new(self, report)
                     end
                   else
                     []
                   end
    end

    # Return true if the request was successful.
    # @return [Boolean] True if the request was successful (response code 200).
    def success?
      code == "200"
    end

    # Return the body of the response
    # @return [String] JSON-formatted response in a String.
    def to_json
      @to_json ||= JSON.parse(to_s)
    end

    # Return the body of the response
    # @return [String] JSON-formatted response in a String.
    def to_s
      response.body
    end
  end
end
