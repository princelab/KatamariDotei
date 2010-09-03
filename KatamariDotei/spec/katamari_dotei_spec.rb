require File.dirname(__FILE__) + '/spec_helper'

describe 'KatamariDotei' do
  
  before do
    @kd = KatamariDotei.new(["#{$path}../data/raw/test.raw"], "human", "#{$path}../../config.xml")
  end
  
  it 'runs the main program' do
    @kd.run
    1.is 1
  end
end
