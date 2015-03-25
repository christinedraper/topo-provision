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

require 'tsort'

#
# The Resource Graph class sorts nodes and services based on their dependencies (topo references) 
#

module Topo
  module Provision
    class TopologyGenerator
      
      def initialize
        @dep = {}
      end
      
      # resource - the resource hash
      # depends_on - an array of resource names
      # generators - a hash of lambdas that are generator code to run for that resource
      #   keys are: :deploy :undeploy
      #   will be called as block.call resource
      def add(resource, depends_on=[], generators={})
       @dep[resource['name']] = [ resource, depends_on, generators ]
      end
      
      def tsort_each_node(&block)
        @dep.each_key(&block)
      end     
      
      def tsort_each_child(node, &block)
        resource, depends_on, gen = @dep.fetch node
        depends_on.each(&block)
      end
      
      def generate(action=:deploy)
        each_strongly_connected_component { |nodes|
          STDERR.puts "WARN: Topology contains a cyclic dependency: #{nodes.inspect}" if nodes.length > 1
          nodes.each { |node|
            resource, depends_on, gen_data = @dep.fetch node
            resource_generator = gen_data[:resource_generator]
            if resource_generator && resource_generator.respond_to?(action)
              resource_generator.send(action) 
            else
              resource_generator.send("default_action", action) 
           end
          }
        }
      end
      
      def reverse_generate(action=:undeploy)
        strongly_connected_components.reverse_each { |nodes|
          STDERR.puts "WARN: Topology contains a cyclic dependency: #{nodes.inspect}" if nodes.length > 1
          nodes.each { |node|
            resource, depends_on, gen_data = @dep.fetch node
            resource_generator = gen_data[:resource_generator]
            if resource_generator && resource_generator.respond_to?(action)
              resource_generator.send(action) 
            else
              resource_generator.send("default_action", action) 
           end
          }
        }
      end
            
      include TSort
    end
  end
end
