class Player

	ROTATION_SPEED = 4
	ACCELERATION = 2
	FRICTION = 0.7
	attr_reader :x, :y, :angle, :radius

	def initialize(window)
		@x = 400
		@y = 550
		@angle = 0
		@image = Gosu::Image.new('images/ship.png')
		@velocity_x = 0
		@velocity_y = 0
		@radius = 20
		@window = window
	end

	def draw
		@image.draw_rot(@x, @y, 1, @angle)
	end

	def turn_right
		@angle += ROTATION_SPEED
	end

	def turn_left
		@angle -= ROTATION_SPEED
	end

	def accelerate
		@velocity_x += Gosu.offset_x(@angle, ACCELERATION)
		@velocity_y += Gosu.offset_y(@angle, ACCELERATION)
	end

	def move
		@x += @velocity_x
		@y += @velocity_y
		@velocity_x *= FRICTION
		@velocity_y *= FRICTION
		if @x > @window.width - @radius
			@velocity_x = 0
			@angle *= -1
			@x = @window.width - (@radius*2)
		end
		if @x < @radius
			@velocity_x = 0
			@angle *= -1
			@x = @radius*2
		end
		if @y > @window.height - @radius
			@velocity_y = 0
			@angle *= -2
			@y = @window.height - (@radius*2)
		end
	end
end