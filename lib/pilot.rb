require 'active_support/dependencies'
require 'active_record'

require 'pilot/railtie'

module Pilot  
  
  autoload :ActiveRecord, 'pilot/active_record'
  autoload :Imageable, 'pilot/imageable'
  autoload :Storage, 'pilot/storage'
  autoload :SanitizedFile, 'pilot/sanitized_file'
    
  mattr_accessor :key
  @@key = nil
  
  mattr_accessor :secret
  @@secret = nil
  
  mattr_accessor :access_policy
  @@access_policy = 'public-read'
  
  mattr_accessor :headers
  @@headers = { }
    
  mattr_accessor :image_fillers_original_path
  @@image_fillers_original_path = nil
  
  mattr_accessor :image_fillers_path
  @@image_fillers_path = nil
  
  mattr_accessor :perform_deletions
  @@perform_deletions = false
      
  def self.configure
    yield self
  end
  
end
