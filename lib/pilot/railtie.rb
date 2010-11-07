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
  end
end