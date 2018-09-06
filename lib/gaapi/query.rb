# frozen_string_literal: true

require "csv"
require "net/http"

module GAAPI
  class Query
    class << self
      def call(options)
        # http://www.rubydoc.info/github/google/google-api-ruby-client/toplevel
        # https://github.com/google/google-auth-library-ruby
        scopes = %w[
          https://www.googleapis.com/auth/analytics
          https://www.googleapis.com/auth/analytics.readonly
        ]

        authorization = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File
                        .open(options[:credentials] || File.join(Dir.home,
                          ".ga-credentials/ga-api-key")),
          scope: scopes
        )

        service = Google::Apis::AnalyticsreportingV4::AnalyticsReportingService.new
        service.authorization = authorization

        request = Google::Apis::AnalyticsreportingV4::ReportRequest.new(
          view_id: options[:view_id],
          date_ranges: [Google::Apis::AnalyticsreportingV4::DateRange.new(
            start_date: options[:start_date],
            end_date: options[:end_date]
          )],
          # dimensions: [
          #   Google::Apis::AnalyticsreportingV4::Dimension.new(name: "ga:segment")
          #   # Google::Apis::AnalyticsreportingV4::Dimension.new(name: "ga:adContent"),
          #   # Google::Apis::AnalyticsreportingV4::Dimension.new(name: "ga:campaign"),
          #   # Google::Apis::AnalyticsreportingV4::Dimension.new(name: "ga:keyword"),
          #   # Google::Apis::AnalyticsreportingV4::Dimension.new(name: "ga:medium"),
          #   # Google::Apis::AnalyticsreportingV4::Dimension.new(name: "ga:socialNetwork"),
          #   # Google::Apis::AnalyticsreportingV4::Dimension.new(name: "ga:source")
          # ],
          metrics: [
            # Google::Apis::AnalyticsreportingV4::Metric.new(
            #   expression: "ga:bounces"
            # ),
            Google::Apis::AnalyticsreportingV4::Metric.new(
              expression: "ga:newUsers"
            ),
            Google::Apis::AnalyticsreportingV4::Metric.new(
              expression: "ga:pageviewsPerSession"
            ),
            Google::Apis::AnalyticsreportingV4::Metric.new(
              expression: "ga:sessions"
            ),
            Google::Apis::AnalyticsreportingV4::Metric.new(
              expression: "ga:sessionDuration"
            ),
            # Google::Apis::AnalyticsreportingV4::Metric.new(
            #   expression: "ga:organicSearches"
            # ),
            Google::Apis::AnalyticsreportingV4::Metric.new(
              expression: "ga:users"
            )
          ],
          metric_filter_clauses: [
            Google::Apis::AnalyticsreportingV4::MetricFilterClause.new(
              filters: [
                Google::Apis::AnalyticsreportingV4::MetricFilter.new(
                  metric_name: "ga:pageviews",
                  comparison_value: "0",
                  operator: "GREATER_THAN"
                )
              ]
            )
          ],
          include_empty_rows: true
        )

        # puts "request.to_json: #{JSON.pretty_generate(JSON.parse(request.to_json))}" if options[:debug]
        get_reports_requests = Google::Apis::AnalyticsreportingV4::GetReportsRequest.new(report_requests: [request])
        # puts get_reports_requests.to_json if options[:debug]
        puts JSON.pretty_generate(JSON.parse(get_reports_requests.to_json)) if options[:debug]
        return nil if options[:dry_run]

        result = service.batch_get_reports(get_reports_requests)
        puts "result: #{result.inspect}" if options[:debug]
        result
      end

      # Convert a response from Google Analytics into a comma-separated values
      # format file.
      def csv(result)
        result = result.to_json if result.is_a?(Google::Apis::AnalyticsreportingV4::GetReportsResponse)
        result = JSON.parse(result) if result.is_a?(String)
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

      def csv_data_row(row_headers, metrics)
        (Array(row_headers) || []) + metrics[0]["values"]
      end

      def csv_header_row(report)
        (report["columnHeader"]["dimensions"] || []) + report["columnHeader"]["metricHeader"]["metricHeaderEntries"].map do |entry|
          entry["name"]
        end
      end

      # Return the JSON result in a readable format.
      # @param result [String] A string containing the JSON result from a query.
      # @return [String] The JSON result formatted in a human-readable way.
      def pp(result)
        JSON.pretty_generate(JSON.parse(result))
      end
    end

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
    def initialize(query_string, options)
      # puts "query_string: #{query_string}"
      # puts "Initializing query. Options: #{options.inspect}" if options[:debug]

      # puts "options[:access_token]: #{options[:access_token]}"
      @access_token = options[:access_token]
      # puts "options[:credentials]: #{options[:credentials]}"
      @access_token ||= access_token_from_credentials(options[:credentials])
      # puts "Final access_token: #{access_token}"
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
      response = https.request(request)
      response
    end

    private

    attr_reader :access_token, :dry_run, :query

    def access_token_from_credentials(credential_file_name)
      stat = File::Stat.new(credential_file_name)
      raise "#{credential_file_name} must be readable and writable only by you." if stat.world_readable? || stat.world_writable?
      authorization = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(credential_file_name),
        scope: "https://www.googleapis.com/auth/analytics.readonly"
      )

      # puts "authorization: #{authorization.inspect}" # if options[:debug]
      token = authorization.fetch_access_token!
      # puts "token: #{token.inspect}" # if options[:debug]
      token["access_token"]
    end
  end
end
