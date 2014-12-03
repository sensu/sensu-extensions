require File.join(File.dirname(__FILE__), "..", "helpers")
require "sensu/extensions/filters/attributes"

describe "Sensu::Extension::Attributes" do
  include Helpers

  before do
    @extension = Sensu::Extension::Attributes.new
    @extension.logger = logger
    @extension.settings = settings
  end

  it "can determine if filter attributes match an event" do
    attributes = {
      :occurrences => 1
    }
    event = event_template
    expect(@extension.attributes_match?(attributes, event)).to be(true)
    event[:occurrences] = 2
    expect(@extension.attributes_match?(attributes, event)).to be(false)
    attributes[:occurrences] = "eval: value == 1 || value % 60 == 0"
    event[:occurrences] = 1
    expect(@extension.attributes_match?(attributes, event)).to be(true)
    event[:occurrences] = 2
    expect(@extension.attributes_match?(attributes, event)).to be(false)
    event[:occurrences] = 120
    expect(@extension.attributes_match?(attributes, event)).to be(true)
  end

  it "can run, filtering an event with a nonexistent filter" do
    event = event_template
    options = {:filter_name => "nonexistent"}
    @extension.safe_run(event, options) do |output, status|
      expect(output).to eq("")
      expect(status).to eq(1)
    end
  end

  it "can run, filtering an event with a filter" do
    event = event_template
    event[:client][:environment] = "development"
    options = {:filter_name => "production"}
    @extension.safe_run(event, options) do |output, status|
      expect(output).to eq("")
      expect(status).to eq(0)
      event[:client][:environment] = "production"
      @extension.safe_run(event, options) do |output, status|
        expect(output).to eq("")
        expect(status).to eq(1)
      end
    end
  end
end
