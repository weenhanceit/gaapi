# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "gaapi"
  s.version     = "0.0.0alpha1"
  s.date        = "2018-03-23"
  s.summary     = "Query Google Analytics from the command line."
  s.description = <<-EOF
    Submit queries expressed in JSON to Google Analytics. Can be run
    from unattended scripts, batch jobs, etc.
  EOF
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
end
