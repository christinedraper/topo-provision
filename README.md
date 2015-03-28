# Topo::Provision

This utility allows you to generate chef-provisioning recipes from
a topology JSON file. 

The format is an extended version of the JSON used by the knife-topo 
plugin. In addition, it is possible to convert from other formats. The
only converter currently implemented is for CloudFormation.

This utility IS NOT READY FOR PRODUCTION USE. It is best described as a
"proof of concept". It has been tested with a pre-release build of 
chef-provisioning 0.5.

## Features

'Nodes' in the topology JSON are generated as machine resources, if
provisioning is specified; otherwise they are generated as chef nodes.

'Node groups' in the topology JSON are generated as combinations of
different resources, depending on the driver and options specified.
Currently, for AWS if 'auto_scaling' is specified, it
generates a machine_image (unless an explicit image_id) is specified;
a launch configuration and an auto-scaling group. For vagrant, the action
is to generate multiple machines using machine_batch.

'Services' can be used to specify other sorts of resource, such as 
a load balancer.

Node attributes can use a special topo_ref to indicate when an attribute
should be set based on attributes of another node. topo-provision will
generate the appropriate 'lazy' evaluation of the attribute value using
a node search, and will use the information to order the resources in the
generated recipe appropriately.

## Usage

    $ topo-provision topofile.json
    
    $ topo-provision cloudformation_template --format=cloudformation --output-topo cloudformation.json
    
    $ topo-provision topofile.json --output topo_deploy.json
    
    $ topo-provision topofile.json --action=undeploy --output topo_undeploy.json
    
    $ topo-provision --help

## Structure

### Generators

Driver Generators support a particular chef provisioning driver, e.g. vagrant,
aws, fog. They live in `lib/topo/provision/#{driver}/` and register themselves using the
name of the driver. They should extend the base `Topo::Provision::Generator`
class and override its methods as needed to process the topo elements (context, node, service)
and call the appropriate Resource Generators.

Resource Generators live in `lib/topo/provision/#{driver}/generators` and
should extend `Topo::Provision::ResourceGenerator`. They are initialized
from a topo context, node or service element and generate the actual output 
for the actions that are supported on the specific resource type (e.g. deploy, undeploy, stop).

The Topology Generator `Topo::Provision::TopologyGenerator` is the top-level generator that calls the appropriate
driver generators and generates a resource graph based on topo_ref dependencies, that it traverses in either
a forward or reverse direction, depending on the actions.

### Installation

gem install topo-provision

### Converters

Converters accept a format other than topology JSON, and convert it to
the standard topo format. They live in `lib/topo/converter` and register themselves using the
name that should be passed in using the --format option. They should extend
`Topo::Converter` and provide a 'convert' method that takes a data hash and returns a topo hash.


## Known Limitations

Only supports the vagrant and aws drivers.

Only covers the following resources:
* machine
* machine_image (as part of creating a node group)
* load_balancer
* aws_auto_scaling_group (as part of creating a node group)
* aws_launch_configuration (as part of creating a node group)

## Future Directions

Here's some things I would like to do, beyond extending current support:
* Support network resources
* Have generators analyse for dependencies (e.g. name refs to other
resources) and include these in the topo ordering as well as explicit topo_refs
* Allow users to customize behavior by providing alternative generators


## Contributing

1. Fork it ( https://github.com/christinedraper/topo-provision/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
