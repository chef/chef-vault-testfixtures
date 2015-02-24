# chef-vault-testfixtures

* home :: https://github.com/Nordstrom/chef-vault-testfixtures
* license :: [Apache2](http://www.apache.org/licenses/LICENSE-2.0)
* gem version :: [![Gem Version](https://badge.fury.io/rb/chef-vault-testfixtures.png)](http://badge.fury.io/rb/chef-vault-testfixtures)
* build status :: [![Build Status](https://travis-ci.org/Nordstrom/chef-vault-testfixtures.png?branch=master)](https://travis-ci.org/Nordstrom/chef-vault-testfixtures)
* code climate :: [![Code Climate](https://codeclimate.com/github/Nordstrom/chef-vault-testfixtures/badges/gpa.svg)](https://codeclimate.com/github/Nordstrom/chef-vault-testfixtures)

## DESCRIPTION

chef-vault-testfixtures provides an RSpec shared context that
dynamically stubs access to chef-vault encrypted data bags.

## USAGE

[chef-vault](https://github.com/Nordstrom/chef-vault) is a gem to manage distribution and control of keys to
decrypt Chef encrypted data bags.

When testing a cookbook that uses chef-vault, encryption is generally
out of scope, which results in a large number of stubs or mocks so that you can get back fixture data without performing decryption.

This gem makes testing Chef cookbooks easier using ChefSpec by
dynamically stubbing attempts to access vault data to return invalid
(i.e. not real passwords for any of your environments) that are properly
formatted (e.g. a vault item containing an RSA key really contains one)

The intended use case is that for each group of distinct secrets
(e.g. an application stack, or a development team) you create one or
more plugins.  The plugins contain data that is specific to your
application.

Since plugins can be whitelisted or blacklisted when the shared
context is created, this makes it easy to only include the appropriate
secrets in a given cookbook's tests.

Attempts to access secrets that would not be available to a node
during a real chef-client run will not be mocked, which will cause
the double to raise an 'unexpected message received' error.

## USAGE

In the file `spec/support/chef-vault/test_fixtures/foo.rb`:

    class ChefVault
      class TestFixtures
        class Foo
          def bar
            { 'baz' => 2 }
          end
        end
      end
    end

In your cookbook Gemfile:

    gem 'chef-vault-testfixtures', '~> 0.1'

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

    chef_gem 'chef-vault' do
      compile_time true if respond_to?(:compile_time)
    end
    require 'chef-vault'
    item = ChefVault::Item.load('foo', 'bar')
    file '/tmp/foo' do
      contents item['password']
    end

The call to `ChefVault::Item.load` will be stubbed so that you don't
need pre-encrypted data or private keys to run your specs.

## PLUGINS

This gem uses [little-plugger](https://rubygems.org/gems/little-plugger)
to make adding vault fixtures easy.  Each data bag needs a plugin
named using [little-pluggers's rules](https://github.com/TwP/little-plugger/blob/master/lib/little-plugger.rb#L13-24).

The plugin must define a class inside the naming hierarchy
`ChefVault::TestFixtures::`.  The class name should be the filename
converted to CamelCase (e.g. `foo_bar.rb` = `FooBar`)

Inside of the plugin, define a class method for each vault item you
want to stub.  The method must return a Hash, which contains the
vault data.

For example, if you wanted to stub the data bag item foo/bar, you would
create the class `ChefVault::TestFixtures::Foo` and inside define a class method `bar`.

### ALIASING VAULT ITEMS

If you want your vault to return the same data for two different
vault items, just alias the method:

    class ChefVault
      class TestFixtures
        class MyApp
          def test
            { 'baz' => 1 }
          end

          alias_method :prod, :test
        end
      end
    end

Now you will get the same value for:

    ChefVault::Item.load('my_app', 'test')['baz']

as you do from

    ChefVault::Item.load('my_app', 'prod')['baz']

This can be useful when your vaults use `node.chef_environment`
(or a derivative thereof) for the item name.

## FINDING VAULTS

LittlePlugger loads any files in any installed gem that match
the pathspec `lib/chef-vault/test_fixtures/*.rb`.  Plugin classes
that are loaded using 'require' are also available as vaults.

You can bundle one or more plugins as a gem that you can distribute
publicly or privately, or you can distribute them baked into your cookbook.

For example, in a cookbook create the file `spec/support/chef-vault/test_fixtures/foo.rb`
with the same contents as above.  LittlePlugger will not find
this automatically because it's not part of an installed gem, but
by requiring it from your `spec/spec_helper.rb`:

    require 'support/chef-vault/test_fixtures/foo'

It will be available when `ChefVault::TestFixtures.rspec_shared_context` is called.

Note that LittlePlugger excludes any plugins that have a class name
all in capitals (because it assumes those are constants).  A plugin
for database secrets should be named `Db` instead of `DB`.  However,
this is only of interest to plugin authors.  When selecting the plugins
to load, the names are always lowercase symbols.

## LISTING VAULTS

To get a list of the stubbed vaults, call

    ChefVault::TestFixtures.load_plugins
    list = ChefVault::TestFixtures.plugins.keys

The return from `::plugins` is a hash of plugin names (as symbols)
to the class or module that provide them.

The plugin name is always a lowercase symbol.

## RESTRICTING WHICH VAULTS ARE USED

Thanks to Little Plugger, you can change what plugins (vaults) will
be loaded the first time that `#rspec_shared_context` is called.

To only load certain plugins, call

    ChefVault::TestFixtures.plugin :pluginone, :plugintwo

before calling `ChefVault::TestFixtures.rspec_shared_context`.

To prevent certain plugins from being loaded, call

    ChefVault::TestFixtures.disregard_plugin :pluginthree

before calling `ChefVault::TestFixtures.rspec_shared_context`.

Note that the context is memoized on first call, so calling `::plugin` or `::disregard_plugin` after calling `::rspec_shared_context` will not change what vaults are available.

## COMPANION COOKBOOK FOR TEST KITCHEN

A [companion cookbook](https://supermarket.chef.io/cookbooks/chef_vault_testfixtures)
is also available that uses the same data to populate vaults during
Test Kitchen integration runs.

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
