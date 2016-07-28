module Sensu
  module Extensions
    unless defined?(Sensu::Extensions::GEM_PREFIX)
      # Sensu Extension Rubygem prefix.
      GEM_PREFIX = "sensu-extensions-".freeze
    end
  end
end
