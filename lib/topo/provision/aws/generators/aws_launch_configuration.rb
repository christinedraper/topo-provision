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
    class AwsLaunchConfigurationGenerator < Topo::Provision::ResourceGenerator
      extend Topo::ParseGen
            
      def initialize(data, image_id=nil)
        @resource_type ||= "aws_launch_configuration"
        super(data)
        @image_id = image_id || value_from_path(data, %w[options image_id])

        %w[image instance_type options].each do |key|
          @resource_attributes[key] = data[key] if data.key? key
        end 
      end
      
      def needs_image?
        @image_id.nil?
      end
     
      def self.from_node(node)
        auto_scaling = value_from_path(node, %w[provisioning  node_group  auto_scaling]) || {}
        options = auto_scaling['launch_configuration_options']
        bootstrap_options = value_from_path(node, %w[provisioning machine_options bootstrap_options])
        options ||= bootstrap_options      
        image_id = options['image_id']
        options.delete('image_id')
           
        lc_data = { 
          "name" => auto_scaling['launch_configuration_name'] ||  node['name'] + "_config",
          "image" => image_id || auto_scaling['image'] || node['name'] + "_image"
        }
  
        %w[instance_type].each do |key|
          lc_data[key] = auto_scaling[key] if auto_scaling.key? key
        end 
              
        if options
         lc_data['options'] = convert_keys_to_sym_deep(options)
        end  
        
        self.new(lc_data, image_id)
       end
    end
  end
end
