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
    expect(@loader).to respond_to(:load_file, :load_directory, :load_instances,
                                  :warnings, :loaded_files, :[], :all,
                                  :bridges, :checks, :mutators, :handlers)
  end

  it "can load an extension from a file" do
    @loader.load_file(@extension_file)
    expect(@loader.warnings.size).to eq(1)
    expect(@loader.loaded_files.size).to eq(1)
    expect(@loader.loaded_files.first).to eq(File.expand_path(@extension_file))
    extension = Sensu::Extension::Test.new
    expect(extension).to respond_to(:name, :description, :definition, :safe_run, :stop, :has_key?, :[])
  end

  it "can attempt to load an extension with a script error" do
    script = File.join(@extension_dir, "error.rb")
    @loader.load_file(script)
    warnings = @loader.warnings
    expect(warnings.size).to eq(3)
    messages = warnings.map do |warning|
      warning[:message]
    end
    expect(messages).to include("loading extension file")
    expect(messages).to include("ignoring extension")
    expect(@loader.loaded_files).to be_empty
  end

  it "can load extensions from a directory" do
    @loader.load_directory(@extension_dir)
    expect(@loader.warnings.size).to eq(6)
    expect(@loader.loaded_files.size).to eq(2)
    extension = Sensu::Extension::Test.new
    expect(extension).to respond_to(:name, :description, :definition, :safe_run, :stop, :has_key?, :[])
    extension = Sensu::Extension::MockCheck.new
    expect(extension).to respond_to(:name, :description, :definition, :safe_run, :stop, :has_key?, :[])
  end

  it "can attempt to load extensions from a nonexistent directory" do
    @loader.load_directory("/tmp/bananaphone")
    expect(@loader.warnings.size).to eq(1)
    expect(@loader.loaded_files).to be_empty
  end

  it "can load instances of the built-in extensions and provide accessors" do
    @loader.load_instances
    expect(@loader.handler_exists?("debug")).to be(true)
    extension = @loader[:handlers]["debug"]
    expect(extension).to be_instance_of(Sensu::Extension::Debug)
    expect(extension).to respond_to(:name, :description, :definition, :safe_run, :stop, :has_key?, :[])
    expect(@loader.handlers).to include(extension.definition)
    expect(@loader.all).to include(extension)
    expect(@loader.mutator_exists?("json")).to be(true)
    expect(@loader.mutator_exists?("ruby_hash")).to be(true)
    expect(@loader.mutator_exists?("only_check_output")).to be(true)
  end

  it "can load instances of the built-in and loaded extensions" do
    @loader.load_file(@extension_file)
    @loader.load_instances
    expect(@loader.handler_exists?("test")).to be(true)
    extension = @loader[:handlers]["test"]
    expect(extension).to be_instance_of(Sensu::Extension::Test)
    expect(extension).to respond_to(:name, :description, :definition, :safe_run, :stop, :has_key?, :[])
    expect(@loader.handlers).to include(extension.definition)
    expect(@loader.all).to include(extension)
    expect(@loader.handler_exists?("debug")).to be(true)
    expect(@loader.mutator_exists?("only_check_output")).to be(true)
    expect(@loader.filter_exists?("attributes")).to be(true)
  end

  it "can load specific extension categories for a sensu client" do
    @loader.load_instances("client")
    expect(@loader.handler_exists?("debug")).to be(false)
    expect(@loader.mutator_exists?("only_check_output")).to be(false)
    expect(@loader.check_exists?("mock_check")).to be(true)
  end

  it "can load specific extension categories for a sensu server" do
    @loader.load_instances("server")
    expect(@loader.handler_exists?("debug")).to be(true)
    expect(@loader.mutator_exists?("only_check_output")).to be(true)
    expect(@loader.filter_exists?("attributes")).to be(true)
    expect(@loader.check_exists?("mock_check")).to be(false)
  end
end
