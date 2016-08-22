gem "sensu-extensions-occurrences", "1.1.0"
gem "sensu-extensions-json", "1.0.0"
gem "sensu-extensions-ruby-hash", "1.0.0"
gem "sensu-extensions-only-check-output", "1.0.0"
gem "sensu-extensions-debug", "1.0.0"

require "sensu/extension"
require "sensu/extensions/constants"
require "sensu/extensions/occurrences"
require "sensu/extensions/json"
require "sensu/extensions/ruby-hash"
require "sensu/extensions/only-check-output"
require "sensu/extensions/debug"

module Sensu
  module Extensions
    class Loader
      # @!attribute [r] warnings
      #   @return [Array] loader warnings.
      attr_reader :warnings

      # @!attribute [r] loaded_files
      #   @return [Array] loaded extension files.
      attr_reader :loaded_files

      # @!attribute [r] loaded_gems
      #   @return [Array] loaded extension gems.
      attr_reader :loaded_gems

      def initialize
        @warnings = []
        @loaded_files = []
        @loaded_gems = []
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

      # Load an extension from a Rubygem.
      #
      # @param [String] gem name.
      def load_gem(raw_gem, version=nil)
        warning("loading extension gem", :gem => raw_gem, :version => version)
        begin
          gem(raw_gem, version) if version
          if raw_gem.start_with?(GEM_PREFIX)
            lib = raw_gem.sub(/^#{GEM_PREFIX}/, "")
            require_path = "sensu/extensions/#{lib}"
          else
            require_path = raw_gem
          end
          warning("requiring extension gem", :require => require_path)
          require require_path
          @loaded_gems << raw_gem
        rescue ScriptError, StandardError => error
          warning("failed to require extension", {
            :gem => raw_gem,
            :version => version,
            :error => error
          })
          warning("ignoring extension", :gem => raw_gem)
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
