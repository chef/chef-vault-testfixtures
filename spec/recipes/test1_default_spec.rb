require "chefspec"
require "chefspec/berkshelf"
require "chef-vault/test_fixtures"

def parse_data_bag(path)
  data_bags_path = File.expand_path(
    File.join(File.dirname(__FILE__), "../../test/integration/data_bags")
  )
  JSON.parse(File.read("#{data_bags_path}/#{path}"))
end

RSpec.describe "test1::default" do
  ChefVault::TestFixtures.clear_context
  include ChefVault::TestFixtures.rspec_shared_context(false)

  let(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04') do |_, server|
      server.create_data_bag(
        "baz", "wibble" => parse_data_bag("baz/wibble.json")
      )
    end.converge(described_recipe)
  end

  it "should converge" do
    expect(chef_run).to include_recipe(described_recipe)
  end

  it "should have the right value for the unencrypted data bag item" do
    expect(chef_run.node.run_state["dbi_wibble"]["wibble"]).to eq(3)
  end

  it "should have the right value for the encrypted data bag item" do
    expect(chef_run.node.run_state["foo"]["baz"]).to eq(4)
  end
end
