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

require 'json'

module Topo
  class Topology

    attr_accessor :nodes, :provisioning, :driver, :services, :network, :format
    attr_reader :raw_data
    
    def initialize(raw_data)
      @raw_data = raw_data
       
       data = Marshal.load(Marshal.dump(raw_data))
       @provisioning = data['provisioning'] || {}
       if @provisioning['driver']
         @driver = @provisioning['driver'].split(":",2)[0]
       else
         @driver = "default"
       end
       @nodes = data['nodes'] || []
       @services = data['services'] || []
       @network = data['network'] || []

       @nodes.each do |node|
         parse_node node
       end      
    end

     def parse_node(node)
      node['attributes'] = node['normal'] if node['normal']
      node['attributes'] ||= {}
  
      node['lazy_attributes'] ||= {}
    end
      
    def to_file(file)
      begin
        File.open(file, 'w') { |f| f.write(JSON.pretty_generate(@raw_data)) }    
      rescue => e
        STDERR.puts "ERROR: Cannot write to topology export file #{file} - #{e.message}"
      end
    end
  end
end
