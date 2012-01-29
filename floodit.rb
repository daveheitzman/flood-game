class Grid
	XDIM=17
  YDIM=17
  COLORS=%w(% $ ! @ & *)

  def last_color
    @last_color ||= @grid[0][0]
  end 
  
  def initialize
    @grid=Array.new(XDIM,[])
    @grid.each_index do |i|
       @grid[i] = Array.new(YDIM,'~') 
    end    
  end 

  def [](x,y)
    @grid[x][y]
  end 

  def all_grid(&block) 
    XDIM.times do |x|
      YDIM.times do |y|
        #@grid[x][y]=block.call(@grid[x][y],x,y)
        @grid[x][y]=COLORS.shuffle.last
      end 
    end 
    
  end 
  
  def reset_grid
    all_grid do |i,x,y|
      i=String.new COLORS.shuffle.last
      i
    end 
  end 
  
  def choose_color(c)
    return if !COLORS.include? c
    
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
    
    ############################# begin drawing 
    puts "Available colors: " + COLORS.inspect
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

class Point < Array
  
  def initialize
    self << 0
    self << 0
  end 
end 

class Area
  
  def initialize(game_grid) 
    @points = [Point.new]
    @color = game_grid[0,0]
  end 
  
end 

class RunGame

  def initialize
    @game_grid=Grid.new
    @game_grid.reset_grid
    @area=Area.new(@game_grid)
  end 

  def game_loop
    loop do
    print "Enter a color: " 
    c=gets
    @game_grid.choose_color(c)
#    @game_grid.reset_grid
    @game_grid.draw
    end 

  end 

end 

rg=RunGame.new
rg.game_loop
