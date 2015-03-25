#
# Author:: Christine Draper (<christine_draper@thirdwaveinsights.com>)
# Copyright:: Copyright (c) 2015 ThirdWave Insights LLC
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# The converter class converts data in a given format into raw "topo" format data
#

require 'topo/utils/parsegen'

module Topo
  class Converter
    
    include Topo::ParseGen

    attr_accessor :topology

    # Converters for each format
    @@converter_classes = {}

    def self.register_converter(format, class_name)
      @@converter_classes[format] = class_name
    end

    self.register_converter("default", self.name)
    self.register_converter("topo", self.name)

    # Get the right converter for the input format
    def self.converter(format)
      converter_class = @@converter_classes[format]

      unless converter_class
        begin
          require "topo/converter/#{format}/converter"
          converter_class = @@converter_classes[format]
        rescue LoadError
          STDERR.puts("#{format} is not a known format for the topology file")
          exit 1
        end
      end

      Object::const_get(converter_class).new(format)
    end

    def self.convert(data, format)
      converter = self.converter(format)
      converter.convert(data)
    end

    attr_accessor :input
    
    def initialize(format, data=nil)
      @format = format
      @input = data
      @output = { "nodes" => [], "services" => [], "network" => [], "provisioning" => {} }
    end
    
    # Other format converters should override this method to convert to topo format data
    def convert(data=nil)
      @input = data if data
      @output = @input
      @output
    end

  end
end
