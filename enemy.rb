class Enemy

	attr_reader :x, :y, :radius, :speed

	def initialize(window)
		@radius = 20
		@x = rand(window.width - 2 * @radius) + @radius
		@y = 0
		@image = Gosu::Image.new('images/enemy.png')
		@angle = rand(-20..21)
		@window = window
		@speed = rand(4) + 1
	end

	def move
		@y -= Gosu.offset_y(1, @speed)
		@x += Gosu.offset_x(@angle, @speed)
		if @x > @window.width - @radius
			@angle *= -1
		end
		if @x < @radius
			@angle *= -1
		end
	end

	def draw
		@image.draw(@x - @radius, @y - @radius, 2)
	end
end