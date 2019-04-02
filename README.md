# chef-vault-testfixtures

* home :: https://github.com/chef/chef-vault-testfixtures
* license :: [Apache2](http://www.apache.org/licenses/LICENSE-2.0)
* gem version :: [![Gem Version](https://badge.fury.io/rb/chef-vault-testfixtures.png)](http://badge.fury.io/rb/chef-vault-testfixtures)
* build status :: [![Build Status](https://travis-ci.org/chef/chef-vault-testfixtures.png?branch=master)](https://travis-ci.org/chef/chef-vault-testfixtures)
* code climate :: [![Code Climate](https://codeclimate.com/github/chef/chef-vault-testfixtures/badges/gpa.svg)](https://codeclimate.com/github/chef/chef-vault-testfixtures)

## DESCRIPTION

chef-vault-testfixtures provides an RSpec shared context that
stubs access to chef-vault encrypted data bags using the same
fallback mechanism as the `chef_vault_item` helper from the
[chef-vault cookbook](https://supermarket.chef.io/cookbooks/chef-vault)

## USAGE

[chef-vault](https://github.com/chef/chef-vault) is a gem to manage
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

      let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04')
        .converge(described_recipe) }

      it 'should converge' do
        expect(chef_run).to include_recipe(described_recipe)
      end
    end

The recipe that the example tests:

    include_recipe 'chef-vault'
    item = chef_vault_item('foo', 'bar')
    file '/tmp/foo' do
      content item['password']
    end

The helper will call `ChefVault::Item.load`, which will be stubbed using
the data bag from the test/integration/data_bags directory.

To set a custom folder from where to load the data bags, you can
use the :custom_data_bags_path parameter when calling rspec_shared_context:

    RSpec.describe 'my_cookbook::default' do
      include ChefVault::TestFixtures.rspec_shared_context(custom_data_bags_path: "path/to/data_bags")

## VAULT PROBING

Some recipes and helpers attempt to determine if a data bag is a vault
by checking the raw data bag item to see if one of the values contains
encrypted data, then checking for the existence of the `_keys` data bag
item to go along with the normal item.  The [sensu cookbook](https://github.com/sensu/sensu-chef/blob/35ee3aa6fa4ad578cdf751fe6822e3d2b3890d94/libraries/sensu_helpers.rb#L39-55) is a good example
of this:

```
raw_hash = Chef::DataBagItem.load(data_bag_name, item)
encrypted = raw_hash.detect do |key, value|
  if value.is_a?(Hash)
    value.has_key?("encrypted_data")
  end
end
if encrypted
  if Chef::DataBag.load(data_bag_name).key? "#{item}_keys"
    chef_vault_item(data_bag_name, item)
  else
    secret = Chef::EncryptedDataBagItem.load_secret
    Chef::EncryptedDataBagItem.new(raw_hash, secret)
  end
else
  raw_hash
end
```

chef-vault-testfixtures also stubs `Chef::DataBag` so that for every JSON
file in your test directory, it will think that there is a side-along
item suffixed with `_keys`.  This satisfies the probes that the chef-vault
cookbook helper uses.  To address the check for the `encrypted_data` key
that the sensu cookbook uses, pass a true value to `rspec_shared_context`:

```
RSpec.describe 'my_cookbook::default' do
  include ChefVault::TestFixtures.rspec_shared_context(true)
end
```

Now, when your recipe calls `Chef::DataBagItem.load`, it will
get back a hash with the same keys as the JSON file, but values which are
hashes of the form:

```
{
  encrypted_data => '...'
}
```

This is not a valid data bag obviously, but it will satisfy the probe
and cause code like that in the sensu cookbook to call `ChefVault::Item.load`,
which is stubbed to return valid data.

## STUBBING UNENCRYPTED DATA BAGS

This technique is not a part of this gem, but was brought to my attention
in an issue.  Credit to Dru Goradia for the approach.  This will let you
populate an unencrypted data bag from the same JSON files:

In `spec/spec_helper.rb`:

```
require 'chef-vault/test_fixtures'
require 'json'

def parse_data_bag (path)
  data_bags_path = File.expand_path(File.join(File.dirname(__FILE__), '../test/integration/data_bags'))
  return JSON.parse(File.read("#{data_bags_path}/#{path}"))
end
```

In your test:

```
describe 'my_cookbook::default' do
  include ChefVault::TestFixtures.rspec_shared_context

  let(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04') do |node, server|
      server.create_data_bag('foo', {
        'bar' => parse_data_bag('foo/bar.json')
      })
    end.converge(described_recipe)
  end

  it 'should converge' do
    expect(chef_run).to include_recipe(described_recipe)
  end
end
```

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
Copyright 2016 Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
