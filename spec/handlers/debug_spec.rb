require File.join(File.dirname(__FILE__), "..", "helpers")
require "sensu/extensions/handlers/debug"

describe "Sensu::Extension::Debug" do
  include Helpers

  before do
    @extension = Sensu::Extension::Debug.new
  end

  it "can run, returning raw event data" do
    event = {
      :client => {},
      :check => {
        :output => "foo",
        :status => 0
      }
    }
    @extension.safe_run(event) do |output, status|
      output.should eq(event)
      status.should eq(0)
    end
  end
end
