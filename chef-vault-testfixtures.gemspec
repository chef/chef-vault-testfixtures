# -*- encoding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + "/lib")
require "chef-vault/test_fixtures_version"

Gem::Specification.new do |s|
  s.name                      = "chef-vault-testfixtures"
  s.version                   = ChefVault::TestFixtures::VERSION

  s.require_paths             = ["lib"]
  s.authors                   = ["Thom May"]
  s.email                     = ["thom@chef.io"]
  s.extra_rdoc_files          = ["History.md", "README.md"]
  s.homepage                  = "https://github.com/chef/chef-vault-testfixtures"
  s.files                     = `git ls-files`.split("\n")
  s.licenses                  = ["apache2"]
  s.rdoc_options              = ["--main", "README.md"]
  s.summary                   = "chef-vault-testfixtures provides an RSpec shared context that stubs access to chef-vault encrypted data bags using the same fallback mechanism as the `chef_vault_item` helper from the [chef-vault cookbook](https://supermarket.chef.io/cookbooks/chef-vault)"
  s.description               = s.summary
  s.required_ruby_version     = ">= 2.2.0"

  s.add_runtime_dependency       "rspec", "~> 3.4"
  s.add_runtime_dependency       "chef-vault", "~> 3"
  s.add_runtime_dependency       "hashie", "< 4.0", ">= 2.0"
  s.add_development_dependency   "rdoc"
  s.add_development_dependency   "chef", ">= 12.9"
  s.add_development_dependency   "rake", "~> 11.0"
  s.add_development_dependency   "guard"
  s.add_development_dependency   "guard-rspec"
  s.add_development_dependency   "guard-rake"
  s.add_development_dependency   "guard-rubocop"
  s.add_development_dependency   "chefspec"
  s.add_development_dependency   "berkshelf"
  s.add_development_dependency   "simplecov"
  s.add_development_dependency   "simplecov-console"
  s.add_development_dependency   "yard"
end
