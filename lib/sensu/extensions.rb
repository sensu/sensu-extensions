require "sensu/extensions/loader"

module Sensu
  module Extensions
    # Load Sensu extensions.
    #
    # @param [Hash] options
    # @option options [String] :extension_file to load.
    # @option options [String] :extension_dir to load.
    # @option options [Array] :extension_dirs to load.
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
      loader.load_instances
      loader
    end
  end
end
