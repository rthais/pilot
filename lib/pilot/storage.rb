require 'fog'

# This file contains code take from CarrierWave
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

    def initialize(record)
      @record = record
    end

    ##
    # Returns the current bucket of the file on S3
    #
    # === Returns
    #
    # [String] A bucket
    #
    def path
      @record.path
    end
    
    def name
      @record.s3_key
    end

    ##
    # Reads the contents of the file from S3
    #
    # === Returns
    #
    # [String] contents of the file
    #
    def read
      result = connection.get_object(path, name)
      @headers = result.headers
      result.body
    end

    ##
    # Remove the file from Amazon S3
    #
    def delete
      self.class.connection.delete_object(path, name)
    end

    ##
    # Returns the url on Amazon's S3 service
    #
    # === Returns
    #
    # [String] file's url
    #
    def url(expires = nil)
      return nil unless name.present?
      if expires.present?
        connection.get_object_url(path, name, expires.to_i)
      else      
        ["http://s3.amazonaws.com", path, name].compact.join('/')
      end
    end
    

    def store!
      content_type ||= @record._temp_file.content_type # this might cause problems if content type changes between read and upload (unlikely)
      self.class.connection.put_object(path, name, @record._temp_file.read,
        {
          'x-amz-acl' => access_policy,
          'Content-Type' => content_type
        }.merge(Pilot.headers || {})
      )
    end

    # The Amazon S3 Access policy ready to send in storage request headers.
    def access_policy
      Pilot.access_policy
    end

    def content_type
      headers["Content-Type"]
    end

    def content_type=(type)
      headers["Content-Type"] = type
    end

    def size
       headers['Content-Length'].to_i
    end

    # Headers returned from file retrieval
    def headers
      @headers ||= begin
        connection.head_object(path, name).headers
      rescue Excon::Errors::NotFound # Don't die, just return no headers
        {}
      end
    end


    def self.connection
      @connection ||= Fog::AWS::Storage.new(
        :aws_access_key_id => Pilot.key,
        :aws_secret_access_key => Pilot.secret
      )
    end
  end
end