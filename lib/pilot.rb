require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/callbacks'
require 'fog'

require 'pilot/railtie'

module Pilot
  autoload :Base, 'pilot/base'
  autoload :Imageable, 'pilot/imageable'
  autoload :Storage, 'pilot/storage'
  autoload :SanitizedFile, 'pilot/sanitized_file'
  
  def self.configure
    yield Railtie
  end
  
  def self.config
    Railtie.config
  end
  
end
