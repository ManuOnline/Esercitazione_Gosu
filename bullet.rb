class Bullet

	attr_reader :x, :y, :radius

	def initialize(window, x, y, angle, speed = 5)
		@x = x
		@y = y
		@direction = angle
		@image = Gosu::Image.new('images/bullet.png')
		@radius = 3
		@window = window
		@speed = speed
	end

	def move
		@x += Gosu.offset_x(@direction, @speed)
		@y += Gosu.offset_y(@direction, @speed)
	end

	def on_screen?
		right = @window.width + @radius
		left = -@radius
		top = -@radius
		bottom = @window.height + @radius
		@x > left and @x < right and @y > top and @y < bottom
	end

	def draw
		@image.draw(@x - @radius, @y - @radius, 1)
	end
end

class EnemyBullet

	SPEED = 5
	attr_reader :x, :y, :radius

	def initialize(window, x, y, angle)
		@x = x
		@y = y
		@direction = angle
		@image = Gosu::Image.new('images/enemy_bullet.png')
		@radius = 3
		@window = window
	end

	def move
		@x += Gosu.offset_x(@direction, SPEED)
		@y -= Gosu.offset_y((@direction*-1), SPEED)
	end

	def on_screen?
		right = @window.width + @radius
		left = -@radius
		top = -@radius
		bottom = @window.height + @radius
		@x > left and @x < right and @y > top and @y < bottom
	end

	def draw
		@image.draw(@x - @radius, @y - @radius, 1)
	end
end

class BossBullet

	WIDTH = 800
	HEIGHT = 600
	#attr_reader :x_left, :x_right, :y_left, :y_right, :radius, :angle
	attr_reader :x, :y, :radius, :angle

	def initialize(window, bossx, bossy, playerangle)
		#@x_left = bossx + 74
		#@x_right = bossx + 125
		@x = bossx
		@y = 187
		@image = Gosu::Image.new('images/laserboss.png')
		@angle = rand(-20..20)
		@radius = 3
		@window = window
		@speed = 5
	end

	def move(playerx)
		#@x_left += Gosu.offset_x(@angle, @speed)
		#@y_left -= Gosu.offset_y(1, @speed)
		#@x_right += Gosu.offset_x(@angle, @speed)
		#@y_right -= Gosu.offset_y(1, @speed)
		@x += Gosu.offset_x(@angle, @speed)
		@y -= Gosu.offset_y(1, @speed)
	end

	def draw
		#@image.draw(@x_left, @y_left, 3)
		#@image.draw(@x_right, @y_right, 3)
		@image.draw(@x+74, @y, 3)
		@image.draw(@x+125, @y, 3)
	end

	def on_screen?#left_on_screen?
		right = @window.width + @radius
		left = -@radius
		top = -@radius
		bottom = @window.height + @radius
		#@x_left > left and @x_left < right and @y_left > top and @y_left < bottom
		@x > left and @x < right and @y > top and @y < bottom
	end
	#def right_on_screen?
	#	right = @window.width + @radius
	#	left = -@radius
	#	top = -@radius
	#	bottom = @window.height + @radius
	#	@x_right > left and @x_right < right and @y_right > top and @y_right < bottom
	#end
end