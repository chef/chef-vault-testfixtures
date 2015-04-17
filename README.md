# chef-vault-testfixtures

* home :: https://github.com/Nordstrom/chef-vault-testfixtures
* license :: [Apache2](http://www.apache.org/licenses/LICENSE-2.0)
* gem version :: [![Gem Version](https://badge.fury.io/rb/chef-vault-testfixtures.png)](http://badge.fury.io/rb/chef-vault-testfixtures)
* build status :: [![Build Status](https://travis-ci.org/Nordstrom/chef-vault-testfixtures.png?branch=master)](https://travis-ci.org/Nordstrom/chef-vault-testfixtures)
* code climate :: [![Code Climate](https://codeclimate.com/github/Nordstrom/chef-vault-testfixtures/badges/gpa.svg)](https://codeclimate.com/github/Nordstrom/chef-vault-testfixtures)

## DESCRIPTION

chef-vault-testfixtures provides an RSpec shared context that
stubs access to chef-vault encrypted data bags using the same
fallback mechanism as the `chef_vault_item` helper from the
[chef-vault cookbook](https://supermarket.chef.io/cookbooks/chef-vault)

## USAGE

[chef-vault](https://github.com/Nordstrom/chef-vault) is a gem to manage
distribution and control of keys to decrypt Chef encrypted data bags.

When testing a cookbook that uses chef-vault, encryption is generally
out of scope, which results in a large number of stubs or mocks so that
you can get back fixture data without performing decryption.

Chef created the [chef-vault cookbook](https://supermarket.chef.io/cookbooks/chef-vault)
to make integration testing easier.  If you use the `chef_vault_item`
helper provided by that cookbook, then failing to load the vault
causes the helper to fall back to a normal JSON data bag in the
directory `test/integration/data_bags`.

This gem makes the unit test side of cookbook testing with ChefSpec
easier by dynamically stubbing attempts to access vault data to
use the same JSON data bags as the helper.  This allows you to provide
one source of stubbing data that works for both unit and integration
test.

## USAGE

In the file `test/integration/data_bags/foo/bar.json`:

    { "password": "sekrit" }

In your cookbook Gemfile:

    gem 'chef-vault-testfixtures', '~> 0.3'

In your cookbook `spec/spec_helper.rb`:

    require 'chef-vault/test_fixtures'

In a cookbook example:

    RSpec.describe 'my_cookbook::default' do
      include ChefVault::TestFixtures.rspec_shared_context

      let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

      it 'should converge' do
        expect(chef_run).to include_recipe(described_recipe)
      end
    end

The recipe that the example tests:

    include_recipe 'chef-vault'
    item = chef_vault_item('foo', 'bar')
    file '/tmp/foo' do
      contents item['password']
    end

The helper will call `ChefVault::Item.load`, which will be stubbed using
the data bag from the test/integration/data_bags directory.

## DEPENDENCIES

It may seem strange that chef isn't a runtime dependency of this gem.
This is due to idiosyncracies in the way that old versions of rubygems
(such as those that ship with chef-client prior to 11.18.0) process
dependencies.

If we include chef as a dependency, even with a relaxed requirement
like '>= 11.0', rubygems v1.8.x will still try to pull in chef-12.0.3,
even if the --conservative switch is used.  This in turn pulls in
Ohai 8.1.x, which doesn't work under Ruby 1.9.3 (which is what chef-client
11 embeds).

rubygems v2.x.x do not suffer from this problem.  The net takeaway is that
attempting to install this gem on a system that does not have chef installed
will fail.  I expect the instances of people trying to do this to be
small.

## AUTHOR

James FitzGibbon - james.i.fitzgibbon@nordstrom.com - @jf647

## LICENSE

Copyright 2015 Nordstrom, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
