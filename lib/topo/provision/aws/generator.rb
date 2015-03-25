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

require 'topo/provision/generator'

# load the resource generators
%w[aws_auto_scaling_group aws_launch_configuration load_balancer machine machine_image context node_group].each do |gen|
  require_relative 'generators/' + gen
end

module Topo
  module Provision
    class AwsGenerator < Topo::Provision::Generator
      
      self.register_generator("aws", self.name)
      
      def context()
        @context ||= Topo::Provision::AwsContextGenerator.new(@topology.provisioning,  @topology.driver)
      end
      
      def node(data)
        if (data['provisioning'])
          if(data['provisioning']['node_group'])
            node = Topo::Provision::AwsNodeGroupGenerator.new(data)
          else 
            node = Topo::Provision::AwsMachineGenerator.new(data)
          end
        else
          node = Topo::Provision::ChefNodeGenerator.new(data)
        end
        node    
      end
      
      def load_balancer(data)
        Topo::Provision::AwsLoadBalancerGenerator.new(data)
      end
      
    end
  end
end
