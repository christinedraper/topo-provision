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

require_relative 'resource'

module Topo
  module Provision
    class ChefNodeGenerator < Topo::Provision::ResourceGenerator
            
      def initialize(data)
        @resource_type ||= "chef_node"
        super
        
        @undeploy_action = "delete"
        %w[run_list chef_environment tags attributes].each do |key|
          @resource_attributes[key] = data[key] if data.key? key
        end
      end
     
    end
  end
end
