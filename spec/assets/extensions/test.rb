module Sensu
  module Extension
    class Test < Handler
      def name
        "test"
      end

      def description
        "test extension"
      end

      def run(event, &callback)
        block.call(event, 0)
      end
    end
  end
end
