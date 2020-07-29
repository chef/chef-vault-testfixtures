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
  s.required_ruby_version     = ">= 2.5"

  s.add_runtime_dependency       "rspec", "~> 3.4"
  s.add_runtime_dependency       "chef-vault", ">= 3", "< 5" # validate 5 if we release that
  s.add_runtime_dependency       "hashie", "< 4.0", ">= 2.0"
end
