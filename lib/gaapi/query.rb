# frozen_string_literal: true

require "csv"
require "net/http"

module GAAPI
  class Query
    # Create a Query object.
    # @param access_token [String] A valid access token with which to make a request to
    #   the specified View ID.
    # @param credentials [String] File name of a credential file provided by
    #   Google Analytics. To obtain a credential file, follow the instructions
    #   at https://developers.google.com/identity/protocols/OAuth2ServiceAccount.
    # @param dry_run [Boolean] If true, do everything except send the query to
    #   Google Analytics.
    # @param end_date [String] The end date for the report.
    # @param query_file [IO] The query in JSON format.
    # @param start_date [String] The start date for the report.
    # @param view_id [String] The view ID of the property for which to submit the
    #   query.
    def initialize(query_string, options, access_token: nil)
      @access_token = access_token || options[:access_token]
      @dry_run = options[:dry_run]

      query_string = JSON.parse(query_string) unless query_string.is_a?(Hash)
      @query = {}
      @query["reportRequests"] = query_string["reportRequests"].map do |report_request|
        report_request["viewId"] = options[:view_id]
        report_request["dateRanges"] = [
          "startDate": options[:start_date],
          "endDate": options[:end_date]
        ]
        report_request
      end
      # puts "query: #{JSON.pretty_generate(query)}"
    end

    # Send the requested query to Google Analytics and return the response.
    # @return [HTTPResponse] The response from the request.
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

    attr_reader :access_token, :dry_run, :query
  end
end
