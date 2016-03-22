require "sensu/extension"
require "sensu/json"

module Sensu
  module Extension
    class Json < Mutator
      def name
        "json"
      end

      def description
        "returns JSON formatted event data"
      end

      def run(event)
        yield Sensu::JSON.dump(event), 0
      end
    end
  end
end
