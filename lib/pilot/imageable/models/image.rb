module Pilot
  module Imageable  
    module Image
            
      def self.extended(base)
        base.send :include, InstanceMethods
        base.send :include, Imageable::Processor        
              
        # We associate all versions
        Pilot.image_versions_class.list.each do |version|
          base.has_one version
        end

        base.has_many :versions, :dependent => :destroy, 
          :class_name => Pilot.image_versions_class_name 

        base.belongs_to :imageable, :polymorphic => true

        base.after_create :create_versions
      end      
      
      module InstanceMethods        
        def create_versions
          version_names = imageable.class.try "#{self.class.name.underscore}_versions"
          return unless version_names.present?
          version_names.each do |v|        
            version_temp_filename = v.to_s + "-" + _temp_file.filename
            version_temp_file = _temp_file.clone(version_temp_filename)
            self.send "create_#{v.to_s}", :_temp_file => version_temp_file
          end
        end              
      end     
    end      
  end
end