# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/*_test.rb"]
  # Other people's gems can cause Ruby warning messages.
  t.warning = false
end

# This automatically updates GitHub Releases whenever we `rake release` the gem
desc "Update Gethub release"
task "release:rubygem_push" do
  require "chandler/tasks"
  Rake.application.invoke_task("chandler:push")
end

desc "Run tests"
task default: :test
