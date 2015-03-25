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

require 'topo/utils/parsegen'
require 'topo/provision/topology_generator'

# load the resource generators
%w[context machine  machine_image chef_node load_balancer node_group].each do |gen|
  require_relative 'generators/' + gen
end
  
#require 'topo/provision/generators/machine_image'

#
# The Generator class invokes driver-specific or base generators to generate
# elements of the provisioning recipe. 
#

module Topo
  module Provision
    class Generator

      include Topo::ParseGen

      attr_accessor :topology
      
      # Generators for each driver (root driver)      
      @@generator_classes = {}
      @driver_name = "default"
        
      def self.register_generator(driver, class_name)
         @@generator_classes[driver] = class_name
      end  
       
      self.register_generator(@driver_name, self.name)
      
      def initialize(topo=nil)
        @topology = topo
        @generators = { @driver_name => self }
      end
      
      # Get the right generator for the driver in place (e.g. vagrant, fog)
      def generator(driver)
        unless @generators.key?(driver)
          
          generator_class = @@generator_classes[driver] 
          
          unless generator_class          
            begin
             require "topo/provision/#{driver}/generator"
             generator_class = @@generator_classes[driver]
             rescue LoadError => e
              STDERR.puts e.message
              STDERR.puts("#{driver} driver cannot be loaded - using default generator instead")
              generator_class = @@generator_classes["default"]              
            end
          end
                  
          @generators[driver] = Object::const_get(generator_class).new(@topology)
        end
        
        @generators[driver]
      end
      
      # Add resources & their generators to the topology generator, then 
      # call them in dependency order to generate the overall recipe
      # TODO: Driver-specific generation of dependencies other than through topo refs, e.g. autoscaling depend on loadbalancer
      def generate_provisioning_recipe(action=:deploy)
        
        topology_generator = Topo::Provision::TopologyGenerator.new()
        generator(@topology.driver).generate_context(action)
         
        @topology.services.each do |service|
          depends_on = topo_refs(service).to_a
          process_lazy_attrs(service) if depends_on.length > 0
          topology_generator.add(service, depends_on,
          { :resource_generator => resource_generator(service['type'], service) })
        end
        
        @topology.nodes.each do |node|
          depends_on = topo_refs(node).to_a
          process_lazy_attrs(node) if depends_on.length > 0
          topology_generator.add(node, depends_on, 
          { :resource_generator => resource_generator("node", node) })
        end
        
        if [:undeploy, :stop].include?(action)
          topology_generator.reverse_generate(action)
        else
          topology_generator.generate(action)
        end

      end

      
      
      def driver(resource)
        if resource['provisioning'] && resource['provisioning']['driver']
          resource_driver = resource['provisioning']['driver'].split(":",2)[0]
        else
        resource_driver = @topology.driver
        end
        resource_driver        
      end
      
      # Convert attributes with references to lazy attributes, and return array of resource names
      # that this resource depends on
      def process_lazy_attrs(resource)
        depends_on = Set.new
        if resource['attributes']
          resource['attributes'].each do |key, value|
            deps = topo_refs(value)
            if deps.size > 0
              depends_on.merge(deps)
              resource['lazy_attributes'][key] = lazy_attribute_to_s(value)
              resource['attributes'].delete(key)
            end
          end
        end
        depends_on.to_a
      end

      # BASE DRIVER GENERATORS
      

      def generate_context(action)
        cxt_gen = context
        if (cxt_gen.respond_to? action)
          cxt_gen.send(action)
        else
          cxt_gen.send("default_action", action)
        end
      end
      
      def resource_generator(resource_type, data) 
        generator = nil
        driver_generator = generator(driver(data))
        if driver_generator.respond_to?(resource_type)
         generator = driver_generator.send(resource_type, data)
        else
          STDERR.puts "Driver #{@topology.driver} does not support resource type #{resource_type}"
        end
        generator
      end
      
      # Functions to return the resource generators
      
      def node(data)
        if (data['provisioning'])
          if(data['provisioning']['node_group'] && data['provisioning']['node_group']['size'])
            Topo::Provision::NodeGroupGenerator.new(data)
          else 
            Topo::Provision::MachineGenerator.new(data)
          end
        else
          Topo::Provision::ChefNodeGenerator.new(data)
        end        
      end
      
      def load_balancer(data)
        Topo::Provision::LoadBalancerGenerator.new(data)
      end

      def context()
        @context ||= Topo::Provision::ContextGenerator.new(@topology.provisioning,  @topology.driver)
      end

    end
  end
end
