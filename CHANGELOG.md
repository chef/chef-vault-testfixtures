# chef-vault-testfixtures Change Log

<!-- latest_release -->
<!-- latest_release -->

<!-- release_rollup -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v3.1.2](https://github.com/chef/chef-vault-testfixtures/tree/v3.1.2) (2021-07-05)

#### Merged Pull Requests
- Relaxed Hashi upper bound to &lt; 5 [#40](https://github.com/chef/chef-vault-testfixtures/pull/40) ([wduncanfraser](https://github.com/wduncanfraser))
<!-- latest_stable_release -->

## [v3.1.1](https://github.com/chef/chef-vault-testfixtures/tree/v3.1.1) (2020-07-30)

#### Merged Pull Requests
- Resolve chefstyle warnings and add buildkite verification [#35](https://github.com/chef/chef-vault-testfixtures/pull/35) ([tas50](https://github.com/tas50))
- Only ship the files we need in the gem + ship license file [#36](https://github.com/chef/chef-vault-testfixtures/pull/36) ([tas50](https://github.com/tas50))
- README: Use SVG badges [#29](https://github.com/chef/chef-vault-testfixtures/pull/29) ([olleolleolle](https://github.com/olleolleolle))
- Require Ruby 2.5+ / allow for chef-vault 4.x [#37](https://github.com/chef/chef-vault-testfixtures/pull/37) ([tas50](https://github.com/tas50))
- Update badges, add CoC doc and contributing doc [#38](https://github.com/chef/chef-vault-testfixtures/pull/38) ([tas50](https://github.com/tas50))



## 0.5.1

* Bump hashie dependency for compatibility with latest chefdk (Thanks to
  dougireton and dwmarshall)

## 0.5.0

* breaking change: by default, only stub calls to `ChefVault::Item.load(bag, item)` and `Chef::DataBag.load(bag).key?(item_keys)`.  This allows people who are using the JSON files in test/integration/data_bags to stub unencrypted data bag to do so.  See the README for details of how to continue to stub `ChefVault::DataBagItem.load(bag, item)` and return a fake hash.  Reported by [Dru Goradia](https://github.com/dgoradia-atlas))

## 0.4.1

* fix bug where only the last item for a given vault was stubbed

## 0.4.0

* add stubs for Chef::DataBagItem.load and Chef::DataBag.load for compatibility with code that probes the data bag to determine if it is a vault (e.g. chef-vault cookbook ~> 1.3)

## 0.3.0

* completely re-work to use JSON data bag files in test/integration for compatibility with the fallback mechanism in the chef-vault cookbook

## 0.2.0

* move chef dependency out of runtime and into development - rubygems 1.8.x (which chef-client shipped with prior to 11.8.0) has major problems now that Chef v11 and v12 are both available

## 0.1.3

* change chef runtime dependency from >= 11.14 to >= 11.0
* clean up some test ordering problems related to not clearing the blacklist properly

## 0.1.2

* allow access to the data bag via the symbol form as well as the string form
* re-organize the README to make the summary extracted by Hoe smaller
* add Travis-CI integration and badging
* add Code Climate integration and badging

## 0.1.1

* fix disconnect between docs and code for shared context method
* remove Hoe test plugin so we don't double up on test runs

## 0.1.0

* initial version