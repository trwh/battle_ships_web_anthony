class Board
	attr_reader :grid

	def initialize(cell)
		@grid = {}
		[*"A".."J"].each do |l|
			[*1..10].each do |n|
				@grid["#{l}#{n}".to_sym] = cell.new
				@grid["#{l}#{n}".to_sym].content = Water.new
			end
		end
	end

	def html_grid
		curses_grid = " 1234567890<br>"
		[*"A".."J"].each do |x|
			curses_grid += x
			[*1..10].each do |y|
				if @grid["#{x}#{y}".to_sym].content.class == Water
					if @grid["#{x}#{y}".to_sym].hit?
						curses_grid += "m"
					else
						curses_grid += "."
					end
				else
					if @grid["#{x}#{y}".to_sym].hit?
						curses_grid += "x"
					else
						curses_grid += "s"
					end
				end
			end
			curses_grid += "<br>"
		end
		curses_grid
	end

	def place(ship, coord, orientation = :horizontally)
		coords = [coord]
		(ship.size - 1).times{coords << next_coord(coords.last, orientation)}
		put_on_grid_if_possible(coords, ship)
	end

	def floating_ships?
		ships.any?(&:floating?)
	end

	def shoot_at(coordinate)
		raise "You cannot hit the same square twice" if  grid[coordinate].hit?
		grid[coordinate].shoot
	end

	def ships
		grid.values.select{|cell|is_a_ship?(cell)}.map(&:content).uniq
	end

	def ships_count
		ships.count
	end

private

 	def next_coord(coord, orientation)
		orientation == :vertically ? next_vertical(coord) : coord.next
	end

	def next_vertical(coord)
		coord.to_s.reverse.next.reverse.to_sym
	end

	def is_a_ship?(cell)
		cell.content.respond_to?(:sunk?)
	end

	def any_coord_not_on_grid?(coords)
		(grid.keys & coords) != coords
	end

	def any_coord_is_already_a_ship?(coords)
		coords.any?{|coord| is_a_ship?(grid[coord])}
	end

	def raise_errors_if_cant_place_ship(coords)
		raise "You cannot place a ship outside of the grid" if any_coord_not_on_grid?(coords)
		raise "You cannot place a ship on another ship" if any_coord_is_already_a_ship?(coords)
	end

	def put_on_grid_if_possible(coords, ship)
		raise_errors_if_cant_place_ship(coords)
		coords.each{|coord|grid[coord].content = ship}
	end

end
