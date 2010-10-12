require 'pilot'
require 'rails'

module Pilot    
  class Railtie < Rails::Railtie
    
    initializer "pilot.extend_activerecord" do  
      ActiveSupport.on_load(:active_record) do          
        self.extend Pilot::ActiveRecord
        self.extend Imageable::ActiveRecord
      end
    end
    
    config.after_initialize do
      if Pilot.image_class_name.present? && Pilot.image_versions_class_name.present?        
        Pilot.image_versions_class = Pilot.image_versions_class_name.constantize
        Pilot.image_class = Pilot.image_class_name.constantize
        
        Pilot.image_versions_class.extend Imageable::ImageVersion
        Pilot.image_class.extend Imageable::Image
      end
      
    end      
  end
end