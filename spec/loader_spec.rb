require File.join(File.dirname(__FILE__), "helpers")
require "sensu/extensions/loader"

describe "Sensu::Extensions::Loader" do
  include Helpers

  before do
    @loader = Sensu::Extensions::Loader.new
    @assets_dir = File.join(File.dirname(__FILE__), "assets")
    @extension_dir = File.join(@assets_dir, "extensions")
    @extension_file = File.join(@extension_dir, "test.rb")
  end

  it "can provide the extensions loader API" do
    @loader.should respond_to(:load_file, :load_directory, :load_instances,
                              :warnings, :loaded_files, :[], :all,
                              :generics, :bridges, :checks, :mutators, :handlers)
  end

  it "can load an extension from a file" do
    @loader.load_file(@extension_file)
    @loader.warnings.size.should eq(1)
    @loader.loaded_files.size.should eq(1)
    @loader.loaded_files.first.should eq(File.expand_path(@extension_file))
    extension = Sensu::Extension::Test.new
    extension.should respond_to(:name, :description, :definition, :safe_run, :stop, :has_key?, :[])
  end

  it "can attempt to load an extension with a script error" do
    script = File.join(@extension_dir, "error.rb")
    @loader.load_file(script)
    warnings = @loader.warnings
    warnings.size.should eq(3)
    messages = warnings.map do |warning|
      warning[:message]
    end
    messages.should include("loading extension file")
    messages.should include("ignoring extension")
    @loader.loaded_files.should be_empty
  end

  it "can load extensions from a directory" do
    @loader.load_directory(@extension_dir)
    @loader.warnings.size.should eq(5)
    @loader.loaded_files.size.should eq(1)
    extension = Sensu::Extension::Test.new
    extension.should respond_to(:name, :description, :definition, :safe_run, :stop, :has_key?, :[])
  end

  it "can attempt to load extensions from a nonexistent directory" do
    @loader.load_directory("/tmp/bananaphone")
    @loader.warnings.size.should eq(1)
    @loader.loaded_files.should be_empty
  end

  it "can load instances of the built-in extensions and provide accessors" do
    @loader.load_instances
    @loader.handler_exists?("debug").should be_true
    extension = @loader[:handlers]["debug"]
    extension.should be_instance_of(Sensu::Extension::Debug)
    extension.should respond_to(:name, :description, :definition, :safe_run, :stop, :has_key?, :[])
    @loader.handlers.should include(extension.definition)
    @loader.all.should include(extension)
    @loader.mutator_exists?("json").should be_true
    @loader.mutator_exists?("ruby_hash").should be_true
    @loader.mutator_exists?("only_check_output").should be_true
  end

  it "can load instances of the built-in and loaded extensions" do
    @loader.load_file(@extension_file)
    @loader.load_instances
    @loader.handler_exists?("test").should be_true
    extension = @loader[:handlers]["test"]
    extension.should be_instance_of(Sensu::Extension::Test)
    extension.should respond_to(:name, :description, :definition, :safe_run, :stop, :has_key?, :[])
    @loader.handlers.should include(extension.definition)
    @loader.all.should include(extension)
    @loader.handler_exists?("debug").should be_true
    @loader.mutator_exists?("only_check_output").should be_true
  end
end
