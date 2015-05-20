RSpec.configure do |c|
  c.add_setting(
    :chef_vault_data_bags_path,
    :default => 'test/integration/data_bags'
  )
end
