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
    Sensu::Extensions.should respond_to(:load)
  end

  it "can provide an instance of Loader" do
    extensions = Sensu::Extensions.load
    extensions.should be_instance_of(Sensu::Extensions::Loader)
    extensions.loaded_files.should be_empty
  end

  it "can load an extension from a file" do
    extensions = Sensu::Extensions.load(:extension_file => @extension_file)
    extensions.loaded_files.size.should eq(1)
    extensions.handler_exists?("test").should be_true
  end

  it "can load extensions from a directory" do
    extensions = Sensu::Extensions.load(:extension_dir => @extension_dir)
    extensions.loaded_files.size.should eq(1)
    extensions.handler_exists?("test").should be_true
  end

  it "can load extensions from one or more directories" do
    extensions = Sensu::Extensions.load(:extension_dirs => [@extension_dir])
    extensions.loaded_files.size.should eq(1)
    extensions.handler_exists?("test").should be_true
  end

  it "can load the built-in extensions" do
    extensions = Sensu::Extensions.load
    extensions.mutator_exists?("only_check_output").should be_true
    extensions.handler_exists?("debug").should be_true
  end
end
