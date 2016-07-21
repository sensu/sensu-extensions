require "sensu/extensions/loader"

module Sensu
  module Extensions
    class << self
      # Load Sensu extensions.
      #
      # @param [Hash] options
      # @option options [String] :extension_file to load.
      # @option options [String] :extension_dir to load.
      # @option options [Array] :extension_dirs to load.
      # @return [Loader] a loaded instance of Loader.
      def load(options={})
        @loader = Loader.new
        if options[:extension_file]
          @loader.load_file(options[:extension_file])
        end
        if options[:extension_dir]
          @loader.load_directory(options[:extension_dir])
        end
        if options[:extension_dirs]
          options[:extension_dirs].each do |directory|
            @loader.load_directory(directory)
          end
        end
        if options[:extensions]
          options[:extensions].each do |name, details|
            gem_name = details[:gem] || "#{GEM_PREFIX}-#{name}"
            load_gem(gem_name, details[:version])
          end
        end
        @loader.load_instances
        @loader
      end

      # Retrieve the current loaded extensions loader or load one up
      # if there isn't one. Note: We may need to add a mutex for
      # thread safety.
      #
      # @param [Hash] options to pass to load().
      # @return [Loader] instance of a loaded loader.
      def get(options={})
        @loader || load(options)
      end
    end
  end
end
