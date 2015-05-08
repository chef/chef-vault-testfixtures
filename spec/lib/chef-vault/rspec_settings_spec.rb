require 'spec_helper'
require 'chef-vault/rspec_settings'

RSpec.describe 'chef_vault_data_bags_path' do
  DEFAULT_DATA_BAGS_PATH = 'test/integration/data_bags'.freeze

  def data_bags_path
    RSpec.configuration.chef_vault_data_bags_path
  end

  it 'eq test/integration/data_bags by default' do
    expect(data_bags_path).to eq(DEFAULT_DATA_BAGS_PATH)
  end

  it "can be overridden" do
    RSpec.configuration.chef_vault_data_bags_path = 'test/fixtures/data_bags'
    expect(data_bags_path).to eq('test/fixtures/data_bags')
    expect(RSpec.configuration.chef_vault_data_bags_path?).to be_truthy
    RSpec.configuration.chef_vault_data_bags_path = DEFAULT_DATA_BAGS_PATH
  end
end
