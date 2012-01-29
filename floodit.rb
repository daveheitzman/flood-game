class Grid
	XDIM=17
  YDIM=17
  COLORS=%w(% $ ! @ & *)
  
  def initialize
    line = Array.new(XDIM,COLORS[0])
    @grid=Array.new(YDIM,line)
    draw
  end 
  
  def draw
    left_margin="   "
    right_margin="   "
    top_margin="\n"
    top_border = "-"
    left_border= "|"
    right_border= "|"
    corner="+"
    item_space=" "
    print top_margin
    print left_margin+corner
    XDIM.times do |x|
      print top_border + top_border + top_border
    end 
    print corner
    print right_margin
    print "\n"
    XDIM.times do |x|
      print left_margin+left_border
      YDIM.times do |y|
        print item_space + @grid[x][y] + item_space
      end 
      print right_border+right_margin
      puts
    end 
    print left_margin+corner
    XDIM.times do |x|
      print top_border + top_border + top_border
    end 
    print corner
    print right_margin
    puts
  end 
  
  def create
	end 

end 

class Area
end 



Grid.new
