require 'rspec'
require 'rspec/core/shared_context'
require 'chef-vault'
require 'little-plugger'

class ChefVault
  # dynamic RSpec contexts for cookbooks that use chef-vault
  class TestFixtures
    VERSION = '0.1.0'

    extend LittlePlugger path: 'chef-vault/test_fixtures',
                         module: ChefVault::TestFixtures

    # dynamically creates a memoized RSpec shared context
    # that when included into an example group will stub
    # ChefVault::Item for each of the defined vaults. The
    # context is memoized and only created once
    # @return [Module] the RSpec shared context
    class << self
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def shared_context
        @context ||= begin
          load_plugins
          Module.new do
            extend RSpec::Core::SharedContext

            before do
              ChefVault::TestFixtures.plugins.each do |vault, klass|
                stub_vault(vault, klass)
              end
            end

            private

            def stub_vault(vaultname, pluginclass)
              plugin = pluginclass.new
              # stub a vault item for each method defined by the plugin
              pluginclass.instance_methods(false).each do |item|
                fakevault = make_fakevault(vaultname, item)
                # stub lookup of each of the vault item keys
                plugin.send(item).each do |k, v|
                  allow(fakevault).to receive(:[]).with(k).and_return(v)
                end
                # stub chef-vault to return the fake vault
                allow(ChefVault::Item).to(
                  receive(:load)
                  .with(vaultname.to_s, item.to_s)
                  .and_return(fakevault)
                )
              end
            end

            def make_fakevault(vault, item)
              fakevault = double "vault item #{vault}/#{item}"
              allow(fakevault).to receive(:[]=).with(String, Object)
              allow(fakevault).to receive(:clients).with(String)
              allow(fakevault).to receive(:save)
              fakevault
            end
          end
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
