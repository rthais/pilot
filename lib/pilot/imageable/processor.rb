# This file contains code taken from CarrierWave
#
# Copyright (c) 2008 Jonas Nicklas
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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