require "topo/converter"
require "topo/topology"

module Topo
    class Loader    

    
    def self.from_file(file, format='default')
      
      unless File.file?(file)        
        STDERR.puts "ERROR: #{file} is not the name of a valid file."
        exit(-1)
      end
  
      begin
        data = JSON.parse(File.read(file))
        filename = File.basename(file)
        index = filename.rindex('.') || -1
        index -= 1 unless index == -1
        data['name'] = filename[0..index] unless data['name']
      rescue JSON::ParserError => e
        STDERR.puts e.message
        STDERR.puts "ERROR: Parsing error in #{file}."
        exit(-1)
      end
  
      Topo::Topology.new(Topo::Converter.convert(data, format))
    end

    end
end
