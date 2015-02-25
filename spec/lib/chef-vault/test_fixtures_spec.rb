require 'chef-vault/test_fixtures'

# sample plugins
require 'support/chef-vault/test_fixtures/foo.rb'
require 'support/chef-vault/test_fixtures/bar.rb'

# LittlePlugger doesn't expect to have its inclusion/exclusion
# lists reset in a single process, so we have to monkeypatch
# in some testing functionality
module LittlePlugger
  module ClassMethods
    def clear_plugins
      @plugin_names = []
      @disregard_plugin = []
      @loaded = {}
    end
  end
end

# same with ChefVault::TestFixtures
class ChefVault
  class TestFixtures
    class << self
      def clear_context
        @context = nil
      end
    end
  end
end

RSpec.describe ChefVault::TestFixtures do
  include ChefVault::TestFixtures.rspec_shared_context

  before do
    ChefVault::TestFixtures.clear_plugins
    ChefVault::TestFixtures.clear_context
  end

  after do
    ChefVault::TestFixtures.clear_plugins
    ChefVault::TestFixtures.clear_context
  end

  describe 'Generic functionality' do
    it 'should be able to load plugins' do
      expect(ChefVault::TestFixtures.plugins).to be_a(Hash)
    end

    it 'should load the expected vaults' do
      expect(ChefVault::TestFixtures.plugins.keys).to(
        contain_exactly(:foo, :bar)
      )
    end

    it 'can create an RSpec shared context' do
      sc = ChefVault::TestFixtures.rspec_shared_context
      expect(sc).to be_a(Module)
      expect(sc).to be_a(RSpec::Core::SharedContext)
    end

    it 'should only create one shared context' do
      mod1 = ChefVault::TestFixtures.rspec_shared_context
      mod2 = ChefVault::TestFixtures.rspec_shared_context
      expect(mod2).to be(mod1)
    end

    it 'allows for the plugin list to be make explicit' do
      ChefVault::TestFixtures.plugin :foo
      expect(ChefVault::TestFixtures.plugins).to include(:foo)
      expect(ChefVault::TestFixtures.plugins).not_to include(:bar)
    end

    it 'allows for plugins to be blacklisted' do
      ChefVault::TestFixtures.disregard_plugin :foo
      expect(ChefVault::TestFixtures.plugins).not_to include(:foo)
      expect(ChefVault::TestFixtures.plugins).to include(:bar)
    end
  end

  describe 'Stub a Vault' do
    it 'should stub the foo/bar vault item' do
      baz = ChefVault::Item.load('foo', 'bar')['baz']
      expect(baz).to eq(2)
    end

    it 'should allow access to foo/bar via a symbol instead of a string' do
      baz = ChefVault::Item.load(:foo, 'bar')['baz']
      expect(baz).to eq(2)
    end

    it 'should stub the bar/foo vault item' do
      baz = ChefVault::Item.load('bar', 'foo')['baz']
      expect(baz).to eq(1)
    end

    it 'should allow access to the aliased bar/gzonk vault item' do
      item1 = ChefVault::Item.load('bar', 'foo')
      item2 = ChefVault::Item.load('bar', 'gzonk')
      expect(item1['baz']).to eq(item2['baz'])
    end

    it 'should allow access to the aliased bar/gzonk vault item via a symbol' do
      item1 = ChefVault::Item.load(:bar, 'foo')
      item2 = ChefVault::Item.load(:bar, 'gzonk')
      expect(item1['baz']).to eq(item2['baz'])
    end

    it 'should allow and ignore an attempt to change a vault' do
      item = ChefVault::Item.load('bar', 'foo')
      item['foo'] = 'foo'
    end

    it 'should allow and ignore an attempt to set the clients' do
      item = ChefVault::Item.load('bar', 'foo')
      item.clients('*:*')
    end

    it 'should allow and ignore an attempt to save' do
      item = ChefVault::Item.load('bar', 'foo')
      item.save
    end
  end
end
