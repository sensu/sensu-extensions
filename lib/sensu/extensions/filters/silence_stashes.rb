require "sensu/extension"
require "em-http-request"

module Sensu
  module Extension
    class SilenceStashes < Filter
      def name
        "silence_stashes"
      end

      def description
        "filter events using api silence stashes"
      end

      def run(event)
        event_silenced?(event) do |silenced|
          if silenced
            yield "event silenced by an api silence stash", 0
          else
            yield "event not silenced by an api silence stash", 1
          end
        end
      end

      private

      def options
        return @options if @options
        @options = settings[:api] || {}
        @options[:host] ||= "127.0.0.1"
        @options[:port] ||= 4567
        @options
      end

      def async_api_stash_request(stash_path)
        connection_options = {
          :connect_timeout => 10,
          :inactivity_timeout => 10
        }
        request_options = {:path => "/stashes/" + stash_path}
        if options[:user] && options[:password]
          request_options[:head] = {
            :authorization => [options[:user], options[:password]]
          }
        end
        url = "http://#{options[:host]}:#{options[:port]}"
        EM::HttpRequest.new(url, connection_options).get(request_options)
      end

      def silence_stash_exists?(stash_path, &callback)
        http = async_api_stash_request(stash_path)
        http.errback do
          @logger.error("failed to query api for silence stash", :stash => stash_path)
          callback.call(false)
        end
        http.callback do
          exists = (http.response_header.status == 200)
          callback.call(exists)
        end
      end

      def event_silenced?(event, &callback)
        client_stash = ["silence", event[:client][:name]].join("/")
        check_stash = [client_stash, event[:check][:name]].join("/")
        silence_stash_exists?(client_stash) do |exists|
          if exists
            @logger.debug("silence stash exists for client", :stash => client_stash)
            callback.call(true)
          else
            silence_stash_exists?(check_stash) do |exists|
              @logger.debug("silence stash exists for check", :stash => check_stash) if exists
              callback.call(exists)
            end
          end
        end
      end
    end
  end
end
