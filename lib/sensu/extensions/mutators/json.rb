require "sensu/extension"

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
        yield MultiJson.dump(event), 0
      end
    end
  end
end
