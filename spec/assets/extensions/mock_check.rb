module Sensu
  module Extension
    class MockCheck < Check
      def name
        "mock_check"
      end

      def description
        "returns 'foo'"
      end

      def run
        yield 'foo', 0
      end
    end
  end
end
