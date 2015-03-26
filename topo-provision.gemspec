# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'topo/provision/version'

Gem::Specification.new do |spec|
  spec.name          = "topo-provision"
  spec.version       = Topo::Provision::VERSION
  spec.authors       = ["Christine Draper"]
  spec.email         = ["christine_draper@thirdwaveinsights.com"]
  spec.summary       = %q{ Generates Chef provisioning recipes from a topology JSON file. }
  spec.description   = %q{ Generate Chef provisioning recipes that can deploy resources such as instance and load balancers to cloud providers (e.g. AWS) or virtual machines in Vagrant. Convert from other formats such as CloudFormation.  }
  spec.homepage      = "https://github.com/christinedraper/topo-provision"
  spec.license       = "Apache License (2.0)"

  spec.files         = Dir['LICENSE', 'README.md', 'bin/*', 'lib/**/*']
  spec.executables   = Dir.glob('bin/**/*').map{ |f| File.basename(f) }
#  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'mixlib-cli', "~> 1.5"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~>10"
end
