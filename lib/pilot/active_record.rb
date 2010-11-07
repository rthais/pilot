module Pilot
  module ActiveRecord
    
    def stores(*args)            
      include InstanceMethods

      options = args.extract_options!
      options.assert_valid_keys [:with, :at]

      class_attribute :path, :instance_writer => false  
      self.path = options[:at]  

      accessor = args[0].try(:to_s) || 'file'  
      
      alias_attribute accessor, :_temp_file      
      attr_writer  :_temp_file        
          
      validates_presence_of :_temp_file    

      define_model_callbacks :upload                
      before_create :upload    

      # destroy file
      after_destroy { self.storage.delete! }    
    end                      
  
    module InstanceMethods     
    
      def storage
        @storage ||= Storage.new(path, name, _temp_file)        
      end

      # Make sure we always get a SanitizedFile back
      # The SanitizedFile  will return the 
      # passed object intact if it's already a SanitizedFile
      def _temp_file
        if @_temp_file.present?      
          @_temp_file = SanitizedFile.ensure_sanitized @_temp_file
        end
      end

      def upload
        _run_upload_callbacks do
          begin
            self.name = "#{SecureRandom.hex(8)}-#{self._temp_file.filename}"
            self.storage.store!
            self.url = self.storage.url
          rescue => e
            errors[:base] << "could not upload the file"
            false
          end
        end
      end
    end
  end
end