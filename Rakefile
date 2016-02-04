require "chef-vault/test_fixtures"

begin
  require "hoe"
  require "hoe/markdown"
  Hoe.plugin :gemspec
  Hoe.plugin :markdown
  Hoe.plugins.delete :test
  Hoe.spec "chef-vault-testfixtures" do |s|
    s.version = ChefVault::TestFixtures::VERSION
    developer "James FitzGibbon", "james.i.fitzgibbon@nordstrom.com"
    license "apache2"
    extra_deps << ["rspec", "~> 3.1"]
    extra_deps << ["chef-vault", "~> 2.5"]
    extra_deps << ["hashie", ">= 2.0", "< 4.0"]
    extra_dev_deps << ["chef", "~> 12.0"]
    extra_dev_deps << ["hoe", "~> 3.13"]
    extra_dev_deps << ["hoe-gemspec", "~> 1.0"]
    extra_dev_deps << ["rake", "~> 10.3"]
    extra_dev_deps << ["rspec", "~> 3.1"]
    extra_dev_deps << ["guard", "~> 2.12"]
    extra_dev_deps << ["guard-rspec", "~> 4.2"]
    extra_dev_deps << ["guard-rake", "~> 0.0"]
    extra_dev_deps << ["guard-rubocop", "~> 1.2"]
    extra_dev_deps << ["chefspec", "~> 4.2"]
    extra_dev_deps << ["berkshelf", "~> 4.0"]
    extra_dev_deps << ["simplecov", "~> 0.9"]
    extra_dev_deps << ["simplecov-console", "~> 0.2"]
    extra_dev_deps << ["yard", "~> 0.8"]
  end
  # re-generate our gemspec before packaging
  task package: "gem:spec"
rescue LoadError
  puts "hoe not available; disabling tasks"
end

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
