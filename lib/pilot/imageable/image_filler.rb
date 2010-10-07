module Pilot
  module Imageable
    class ImageFiller  
      
      cattr_accessor :map, :versions_model, :versions, :path
      @@map = {}
      @@versions = []
      @@versions_model= nil
      @@path = nil
      
      attr_reader :s3_key
      attr_accessor :_temp_file
            
      def initialize(s3_key)
        @s3_key = s3_key
      end
      
      def url
        storage.url
      end
      
      def storage
        @storage ||= Storage.new(self)
      end
      
      def method_missing(method, *args, &blk)
        if self.class.versions.include? method
          self.class.new self.class.filename_from_version self.s3_key, method
        else
          raise NoMethodError
        end
      end
  
      def self.fill(imageable, name)
        filenames = filenames_from_association imageable, name
        filename = pick imageable, filenames
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
        Dir[File.join(Imageable.config.image_filler_originals_path, "*")]
      end     
      
      def self.load
        @@map.clear
        original_paths.each do |path|
          basename = File.basename path
          (@@map[key_from_basename basename] ||= []) << basename
        end
      
        @@versions.clear
        @@versions += @@versions_model.list        
      end    
  
      def self.recreate!
        original_paths.each do |p|
          file = File.open(p, "r")
          ([""] + self.class.versions).each do |version|
            filler = new filename_from_version(File.basename.path, version)
            filler._temp_file = file
            filler.storage.store!
          end
        end
      end
      
      protected
      
        def self.key_from_basename(basename)
          segments = basename.split "."
          segments[0,2].join "."
        end
        
        def self.filename_from_version(original_filename, version)
          "#{version.to_s}.#{original_filename}"
        end
        
        def self.key_from_association(imageable_klass, name)
          "#{imageable_klass.name.underscore}.#{name}"
        end
        
        def self.filenames_from_association(imageable, name)
          filenames = nil
          imageable.class.lookup_ancestors.each do |ancestor|
            filenames = self.map.find { |k,v| k == key_from_association(ancestor, name) }
            break unless filenames.blank?
          end
          filenames.present? ? filenames[1] : nil
        end        
  
    end
  end
end