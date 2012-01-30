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
  
  @@game_number = 0
  
  @@rand=Random.new( @@game_number  )
  
  COLOR_HEX={'%'=>sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) ) , 
    '$'=>sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) ),
    '!'=> sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) ),
    '@'=> sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) ), 
    '&' => sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) ),
    '*' =>sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) ),
    '~' =>sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) )}

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

  def pretend_flood(caller,start_at)
    #this floods a cell but only in order to get a count of how many cells we would gain if we flooded on this cell
    count = 1
    start_at.flooded=true
    #adjs=start_at.get_adjacents
    get_adjacents(start_at).each do |adj_cell|
      next if adj_cell==caller
      next if adj_cell.flooded
      if adj_cell.color == start_at.color 
        count += pretend_flood(start_at,adj_cell)
      end 
    end 
    count
  end 

  def possible_conversions
    #outputs a hash : {color=>number of squares that would be gained by playing this color }
    poss={}
    COLORS.each do |c| poss[c]=0 end 
    owned_cells.each do |owned_cell|
      owned_cell.flooded=true
      get_adjacents(owned_cell).each do |adj| 
        poss[adj.color] += pretend_flood(owned_cell,adj) if !adj.flooded #use flooded marker so as not to count twice. we'll reset all when done 
        adj.flooded=true
      end  
    end 
    unflood_all
    return poss
  end 

  def change_color(color)
    return unless COLORS.include? color
    point_set=[]
    owned=owned_cells
    owned.each do |cell|
      self[cell.point].color=color
    end 
    unflood_all
  end 
  
  def unflood_all
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
    @@game_number += 1
    all_grid do |i,x,y|
      i=Cell.new
      i.color=COLORS[@@rand.rand(COLORS.size)]
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
    @game_grid ||= Grid.new
    new_game
  end 

  def new_game
    @game_grid.reset_grid
    @last_color=''
    @turns_taken=0
    @computer_player=true
    @game_finished=false
    game_loop
  end 
  
  def game_loop
    @game_grid.flood

    while(!@game_finished) do
      @last_color=@game_grid.owned_cells.first.color
      puts
      #info line:
      print "Owned: #{@game_grid.owned_cells.size}/#{Grid::XDIM*Grid::YDIM} | "  
      print "Turns: #{@turns_taken} | "
      pconvs=@game_grid.possible_conversions
      ava=Grid::COLORS
      print ava.map{|e| e.to_s.color(Grid::COLOR_HEX[e]) + ":" + pconvs[e].to_s }.join("  ")

      puts
      @game_grid.draw
  #    @game_grid.draw(:owned)
   
      ava=Grid::COLORS
      puts "Available colors: " + ava.map{|e| e.to_s.color(Grid::COLOR_HEX[e])}.join(", ")
      print("Enter a color:".color('#EFC238'))
      if @computer_player
        c=choose_move(pconvs)
      else 
        c=gets
      end 
      
      @game_grid.change_color c.chomp
      @game_grid.flood
      @turns_taken+=1 if @game_grid.owned_cells.first.color != @last_color
      @game_finished = @game_grid.owned_cells.size==Grid::XDIM*Grid::YDIM
    
    end 
      @game_grid.draw
      puts "Congratulations. Solution found in #{@turns_taken} moves."  
  end 

  def choose_move(conversions)
    choice = Grid::COLORS.first
    highest=0  
    conversions.each do |k,v|
      if v > highest then highest=v;choice=k end 
    end 
    choice
  end 
end 

class SetOfGames

  def initialize(number_of_games=14)
    rg=RunGame.new
    number_of_games.times do 
      rg.new_game
    end
  end 

end 


SetOfGames.new
