require 'fog'

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
  class Storage
    
    attr_reader :path, :name, :file
    attr_writer :headers, :content_type, :access_policy

    def initialize(path, name, file = nil)
      file &&= SanitizedFile.ensure_sanitized(file) 
      @path, @name, @file = path, name, file
    end
    
    def self.store!(*args)
      obj = new(*args)
      yield obj if block_given?
      obj.store!
    end
    
    def self.delete!(*args)
      new(*args).delete!
    end
    
    def self.url(*args)
      new(*args).url
    end
    
    def self.read(*args)
      new(*args).read
    end
    
    def self.connection
      @connection ||= Fog::AWS::Storage.new(
        :aws_access_key_id => Pilot.key,
        :aws_secret_access_key => Pilot.secret
      )
    end
    
    def connection
      self.class.connection
    end

    def read
      result = connection.get_object(@path, @name)
      @headers = result.headers
      result.body
    end
    
    def read_to_file
      SanitizedFile.from_blob read
    end
    
    def delete!
      connection.delete_object(@path, @name)
    end

    def url(expires = nil)
      return nil unless name.present?
      if expires.present?
        connection.get_object_url(@path, @name, expires.to_i)
      else      
        ["http://s3.amazonaws.com", @path, @name].join('/')
      end
    end
    
    def store!
      self.content_type ||= @file.content_type # this might cause problems if content type changes between read and upload (unlikely)
      connection.put_object(@path, @name, @file.read,
        {
          'x-amz-acl' => access_policy,
          'Content-Type' => content_type
        }.merge(Pilot.headers || {})
      )
    end

    # The Amazon S3 Access policy ready to send in storage request headers.
    def access_policy
      @access_policy || Pilot.access_policy
    end   
 

    def content_type
      @content_type || headers["Content-Type"]
    end

    def size
       headers['Content-Length'].to_i
    end

    # Headers returned from file retrieval
    def headers
      @headers ||= begin
        connection.head_object(@path, @name).headers
      rescue Excon::Errors::NotFound # Don't die, just return no headers
        {}
      end
    end
  end
end