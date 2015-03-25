
module Topo
    class Exporter    

    
    def self.to_file(file, topo)
      
      begin
        File.open(file, 'w') { |f| f.write(JSON.pretty_generate(topo)) }    
       rescue
        STDERR.puts "ERROR: Cannot write to topology export file #{f}"
      end
    end
  end
end
