class Grid
	XDIM=5
  YDIM=17
  COLORS=%w(% $ ! @ & *)

  def get_adjacents(point)
    self[point.x,point.y]
    r=[]
    r << self[point.x,point.y-1] || nil # to the up 
    r << self[point.x+1,point.y] || nil # to the right 
    r << self[point.x,point.y+1] || nil # to the down 
    r << self[point.x-1,point.y] || nil # to the left 
    #returns an array of up to 4 points that are adjacent to this one
  end 

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
    @grid[x][y] rescue nil
  end 

  def all_grid(&block) 
    XDIM.times do |x|
      YDIM.times do |y|
        @grid[x][y]=block.call(@grid[x][y],x,y)
      end 
    end 
    
  end 
  
  def reset_grid
    all_grid do |i,x,y|
      i=COLORS.shuffle.last
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
    YDIM.times do |y|
      print left_margin+left_border
      XDIM.times do |x|
        print item_space + self[x,y] + item_space
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

class Point 
  def x
    @x
  end 
  def y
    @y
  end 
  
  def initialize(x=nil,y=nil)
    @x = x || 0; 
    @y = y || 0
  end 
end 

class Area
  
  def initialize(game_grid) 
    @points = [Point.new]
    @color = game_grid[0,0]
    @grid = game_grid
  end 
  
  def choose_color(color)
    @points.each do |point|
    
    end 
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
    @area.choose_color(c)
#   @game_grid.reset_grid

    @game_grid.all_grid do |g,x,y|  
      puts " #{x} #{y} #{g} " + @game_grid.get_adjacents(Point.new(x,y)).inspect
      g 
    end 
    
    @game_grid.draw
    end 

  end 

end 

rg=RunGame.new
rg.game_loop
