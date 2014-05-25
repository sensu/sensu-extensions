require "sensu/extensions/loader"

module Sensu
  module Extensions
    # Load Sensu extensions.
    #
    # @param [Hash] options
    # @option options [String] :extension_file to load.
    # @option options [String] :extension_dir to load.
    # @option options [Array] :extension_dirs to load.
    # @option options [String] :service to load extensions for.
    # @return [Loader] a loaded instance of Loader.
    def self.load(options={})
      loader = Loader.new
      if options[:extension_file]
        loader.load_file(options[:extension_file])
      end
      if options[:extension_dir]
        loader.load_directory(options[:extension_dir])
      end
      if options[:extension_dirs]
        options[:extension_dirs].each do |directory|
          loader.load_directory(directory)
        end
      end
      service = options[:service] || File.basename($0).split("-").last
      loader.load_instances(service)
      loader
    end
  end
end
