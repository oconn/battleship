class BattleShip
  attr_accessor :user_board, :enemy_board, :choices, :round, :enemy_ships_sunk
  
  SHIPS = [["Aircraft Carrier", 5],
           ["Battleship", 4],
           ["Cruiser", 3],
           ["Destroyer1", 2],
           ["Destroyer2", 2],
           ["Submarine1", 1],
           ["Submarine2", 1]
          ]
          
  def initialize
    system 'clear'
    printf "\e[8;29;131;t"
    @user_board = Grid.new
    @enemy_board = Grid.new
    @blank_board = Grid.new
    @enemy_ships_sunk = []
    @user_ships, @enemy_ships = [], []
    @all_ships = [@user_ships, @enemy_ships]
  end
  
  def play_game
    @round = 1
    create_ship(@user_ships)
    create_ship(@enemy_ships)
    loop do
      puts "[1] Place Ships"
      puts "[2] Auto Place Ships"
      print "Choose an option: "
      @option = gets.chomp.to_i
      break if @option == 1 || @option == 2 
      puts "Not a valid option. Choose again."
    end
    
    case @option
    when 1
      place_ships(@user_ships, @user_board)
    when 2
      place_ships(@user_ships, @user_board, false)
    end
    place_ships(@enemy_ships, @enemy_board, false)
    print_grid(@user_board.grid, @blank_board.grid)
    
    loop do
      system 'clear'
      round
      sleep(1.5)
      break if all_ships_sunk?(@user_ships) || all_ships_sunk?(@enemy_ships)
      print_grid(@user_board.grid, @blank_board.grid)
    end
    results
    print_grid(@user_board.grid, @blank_board.grid)
  end
  
  def round
    print_grid(@user_board.grid, @blank_board.grid)
    puts "Round #{@round}"
    
    #User takes turn
      # Ask for coord
      coordinate = get_user_input
      row = coordinate[0]
      col = coordinate[1]
      # Check enemy board for ship or water
      if @enemy_board.grid[row][col] == "   "
        puts green("Miss")
        @blank_board.grid[row][col] = " - "
      elsif @enemy_board.grid[row][col] == " 0 "
        puts green("Hit!")
        @blank_board.grid[row][col] = " X "
        @enemy_ships.each do |ship|
          ship.ship_location.each_with_index do |coordinate, index|
            if coordinate == [row, col] then ship.ship_location[index] << "hit" end
            if ship.sunk?
              sink_ship_on_board(@blank_board.grid, ship)
            end
          end
          if ship.sunk?
            if @enemy_ships_sunk.include?(ship.type)
            else
              @enemy_ships_sunk << ship.type
              puts "You sunk the #{ship.type}"
            end
          end
        end
        if @enemy_ships_sunk.empty?
        else
          print "Ships sunk: "
          @enemy_ships_sunk.each do |ship|
            print " #{ship}"
          end
          puts
        end
      end
      
      if all_ships_sunk?(@enemy_ships) == false
        coordinate = get_random_coordinate
        row = coordinate[0]
        col = coordinate[1]
        if @user_board.grid[row][col] == "   "
          puts red("Enemy Missed")
          @user_board.grid[row][col] = " - "
        elsif @user_board.grid[row][col] == " 0 "
          puts red("Enemy Hit!")
          @user_board.grid[row][col] = " X "
          @user_ships.each do |ship|
            ship.ship_location.each_with_index do |coordinate, index|
              if coordinate == [row, col] then ship.ship_location[index] << "hit" end
              if ship.sunk?
                puts "The enemy sunk your #{ship.type}." 
                sink_ship_on_board(@user_board.grid, ship)
              end
            end
          end
        end
      end
    @round += 1
  end
  
  def sink_ship_on_board(grid, ship)
    ship.ship_location.each do |coord|
      row = coord[0]
      col = coord[1]
      grid[row][col] = red(" X ")
    end
  end
  
  def all_ships_sunk?(ships)
    ships.each do |ship|
      if ship.sunk? != true 
        return false 
      end
    end
    return true
  end
  
  def results
    if all_ships_sunk?(@user_ships)
      puts "The enemy sunk all your ships"
    else
      puts "You win!"
    end
  end

  def print_grid(grid1, grid2)
    print green("  -------------------------USER GRID-------------------------        ")
    print red("------------------------ENEMY GRID-------------------------\n")
    print green("    1     2     3     4     5     6     7     8     9     10       ")
    print red("    1     2     3     4     5     6     7     8     9     10\n")
    print_line
    row = 0
    10.times do
      print green((row + 65).chr)
      grid1[row].each do |point|
        print "| #{point} "
      end
      print "|"
      print "     "
      print red((row + 65).chr)
      grid2[row].each do |point|
        print "| #{point} "
      end
      print "|"
      puts
      print_line
      row += 1
    end
  end

  def print_line
    print "  ------------------------------------------------------------       ------------------------------------------------------------\n"
  end
  
  def create_ship(player)
    SHIPS.each do |ship|
      player << Ship.new("#{ship[0]}", ship[1])
    end
  end
  
  # This method will place each user's, or computer's, ships one at a time
  def place_ships(all_ships, grid, human_place = true)
    all_ships.each do |ship|
      @choices = {:up => "up", :down => "down", :right => "right", :left => "left"}
      if human_place
        system 'clear'
        print_grid(@user_board.grid, @blank_board.grid)
        #call check coordinates method
        loop do
          @coordinate = get_user_input(ship.type, ship.length, false)
          break if check_spacing?(grid, ship, @coordinate)
          puts "There's not enough space or a ship is in the way. Try again."
        end
        if ship.length == 1
          @dir_picked = "right"
        else
          @dir_picked = get_user_choice
        end
      else #computer
        #pass a random coordinate  
        loop do 
          @coordinate = get_random_coordinate 
          break if check_spacing?(grid, ship, @coordinate)
        end
        @dir_picked = get_random_choice
      end
      
      print_ship(ship, grid.grid, @coordinate,  @dir_picked)
    end
  end
  
  def print_ship(ship, grid, coordinate, direction)
    row = coordinate[0]
    col = coordinate[1]
    space = 0
    # FIX THIS LATER
    # if ship.length == 2
    #   grid[row][col] = " ^ "
    #   ship.ship_location[space] = [row,col]
    #   return true
    # end
    case direction
    when "up"
      ship.length.times do 
        grid[row][col] = " 0 "
        ship.ship_location[space] = [row,col]
        space += 1
        row -= 1
      end
    when "down"
      ship.length.times do 
        grid[row][col] = " 0 "
        ship.ship_location[space] = [row,col]
        space += 1
        row += 1
      end
    when "right"
      ship.length.times do 
        grid[row][col] = " 0 "
        ship.ship_location[space] = [row,col]
        space += 1
        col += 1
      end
    when "left"
      ship.length.times do 
        grid[row][col] = " 0 "
        ship.ship_location[space] = [row,col]
        space += 1
        col -= 1
      end
    end
  end
  
  def get_user_choice
    options = []
    number = 1
    @choices.each_value do |direction|
      if direction != nil
        options << direction
      end
    end
    options.each do |direction|
      puts "[#{number}]: #{direction}"
      number += 1
    end
    loop do
      print "Choose a direction: "
      @answer = gets.chomp.to_i - 1
      break if (0..options.length).to_a.include?(@answer)
      puts "That's not a valid answer, try again: "
    end
    return options[@answer]
  end
  
  def get_random_choice
    options = []
    number = 1
    @choices.each_value do |direction|
      if direction != nil
        options << direction
      end
    end
    return options.sample
  end
  
  def coord_string_to_array(coordinate)
    coordinate_array = []
    coordinate_array << (coordinate[0].ord - 65)
    coordinate_array << (coordinate[1..-1].to_i) - 1
  end
  
  def get_user_input(ship_type = "", ship_length = 1, fire = true)
    if fire == true
      print "Input a coordinate to fire at: "
      coordinate = gets.chomp.upcase
    else
      print "Give me a coordinate to place your #{ship_type}: Length (#{ship_length}): "
      coordinate = gets.chomp.upcase
    end
    until is_coordinate?(coordinate) == true
      print "That's not a valid coordinate, try again: "
      coordinate = gets.chomp.upcase
    end
    return coord_string_to_array(coordinate)
  end
  
  def is_coordinate?(coordinate)
    coordinate[0] =~ /[A-J]/ && (1..10).to_a.include?(coordinate[1..-1].to_i)
  end
  
  def get_random_coordinate
    first = ["A","B","C","D","E","F","G","H","I","J"].to_a.sample
    second = rand(1..10).to_s
    return coord_string_to_array(first + second)
  end
  
  def check_spacing?(grid, ship, coordinate)
    row = coordinate[0]
    col = coordinate[1]
    if grid.grid[row][col] == "   " 
      check_vertical(ship.length, grid.grid, coordinate)
      check_horizontal(ship.length, grid.grid, coordinate)
      return true
    else grid.grid[row][col] == " 0 "
      return false
    end
  end
  
  def check_vertical(length, grid, coordinate)
    row = coordinate[0]
    col = coordinate[1]
    directions = [[row, col, -1, "up"], [row, col, 1, "down"]]
    directions.each do |direction|
      r = row
      c = col
      poss_options = (0..9).to_a
      (length - 1).times do
        r += direction[2]
        if poss_options.include?(r)
          if grid[r][c] == nil || grid[r][c] == " 0 "
            @choices[direction[3].to_sym] = nil
          end
        else 
           @choices[direction[3].to_sym] = nil
        end
      end
    end
  end

  def check_horizontal(length, grid, coordinate)
    row = coordinate[0]
    col = coordinate[1]
    directions = [[row, col, 1, "right"], [row, col, -1, "left"]]
    directions.each do |direction|
      r = row
      c = col
      poss_options = (0..9).to_a
      (length - 1).times do
        c += direction[2]
        if poss_options.include?(c)
          if grid[r][c] == nil || grid[r][c] == " 0 "
            @choices[direction[3].to_sym] = nil
          end
        else 
           @choices[direction[3].to_sym] = nil
        end
      end
    end
  end
  
  ############ TERMINAL COLOR OUTPUT ####################
  def colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end
  def red(text); colorize(text, 31); end
  def green(text); colorize(text, 32); end
  def yellow(text); colorize(text, 33); end
  #######################################################  
end

class Grid
  attr_accessor :grid
  
  def initialize  
    @grid = [["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "],
             ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "],
             ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "],
             ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "],
             ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "],
             ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "],
             ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "],
             ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "],
             ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "],
             ["   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   ", "   "]]
  end
end

class Ship
  attr_accessor :ship_location
  attr_reader :type, :length
  def initialize(type, length)
    @type = type
    @length = length
    @ship_location = Array.new(@length)
  end
  
  def sunk?
    @ship_location.each do |status|
      if status.last != "hit"
        return false
      end
    end
    return true
  end  
end

game = BattleShip.new
game.play_game  

loop do # New game function
  new_game = false
  print "Play again [y/n]: "
  choice = gets.chomp.downcase
  if choice == "y"
    game_new = BattleShip.new
    game_new.play_game
  elsif choice == "n"
    new_game = true
  else
    new_game = false
  end
  break if new_game == true
  puts "Not a valid option."
end