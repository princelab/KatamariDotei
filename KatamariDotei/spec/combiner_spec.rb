require File.dirname(__FILE__) + "/spec_helper"
require "combiner"

describe 'Combiner' do
  before do
    path = SPEC_DIR + "/test_files"
    files1 = ["#{path}/test_1_omssa.psms", "#{path}/test_1_tandem.psms", "#{path}/test_1_tide.psms", "#{path}/test_1_mascot.psms"]
    
    @c1 = Combiner.new(files1, "test", "1")
  end
  
  it 'Combines multiple .psms files into one .psms file' do
    @c1.combine
    FileUtils::cmp(File.open(DATA_DIR + "/results/test_combined_1.psms", "r"), File.open(SPEC_DIR + "/test_files/test_combined_1-key.psms", "r")).is true
  end
end
