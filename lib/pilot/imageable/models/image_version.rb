module Pilot
  module Imageable  
    module ImageVersion           
      
      def self.extended(base)
        base.send :include, Imageable::Processor
        base.belongs_to :image, :class_name => Pilot.image_class_name 
        base.before_upload :process
      end

      def list
        @list ||= descendants.map do |d| 
          d.name.underscore.to_sym
        end
      end            
    end    
  end
end