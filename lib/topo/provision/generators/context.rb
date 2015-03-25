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

require 'erb'
require 'topo/utils/parsegen'

#
# The ContextGenerator class generates the recipe context  
#

module Topo
  module Provision

    class ContextGenerator   
      include Topo::ParseGen

      @@driver_files = {
        'default' =>'chef/provisioning',
        'aws' =>'chef/provisioning/aws_driver',
        # 'fog' => 'chef/provisoning/fog_driver/driver', - not currently supported
        'vagrant' => 'chef/provisioning/vagrant_driver/driver'
      }
      @@template = nil
      

      def initialize(data, default_driver)
        @driver = data['driver'].split(':', 2).first if data['driver'] 
        @driver ||= default_driver
        @require_driver = @@driver_files['default']
        if @driver && @@driver_files.key?(@driver)
          @require_driver = @@driver_files[@driver]
        end
        @machine_options = convert_keys_to_sym(data['machine_options']) if data['machine_options']
        @driver = data['driver']
      end

      def deploy()
        puts(template.result(binding))
      end
      
      def default_action(action)
        puts(template.result(binding))
      end
      
      def template()
        unless @@template
          path = File.expand_path("../templates/context.erb", __FILE__)
          @@template = ERB.new(File.new(path).read, nil, '>')
        end
        @@template
      end
    
    end
  end
end
