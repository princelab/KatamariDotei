
#Transforms a .raw file to a mzXML file
class RawTomzXML
  def initialize(file)
    @file = file
  end
    
  def convert
		puts "\n----------------"
		puts "Transforming raw file to mzXML format...\n\n"
		
		exec("wine readw.exe --mzXML #{@file} 2>/dev/null") if fork == nil
		Process.wait
  end
end
