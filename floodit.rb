require 'rainbow'


class Cell
  attr_accessor :point, :color, :flooded
  
  def initialize
    @point=Point.new(0,0)
    @color=Grid::NULLCOLOR
    @owned=false
    @flooded=false
  end 
  def to_s
    @color.color(Grid::COLOR_HEX[@color])
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
	XDIM=14
  YDIM=14
  COLORS=%w(% $ ! @ & *)
  NULLCOLOR='~'
  
  COLOR_HEX={'%'=>sprintf("#%0.6x",(2**23)+rand(2**23)), 
    '$'=>sprintf("#%0.6x",(2**23)+rand(2**23)),
    '!'=> sprintf("#%0.6x",(2**23)+rand(2**23)) ,
    '@'=> sprintf("#%0.6x",(2**23)+rand(2**23)), 
    '&' => sprintf("#%0.6x",(2**23)+rand(2**23)),
    '*' =>sprintf("#%0.6x",(2**23)+rand(2**23)),
    '~' =>sprintf("#%0.6x",(2**23)+rand(2**23))}

  def get_adjacents(point_or_cell)
    point = point_or_cell.kind_of?(Cell) ? point_or_cell.point :  point_or_cell 
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

  def cells
    owned=[]
    all_grid do |cell,x,y|
      owned << cell
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
      next if adj_cell==caller
      next if adj_cell.flooded
      if adj_cell.color == start_at.color 
        flood(start_at,adj_cell)
      end 
    end 
    
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
        e=self[x,y].send(disp_type).to_s
        print item_space + e.color(COLOR_HEX[e]) + item_space
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


class RunGame

  def initialize
    @game_grid=Grid.new
    @game_grid.reset_grid
    Kernel.srand(1)
    @last_color=''
    @turns_taken=0
  end 

  def game_loop
    @game_grid.flood

    loop do
      @last_color=@game_grid.owned_cells.first.color
      
      #info line:
      print "Owned: #{@game_grid.owned_cells.size} / #{Grid::XDIM*Grid::YDIM} | "  
      print "Turns: #{@turns_taken} | "
      puts;puts
      @game_grid.draw
  #    @game_grid.draw(:owned)
   
      ava=@game_grid.cells.uniq! || Grid::COLORS
      puts "Available colors: " + ava.map(&:to_s).join(", ")
      print("Enter a color:".color('#EFC238'))
      c=gets
      
      @game_grid.change_color c.chomp
      @game_grid.flood
      @turns_taken+=1 if @game_grid.owned_cells.first.color != @last_color
    
    end 

  end 

end 

rg=RunGame.new
rg.game_loop
