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

#
#

module Topo
  module Provision
    class CloudFormationConverter < Topo::Converter

      Topo::Converter.register_converter("cloudformation", self.name)
      
      def convert(data)
        @input = data if data
        
        @output['name'] = @input['name'] || "CloudFormation"
        
        create_provisioning

        @input['Resources'].each do |name, resource|
          convert_resource(name, resource)
        end
        
        @output
      end
      

      def create_provisioning
        @output['provisioning'] = {'driver' => "aws", 'machine_options'=> {  }}
      end
      
      FIELDS = {
        :boolean => {
          :bootstrap_options => %w[disable_api_termination associate_public_ip_address 
            ebs_optimized dedicated_tenancy monitoring monitoring_enabled ],
          :network_interface => %w[ requester_managed source_dest_check delete_on_termination ],
          :block_device_mapping_ebs => %w[delete_on_termination]

        },
        :integer => {
          :listener => %w[instance_port load_balancer_port],
          :network_interface => %w[ device_index ],
          :block_device_mapping_ebs => %w[volume_size iops],
          :auto_scaling_group => %w[max_size min_size desired_capacity cooldown default_cooldown health_check_grace_period]
        },
        :maptov1 => {
          :listener => { "load_balancer_port" => "port" },
          :bootstrap_options => { "monitoring" => "monitoring_enabled" },
          :launch_config => { "monitoring" => "detailed_instance_monitoring" }
        }
      }

      # CloudFormation keys are camelcase - convert to underscore
      # CloudFormation values are all strings - convert to proper type
      # CloudFormation is using AWS V2, chef-provisioning-aws is using AWS V1 
      def convert_resource(name, resource)
        
        props = value_from_path(resource, ["Properties"]) || {}
        props = keys_to_underscore props
         
        case resource['Type']
        when "AWS::EC2::Instance"
          @output['nodes'] << convert_instance(name, resource)

        when "AWS::ElasticLoadBalancing::LoadBalancer"
          listeners = value_from_path(props, ["listeners"]) || []
          props["listeners"] = listeners.map{|listener|             
            fields_to_v1(:listener, fields_to_i(:listener, keys_to_underscore(listener)))
          } 
          @output['services'] << { "name" => name, "type" => "load_balancer", 
            "provisioning" => { "load_balancer_options" => props } }

        when "AWS::AutoScaling::AutoScalingGroup"
          @output['nodes'] << convert_auto_scaling_group(name, resource)
        end
      end
      
      def convert_instance(name, resource)

        instance = { 
          "name" => name,
          "provisioning" => { "machine_options" => {} }
        }
          
        props = value_from_path(resource, ["Properties"]) || {}
        props = keys_to_underscore props
        props = fields_to_v1(:bootstrap_options, fields_to_bool(:bootstrap_options, props))
        
        # Need to convert object arrays (TODO helpers)
        if props["tags"]
          props["tags"].each_with_index do | tag, index | 
            props["tags"][index] = keys_to_underscore(tag) 
            STDERR.puts "WARN: Setting AWS tags on instances is not supported yet"
            instance["provisioning"]["tags"] = props["tags"]
            props.delete("tags")
          end
        end
        if props["network_interfaces"]
          props["network_interfaces"].each_with_index do | network_interface, index | 
            temp = fields_to_i(:network_interface, keys_to_underscore(network_interface))
            temp = fields_to_bool(:network_interface, temp) 
            props["network_interfaces"][index] = temp
            # if one of the network interfaces had associate_public_ip_address: true, then
            # set that in bootstrap
            if temp['associate_public_ip_address']
              props['associate_public_ip_address'] = temp['associate_public_ip_address']
            end
          end
          STDERR.puts "WARN: Setting network_interfaces on instances is not supported"
          instance["provisioning"]["network_interfaces"] = props["network_interfaces"]
          props.delete("network_interfaces")
        end
        
        instance["provisioning"]["machine_options"]["bootstrap_options"] = props
        
        instance
        
      end
      
    def convert_auto_scaling_group(name, resource)
  
      node = { 
        "name" => name,
        "provisioning" => { "machine_options" => {}, "node_group" => { "auto_scaling" => {}} }       
      }
      # find asg properties 
      asg_props = value_from_path(resource, %w[Properties]).clone || {}
      asg_props = fields_to_i(:auto_scaling_group, keys_to_underscore(asg_props))
      asg_props.delete("launch_configuration_name")
      asg_props.delete("load_balancer_names")
      %w[availability_zones load_balancers].each do |key|
        node["provisioning"]["node_group"]["auto_scaling"][key] = asg_props[key] if asg_props.key? key
        asg_props.delete(key)
      end 
      node["provisioning"]["node_group"]["auto_scaling"]["group_options"] = asg_props
                
      # find the launch config
      lc_name = value_from_path(resource, %w[Properties LaunchConfigurationName Ref])
      lc_props = keys_to_underscore(value_from_path(@input, ['Resources', lc_name, 'Properties'])) || {}
      lc_props = fields_to_bool(:bootstrap_options, lc_props)
      node["provisioning"]["node_group"]["auto_scaling"]["launch_configuration_options"] = lc_props
      
      # find the load balancers
      lb_refs = value_from_path(resource, %w[Properties LoadBalancerNames]) || []
      load_balancers = lb_refs.map{|lb_ref| lb_ref['Ref'] }
      # TODO should this be a topo ref instead? - needs to pick up load balancer name
      if load_balancers.length > 0
        node["provisioning"]["node_group"]["auto_scaling"]["load_balancers"] = load_balancers
      end
      
      node
      
    end
      
      

      def camel_to_underscore(str)
        str.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          downcase
      end

      def keys_to_underscore(hash)
        converted = Hash[hash.map{|key, val|
          if (val.kind_of? Hash)
            [ camel_to_underscore(key), keys_to_underscore(val) ]
          else
            [camel_to_underscore(key), val]
          end
        }]
      end
    
      # 
      def fields_to_i(field_name, hash)
        FIELDS[:integer][field_name].each do | key |
          hash[key] = hash[key].to_i if hash.key? key
        end
       
        hash
      end
      
    def fields_to_bool(field_name, hash)
      FIELDS[:boolean][field_name].each do | key |
        if hash.key? key
          hash[key] = (hash[key].downcase == "true")
        end
      end
      hash
    end
    
  def fields_to_v1(field_name, hash)
    FIELDS[:maptov1][field_name].each do | key, value |
     if hash.key? key
       hash[value] = hash[key]
       hash.delete(key)
     end
    end
   
    hash
end

    end
  end
end
