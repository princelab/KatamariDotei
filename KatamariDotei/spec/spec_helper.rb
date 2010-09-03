require 'spec/more'
require 'fileutils'
require 'nokogiri'

BASE_DIR = File.dirname(__FILE__) + "/.."
SPEC_DIR = BASE_DIR + "/spec"
$config = Nokogiri::XML(IO.read(BASE_DIR + "/config.xml"))
DATA_DIR = BASE_DIR + "/../data"

Bacon.summary_on_exit
