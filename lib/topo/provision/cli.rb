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

require 'mixlib/cli'
require 'topo/provision'

module Topo
  module Provision
    class CLI
      include Mixlib::CLI
 
      banner('Usage: topo-provision topofile [option]')
  
      option :format,
             long: '--format topo|cloudformation',
             description: 'Specifies format of the input topology file'

      option :output_topo,
             long: '--output-topo filename',
             description: 'Specifies file to output topology JSON'

      option :output,
             long: '--output filename',
             description: 'Specifies file to output generated recipe to'

      option :action,
             long: '--action deploy|undeploy|stop',
             description: 'Specifies action to generate - defaults to deploy',
             default: "deploy"
                                                                    
      attr_accessor :topology
      
      def initialize(argv=[])
        super()
        parse_and_validate_args
      end
      
      def parse_and_validate_args
        begin
          parse_options
          @input_file = cli_arguments()[0]
        rescue OptionParser::InvalidOption => e
          STDERR.puts e.message
          puts opt_parser
          exit(-1)
        end
        
        if !@input_file
          STDERR.puts opt_parser
          exit(-1)
        end
      end
      
      def redirect_stdout(file)
        begin
          $stdout.reopen(file, "w")    
        rescue => e
          STDERR.puts "ERROR: Cannot open provisioning output file #{file} - #{e.message}"
        end 
      end
       
      def run        
        @topology = Topo::Loader.from_file(@input_file,  @config[:format] || "default")

        # output topo file
        @topology.to_file(@config[:output_topo]) if(@config[:output_topo])         
          
        # redirect generated recipe to file
        redirect_stdout(@config[:output]) if(@config[:output])
          
        # run generator
        @generator = Topo::Provision::Generator.new(@topology)
        action = @config[:action].to_sym
        @generator.generate_provisioning_recipe(action)
        
      end
      
    end
  end
end
