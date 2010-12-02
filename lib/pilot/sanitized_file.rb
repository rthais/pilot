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

require 'pathname'

module Pilot

  ##
  # SanitizedFile is a base class which provides a common API around all
  # the different quirky Ruby File libraries. It has support for Tempfile,
  # File, StringIO, Merb-style upload Hashes, as well as paths given as
  # Strings and Pathnames.
  #
  class SanitizedFile
    
    attr_accessor :file
    
    def self.ensure_sanitized(file)
      return file if file.is_a? self.class
      self.new file
    end
    
    def self.from_blob(blob)
      tempfile do |tmp|
        tmp.write blob
      end
    end
    
    def self.tempfile(name = nil)
      name ||= SecureRandom.hex(4)
      temp = Tempfile.new(name).tap do |file|
        file.class_eval { attr_accessor :original_filename }
        file.original_filename = name
        file.binmode
        yield file if block_given?
      end
      self.new temp
    end

    def initialize(file)
      self.file = file      
      # Move a file to a location where its filename won't wreak havoc 
      # if called in a shell command (like mogrify)
      self.move_to File.join(File.dirname(path), filename)
    end

    # Returns the filename, sanitized to strip out any evil characters.
    #
    # === Returns
    #
    # [String] the sanitized filename
    #
    def filename
      sanitize(original_filename) if original_filename
    end

    alias_method :identifier, :filename

    ##
    # Returns the part of the filename before the extension. So if a file is called 'test.jpeg'
    # this would return 'test'
    #
    # === Returns
    #
    # [String] the first part of the filename
    #
    def basename
      split_extension(filename)[0] if filename
    end

    ##
    # Returns the file extension
    #
    # === Returns
    #
    # [String] the extension
    #
    def extension
      split_extension(filename)[1] if filename
    end

    ##
    # Returns the file's size.
    #
    # === Returns
    #
    # [Integer] the file's size in bytes.
    #
    def size
      if is_path?
        exists? ? File.size(path) : 0
      elsif @file.respond_to?(:size)
        @file.size
      elsif path
        exists? ? File.size(path) : 0
      else
        0
      end
    end

    ##
    # === Returns
    #
    # [Boolean] whether the file is supplied as a pathname or string.
    #
    def is_path?
      !!((@file.is_a?(String) || @file.is_a?(Pathname)) && !@file.blank?)
    end

    ##
    # === Returns
    #
    # [Boolean] whether the file is valid and has a non-zero size
    #
    def empty?
      @file.nil? || self.size.nil? || self.size.zero?
    end

    alias_method :blank?, :empty?

    ##
    # === Returns
    #
    # [Boolean] Whether the file exists
    #
    def exists?
      return File.exists?(path) if path
      return false
    end

    ##
    # Returns the contents of the file.
    #
    # === Returns
    #
    # [String] contents of the file
    #
    def read(*args)
      if is_path?
        File.open(@file, "rb").read(*args)
      else
        # Rewind only if there are no args        
        if args.blank? && @file.respond_to?(:rewind)
          @file.rewind 
        end
        @file.read(*args)
      end
    end

    ##
    # Moves the file to the given path
    #
    # === Parameters
    #
    # [new_path (String)] The path where the file should be moved.
    # [permissions (Integer)] permissions to set on the file in its new location.
    #
    def move_to(new_path, permissions=nil)
      return if self.empty?
      new_path = File.expand_path(new_path)

      mkdir!(new_path)
      if exists?
        FileUtils.mv(path, new_path) unless new_path == path
      else
        File.open(new_path, "wb") { |f| f.write(read) }
      end
      chmod!(new_path, permissions)
      self.file = new_path
    end
    
    ##
    # Returns the full path to the file. If the file has no path, it will return nil.
    #
    # === Returns
    #
    # [String, nil] the path where the file is located.
    #
    def path
      unless @file.blank?
        if is_path?
          File.expand_path(@file)
        elsif @file.respond_to?(:path) and not @file.path.blank?
          File.expand_path(@file.path)
        end
      end
    end   
    
    ##
    # Returns the filename as is, without sanizting it.
    #
    # === Returns
    #
    # [String] the unsanitized filename
    #
    def original_filename
      return @original_filename if @original_filename
      if @file and @file.respond_to?(:original_filename)
        @file.original_filename
      elsif path
        File.basename(path)
      end
    end

    ##
    # Creates a copy of this file and moves it to the given path. Returns the copy.
    #
    # === Parameters
    #
    # [new_path (String)] The path where the file should be copied to.
    # [permissions (Integer)] permissions to set on the copy
    #
    # === Returns
    #
    # @return [Pilot::SanitizedFile] the location where the file will be stored.
    #
    def copy_to(new_path, permissions=nil)
      return if self.empty?
      new_path = File.expand_path(new_path)

      mkdir!(new_path)
      if exists?
        FileUtils.cp(path, new_path) unless new_path == path
      else
        File.open(new_path, "wb") { |f| f.write(read) }
      end
      chmod!(new_path, permissions)
      self.class.new({:tempfile => new_path, :content_type => content_type})
    end
    
    
    def clone
      self.class.tempfile do |file|
        file.write self.read
      end
    end

    ##
    # Removes the file from the filesystem.
    #
    def delete
      FileUtils.rm(path) if exists?
    end

    ##
    # Returns the content type of the file.
    #
    # === Returns
    #
    # [String] the content type of the file
    #
    def content_type
      return @content_type if @content_type
      @file.content_type.chomp if @file.respond_to?(:content_type) and @file.content_type
    end
    
    def close
      unless is_path?
        @file.close if @file.respond_to?(:close)
      end
    end
    

  private

    def file=(file)
      if file.is_a?(Hash)
        @file = file["tempfile"] || file[:tempfile]
        @original_filename = file["filename"] || file[:filename]
        @content_type = file["content_type"] || file[:content_type]
      else
        @file = file
        @original_filename = nil
        @content_type = nil
      end
    end

    # create the directory if it doesn't exist
    def mkdir!(path)
      FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))
    end

    def chmod!(path, permissions)
      File.chmod(permissions, path) if permissions
    end

    # Sanitize the filename, to prevent hacking
    def sanitize(name)
      name = name.gsub("\\", "/") # work-around for IE
      name = File.basename(name)
      name = name.gsub(/[^a-zA-Z0-9\.\-\+_]/,"_")
      name = "_#{name}" if name =~ /\A\.+\z/
      name = "unnamed" if name.size == 0
      return name.downcase
    end

    def split_extension(filename)
      # regular expressions to try for identifying extensions
      extension_matchers = [
/\A(.+)\.(tar\.gz)\z/, # matches "something.tar.gz"
/\A(.+)\.([^\.]+)\z/ # matches "something.jpg"
      ]

      extension_matchers.each do |regexp|
        if filename =~ regexp
          return $1, $2
        end
      end
      return filename, "" # In case we weren't able to split the extension
    end
  end 
end 