require 'spec_helper'


describe Cell do
  it "should return a Point when point is called on it" do 
    cell=Cell.new
    cell.point.should be_a Point
  end 
  it "should be not owned and not flooded when first created " do
    cell=Cell.new
    cell.owned?.should == false
    cell.flooded.should == false
  end 

  it "should execute owned correctly " do
    cell=Cell.new
    cell.owned.should == "-"
    cell.owned=true
    cell.owned.should == "+"
  end 
  it "should execute clone correctly" do 
    cell1=Cell.new
    cell2=cell1.clone
    cell2.point.should == cell1.point
    cell2.owned.should == cell1.owned
    cell2.owned?.should == cell1.owned?
    cell1.to_s.should==cell2.to_s
  end 
  
end 
