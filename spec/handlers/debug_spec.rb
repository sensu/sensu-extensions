require File.join(File.dirname(__FILE__), "..", "helpers")
require "sensu/extensions/handlers/debug"

describe "Sensu::Extension::Debug" do
  include Helpers

  before do
    @extension = Sensu::Extension::Debug.new
  end

  it "can run, returning an inspected event data" do
    event = {
      :client => {},
      :check => {
        :output => "foo",
        :status => 0
      }
    }
    @extension.safe_run(event) do |output, status|
      output.should eq(event.inspect)
      status.should eq(0)
    end
  end
end
