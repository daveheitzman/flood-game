require 'spec_helper'

describe Grid do
  it "creates a new grid when new is called " do 
    @grid=Grid.new
    @grid.should_not == nil
  end 

  it "returns a cell when grid[0,0] is called" do 
    @grid=Grid.new
    @grid[0,0].should be_a Cell
  end 

  it "returns a Point when grid[0,0].point is called" do 
    @grid=Grid.new
    @grid[0,0].point.should be_a Point
  end 

  it "should have the same coordinates in each cell's Point as the cell's array coordinates" do 
    @grid=Grid.new
    @grid[1,1].point.x.should equal 1
    @grid[1,1].point.y.should equal 1
    @grid[3,2].point.x.should equal 3
    @grid[3,2].point.y.should equal 2
  end 

  it "should say two points with equal coordinates are equal" do 
    @grid1=Grid.new
    @grid2=Grid.new
    @grid2[1,1].point.should == @grid1[1,1].point
  end 

  it "should say two points with non-equal coordinates are not equal" do 
    @grid1=Grid.new
    @grid2=Grid.new
    @grid2[1,2].point.should_not == @grid1[1,1].point
  end 
  
  it "should build a grid of the size specified in #new" do 
    grid=Grid.new(5,5)
    grid[0,0].should_not == nil
    grid[4,4].should_not == nil
  end 
  
  describe "#get_adjacents" do 
    it "should report correct number of adjacent cells" do
      grid = Grid.new(4,4)
      grid.get_adjacents(0,0).size.should == 2
      grid.get_adjacents(1,2).size.should == 4
      grid.get_adjacents(3,3).size.should == 2
      grid.get_adjacents(0,2).size.should == 3
      grid.get_adjacents(3,1).size.should == 3
      grid.get_adjacents(31,11).size.should == 0
    end 
    it "should report correct items in get_adjacents" do 
      grid = Grid.new(4,4)
      i00=grid[0,0]
      i01=grid[0,1]
      i10=grid[1,0]
      i11=grid[1,1]
      grid.get_adjacents(0,0).include?(i01).should == true  
      grid.get_adjacents(0,0).include?(i10).should == true  
      grid.get_adjacents(0,0).include?(i11).should_not == true  
      grid.get_adjacents([0,0]).include?(i11).should_not == true  
    end 
  end 

end 
