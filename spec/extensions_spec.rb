require File.join(File.dirname(__FILE__), "helpers")
require "sensu/extensions"

describe "Sensu::Extensions" do
  include Helpers

  it "can provide the extensions API" do
    Sensu::Extensions.should respond_to(:load)
  end

  it "can provide an instance of Loader" do
    extensions = Sensu::Extensions.load
    extensions.should be_instance_of(Sensu::Extensions::Loader)
    extensions.loaded_files.should be_empty
  end

  it "can load extensions from a directory" do
    extension_dir = File.join(File.dirname(__FILE__), "assets", "extensions")
    extensions = Sensu::Extensions.load(:extension_dir => extension_dir)
    extensions.loaded_files.size.should eq(1)
    extensions.handler_exists?("test").should be_true
  end
end
