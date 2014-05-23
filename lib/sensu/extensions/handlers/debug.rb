require "sensu/extension"

module Sensu
  module Extension
    class Debug < Handler
      def name
        "debug"
      end

      def description
        "returns raw event data"
      end

      def run(event)
        yield event, 0
      end
    end
  end
end
