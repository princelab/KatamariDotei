require File.dirname(__FILE__) + "/spec_helper"
require "combiner"

describe 'Combiner' do
  before do
    path = SPEC_DIR + "/test_files"
    files1 = %w(test_1_omssa test_1_tandem test_1_tide test_1_mascot).map {|v| path + v + ".psms" }
    @c1 = Combiner.new(files1, "test", "1")
  end
  
  it 'Combines multiple .psms files into one .psms file' do
    @c1.combine
    FileUtils::cmp(File.open(DATA_DIR + "/results/test_combined_1.psms", "r"), File.open(SPEC_DIR + "/test_files/test_combined_1-key.psms", "r")).is true
  end
end
