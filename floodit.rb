class Cell
  attr_accessor :point, :color, :flooded
  
  def initialize
    @point=Point.new(0,0)
    @color=Grid::NULLCOLOR
    @owned=false
    @flooded=false
  end 
  def to_s
    color
  end 
  
  def owned?
    @owned
  end 
  def owned=(o)
    @owned=(o)
  end 
  def owned
    owned? ? "+" : "-"
  end 
end 

class Grid
	XDIM=5
  YDIM=11
  COLORS=%w(% $ ! @ & *)
  NULLCOLOR='~'
  
  def get_adjacents(point_or_cell)
    point = point_or_cell.kind_of?(Cell) ? point_or_cell.point :  point_or_cell 
    #point= self[point].point
    r=[]
    r << self[point.x,point.y-1]  # to the up 
    r << self[point.x+1,point.y]  # to the right 
    r << self[point.x,point.y+1]  # to the down 
    r << self[point.x-1,point.y]  # to the left
    r.compact
    #returns an array of up to 4 points that are adjacent to this one
  end 

  def owned_cells
    owned=[]
    all_grid do |cell,x,y|
      owned << cell if cell.owned? 
      cell      #remember the all_grid method assigns whatever is the outcome of this block back to the original cell
    end 
    owned
  end 

  def change_color(color)
    return unless COLORS.include? color
    point_set=[]
    owned=owned_cells
    owned.each do |cell|
      self[cell.point].color=color
    end 
    all_grid do |cell,x,y|
      cell.flooded=false 
      cell      #remember the all_grid method assigns whatever is the outcome of this block back to the original cell
    end 

  end 
  
  def flood(caller=nil, start_at=nil)
    start_at = start_at || self[0,0]
    start_at.owned=true
    start_at.flooded=true
    #adjs=start_at.get_adjacents
    get_adjacents(start_at).each do |adj_cell|
puts "cell: #{adj_cell} caller: #{caller}"
puts "#{adj_cell==caller}"
      next if adj_cell==caller
      next if adj_cell.flooded
      if adj_cell.color == start_at.color 
puts "b4 flood "
puts "cell: #{adj_cell} caller: #{caller}"
puts "#{adj_cell==caller}"
          flood(start_at,adj_cell)
      end 
    end 
    
  end     

    
    #cell= self[ args ] ||  self[ 0 , 0]
    #@starting_point=cell.point
    #point_set << @starting_point

    #adjs = get_adjacents(@starting_point).compact

    

#puts "***"
#puts adjs.inspect
#puts "***"


    #adjs.each do |adj_cell|
    
      #if adj_cell.color == @starting_point.color then 
        #if !adj_cell.owned?  
          #adj_cell.owned=true
          #ops = get_owned_cells(adj_cell).reject!{|cell| cell.owned } 
          #point_set += ops
        #else #it's a cell we already own so we need to explore its adjacents
          
        #end 
        ##ops.reject!{|p| p==@starting_point }
      #end   
    #end 
    
    #point_set
    ##returns an array? of points in the grid that the player "owns" 
  #end 

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
    if args.nil? 
      nil
    elsif args.first.kind_of? Point
      @color_grid[args.first.x][args.first.y] rescue nil
    elsif args.size > 1
      ( (args[1] < 0 || args[0] < 0 ) ? nil :   @color_grid[args[0]][args[1]] ) rescue nil  
    else
      nil
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
  
  def draw(disp_type=:color)
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
        print item_space + self[x,y].send(disp_type).to_s + item_space
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
  def to_s
    "#{@x},#{@y}"
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
    @game_grid.flood

    loop do
    @game_grid.draw
    @game_grid.draw(:owned)

    
    print "Enter a color: " 
    c=gets
    @game_grid.change_color c.chomp
    @game_grid.flood
#@game_grid.all_grid do |g,x,y|  
  #puts " #{x} #{y} #{g} " + @game_grid.get_adjacents(g.point).inspect
  #puts "the point as it says it is: "+g.point.to_s
  #g 
#end 
    
    
    puts "owned points: "
    puts @game_grid.owned_cells.inspect 
    
    
    end 

  end 

end 

rg=RunGame.new
rg.game_loop
