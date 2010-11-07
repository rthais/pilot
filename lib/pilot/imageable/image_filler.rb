module Pilot
  module Imageable
    class ImageFiller  
      
      @@map = {}
      @@urls = {}
      
      attr_reader :name
      
      def initialize(name, versions = [])
        @name, @versions = name, versions
      end
      
      def url
        self.class.url(@name)
      end
      
      def method_missing(method, *args, &blk)
        if @versions.include? method 
          version_name = "#{method}.#{@name}"
          ImageUrl.new self.class.url(version_name)
        else
          super
        end
      end
      
      alias_method :to_s, :url
      
      class << self
                                  
        def fill(imageable, image_class, association_name, filler_class = nil)
          load if @@map.empty?
          
          filler_class ||= imageable.class
        
          filenames = filenames_from_association(filler_class, association_name)        
          return nil unless filenames.present?        
          filename = pick(imageable, filenames)
                
          new filename, image_class.versions.keys
        end  
      
        def pick(imageable, filenames)
          index = if imageable.id.present?
            imageable.id.modulo(filenames.count)
          else 
            rand(filenames.count)
          end
          filenames[index]
        end
    
        def original_paths
          Dir[File.join(Pilot.image_fillers_original_path, "*")]
        end     
      
        def load
          @@map.clear
          original_paths.each do |path|
            basename = File.basename(path)
            (@@map[key_from_basename basename] ||= []) << basename
          end      
        end  
        alias_method :reload, :load
      
        def url(name) 
          @@urls[name] ||= Storage.url(Pilot.image_fillers_path, name)
        end
      
        # This creates and re-uploads all fillers and their versions
        def recreate!(image_class)
          remote_path = Pilot.image_fillers_path
          puts "\e[33mRecreating Fillers\e[0m..."
          original_paths.each do |p|
            file = SanitizedFile.new File.open(p, "r")
            Storage.store! remote_path, file.filename, file
            image_class.versions.each do |version, processor|              
              temp_filename = "#{version}.#{file.filename}"
              temp_file = file.clone
              Processor.process temp_file, &processor
              Storage.store! remote_path, temp_filename, temp_file              
            end
          end
          puts "\e[32mDone\e[0m."
        end
      
        protected
      
          def key_from_basename(basename)
            segments = basename.split(".")
            segments[0,2].join(".")
          end
        
          def filenames_from_association(filler_class, name)
            filenames = nil
            filler_class.lookup_ancestors.each do |ancestor|
              filenames = @@map.find { |k,v| k == "#{ancestor.name.underscore}.#{name}" }
              break unless filenames.blank?
            end
            filenames.present? ? filenames[1] : nil
          end   
      end
    end
  end
end