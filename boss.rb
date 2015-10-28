class Boss

	WIDTH = 800
	HEIGHT = 600
	attr_reader :radius_x, :radius_y, :x, :y

	def initialize(window, player_angle)
		@image = Gosu::Image.new('images/boss.png')
		@radius_x = 102
		@radius_y = 150
		@x = (WIDTH/2) - @radius_x
		@y = 0
	end

	def draw
		@image.draw(@x, @y, 1)
	end

	def move(x)
		@x = (x)-@radius_x
		if @x < 0
			@x = 0
		elsif @x > 800-204
			@x = 800-204			
		end
	end
end