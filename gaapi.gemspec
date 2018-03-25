# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "gaapi"
  s.version     = "0.0.1alpha1"
  s.date        = "2018-03-23"
  s.summary     = "Query Google Analytics from the command line."
  s.description = <<-DESCRIPTION
    Submit queries expressed in JSON to Google Analytics. Can be run
    from unattended scripts, batch jobs, etc.
  DESCRIPTION
  s.add_development_dependency "minitest", "~> 5.11"
  s.add_runtime_dependency "google-api-client", "~> 0.19"
  s.authors     = ["Larry Reid", "Phil Carrillo"]
  s.email       = "larry.reid@weenhanceit.com"
  s.executables << "gaapi"
  s.files = [
    "bin/gaapi",
    "lib/gaapi.rb",
    "lib/gaapi/main.rb",
    "lib/gaapi/query.rb"
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
