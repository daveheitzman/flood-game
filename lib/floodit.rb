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
  def initialize_copy(orig)
    @point = orig.point.clone
  end 
end 

class Grid
#on google it's 14x14
	XDIM=14
  YDIM=14
  COLORS=%w(% $ ! @ & *)
  NULLCOLOR='~'
  
  @@game_number = Random.new_seed
  
  @@rand=Random.new( @@game_number  )
  
  COLOR_HEX={'%'=>sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) ) , 
    '$'=>sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) ),
    '!'=> sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) ),
    '@'=> sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) ), 
    '&' => sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) ),
    '*' =>sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) ),
    '~' =>sprintf("#%0.6x",(2**23)+@@rand.rand(2**23) )}

  def get_adjacents(*args)
  #inputs: an array, point, cell or fixnum pair indicating the cell in question
  #returns an array of cells that are adjacent to it.  
    point = case args.first 
    when Cell
      args.first.point
    when Point
      args.first
    when Array
      Point.new(args.first[0],args.first[1])
    when Fixnum
      Point.new(args[0] , args[1])
    end 
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

  def copy_grid
    newg=new_grid
    all_grid do |cell,x,y|
      newg[x][y]=cell.clone
      cell
    end 
    newg
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
    #act of player choosing a color. changes color, changes ownership of new adjacent blocks w/ same color, returns new size of owned
    #territory
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
    @xdim,@ydim=xdim,ydim
    @starting_point_color = NULLCOLOR
    @starting_point = Point.new
    @color_grid = new_grid(@xdim,@ydim)
    reset_grid
  end 
  
  def new_grid(xdim=@xdim,ydim=@ydim)
    grid=[]
    xdim.times do 
      grid << []
    end 
    grid
  end 

  def [](*args)
  #expects either a Point argument or two fixnums indicating the coordinates 
    if args.nil? 
      nil
    elsif args.first.kind_of? Point
      @color_grid[args.first.x][args.first.y] rescue nil
    elsif args.size > 1
      if args[0] < 0 || args[1] < 0 then nil else @color_grid[args[0]][args[1]] rescue nil end    
    else
      nil
    end 
  end 

  def all_grid(&block) 
    @color_grid ||= new_grid
    @xdim.times do |x|
      @ydim.times do |y|
        @color_grid[x][y]=block.call(@color_grid[x][y],x,y)
      end 
    end 
  end 
  
  def reset_grid
    @@game_number += 1
    @@rand=Random.new(@@game_number)
    all_grid do |i,x,y|
      i=Cell.new
      i.color=COLORS[@@rand.rand(COLORS.size)]
      i.point=Point.new(x,y)
      i.owned=false
      i
    end 
    unflood_all
    @color_grid[0][0].owned=true
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
      1.times do 
      print left_margin+left_border
      XDIM.times do |x|
        e=self[x,y].send(disp_type).to_s
        print item_space + e.color(COLOR_HEX[e]) + item_space
      end 
      print right_border+right_margin
      puts
      end
    end 
    print left_margin+corner
    XDIM.times do |x|
      print top_border + top_border + top_border
    end 
    print corner
    print right_margin
    puts
  end 
  
  def initialize_copy(orig)
    @last_color=orig.last_color.clone
    @color_grid=orig.copy_grid
  end 
end 

class Point 
  def x  ; @x  end 
  def y   ; @y  end 
  def to_s ;    "#{@x},#{@y}"  end 
  def ==(p)
    p.kind_of?( self.class ) ? (p.x==self.x && p.y==self.y) : false   
  end 
  def initialize(x=nil,y=nil)
    @x = x || 0 
    @y = y || 0
  end 
end 


