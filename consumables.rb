class Consumables

	attr_reader :radius, :x, :y

	def initialize(window, kind)
		@kind = kind
		@sprite = Gosu::Image.load_tiles("images/#{@kind}.png", 25, 25)
		@radius = 12
		@x = x = rand(39..760)
		@y = y = rand(54..500)
	end

	def draw
		frame = Gosu.milliseconds / 100 % @sprite.count
		@sprite[frame].draw(@x, @y, 1)
	end
end