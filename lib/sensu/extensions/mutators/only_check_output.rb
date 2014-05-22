require "sensu/extension"

module Sensu
  module Extension
    class OnlyCheckOutput < Mutator
      def name
        "only_check_output"
      end

      def description
        "returns check output"
      end

      def run(event)
        yield event[:check][:output], 0
      end
    end
  end
end
