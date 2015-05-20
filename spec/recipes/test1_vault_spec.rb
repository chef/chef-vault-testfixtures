require 'chefspec'
require 'chefspec/berkshelf'
require 'chef-vault/test_fixtures'

RSpec.describe 'test1::vault' do
  around(:each) do |example|
    path = RSpec.configuration.chef_vault_data_bags_path = 'test/integration/data_bags'
    RSpec.configuration.chef_vault_data_bags_path = 'test/fixtures/data_bags'
    example.run
    RSpec.configuration.chef_vault_data_bags_path = path
  end

  ChefVault::TestFixtures.clear_context
  include ChefVault::TestFixtures.rspec_shared_context(false)

  let(:chef_run) do
    ChefSpec::SoloRunner.new do
    end.converge(described_recipe)
  end

  it 'should converge' do
    expect(chef_run).to include_recipe(described_recipe)
  end

  describe 'unencrypted data bag item' do
    subject { chef_run.node.run_state['lol_rofl'] }

    it 'has the right values' do
      expect(subject['id']).to eq('rofl')
      expect(subject['test']).to eq('hey ho')
    end
  end
end
