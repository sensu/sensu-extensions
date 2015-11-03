require "sensu/extension"
require "sensu/extensions/mutators/json"
require "sensu/extensions/mutators/ruby_hash"
require "sensu/extensions/mutators/only_check_output"
require "sensu/extensions/handlers/debug"

module Sensu
  module Extensions
    class Loader
      # @!attribute [r] warnings
      #   @return [Array] loader warnings.
      attr_reader :warnings

      # @!attribute [r] loaded_files
      #   @return [Array] loaded extension files.
      attr_reader :loaded_files

      def initialize
        @warnings = []
        @loaded_files = []
        @extensions = {}
        Extension::CATEGORIES.each do |category|
          @extensions[category] = {}
        end
        self.class.create_category_methods
      end

      # Create extension category accessors and methods to test the
      # existence of extensions. Called in initialize().
      def self.create_category_methods
        Extension::CATEGORIES.each do |category|
          define_method(category) do
            extension_category(category)
          end
          method_name = category.to_s.chop + "_exists?"
          define_method(method_name.to_sym) do |name|
            extension_exists?(category, name)
          end
        end
      end

      # Retrieve the extension object corresponding to a key, acting
      # like a Hash object.
      #
      # @param key [Symbol]
      # @return [Object] value for key.
      def [](key)
        @extensions[key]
      end

      # Retrieve all extension instances.
      #
      # @return [Array<object>] extensions.
      def all
        @extensions.map { |category, extensions|
          extensions.map { |name, extension|
            extension
          }.uniq
        }.flatten
      end

      # Load an extension from a file.
      #
      # @param [String] file path.
      def load_file(file)
        warning("loading extension file", :file => file)
        begin
          require File.expand_path(file)
          @loaded_files << file
        rescue ScriptError, StandardError => error
          warning("failed to require extension", :file => file, :error => error)
          warning("ignoring extension", :file => file)
        end
      end

      # Load extensions from files in a directory. Files may be in
      # nested directories.
      #
      # @param [String] directory path.
      def load_directory(directory)
        warning("loading extension files from directory", :directory => directory)
        path = directory.gsub(/\\(?=\S)/, "/")
        Dir.glob(File.join(path, "**{,/*/**}/*.rb")).each do |file|
          load_file(file)
        end
      end

      # Load instances of the loaded extensions.
      #
      # @param [String] sensu service to load extensions for.
      def load_instances(service=nil)
        service ||= sensu_service_name
        categories_to_load(service).each do |category|
          extension_type = category.to_s.chop
          Extension.const_get(extension_type.capitalize).descendants.each do |klass|
            extension = klass.new
            @extensions[category][extension.name] = extension
            if extension.name_alias
              @extensions[category][extension.name_alias] = extension
            end
            warning("loaded extension", {
              :type => extension_type,
              :name => extension.name,
              :description => extension.description
            })
          end
        end
      end

      private

      # Retrieve extension category definitions.
      #
      # @param [Symbol] category to retrive.
      # @return [Array<Hash>] category definitions.
      def extension_category(category)
        @extensions[category].map { |name, extension|
          extension.definition
        }.uniq
      end

      # Check to see if an extension exists in a category.
      #
      # @param [Symbol] category to inspect for the extension.
      # @param [String] name of extension.
      # @return [TrueClass, FalseClass]
      def extension_exists?(category, name)
        @extensions[category].has_key?(name)
      end

      # Retrieve Sensu service name.
      #
      # @return [String] service name.
      def sensu_service_name
        File.basename($0).split("-").last
      end

      # Determine which extension categories to load for the given
      # sensu service.
      #
      # @param [String] sensu service to load extensions for.
      # @return [Array] extension categories.
      def categories_to_load(service)
        case service
        when "client"
          [:checks]
        when "server"
          Extension::CATEGORIES.reject { |category| category == :checks }
        else
          Extension::CATEGORIES
        end
      end

      # Record a warning.
      #
      # @param message [String] warning message.
      # @param data [Hash] warning context.
      # @return [Array] current warnings.
      def warning(message, data={})
        @warnings << {
          :message => message
        }.merge(data)
      end
    end
  end
end
