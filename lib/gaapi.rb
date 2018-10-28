# frozen_string_literal: true

# http://www.rubydoc.info/github/google/google-api-ruby-client/
require "google/apis/analyticsreporting_v4"
require "googleauth"
# require "gaapi/access_token.rb"
# require "gaapi/main.rb"
# require "gaapi/query.rb"
# require "gaapi/response.rb"
Dir.glob("lib/gaapi/**/*.rb").each { |f| require Pathname.new(f).relative_path_from(Pathname.new("lib")) }
