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
    
    class LoadBalancerGenerator < Topo::Provision::ResourceGenerator
      include Topo::ParseGen
           
      def initialize(data)
        @resource_type ||= "load_balancer"
        super
        @undeploy_action = "destroy"
        %w[machines load_balancer_options].each do |key|
          @resource_attributes[key] = data['provisioning'][key] if data['provisioning'].key? key
        end
        
        # Note: driver-specific classes may need to convert load_balancer_options into symbols
      end
     
    end
  end
end
