module Sensu
  module Extension
    class SymlinkedCheck < Check
      def name
        "symlinked_check"
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
