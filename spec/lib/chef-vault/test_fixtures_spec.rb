require 'chef-vault/test_fixtures'

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
    ChefVault::TestFixtures.clear_context
  end

  after do
    ChefVault::TestFixtures.clear_context
  end

  describe 'Generic functionality' do
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
  end

  describe 'stub ChefVault::Item.load' do
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

  describe 'stub Chef::DataBagItem.load' do
    it 'should present the foo/bar data bag item as encrypted' do
      dbi = Chef::DataBagItem.load('foo', 'bar')
      encrypted = dbi.detect do |_, v|\
        v.is_a?(Hash) && v.key?('encrypted_data')
      end
      expect(encrypted).to be_truthy
    end
  end

  describe 'stub Chef::DataBag.load' do
    it 'should fake the foo/bar_keys data bag item' do
      db = Chef::DataBag.load('foo')
      expect(db.key?('bar_keys')).to be_truthy
    end
  end
end
