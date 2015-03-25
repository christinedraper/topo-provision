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
# The NodeGroupGenerator class generates multiple resources depending on the node data  
#

module Topo
  module Provision
    class AwsNodeGroupGenerator < Topo::Provision::ResourceGenerator
            
      def initialize(data)
        super
        @resources=[]
        launch_config = Topo::Provision::AwsLaunchConfigurationGenerator.from_node(data)
        @resources << Topo::Provision::AwsMachineImageGenerator.new(data) if launch_config.needs_image?
        @resources << launch_config
        @resources << Topo::Provision::AwsAutoScalingGroupGenerator.from_node(data)
      end
      
      def deploy() 
        @resources.each do |resource|
          resource.do_action("deploy") 
        end
      end
      
      def undeploy() 
        @resources.reverse.each do |resource|
          resource.do_action("undeploy") 
        end
      end
      
      def stop()
        @resources.reverse.each do |resource|
          resource.do_action("stop") 
        end
      end
      
      def default_action(action)
        @resources.each do |resource|
          resource.do_action(action) 
        end
      end
     
    end
  end
end
