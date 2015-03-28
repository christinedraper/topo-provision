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
# This module contains functions useful for parsing, converting and generating
#
require 'set'

module Topo
  module ParseGen
    def value_from_path(hash, path)
      path.reduce(hash) do |val, key|
        val.kind_of?(Hash) ? val[key] : nil
      end
    end

    # convert keys to symbols (deep)
    # NOTE: recurses into hashes but not into arrays
    def convert_keys_to_sym(hash)
      new_hash = {}
      hash.each do |key, val|
        new_hash[key.to_sym] = val
      end
      new_hash
    end
    
    # convert keys to symbols (deep)
    # NOTE: recurses into hashes but not into arrays
    def convert_keys_to_sym_deep(hash)
      new_hash = {}
      hash.each do |key, val|
        new_hash[key.to_sym] = val.kind_of?(Hash) ? convert_keys_to_sym_deep(val) : val
      end
      new_hash
    end

    
    # find and return dependencies (names) in topo_refs
    def topo_refs(hash, depends_on=Set.new)
      if hash.kind_of? Hash
        hash.each do |key, val|
         if key == "topo_ref"
            depends_on.add val['name']
          else
            topo_refs(val, depends_on)
          end
        end
      elsif hash.kind_of? Array
        hash.each do |val|
          topo_refs(val, depends_on)
        end
      end
      depends_on
    end
    
    # Convert lazy attributes to a string
    def lazy_attribute_to_s (hash)
      str = ""
      hash.each do |key, val|
        str += ', ' if str != ""
        if val.kind_of?(Hash)
          if val.key?("topo_ref") && val.keys.length == 1
            # this is a topology reference so expand it
            str += "'#{key}' => " + expand_ref(val['topo_ref'])
          else
            str += lazy_attribute_to_s(val)
          end
        else
          str += "'#{key}' => " + val.inspect
        end
      end
    
      str
    end

    # Expand a particular reference into a node search
   def expand_ref(ref)
     path = ref['path']
     "topo_search_node_fn.call(#{ref['name'].inspect}, #{path})"
   end

  end
end
