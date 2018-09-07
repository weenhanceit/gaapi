# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "gaapi/version"

Gem::Specification.new do |s|
  s.name        = "gaapi"
  s.version     = GAAPI::VERSION
  s.date        = "2018-09-06"
  s.summary     = "Query Google Analytics from the command line."
  s.description = <<-DESCRIPTION
    Submit queries expressed in JSON to Google Analytics. Can be run
    from unattended scripts, batch jobs, etc.
  DESCRIPTION
  s.add_development_dependency "chandler"
  s.add_development_dependency "minitest"
  s.add_development_dependency "webmock"
  s.add_runtime_dependency "google-api-client", "~> 0.19"
  s.add_runtime_dependency "googleauth"
  s.authors     = ["Larry Reid", "Phil Carrillo"]
  s.email       = "larry.reid@weenhanceit.com"
  s.executables << "gaapi"
  s.files = [
    "bin/gaapi",
    "lib/gaapi.rb",
    "lib/gaapi/access_token.rb",
    "lib/gaapi/main.rb",
    "lib/gaapi/query.rb",
    "lib/gaapi/response.rb",
    "lib/gaapi/version.rb"
  ]
  s.homepage =
    "https://github.com/weenhanceit/gaapi"
  s.license = "MIT"
  s.metadata = {
    # "bug_tracker_uri"   => "https://example.com/user/bestgemever/issues",
    # "changelog_uri"     => "https://example.com/user/bestgemever/CHANGELOG.md",
    # "documentation_uri" => "https://www.example.info/gems/bestgemever/0.0.1",
    # "homepage_uri"      => "https://bestgemever.example.io",
    # "mailing_list_uri"  => "https://groups.example.com/bestgemever",
    "source_code_uri" => "https://github.com/weenhanceit/gaapi"
    # "wiki_uri"          => "https://example.com/user/bestgemever/wiki"
  }
end
