#!/usr/bin/ruby

Sample = Struct.new(:mzml, :mgfs, :searches, :percolator, :combined)
$path = "#{File.expand_path(File.dirname(__FILE__))}/"
$: << $path

require "raw_to_mzml"
require "mzml_to_other"
require "search"
require "refiner"
require "percolator"
require "combiner"
require "resolver"
require "helper_methods"
require "#{$path}../../mzIdentML/lib/search2mzidentml.rb"
require 'nokogiri'

# This is the main class of the pipeline.
#
# @author Jesse Jashinsky (Aug 2010)
class KatamariDotei
  # @param [String] files the location of the raw file
  # @param [String] dbID the type of input, e.g. human or bovin
  # @param [String] config the location of the xml config file
  def initialize(files, dbID, config)
    @files = files
    @dbID = dbID
    @dataPath = File.expand_path("#{$path}../data/") + "/"
    $config = Nokogiri::XML(IO.read(config))
  end
  
  # Begins and runs the pipeline process.
  def run
    puts "\nHere we go!\n"
    
    runHardklor = config_value("//Hardklor/@run")
    mzType = config_value("//Format/@type")
    cutoff = config_value("//Refiner/@cutoff").to_f
    samples = {}
    
    @files.each do |file|
      fileName = File.basename(file).chomp(File.extname(file))
      puts "\nCommencing work on #{fileName}"
      samples[fileName] = Sample.new(fileName, [], [], [], [])
      iterations = get_iterations
      
      create_mzML(mzType, file)
      
      mzFile = "#{@dataPath}spectra/#{fileName}.#{mzType}"
      # run Hardklor??
      # s_true(runHardklor)
      samples[fileName].mgfs << Ms::Msrun::Search.convert(:mgf, mzFile, :run_id => iterations[0][0])
      Ms::Msrun::Search.convert(:ms2, mzFile, :run_id => iterations[0][0])
      
      iterations.each do |i|
        samples[fileName].searches << Search.new(samples[fileName].mgfs[-1].chomp(".mgf"), @dbID, i[1], selected_search_engines).run
        convert_to_mzIdentML(samples[fileName].searches[-1])
        samples[fileName].percolator << Percolator.new(samples[fileName].searches[-1], @dbID).run
        samples[fileName].combined << Combiner.new(samples[fileName].percolator[-1], fileName, i[0]).combine
        samples[fileName].mgfs << Refiner.new(samples[fileName].combined[-1], cutoff, mzFile, iterations[i[2]+1][0]).refine if i[2] < iterations.length-1
        GC.start
      end
    end
    
    Resolver.new(samples).resolve
    
    tell_the_user_that_the_program_has_like_totally_finished_doing_its_thang_by_calling_this_butt_long_method_name_man
  end
  
  
  private
  
  # Creates either an mzXML file or an mzML file.
  #
  # @param [String] mzType the type of file to create, i.e. "mzML" or "mzXML"
  def create_mzML(mzType, file)
    if mzType == "mzML"
      RawToMzml.new("#{file}").to_mzML
    else
      RawToMzml.new("#{file}").to_mzXML
    end
  end
  
  # Obtains the iteration information from the config file.
  #
  # @return [Array(String, String)] an array of iteration information, currently holding [[run, enzyme], ...]
  def get_iterations
    array = []
    i = 0
    
    $config.xpath("//Iteration").each do |x|
      array << [x.xpath("./@run").to_s, x.xpath("./@enzyme").to_s, i]
      i += 1
    end
    
    array
  end
  
  # Creates the hash that states which search engines to run.
  def selected_search_engines
    {:omssa => s_true(config_value("//OMSSA/@run")),
     :xtandem => s_true(config_value("//XTandem/@run")),
     :tide => s_true(config_value("//Tide/@run")),
     :mascot => s_true(config_value("//Mascot/@run"))}
  end
  
  # Method name says it all
  #
  # @param [Array(String, String)] files an array of the files to convert in the format of [[target, decoy], ...]
  def convert_to_mzIdentML(files)
    files.each do |pair|
      pair.each {|file| exec("#{$path}../../mzIdentML/bin/search2mzidentml_cl.rb #{file} #{extractDatabase(@dbID)}") if fork == nil}
    end
    
    # Wait for the conversion to finish before moving on.
    waitForAllProcesses
  end
  
  # Displays a randomly chosen exclamation of joy.
  def tell_the_user_that_the_program_has_like_totally_finished_doing_its_thang_by_calling_this_butt_long_method_name_man
    done = rand(13)
    puts "\nBoo-yah!" if done == 0
    puts "\nOh-yeah!" if done == 1
    puts "\nYah-hoo!" if done == 2
    puts "\nYeah-yuh!" if done == 3
    puts "\nRock on!" if done == 4
    puts "\n^_^" if done == 5
    puts "\nRadical!" if done == 6
    puts "\nAwesome!" if done == 7
    puts "\nTubular!" if done == 8
    puts "\nYay!" if done == 9
    puts "\nGnarly!" if done == 10
    puts "\nSweet!" if done == 11
    puts "\nGroovy!" if done == 12
    puts "--------------------------------\n"
  end
end
