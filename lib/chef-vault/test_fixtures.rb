require "pathname"
require "json"
require "hashie/extensions/method_access"

require "rspec"
require "rspec/core/shared_context"
require "chef-vault"

require "chef-vault/test_fixtures_version"

# chef-vault helps manage encrypted data bags using a node's public key
class ChefVault
  # dynamic RSpec contexts for cookbooks that use chef-vault
  class TestFixtures
    # dynamically creates a memoized RSpec shared context
    # that when included into an example group will stub
    # ChefVault::Item for each of the defined vaults. The
    # context is memoized and only created once
    # @return [Module] the RSpec shared context
    class << self
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

      # created a shared RSpec context that stubs calls to ChefVault::Item.load
      # @param stub_encrypted_data [Boolean] whether to also stub calls to
      #   Chef::DataBagItem.load
      # @param custom_data_bags_path [String] path to a custom data bags folder
      # @return [Module] a shared context to include in your example groups
      def rspec_shared_context(stub_encrypted_data = false,
                               custom_data_bags_path: nil)
        @context ||= begin
          Module.new do
            extend RSpec::Core::SharedContext

            before do
              unless custom_data_bags_path.nil?
                custom_data_bags_path = Pathname.new(custom_data_bags_path)
              end
              find_vaults(stub_encrypted_data, custom_data_bags_path)
            end

            private

            # finds all the directories in test/integration/data_bags, stubbing
            # each as a vault
            # @param stub_encrypted_data [Boolean] whether to also stub calls to
            #   Chef::DataBagItem.load
            # @param custom_data_bags_path [Pathname] path to a custom data bags
            # folder
            # return [void]
            # @api private
            def find_vaults(stub_encrypted_data, custom_data_bags_path)
              dbdir = Pathname.new("test") + "integration" + "data_bags"
              smokedir = Pathname.new("test") + "smoke" + "default" + "data_bags"
              [ dbdir, smokedir, custom_data_bags_path ].compact.each do |dir|
                next unless dir.directory?
                dir.each_child do |vault|
                  next unless vault.directory?
                  stub_vault(stub_encrypted_data, vault)
                end
              end
            end

            # stubs a vault with the contents of JSON files in a directory.
            # Finds all files in the vault path ending in .json and stubs
            # each as a vault item.
            # @param stub_encrypted_data [Boolean] whether to also stub calls to
            #   Chef::DataBagItem.load
            # @param vault [Pathname] the path to the directory that will be
            #   stubbed as a vault
            # @return [void]
            # @api private
            def stub_vault(stub_encrypted_data, vault)
              db = {}
              vault.each_child do |e|
                next unless e.file?
                m = e.basename.to_s.downcase.match(/(.+)\.json/i)
                next unless m
                content = JSON.parse(e.read)
                vaultname = vault.basename.to_s
                stub_vault_item(vaultname, m[1], content, db)
                if stub_encrypted_data
                  stub_vault_item_encrypted_data(vaultname, m[1], content)
                end
              end
            end

            # stubs a vault item with the contents of a parsed JSON string.
            # If the class-level setting `encrypted_data_stub` is true, then
            # Chef::DataBagItem.load
            # @param vault [String] the name of the vault data bag
            # @param item [String] the name of the vault item
            # @param content [String] the JSON-encoded contents to populate the
            #   fake vault with
            # @param db [Hash] the fake data bag item that contains the item
            # @return [void]
            # @api private
            def stub_vault_item(vault, item, content, db)
              db["#{item}_keys"] = true
              vi = make_fakevault(vault, item)

              # stub vault lookup of each of the vault item keys
              content.each do |k, v|
                next if "id" == k
                allow(vi).to receive(:[]).with(k).and_return(v)
              end

              # stub hash conversion as a stopgap to other hash methods
              allow(vi).to receive(:to_h).with(no_args).and_return(content)
              allow(vi).to receive(:to_hash).with(no_args).and_return(content)

              # stub ChefVault and Chef::DataBag to return the doubles
              # via both symbol and string forms of the data bag name
              [vault, vault.to_sym].each do |dbname|
                allow(ChefVault::Item).to(
                  receive(:vault?).with(dbname, item).and_return(true)
                )

                allow(ChefVault::Item).to(
                  receive(:load)
                  .with(dbname, item)
                  .and_return(vi)
                )
                allow(Chef::DataBag).to(
                  receive(:load)
                  .with(dbname)
                  .and_return(db)
                )
              end
            end

            # stubs Chef::DataBagItem.load to return a fake hash in which
            # each key of the content returns a hash with single
            # `encrypted_data` key, which fools some attempts to determine
            # whether a data bag is a vault
            # @param vault [String] the name of the vault data bag
            # @param item [String] the name of the vault item
            # @param content [String] the JSON-encoded contents to populate the
            #   fake vault with
            # @return [void]
            # @api private
            def stub_vault_item_encrypted_data(vault, item, content)
              # stub data bag lookup of each of the vault item keys
              dbi = ChefVault::TestFixtureDataBagItem.new
              dbi["raw_data"] = content
              content.each_key do |k|
                next if "id" == k
                dbi[k] = { "encrypted_data" => "..." }
              end

              [vault, vault.to_sym].each do |dbname|
                allow(Chef::DataBagItem).to(
                  receive(:load).with(dbname, item).and_return(dbi)
                )
              end
            end

            # returns an RSpec double that acts like a vault item
            # @param vault [String] the name of the vault data bag
            # @param item [String] the name of the vault item
            # @return [RSpec::Mocks::Double] the vault double
            # @api private
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

  # a hash with method access to stand in for a Chef::DataBagItem
  class TestFixtureDataBagItem < Hash
    include Hashie::Extensions::MethodAccess
  end
end
