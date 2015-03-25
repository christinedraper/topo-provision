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

#
# The ResourceGenerator class generates the recipe resources  
#

module Topo
  module Provision
    class MachineGenerator < Topo::Provision::ResourceGenerator
      
      attr_reader :machine_options, :normal_attributes, :lazy_attributes
      
      def initialize(data)
        @resource_type ||= "machine"
        super
        @undeploy_action = "destroy"
        @normal_attributes =  data['attributes']||{}
        @lazy_attributes = data['lazy_attributes']||{}
        %w[run_list chef_environment tags ].each do |key|
          @resource_attributes[key] = data[key] if data.key? key
        end
        opts = data['provisioning']['machine_options']
        @machine_options = convert_keys_to_sym(opts) if opts
      end
      
      def stop()
        puts(template("stop").result(binding))
      end
     
    end
  end
end
