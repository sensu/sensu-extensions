module Sensu
  module Extension
    class ScriptError < Handler
      def name
        "error"
      #end

      def description
        "error extension"
      end

      def run(event, &callback)
        block.call(event, 0)
      end
    end
  end
end
