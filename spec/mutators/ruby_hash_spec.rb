require File.join(File.dirname(__FILE__), "..", "helpers")
require "sensu/extensions/mutators/ruby_hash"

describe "Sensu::Extension::RubyHash" do
  include Helpers

  before do
    @extension = Sensu::Extension::RubyHash.new
  end

  it "can run, returning event data as a ruby hash" do
    event = {
      :client => {},
      :check => {
        :output => "foo",
        :status => 0
      }
    }
    @extension.safe_run(event) do |output, status|
      expect(output).to eq(event)
      expect(status).to eq(0)
    end
  end
end
