require File.join(File.dirname(__FILE__), "helpers")
require "sensu/extensions"

describe "Sensu::Extensions" do
  include Helpers

  before do
    @assets_dir = File.join(File.dirname(__FILE__), "assets")
    @extension_dir = File.join(@assets_dir, "extensions")
    @extension_file = File.join(@extension_dir, "test.rb")
  end

  it "can provide the extensions API" do
    expect(Sensu::Extensions).to respond_to(:load)
  end

  it "can provide an instance of Loader" do
    extensions = Sensu::Extensions.load
    expect(extensions).to be_instance_of(Sensu::Extensions::Loader)
    expect(extensions.loaded_files).to be_empty
  end

  it "can retrive the current loaded loader" do
    extensions = Sensu::Extensions.load
    expect(Sensu::Extensions.get).to eq(extensions)
    expect(Sensu::Extensions.get).to eq(extensions)
  end

  it "can load up a loader if one doesn't exist" do
    extensions = Sensu::Extensions.get
    expect(extensions).to be_an_instance_of(Sensu::Extensions::Loader)
    expect(Sensu::Extensions.get).to eq(extensions)
  end

  it "can load an extension from a file" do
    extensions = Sensu::Extensions.load(:extension_file => @extension_file)
    expect(extensions.loaded_files.size).to eq(1)
    expect(extensions.handler_exists?("test")).to be(true)
  end

  it "can load extensions from a directory" do
    extensions = Sensu::Extensions.load(:extension_dir => @extension_dir)
    expect(extensions.loaded_files.size).to eq(3)
    expect(extensions.handler_exists?("test")).to be(true)
    expect(extensions.check_exists?("mock_check")).to be(true)
  end

  it "can load extensions from one or more directories" do
    extensions = Sensu::Extensions.load(:extension_dirs => [@extension_dir])
    expect(extensions.loaded_files.size).to eq(3)
    expect(extensions.handler_exists?("test")).to be(true)
    expect(extensions.check_exists?("mock_check")).to be(true)
  end

  it "can load the built-in extensions" do
    extensions = Sensu::Extensions.load
    expect(extensions.filter_exists?("occurrences")).to be(true)
    expect(extensions.mutator_exists?("json")).to be(true)
    expect(extensions.mutator_exists?("ruby_hash")).to be(true)
    expect(extensions.mutator_exists?("only_check_output")).to be(true)
    expect(extensions.handler_exists?("debug")).to be(true)
    expect(extensions.handler_exists?("deregistration")).to be(true)
  end

  it "can load extensions from gems" do
    options = {
      :extensions => {
        "system-profile" => {
          :version => "1.0.0"
        }
      }
    }
    extensions = Sensu::Extensions.load(options)
    expect(extensions.check_exists?("system_profile")).to be(true)
  end
end
