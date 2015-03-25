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
    
    class AwsLoadBalancerGenerator < Topo::Provision::LoadBalancerGenerator
           
      def initialize(data)
        super
        @undeploy_action = "destroy"
        %w[machines].each do |key|
          @resource_attributes[key] = data['provisioning'][key] if data['provisioning'].key? key
        end
        
        lbopts =  (data['provisioning']|| {})['load_balancer_options'] 
        if(lbopts)
          lbopts = convert_keys_to_sym_deep(lbopts)
          if (lbopts[:listeners])
             lbopts[:listeners].each_with_index do |listener, index|
              lbopts[:listeners][index] = convert_keys_to_sym(listener)
             end
          end
          @resource_attributes['load_balancer_options'] = lbopts
        end
      end
     
    end
  end
end
