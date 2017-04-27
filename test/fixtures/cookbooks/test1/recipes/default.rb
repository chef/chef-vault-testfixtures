node.run_state["dbi_wibble"] = data_bag_item("baz", "wibble")

vault_item = ChefVault::Item.load("foo", "bar")
unless vault_item.to_h.empty?
  node.run_state["foo"] = {}
  vault_item.to_h.each do |key, val|
    node.run_state["foo"][key] = val * 2
  end
end
