class Stars
	
	SPEED = 10
	attr_reader :y

	def initialize(window)
		@image = Gosu::Image.load_tiles('images/star.png', 25, 25)
		@x = rand(0..775)
		@y = 0
		@window = window
		@radius = 25/2
	end

	def draw
		frame = Gosu.milliseconds / 100 % @image.count
		@image[frame].draw(@x, @y, ZOrder::Stars)
	end

	def move
		@y += SPEED
	end

	def on_screen?
		right = @window.width + @radius
		left = -@radius
		top = -@radius
		bottom = @window.height + @radius
		@x > left and @x < right and @y > top and @y < bottom
	end
end