class ChefVault
  class TestFixtures
    class Bar
      def foo
        { 'baz' => 1 }
      end

      alias_method :gzonk, :foo
    end
  end
end
