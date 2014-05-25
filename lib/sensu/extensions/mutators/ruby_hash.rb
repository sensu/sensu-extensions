require "sensu/extension"

module Sensu
  module Extension
    class RubyHash < Mutator
      def name
        "ruby_hash"
      end

      def description
        "returns ruby hash event data"
      end

      def run(event)
        yield event, 0
      end
    end
  end
end
