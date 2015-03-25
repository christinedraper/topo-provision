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
    class MachineImageGenerator < Topo::Provision::MachineGenerator
      
      attr_reader :machine_options, :normal_attributes, :lazy_attributes
      
      def initialize(data)
        @resource_type ||= "machine_image"
        super
        @name = data['name'] + "_image"
        @template_base_name = "machine"
        # Note: specific driver may need to convert image options to symbols
        opts = data['provisioning']['image_options']
        @resource_attributes["image_options"] = opts if opts
      end
     
    end
  end
end
