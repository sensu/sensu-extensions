module Sensu
  module Extension
    class ScriptError < Handler
      def name
        "error"
      #end

      def description
        "error extension"
      end

      def run(event)
        yield event, 0
      end
    end
  end
end