class RunGame

  def initialize(computer_player=false)
    @game_grid ||= Grid.new
    @computer_player_stats={}
    @computer_player = computer_player # true
    #new_game
  end 

  def new_game
    @game_grid.reset_grid
    @last_color=''
    @turns_taken=0
    @game_finished=false
    game_loop
  end 
  
  def game_loop
    @game_grid.flood

    while(!@game_finished) do
      @last_color=@game_grid.owned_cells.first.color
      pconvs=@game_grid.possible_conversions

      if !@computer_player
        puts
        #info line:
        print "Owned: #{@game_grid.owned_cells.size}/#{Grid::XDIM*Grid::YDIM} | "  
        print "Turns: #{@turns_taken} | "
        ava=Grid::COLORS
        print ava.map{|e| e.to_s.color(Grid::COLOR_HEX[e]) + ":" + pconvs[e].to_s }.join("  ")
        puts
        #@game_grid=@game_grid.clone
        c=choose_move pconvs
        
        @game_grid.draw
        ava=Grid::COLORS
        puts "Available colors: " + ava.map{|e| e.to_s.color(Grid::COLOR_HEX[e])}.join(", ")
        print("(CTRL-C to exit)  Enter a color:".color('#EFC238'))
        c=gets
      else
        c=choose_move(pconvs)
      end 
      
      @game_grid.change_color c.chomp
      @game_grid.flood
      @turns_taken+=1 if @game_grid.owned_cells.first.color != @last_color
      @game_finished = @game_grid.owned_cells.size==Grid::XDIM*Grid::YDIM
    
    end 
      @computer_player_stats[:highest] ||=0
      
      @computer_player_stats[:lowest] ||= 111111111110
      @computer_player_stats[:total_games] ||= 0
      @computer_player_stats[:total_moves] ||= 0
      @computer_player_stats[:average_moves] ||=0
      @computer_player_stats[:average_moves] ||= 0

      @computer_player_stats[:highest] = [@computer_player_stats[:highest], @turns_taken ].max
      
      @computer_player_stats[:lowest] = [@computer_player_stats[:lowest], @turns_taken ].min
      @computer_player_stats[:total_games] += 1
      @computer_player_stats[:total_moves] += @turns_taken
      @computer_player_stats[:average_moves] = @computer_player_stats[:total_moves].to_f/ @computer_player_stats[:total_games]
       
    #@computer_player_stats is for human and computer players    
    if @computer_player
      puts "Computer solved board in #{@turns_taken} moves. Highest: #{@computer_player_stats[:highest] } Lowest: #{@computer_player_stats[:lowest] } Average moves: #{sprintf('%0.2f',@computer_player_stats[:average_moves])} Total games: #{@computer_player_stats[:total_games]}"
    else
      @game_grid.draw
      puts "Solution found in #{@turns_taken} moves. Highest: #{@computer_player_stats[:highest] } Lowest: #{@computer_player_stats[:lowest] } Average moves: #{sprintf('%0.2f',@computer_player_stats[:average_moves])} Total games: #{@computer_player_stats[:total_games]}"  
    end
    
  end 

  def look_ahead(grid,s='')
    #input: a string representing a sequence of moves to be made against the current grid
    #output: number of cells you'll own after playing sequence s 
    owned = grid.owned_cells.size
#puts "owned = grid.owned_cells.size " + owned.to_s + "  "
    return owned if s.size == 0 
    grid = grid.clone  
    grid.change_color( s[0] )
    grid.flood
    cc=grid.owned_cells.size
    if cc > owned  
      la=look_ahead(grid,s[1..-1] )
      return la
    else 
      return owned
    end 
#puts "after clone owned = grid.owned_cells.size " + owned.to_s 
#puts "grid.change_color( s[0] )                 " + cc.to_s 
#puts "after look_ahead(grid,s[1..-1] )          " + la.to_s     
    
  end 

  #def choose_move(conversions)
    #choice = Grid::COLORS.first

    #highest=0  
    #conversions.each do |k,v|
      #if v > highest then highest=v;choice=k end 
    #end 
    #choice
  #end 

  
  def choose_move(conversions)
    look_ahead_moves = 3
    choice = nil
    highest=0 
    seq=''
    move_chains=Grid::COLORS.permutation(look_ahead_moves).to_a
    #grid_clones={}
    move_chains.each do |mc|
      #look_ahead(mc.join)
        la=look_ahead( @game_grid, mc.join ) 
#puts "look_ahead( @game_grid,'#{mc.join}'): "+la.to_s+" "
        if  la > highest then highest=la; choice=mc[0]; seq=mc.join+":"+highest.to_s end  
    end 
puts "best move (#{look_ahead_moves}): "+seq    
    choice
  end 

end 

class SetOfGames

  def initialize(number_of_games=1000)
    puts "***********************************************************************************"
    puts "*                           Floodly (or something cute )                          *"
    puts "*                a ruby implementation of Google's cool game floodit              *"
    puts "*                       available if you sign up for google +                     *"
    puts "*                                                                                 *"
    puts "*                                by David Heitzman                                *"
    puts "*                               http://aptifuge.com                               *"
    puts "*                          http://github.com/daveheitzman                         *"
    puts "*                                   CTRL-C to exit                                *"
    puts "*                                                                                 *"
    puts "***********************************************************************************"
    puts
    print "Computer or human ('c' or 'h') ? "
    c=gets
    cp= c.include?( 'c' ) ? true : false 
    if cp
      print "Number of games for computer to play ? "
      c=gets
      number_of_games=[c.to_i, 10000].min
      number_of_games=[number_of_games, 0].max
    else
      number_of_games=2**30
    end 
    
    rg = RunGame.new(cp)
    number_of_games.times do 
      rg.new_game
    end
  end 

end 


