require File.join(File.dirname(__FILE__), "..", "helpers")
require "sensu/extensions/mutators/json"

describe "Sensu::Extension::Json" do
  include Helpers

  before do
    @extension = Sensu::Extension::Json.new
  end

  it "can run, returning JSON event data" do
    event = {
      :client => {},
      :check => {
        :output => "foo",
        :status => 0
      }
    }
    @extension.safe_run(event) do |output, status|
      output.should eq(MultiJson.dump(event))
      status.should eq(0)
    end
  end
end
