require 'active_support/dependencies'
require 'active_record'

require 'pilot/railtie'

module Pilot  
  
  autoload :ActiveRecord, 'pilot/activerecord'
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
  @@headers = { 'Cache-Control' => 'public,max-age=86400000' }
  
  mattr_accessor :image_class_name
  @@image_class_name = nil
  
  mattr_accessor :image_versions_class_name
  @@image_versions_class_name = nil
  
  mattr_accessor :image_class
  @@image_class = nil
  
  mattr_accessor :image_versions_class
  @@image_versions_class = nil
  
  mattr_accessor :image_fillers_original_path
  @@image_fillers_original_path = nil
  
  mattr_accessor :image_fillers_path
  @@image_fillers_path = nil
  
  def self.configure
    yield self
  end

end
