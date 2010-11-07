module Pilot
  module Imageable   
    
    autoload :ActiveRecord, 'pilot/imageable/active_record'
    autoload :Image, 'pilot/imageable/image'
    autoload :Processor, 'pilot/imageable/processor'      
    autoload :ImageFiller, 'pilot/imageable/image_filler'
    autoload :ImageUrl, 'pilot/imageable/image_url'
    
   end
end