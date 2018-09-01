# frozen_string_literal: true

require "optparse"

module Main
  class << self
    def call
      options = process_options

      puts "options: #{options.inspect}" if options[:debug]

      # return unless (result = Query.call(options))
      query = Query.new((options[:query_file] || STDIN).read, options)

      return if options[:dry_run]

      result = query.execute

      if result.code != "200"
        puts "Request failed #{result.code}"
        puts Query.pp(result.body)
        return
      end

      case options[:output_format]
      when :csv
        puts Query.csv(result.body)
      else
        puts Query.pp(result.body)
      end
    end

    def process_options
      options = { credentials: File.join(Dir.home, ".gaapi/ga-api-key") }
      opts = OptionParser.new do |opts|
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
          "Location of the credentials file. Default: `#{options[:credentials]}`.") do |credentials|
            options[:credentials] = credentials
          end

        opts.on("-d", "--debug", "Print debugging information.") do
          options[:debug] = true
        end

        opts.on("-e",
          "--end-date END_DATE",
          Date,
          "Report including END_DATE.") do |end_date|
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
          "Report including START_DATE.") do |start_date|
          options[:start_date] = start_date
        end
      end
      opts.parse!
      opts.abort("You must provide a view ID. \n" + opts.to_s) unless ARGV.size == 1
      options[:view_id] = ARGV[0]

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

# Some hints:
# https://stackoverflow.com/a/41179467/3109926
# http://www.daimto.com/google-service-accounts-with-json-file/
# https://github.com/google/google-api-ruby-client/issues/489
# The above gave some progress.
