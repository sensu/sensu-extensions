require "sensu/extensions/loader"

module Sensu
  module Extensions
    def self.load(options={})
      loader = Loader.new
      if options[:extension_dir]
        loader.load_directory(options[:extension_dir])
      end
      loader.load_instances
      loader
    end
  end
end
