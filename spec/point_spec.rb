require 'spec_helper'

describe Point do 

  it "should correctly initialize point coordinates if parameters provided" do 
    p1=Point.new(-2,0)
    p1.x.should == -2
    p1.y.should == 0
    p1=Point.new(4,6)
    p1.x.should == 4
    p1.y.should == 6
  end 

  it "should initialize coordinates as 0,0 if none are given on creating new" do 
    p1=Point.new
    p1.x.should == 0
    p1.y.should==0
  end 
  
  it "should report equality if two points have same coordinates" do
    p1=Point.new
    p2=Point.new
    p1.should == p2

    p3=Point.new(16,12)
    p4=Point.new(12,11)
    p3.should_not == p4

    p5=Point.new(16,12)
    p6=Point.new(16,13)
    p5.should_not == p6

    p7=Point.new(15,0)
    p8=Point.new(14,0)
    p8.should_not == p7
  end 
  
end 
