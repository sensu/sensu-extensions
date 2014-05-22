require "sensu/extension"

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
        @loaded_files = []
        @warnings = []
      end

      # Load an extension from a file.
      #
      # @param [String] file path.
      def load_file(file)
        warning(file, "loading extension file")
        begin
          require File.expand_path(file)
          @loaded_files << file
        rescue ScriptError, StandardError => error
          warning(file, "failed to require extension: #{error}")
          warning(file, "ignoring extension")
        end
      end

      # Load extensions from files in a directory. Files may be in
      # nested directories.
      #
      # @param [String] directory path.
      def load_directory(directory)
        warning(directory, "loading extension files from directory")
        path = directory.gsub(/\\(?=\S)/, "/")
        Dir.glob(File.join(path, "**/*.rb")).each do |file|
          load_file(file)
        end
      end

      private

      # Record a warning for an object.
      #
      # @param object [Object] under suspicion.
      # @param message [String] warning message.
      # @return [Array] current warnings.
      def warning(object, message)
        @warnings << {
          :object => object,
          :message => message
        }
      end
    end
  end
end
