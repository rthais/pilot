module Pilot
  module Imageable  
    module Image
            
      def self.extended(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods        
        base.class_inheritable_hash :versions              
        base.versions = {}.with_indifferent_access
        base.belongs_to :imageable, :polymorphic => true
        base.after_create :create_versions!
      end   
    
      module ClassMethods        
        def version(*args, &proc)
          proc ||= args.last
          unless proc.is_a? Proc
            raise ArgumentError
          end
          self.versions[args.first] = proc
        end                
      end
    
      module InstanceMethods
        def method_missing(method, *args, &blk)
          if versions.keys.include? method 
            version_name = "#{method}_#{name}"
            url = Storage.url versions_path, version_name
            ImageUrl.new url
          else
            super
          end
        end
        
        def respond_to?(*args)
          return true if versions.keys.include? args[0]
          super
        end
           
        def process(file = nil, &blk)
          file ||= self._temp_file
          Processor.process(file, &blk)
        end

        def create_versions!
          version_names = imageable.class.try "#{self.class.name.underscore}_versions"
          return unless version_names.present?
          version_names.each { |v| create_version!(v) }
        end 
        
        def create_version!(version, &processor)   
          processor ||= versions[version]
          key = "#{version}_#{self.name}"
          filename =  "#{version}_#{_temp_file.filename}"
          file = _temp_file.dup
          process file, &processor
          Storage.store! versions_path, key, file
        end
        
        def recreate_version!(version, &processor)   
          self._temp_file = self.storage.read_to_file
          create_version! version, &processor     
        end

        def recreate_versions!
          self._temp_file = self.storage.read_to_file
          create_versions!
        end
        
        def filler?
          false
        end
                                     
      end        
    end#Image      
  end#Imageable
end#Pilot