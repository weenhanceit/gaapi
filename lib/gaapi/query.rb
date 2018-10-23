# frozen_string_literal: true

require "csv"
require "net/http"

module GAAPI
  class Query
    # Create a Query object.
    # @param access_token [String] A valid access token with which to make a request to
    #   the specified View ID.
    # @param end_date [Date, String] The end date for the report.
    # @param query_string [String, Hash, JSON] The query in JSON format.
    # @param start_date [Date, String] The start date for the report.
    # @param view_id [String] The view ID of the property for which to submit the
    #   query.
    def initialize(query_string, view_id, access_token, start_date, end_date)
      @access_token = access_token.to_s
      query_string = JSON.parse(query_string) unless query_string.is_a?(Hash)
      @query = stringify_keys(query_string)
      @query["reportRequests"] = @query["reportRequests"].map do |report_request|
        report_request["viewId"] = view_id
        report_request["dateRanges"] = [
          "startDate": start_date.to_s,
          "endDate": end_date.to_s
        ]
        report_request["pageSize"] ||= 10_000
        report_request
      end
      # puts "query: #{JSON.pretty_generate(query)}"
    end

    # Send the requested query to Google Analytics and return the response.
    # @return [GAAPI::Response] The response from the request.
    def execute
      uri = URI.parse("https://analyticsreporting.googleapis.com/v4/reports:batchGet")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      # https.set_debug_output($stdout)
      request = Net::HTTP::Post.new(uri.request_uri,
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{access_token}")
      request.body = query.to_json
      Response.new(https.request(request))
    end

    private

    attr_reader :access_token, :query

    # The keys have to be strings to get converted to a GA query.
    # Adapted from Rails.
    def stringify_keys(object)
      case object
      when Hash
        object.each_with_object({}) do |(key, value), result|
          result[key.to_s] = stringify_keys(value)
        end
      when Array
        object.map { |e| stringify_keys(e) }
      else
        object
      end
    end
  end
end
