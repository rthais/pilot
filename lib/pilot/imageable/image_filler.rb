module Pilot
  module Imageable
    class ImageFiller  
      
      cattr_accessor :map, :path, :loaded
      @@map = {}
      @@path = nil
      @@loaded = false
      
      attr_reader :s3_key
      attr_accessor :_temp_file
            
      def initialize(s3_key)
        @s3_key = s3_key
      end
      
      def path
        Pilot.image_fillers_path
      end
      
      def url
        storage.url
      end
      
      def filler? 
        true
      end
      
      def storage
        @storage ||= Storage.new(self)
      end
      
      def method_missing(method, *args, &blk)
        if Pilot.image_versions_class.list.include? method
          self.class.new self.class.filename_from_version(self.s3_key, method)
        else
          raise NoMethodError
        end
      end
  
      def self.fill(imageable, version_name, imageable_class = nil)
        load! unless self.loaded
        
        filler_class = if imageable_class.is_a? Class
          imageable_class
        else
          imageable.class
        end        
        
        filenames = filenames_from_association(filler_class, version_name)        
        return nil unless filenames.present?        
        filename = pick(imageable, filenames)
        self.new filename
      end  
      
      def self.pick(imageable, filenames)
        index = if imageable.id.present?
          imageable.id.modulo(filenames.count)
        else 
          rand(filenames.count)
        end
        puts 
        filenames[index]
      end
    
      def self.original_paths
        Dir[File.join(Pilot.image_fillers_original_path, "*")]
      end     
      
      def self.load!
        @@map.clear
        original_paths.each do |path|
          basename = File.basename(path)
          (@@map[key_from_basename basename] ||= []) << basename
        end
        self.loaded = true        
      end  
      alias_method :load!, :reload!  
      
      # This creates and re-uploads all filler and their versions
      def self.recreate!
        original_paths.each do |p|
          file = SanitizedFile.new File.open(p, "r")
          ([""] + Pilot.image_versions_class.list).each do |version_name|
            unless version_name.blank?
              version_temp_filename = filename_from_version(file.filename, version_name)
              version_temp_file = file.clone(version_temp_filename)
              version = version_name.to_s.classify.constantize.new :_temp_file => version_temp_file
              version.process
            else
              version_temp_filename = file.filename
              version_temp_file = file
            end
            filler = self.new(version_temp_filename)
            filler._temp_file = version_temp_file
            filler.storage.store!
          end
        end
      end
      
      protected
      
        def self.key_from_basename(basename)
          segments = basename.split(".")
          segments[0,2].join(".")
        end
        
        def self.filename_from_version(filename, version)
          "#{version.to_s}.#{filename}"
        end
        
        def self.key_from_association(imageable_class, name)
          "#{imageable_class.name.underscore}.#{name}"
        end
        
        def self.filenames_from_association(imageable_class, name)
          filenames = nil
          imageable_class.lookup_ancestors.each do |ancestor|
            filenames = self.map.find { |k,v| k == key_from_association(ancestor, name) }
            break unless filenames.blank?
          end
          filenames.present? ? filenames[1] : nil
        end   
    end
  end
end