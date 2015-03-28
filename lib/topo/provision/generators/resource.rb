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

require 'topo/utils/parsegen'

#
# The ResourceGenerator class generates the recipe resources  
#

module Topo
  module Provision

    class ResourceGenerator
      include Topo::ParseGen
           
      attr_reader :resource_type, :name, :resource_attributes, :undeploy_action
      @@templates = {}

      def initialize(data)
        @resource_type||= "resource"  # define in each class
        @template_base_name = @resource_type
        @undeploy_action = "destroy"
        @resource_attributes = {}  # define in each class
        @name = data['name']
        provisioning = data['provisioning']
        %w[ driver chef_server].each do |key|
          @resource_attributes[key] = provisioning[key] if provisioning && provisioning.key?(key)
        end
      end
      
      def do_action(action)
        if (self.respond_to? action)
          self.send(action) 
        else
          self.send("default_action", action) 
        end
      end

      def deploy()
        puts(template("deploy").result(binding))
      end
      
      def undeploy()
        puts(template("undeploy").result(binding))
      end
      
      def default_action(action)
      end
      
      def template_root_dir
        File.expand_path("../templates", __FILE__)
      end
      
      def default_resource_template(action)
        default = "resource_#{action}"
        if @@templates[default] == nil
          path = File.join(File.expand_path("../templates", __FILE__), "#{default}.erb")
          @@templates[default] = ERB.new(File.new(path).read, nil, '>')
        end        
        @@templates[default]
      end

  
      def template(action)
       name = "#{@template_base_name}_#{action}"
       if (@@templates[name] == nil)
          path = File.join(template_root_dir, "#{name}.erb")
          @@templates[name] = File.exists?(path) ? ERB.new(File.new(path).read, nil, '>') :
            default_resource_template(action)       
        end
        @@templates[name]
      end
  
    end
  end
end
