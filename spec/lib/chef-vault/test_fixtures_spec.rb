require "chef-vault/test_fixtures"

RSpec.describe ChefVault::TestFixtures do
  describe "without the encrypted_data stub" do
    ChefVault::TestFixtures.clear_context
    include ChefVault::TestFixtures.rspec_shared_context(false)

    it "can create an RSpec shared context" do
      sc = ChefVault::TestFixtures.rspec_shared_context
      expect(sc).to be_a(Module)
      expect(sc).to be_a(RSpec::Core::SharedContext)
    end

    it "should only create one shared context" do
      mod1 = ChefVault::TestFixtures.rspec_shared_context
      mod2 = ChefVault::TestFixtures.rspec_shared_context
      expect(mod2).to be(mod1)
    end

    it "should stub the foo/bar vault item" do
      baz = ChefVault::Item.load("foo", "bar")["baz"]
      expect(baz).to eq(2)
    end

    it "should allow access to foo/bar via a symbol instead of a string" do
      baz = ChefVault::Item.load(:foo, "bar")["baz"]
      expect(baz).to eq(2)
    end

    it "should stub the bar/foo vault item" do
      baz = ChefVault::Item.load("bar", "foo")["baz"]
      expect(baz).to eq(1)
    end

    it "should allow access to the bar/gzonk vault item" do
      item1 = ChefVault::Item.load("bar", "foo")
      item2 = ChefVault::Item.load("bar", "gzonk")
      expect(item1["baz"]).to eq(item2["baz"])
    end

    it "should allow access to the bar/gzonk vault item via a symbol" do
      item1 = ChefVault::Item.load(:bar, "foo")
      item2 = ChefVault::Item.load(:bar, "gzonk")
      expect(item1["baz"]).to eq(item2["baz"])
    end

    it "should check both smoke and integration for a vault" do
      item = ChefVault::Item.load("canteloupe", "foo")
      item["cat"] == "cat"
    end

    it "should allow and ignore an attempt to change a vault" do
      item = ChefVault::Item.load("bar", "foo")
      item["foo"] = "foo"
    end

    it "should allow and ignore an attempt to set the clients" do
      item = ChefVault::Item.load("bar", "foo")
      item.clients("*:*")
    end

    it "should allow and ignore an attempt to save" do
      item = ChefVault::Item.load("bar", "foo")
      item.save
    end

    it "should stub the _keys data bag item" do
      db = Chef::DataBag.load("foo")
      expect(db.key?("bar_keys")).to be_truthy
    end
  end
end

RSpec.describe ChefVault::TestFixtures do
  describe "with the encrypted_data stub" do
    ChefVault::TestFixtures.clear_context
    include ChefVault::TestFixtures.rspec_shared_context(true)

    it "should present the foo/bar data bag item as encrypted" do
      dbi = Chef::DataBagItem.load("foo", "bar")
      encrypted = dbi.detect do |_, v|\
        v.is_a?(Hash) && v.key?("encrypted_data")
      end
      expect(encrypted).to be_truthy
    end
  end
end

RSpec.describe ChefVault::TestFixtures do
  describe "with a custom data bags path" do
    ChefVault::TestFixtures.clear_context
    include ChefVault::TestFixtures.rspec_shared_context(
      custom_data_bags_path: 'test/custom/data_bags'
    )

    it "should load data bags from a custom path" do
      bar = ChefVault::Item.load("foobar", "foo")["bar"]
      expect(bar).to eq(42)
    end
  end
end
