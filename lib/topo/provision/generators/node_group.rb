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
require 'topo/utils/output'

#
# The NodeGroupGenerator class generates multiple resources depending on the node data  
#

module Topo
  module Provision
    class NodeGroupGenerator < Topo::Provision::ResourceGenerator
      include Topo::Output
      
      attr_reader :size
            
      def initialize(data, machine_generator=nil)
        @resource_type ||= "machine_batch"
         super(data)
        @template_base_name = "node_group"
        machine_data = data.clone
        @size = value_from_path(data, %w[provisioning node_group size])
        # append a number to the name if size is specified
        if !@size.nil?
          machine_data['name'] = "#{data['name']}\#{i}"          
        end
        @size ||= 1
        @machine_generator = machine_generator || Topo::Provision::MachineGenerator.new(machine_data)
      end
      
      def deploy() 
        # temporarily divert stdout & perform machine action
        machine_output = divert_stdout do
          @machine_generator.deploy
        end
        # put into batch
        puts(template("deploy").result(binding))   
      end
      
      def undeploy()
        batch_action(:undeploy)
      end
      
      def stop()
        batch_action(:stop)
      end
      
      def batch_action(action)
        machine_names = []
        1.upto @size do |i|
          machine_names << "#{name}#{@size}"
        end
        puts(template("action").result(binding))   
      end
                  
    end
  end
end
