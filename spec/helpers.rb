require "rspec"
require "eventmachine"
require "sensu/logger"
require "sensu/settings"
require "uuidtools"

unless RUBY_VERSION < "1.9" || RUBY_PLATFORM =~ /java/
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

module Helpers
  def timer(delay, &callback)
    periodic_timer = EM::PeriodicTimer.new(delay) do
      callback.call
      periodic_timer.cancel
    end
  end

  def async_wrapper(&callback)
    EM.run do
      timer(10) do
        raise "test timed out"
      end
      callback.call
    end
  end

  def async_done
    EM.stop_event_loop
  end

  def logger
    Sensu::Logger.get(:log_level => :fatal)
  end

  def settings
    asset_dir = File.join(File.dirname(__FILE__), "assets")
    config_file = File.join(asset_dir, "config.json")
    Sensu::Settings.get(:config_file => config_file)
  end

  def epoch
    Time.now.to_i
  end

  def client_template
    {
      :name => "i-424242",
      :address => "127.0.0.1",
      :subscriptions => [
        "test"
      ]
    }
  end

  def check_template
    {
      :name => "test",
      :command => "echo WARNING && exit 1",
      :issued => epoch
    }
  end

  def event_template
    client = client_template
    client[:timestamp] = epoch
    check = check_template
    check[:output] = "WARNING"
    check[:status] = 1
    check[:history] = [1]
    {
      :id => UUIDTools::UUID.random_create.to_s,
      :client => client,
      :check => check,
      :occurrences => 1,
      :action => :create
    }
  end
end
