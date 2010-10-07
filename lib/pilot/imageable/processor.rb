module Pilot
  module Imageable
    module Processor
            
      def resize_to_limit(width, height)
        manipulate! do |img|
          img.resize "#{width}x#{height}>"
          img = yield(img) if block_given?
          img
        end
      end
    
      def resize_to_fill(width, height, gravity = 'Center')
        manipulate! do |img|
          cols, rows = img[:dimensions]
          img.combine_options do |cmd|
            if width != cols || height != rows
              scale = [width/cols.to_f, height/rows.to_f].max
              cols = (scale * (cols + 0.5)).round
              rows = (scale * (rows + 0.5)).round
              cmd.resize "#{cols}x#{rows}"
            end
            cmd.gravity gravity
            cmd.extent "#{width}x#{height}" if cols != width || rows != height
          end
          img = yield(img) if block_given?
          img
        end
      end
    
      def convert(format)
        manipulate! do |img|
          img.format(format.to_s.downcase)
          img = yield(img) if block_given?
          img
        end
      end
  
      def manipulate!
        image = ::MiniMagick::Image.from_file(self._temp_file.path)
        image = yield(image)
        image.write(self._temp_file.path)
        # rescue ::MiniMagick::Error => e    
      end
      
    end
  end
end