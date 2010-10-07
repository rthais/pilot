module Pilot
  module Imageable   
    
    autoload :ActiveRecord, 'pilot/imageable/activerecord'
    autoload :Image, 'pilot/imageable/models/image'
    autoload :ImageVersion, 'pilot/imageable/models/image_version'
    autoload :Processor, 'pilot/imageable/processor'      
    autoload :ImageFiller, 'pilot/imageable/image_filler'
    
   end
end