source "https://rubygems.org"

gemspec
group :development do
  gem "chefstyle", "= 1.2.0"
  gem "rake"
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.6")
    gem "chef-zero", "~> 14"
    gem "chef", ">= 12.9", "< 16"
  else
    gem "chef", ">= 12.9"
  end
  gem "rdoc"
  gem "guard"
  gem "guard-rspec"
  gem "guard-rake"
  gem "guard-rubocop"
  gem "chefspec"
  gem "berkshelf"
  gem "simplecov"
  gem "simplecov-console"
end

group :docs do
  gem "yard"
  gem "redcarpet"
  gem "github-markup"
end

group :debug do
  gem "pry"
  gem "pry-byebug"
end
