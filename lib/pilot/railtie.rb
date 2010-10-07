module Pilot
    
  class Railtie < Rails::Railtie
    
    initializer "pilot.extend_activerecord" do           
 #     ActiveRecord::Base.extend(Base::ClassMethods)
#      ActiveRecord::Base.extend(Imageable)
    end
    
    config.after_initialize do
      puts Photo
    end
      
  end

end