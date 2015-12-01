require File.join(File.dirname(__FILE__), "..", "helpers")
require "webmock/rspec"

require "sensu/extensions/filters/silence_stashes"

describe "Sensu::Extension::SilenceStashes" do
  include Helpers

  before do
    @extension = Sensu::Extension::SilenceStashes.new
    @extension.logger = Sensu::Logger.get
    @extension.settings = {}
    stub_request(:get, %r(127\.0\.0\.1:4567/stashes/silence/.*)).
      to_return(:status => 404)
  end

  it "can run, not filtering the event by default" do
    async_wrapper do
      event = event_template
      @extension.safe_run(event) do |output, status|
        expect(output).to eq("event not silenced by an api silence stash")
        expect(status).to eq(1)
        async_done
      end
    end
  end

  it "can determine if an event is silenced for a client" do
    async_wrapper do
      event = event_template
      @extension.safe_run(event) do |output, status|
        expect(status).to eq(1)
        stub_request(:get, "127.0.0.1:4567/stashes/silence/foo").
          to_return(:status => 200)
        @extension.safe_run(event) do |output, status|
          expect(status).to eq(1)
          stub_request(:get, "127.0.0.1:4567/stashes/silence/i-424242").
            to_return(:status => 200)
          @extension.safe_run(event) do |output, status|
            expect(status).to eq(0)
            expect(output).to eq("event silenced by an api silence stash")
            async_done
          end
        end
      end
    end
  end

  it "can determine if an event is silenced for a client check" do
    async_wrapper do
      event = event_template
      @extension.safe_run(event) do |output, status|
        expect(status).to eq(1)
        stub_request(:get, "127.0.0.1:4567/stashes/silence/i-424242/foo").
          to_return(:status => 200)
        @extension.safe_run(event) do |output, status|
          expect(status).to eq(1)
          stub_request(:get, "127.0.0.1:4567/stashes/silence/i-424242/test").
            to_return(:status => 200)
          @extension.safe_run(event) do |output, status|
            expect(status).to eq(0)
            expect(output).to eq("event silenced by an api silence stash")
            async_done
          end
        end
      end
    end
  end
end
