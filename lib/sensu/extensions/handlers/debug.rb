require "sensu/extension"

module Sensu
  module Extension
    class Debug < Handler
      def name
        "debug"
      end

      def description
        "returns inspected event data"
      end

      def run(event)
        yield event.inspect, 0
      end
    end
  end
end
