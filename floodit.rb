class Cell
  attr_accessor :point, :color, :owned
  def initialize
    @point=Point.new(0,0)
    @color=Grid::NULLCOLOR
    @owned=false
  end 
  def to_s
    color
  end 
end 

class Grid
	XDIM=5
  YDIM=17
  COLORS=%w(% $ ! @ & *)
  NULLCOLOR='~'
  
  def get_adjacents(point)
   # self[point.x,point.y]
    r=[]
    r << Point.new(point.x,point.y-1)  # to the up 
    r << Point.new(point.x+1,point.y)  # to the right 
    r << Point.new(point.x,point.y+1)  # to the down 
    r << Point.new(point.x-1,point.y)  # to the left
    #returns an array of up to 4 points that are adjacent to this one
  end 

  def get_owned_points(*args)
    color=NULLCOLOR
    point_set=[]
    @starting_point= if args.empty? 
      Point.new(0,0)
    elsif args.first.kind_of? Point
      args.first
    elsif args.size > 1
      Point.new(args[0],args[1])
    end 
    point_set << @starting_point
    @starting_point_color=self[@starting_point].color

    adjs = get_adjacents(@starting_point).compact
    adjs.each do |adj_point|
      if self[adj_point].color == @starting_point_color then 
        self[adj_point].owned = true 
        ops = get_owned_points(adj_point) 
        point_set += ops
        #ops.reject!{|p| p==@starting_point }
      end   
    end 
    
    point_set
    #returns an array? of points in the grid that the player "owns" 
  end 

  def last_color
    @last_color ||= @color_grid[0][0]
  end 
  
  def initialize(xdim=XDIM,ydim=YDIM)
    @starting_point_color = NULLCOLOR
    @starting_point = Point.new
    @color_grid = new_grid(xdim,ydim)
    reset_grid
  end 
  
  def new_grid(xdim=XDIM,ydim=YDIM)
    grid=[]
    xdim.times do 
      grid << []
    end 
    grid
  end 

  def [](*args)
    if args.first.kind_of? Point
      @color_grid[args.first.x][args.first.y] rescue nil
    elsif args.size > 1
      @color_grid[args[0]][args[1]] rescue nil
    end 
  end 

  def all_grid(&block) 
    XDIM.times do |x|
      YDIM.times do |y|
        @color_grid[x][y]=block.call(@color_grid[x][y],x,y)
      end 
    end 
    
  end 
  
  def reset_grid
    all_grid do |i,x,y|
      i=Cell.new
      i.color=COLORS.shuffle.last
      i.point=Point.new(x,y)
      i.owned=false
      i
    end 
    @color_grid[0][0].owned=true
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
        print item_space + self[x,y].to_s + item_space
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
  
  def ==(p)
    p.kind_of?( self.class ) ? (p.x==self.x && p.y==self.y) : false   
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
    @game_grid.draw
  
    print "Enter a color: " 
    c=gets
    @area.choose_color(c)

@game_grid.all_grid do |g,x,y|  
  puts " #{x} #{y} #{g} " + @game_grid.get_adjacents(Point.new(x,y)).inspect
  g 
end 
    
    
    puts "owned points: "
    puts @game_grid.get_owned_points.inspect 
    
    
    end 

  end 

end 

rg=RunGame.new
rg.game_loop
