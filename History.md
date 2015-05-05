# Changelog for chef-vault-testfixtures

## 0.4.2

* ensure that the data bag item returned from the `Chef::DataBagItem.load` stub responds to `#raw_data` so that stubbing unencrypted data bags still works (reported by [Dru Goradia](https://github.com/dgoradia-atlas))

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
