require "bundler/gem_tasks"
require "chef-vault/test_fixtures"

# Style Tests
begin
  require "chefstyle"
  require "rubocop/rake_task"
  RuboCop::RakeTask.new do |t|
    t.formatters = ["progress"]
    t.options = ["-D"]
    t.patterns = %w{
      bin/*
      lib/**/*.rb
      spec/**/*.rb
      ./Rakefile
    }
  end
  desc "Run Style Tests"
  task style: [:rubocop]
rescue LoadError
  puts "rubocop not available; disabling tasks"
end

# Unit Tests
begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new

  # Coverage
  desc "Generate unit test coverage report"
  task :coverage do
    ENV["COVERAGE"] = "true"
    Rake::Task[:test].invoke
  end

  # test is an alias for spec
  desc "runs unit tests"
  task test: :spec

  # default is to test everything
  desc "runs all tests"
  task default: :test
rescue LoadError
  puts "rspec not available; disabling tasks"
end

# Documentation
begin
  require "yard"
  require "yard/rake/yardoc_task"
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.stats_options = ["--list-undoc"]
  end
rescue LoadError
  puts "yard not available; disabling tasks"
end
