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

require 'topo/provision/generators/resource'

module Topo
  module Provision
    class AwsAutoScalingGroupGenerator < Topo::Provision::ResourceGenerator
      extend Topo::ParseGen
           
      def initialize(data)
        @resource_type ||= "aws_auto_scaling_group"
        super
        %w[launch_configuration max_size min_size desired_capacity availability_zones load_balancers options].each do |key|
          @resource_attributes[key] = data[key] if data.key? key
        end       
      end
      
      def self.from_node(node)
        auto_scaling = value_from_path(node, %w[provisioning  node_group  auto_scaling]) || {}
            
        group_data = { 
          "name" => auto_scaling['group_name'] ||  node['name'] + "_group",
          "launch_configuration" => auto_scaling['launch_configuration'] ||  node['name'] + "_config"
        }

        %w[max_size min_size desired_capacity availability_zones load_balancers].each do |key|
          group_data[key] = auto_scaling[key] if auto_scaling.key? key
        end 
              
        options = auto_scaling['group_options']
        if options
           # we also need to convert some of the field values in options, and then all of the keys  
           %w[health_check_type].each do |key|
             options[key] = options[key].to_sym if options.key? key
           end
           group_data['options'] = convert_keys_to_sym_deep(options)
        end    
        
        self.new(group_data)
       end

     
    end
  end
end
