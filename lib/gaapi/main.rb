# frozen_string_literal: true

require "optparse"

module GAAPI
  module Main
    class << self
      def call
        begin
          return false if (options = process_options).nil?

          puts "options: #{options.inspect}" if options[:debug]

          # return unless (result = Query.call(options))
          query = Query.new((options[:query_file] || $stdin).read,
            options[:view_id],
            options[:access_token],
            options[:start_date],
            options[:end_date])
          puts "query: #{query.inspect}" if options[:debug]
        rescue StandardError => e
          $stderr.puts e.message # rubocop:disable Style/StderrPuts
          return false
        end

        return true if options[:dry_run]

        result = query.execute
        puts "result: #{result.inspect}" if options[:debug]

        unless result.success?
          # Show the output unformatted, because we don't know what we're going
          # to get back.
          puts result.body
          return false
        end

        case options[:output_format]
        when :csv
          puts result.csv
        else
          puts result.pp
        end

        true
      end

      def process_options
        options = {}
        credential_file = File.join(Dir.home, ".gaapi/ga-api-key")
        parsed_options = OptionParser.new do |opts|
          opts.banner = "Usage: [options] VIEW_ID"
          opts.accept(Date)

          opts.on("-a TOKEN",
            "--access-token TOKEN",
            "An access token obtained from https://developers.google.com/oauthplayground.") do |access_token|
            options[:access_token] = access_token
          end

          opts.on("--csv",
            "Output result as a csv file.") do
            options[:output_format] = :csv
          end

          opts.on("-c CREDENTIALS",
            "--credentials CREDENTIALS",
            "Location of the credentials file. Default: `#{credential_file}`.") do |credentials|
              credential_file = credentials
            end

          opts.on("-d", "--debug", "Print debugging information.") do
            options[:debug] = true
          end

          opts.on("-e",
            "--end-date END_DATE",
            Date,
            "Report including END_DATE (yyyy-mm-dd).") do |end_date|
            options[:end_date] = end_date
          end

          opts.on("-n", "--dry-run", "Don't actually send the query to Google.") do
            options[:dry_run] = true
          end

          opts.on("-q QUERYFILE",
            "--query-file QUERYFILE",
            "File containing the query. Default STDIN.") do |query_file|
              options[:query_file] = File.open(query_file)
            end

          opts.on("-s",
            "--start-date START_DATE",
            Date,
            "Report including START_DATE (yyyy-mm-dd).") do |start_date|
            options[:start_date] = start_date
          end
        end
        parsed_options.parse!
        unless ARGV.size == 1
          $stderr.puts("gaapi: You must provide a view ID.\n" + parsed_options.to_s) # rubocop:disable Style/StderrPuts
          return nil
        end
        options[:view_id] = ARGV[0]

        options[:access_token] ||= GAAPI::AccessToken.new(credential_file)

        if options[:end_date].nil? && !options[:start_date].nil?
          options[:end_date] = options[:start_date]
        elsif options[:start_date].nil? && !options[:end_date].nil?
          options[:start_date] = options[:end_date]
        elsif options[:start_date].nil? && options[:end_date].nil?
          options[:end_date] = options[:start_date] = (Date.today - 1).to_s
        end

        options
      end
    end
  end
end
# Some hints:
# https://stackoverflow.com/a/41179467/3109926
# http://www.daimto.com/google-service-accounts-with-json-file/
# https://github.com/google/google-api-ruby-client/issues/489
# The above gave some progress.
