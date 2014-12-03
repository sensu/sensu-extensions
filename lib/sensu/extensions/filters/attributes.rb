require "sensu/extension"

module Sensu
  module Sandbox
    def self.eval(eval_string, value=nil)
      result = Proc.new do
        $SAFE = (RUBY_VERSION < "2.1.0" ? 4 : 3)
        Kernel.eval(eval_string)
      end
      result.call
    end
  end

  module Extension
    class Attributes < Filter
      def name
        "attributes"
      end

      def description
        "filters events using event attributes"
      end

      def run(event, options)
        status = filter_event?(options[:filter_name], event) ? 0 : 1
        yield "", status
      end

      def eval_attribute_value(raw_eval_string, value)
        begin
          eval_string = raw_eval_string.gsub(/^eval:(\s+)?/, "")
          !!Sandbox.eval(eval_string, value)
        rescue => error
          @logger.error("filter attribute eval error", {
            :raw_eval_string => raw_eval_string,
            :value => value,
            :error => error.to_s
          })
          false
        end
      end

      def attributes_match?(hash_one, hash_two)
        hash_one.all? do |key, value_one|
          value_two = hash_two[key]
          case
          when value_one == value_two
            true
          when value_one.is_a?(Hash) && value_two.is_a?(Hash)
            attributes_match?(value_one, value_two)
          when value_one.is_a?(String) && value_one.start_with?("eval:")
            eval_attribute_value(value_one, value_two)
          else
            false
          end
        end
      end

      def filter_event?(filter_name, event)
        if @settings.filter_exists?(filter_name)
          filter = @settings[:filters][filter_name]
          matched = attributes_match?(filter[:attributes], event)
          filter[:negate] ? matched : !matched
        else
          @logger.error("unknown filter", :filter_name => filter_name)
          false
        end
      end
    end
  end
end
