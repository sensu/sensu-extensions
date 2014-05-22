require File.join(File.dirname(__FILE__), "..", "helpers")
require "sensu/extensions/mutators/only_check_output"

describe "Sensu::Extension::OnlyCheckOutput" do
  include Helpers

  before do
    @extension = Sensu::Extension::OnlyCheckOutput.new
  end

  it "can run, returning only check output" do
    event = {
      :client => {},
      :check => {
        :output => "foo",
        :status => 0
      }
    }
    @extension.safe_run(event) do |output, status|
      output.should eq("foo")
      status.should eq(0)
    end
  end
end
