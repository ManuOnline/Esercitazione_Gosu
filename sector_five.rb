require 'rubygems'
require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'credit'
require_relative 'consumables'
require_relative 'boss'
require_relative 'stars'

module ZOrder
	Background, Stars, Consumables, Enemy, Player, Bullets, Boss, Texts= *0..8
end

class SectorFive < Gosu::Window

	WIDTH = 800
	HEIGHT = 600
	ENEMY_FREQUENCY = 0.02
	MAX_ENEMIES = 100
	CONSUMABLES_FREQUENCY = 0.002
	STARS_FREQUENCY = 0.001

	def initialize
		super(WIDTH, HEIGHT)
		self.caption = 'Sector Five'
		@background_image = Gosu::Image.new('images/start_screen.png')
		@scene = :start
		@start_music = Gosu::Song.new('sounds/Lost Frontier.ogg')
		@start_music.play(true)
	end

	def initialize_game
		@player = Player.new(self)
		@enemy 	= Enemy.new(self)
		@enemies = []
		@bullets = []
		@explosions = []
		@enemy_bullets = []
		@scene = :game
		@enemies_appeared = 0
		@enemies_destroyed = 0
		@life_image = Gosu::Image.new('images/life.png')
		@life = 5
		@game_music = Gosu::Song.new('sounds/Cephalopod.ogg')
		@game_music.play(true)
		@explosion_sound = Gosu::Sample.new('sounds/explosion.ogg')
		@shooting_sound = Gosu::Sample.new('sounds/shoot.ogg')
		@background_stage_1 = Gosu::Image.new('images/schema1.png')
		@danger_sound = Gosu::Sample.new('sounds/danger.wav')
		#-------------------------------------------------------pause
		@paused = false
		@background_pause = Gosu::Image.new('images/pause.png')
		@sounds = []

		#--------------------------------------------------------consumables
		@taken_sound = Gosu::Sample.new('sounds/taken.wav')
		@invulnerability = Consumables.new(self, :invulnerability)
		@ammo = Consumables.new(self, :ammo)
		@ammo_length = 0
		@ammo_sound = Gosu::Sample.new('sounds/ammo.wav')
		@bomb = Consumables.new(self, :bomb)
		@bomb_armed = false
		@bomb_sound = Gosu::Sample.new('sounds/bomb.wav')
		@life_cons = Consumables.new(self, :life)
		@rand_cons = [@invulnerability, @bomb, @ammo, @life_cons]
		@consumables = []
		@invulnerability_length = 0
		@invulnerable = false if @invulnerability_length == 0
		@bubble = Gosu::Image.load_tiles('images/bolla2.png', 54, 54)
		@stars = []
		@ad_font = Gosu::Font.new(22)

	end

	def initialize_boss
		@scene = :boss
		@player = Player.new(self)
		@boss = Boss.new(self, @player.angle)
		@hitboss = Gosu::Image.new('images/hitboss.png')
		@boss_damaged = false
		@hit_length = 0
		@boss_life = 100
		@boss_bullets = []
		@boss_font = Gosu::Font.new(22)
		@fire_frequency = 0.03
		@explosions_frequency = 0.09
	end

	def initialize_end(fate)
		case fate
		when :victory
			@message = "You made it! You destroyed #{@enemies_destroyed} ships"
			@message2 = "and #{100 - @enemies_destroyed} reached the base."
		when :hit_by_enemy
			@message = "You were struck by an enemy ship."
			@message2 = "Before your ship was destroyed, "
			@message2 += "you took out #{@enemies_destroyed} enemy ships."
		when :boss_wins
			@message = "You were struck by the enemy mother ship."
			@message2 = "Before your ship was destroyed, "
			@message2 += "you took out #{@enemies_destroyed} enemy ships."
		when :off_top
			@message = "You got too close to the enemy mother ship."
			@message2 = "Before your ship was destroyed, "
			@message2 += "you took out #{@enemies_destroyed} enemy ships."
		end
		@bottom_message = "Press P to play again, or Q to quit the game."
		@message_font = Gosu::Font.new(22)
		@credits = []
		y = 700
		File.open('credits.txt').each do |line|
			@credits.push(Credit.new(self, line.chomp,100,y))
			y += 30
		end
		@scene = :end
		@end_music = Gosu::Song.new('sounds/FromHere.ogg')
		@end_music.play(true)
	end

	def update
		case @scene
		when :game
			update_game
		when :boss
			update_boss
		when :end
			update_end
		end
	end

	def update_game
		if @paused == false
		@player.turn_left if button_down?(Gosu::KbLeft) || button_down?(Gosu::KbA)
		@player.turn_right if button_down?(Gosu::KbRight) || button_down?(Gosu::KbD)
		@player.accelerate if button_down?(Gosu::KbUp) || button_down?(Gosu::KbW)
		@player.move

		if rand < CONSUMABLES_FREQUENCY && @consumables.count == 0
			@consumables.push @rand_cons[rand(4)]
		end
		
		if rand < ENEMY_FREQUENCY
			@enemies.push Enemy.new(self)
			@enemies_appeared += 1
		end
		
		@enemies.each do |enemy|
			enemy.move
		end
		
		@bullets.each do |bullet|
			bullet.move
		end

		@explosions.each do |explosion|
			explosion.move
		end

		@enemy_bullets.each do |bullet|
			bullet.move
		end

		if rand < STARS_FREQUENCY
			@stars.push Stars.new(self)
		end
		@stars.each do |star|
			star.move
		end
		@stars.each do |star|
			@stars.delete star unless star.on_screen?
		end

		end#close if paused

		@enemies.dup.each do |enemy|
			@bullets.dup.each do |bullet|
				distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
				if distance < enemy.radius + bullet.radius
					@enemies.delete enemy
					@bullets.delete bullet
					@explosions.push Explosion.new(self, enemy.x, enemy.y)
					@enemies_destroyed += 1
					@sounds << @explosion_sound.play
				end
			end
		end

		@explosions.dup.each do |explosion|
			@explosions.delete explosion if explosion.finished
		end
		
		@enemies.dup.each do |enemy|
			if enemy.y > HEIGHT + enemy.radius
				@enemies.delete enemy
				@sounds << @danger_sound.play(1.6)
			end
		end

		@bullets.dup.each do |bullet|
			@bullets.delete bullet unless bullet.on_screen?
		end

		@enemy_bullets.dup.each do |bullet|
			distance = Gosu.distance(@player.x, @player.y, bullet.x, bullet.y)
			if distance < @player.radius + bullet.radius
				@enemy_bullets.delete bullet
				@explosions.push Explosion.new(self, @player.x, @player.y)
				@life -= 1 if @invulnerable == false
				@sounds << @explosion_sound.play
			end
		end

		@enemy_bullets.dup.each do |bullet|
			@enemy_bullets.delete bullet unless bullet.on_screen?
		end

		@enemies.dup.each do |enemy|
			if Gosu.distance(enemy.x, enemy.y, @player.x, @player.y) < 300 && rand < ENEMY_FREQUENCY
				@enemy_bullets.push EnemyBullet.new(self, enemy.x, enemy.y, @player.angle)
				@shooting_sound.play(0.3) if @paused != true
			end
		end

		@enemies.each do |enemy|
			distance = Gosu.distance(@player.x, @player.y, enemy.x, enemy.y)
			if distance < @player.radius + enemy.radius
				@enemies.delete enemy
				@explosions.push Explosion.new(self, @player.x, @player.y)
				@enemies_destroyed += 1
				@life -= 1 if @invulnerable == false
				@sounds << @explosion_sound.play
			end
		end

		@enemies.dup.each do |enemy|
			@explosions.dup.each do |explosion|
				distance = Gosu.distance(explosion.x, explosion.y, enemy.x, enemy.y)
				if distance < enemy.radius + explosion.radius
					@enemies.delete enemy
					@explosions.push Explosion.new(self, enemy.x, enemy.y)
					@enemies_destroyed += 1
					@sounds << @explosion_sound.play
				end
			end
		end

		@consumables.each do |cons|
			distance = Gosu.distance(@player.x, @player.y, cons.x, cons.y)
			if distance < @player.radius + cons.radius
				@sounds << @taken_sound.play
				case cons
				when @life_cons
					@life += 1 if @life < 5
					@consumables.delete cons
				when @invulnerability
					@invulnerability_length = 800
					@consumables.delete cons
				when @ammo
					@ammo_length = 800
					@consumables.delete cons
				when @bomb
					@bomb_armed = true
					@consumables.delete cons
				end
			end
		end

		if @invulnerability_length > 0
			@invulnerable = true
			@invulnerability_length -= 1
		else @invulnerable = false
		end

		if @ammo_length > 0
			@ammo_length -= 1
		end

		clear_stopped_sounds

		
		initialize_boss if @enemies_appeared > MAX_ENEMIES
		initialize_end(:hit_by_enemy) if @life < 1
		initialize_end(:off_top) if @player.y < -@player.radius && @invulnerable == false
	end

	def update_boss

		@boss_bullets.dup.each do |bullet|
			@boss_bullets.delete bullet unless bullet.on_screen?
				
			end
		
		@bullets.dup.each do |bullet|
			@bullets.delete bullet unless bullet.on_screen?
		end

		@explosions.dup.each do |explosion|
			@explosions.delete explosion if explosion.finished
		end

		clear_stopped_sounds

		@bullets.each do |bullet|
			if bullet.x.between?(@boss.x, @boss.x+205) && bullet.y.between?(@boss.y, @boss.y+300)
				@bullets.delete bullet
				@boss_damaged = true
				@hit_length = 8
				@explosions.push Explosion.new(self, bullet.x, bullet.y)
				@sounds << @explosion_sound.play
				@boss_life -= 1
			end
		end

		if @boss_life < 10
			if rand < @explosions_frequency
			@explosions.push Explosion.new(self, rand(@boss.x..@boss.x+205), rand(@boss.y..@boss.y+300))
			@sounds << @explosion_sound.play
			end
		end

		if @hit_length > 0
			@hit_length -= 1
		else @boss_damaged = false
		end

		if @player.x.between?(@boss.x, @boss.x+205) && @player.y.between?(@boss.y, @boss.y+300)
			@boss_damaged = true
			@hit_length = 8
			@explosions.push Explosion.new(self, @player.x, @player.y)
			@sounds << @explosion_sound.play
			@boss_life -= 1
			@life -= 1
		end

		@boss_bullets.dup.each do |bullet|
			if Gosu.distance(@player.x, @player.y, bullet.x+74, bullet.y) < @player.radius + bullet.radius
				@boss_bullets.delete bullet
				@explosions.push Explosion.new(self, @player.x, @player.y)
				@life -= 1 if @invulnerable == false
				@sounds << @explosion_sound.play
			end
		end

		@boss_bullets.dup.each do |bullet|
			if Gosu.distance(@player.x, @player.y, bullet.x+125, bullet.y) < @player.radius + bullet.radius
				@boss_bullets.delete bullet
				@explosions.push Explosion.new(self, @player.x, @player.y)
				@life -= 1 if @invulnerable == false
				@sounds << @explosion_sound.play
			end
		end

		if rand < @fire_frequency
			@boss_bullets.push BossBullet.new(self, @boss.x, @boss.y, @player.angle)
			#@boss_bullets.push BossBullet.new(self, @boss.x, @boss.y, @player.angle)
		end

		if @paused == false
		@player.turn_left if button_down?(Gosu::KbLeft) || button_down?(Gosu::KbA)
		@player.turn_right if button_down?(Gosu::KbRight) || button_down?(Gosu::KbD)
		@player.accelerate if button_down?(Gosu::KbUp) || button_down?(Gosu::KbW)

		@player.move
		@boss.move(@player.x)

		@explosions.each do |exp|
			exp.move
		end

		@boss_bullets.each do |bullet|
			bullet.move(@player.x)
		end
		
		@bullets.each do |bullet|
			bullet.move
		end
		end#close if paused

		initialize_end(:boss_wins) if @life < 1
		initialize_end(:off_top) if @player.y < -@player.radius && @invulnerable == false
		initialize_end(:victory) if @boss_life < 1
	end

	def update_end
		@credits.each do |credit|
			credit.move
		end
		if @credits.last.y < 150
			@credits.each do |credit|
				credit.reset
			end
		end
	end

	def draw
		case @scene
		when :start
			draw_start
		when :game
			draw_game
		when :boss
			draw_boss
		when :end
			draw_end
		end
	end

	def draw_start
		@background_image.draw(0, 0, 0)
	end

	def draw_game
		@background_stage_1.draw(0, 0, 0)
		@stars.each do |star|
			star.draw
		end
		@life_image.draw(10, 10, 3) if @life > 0
		@life_image.draw(40, 10, 3) if @life > 1
		@life_image.draw(70, 10, 3) if @life > 2
		@life_image.draw(100, 10, 3) if @life > 3
		@life_image.draw(130, 10, 3) if @life > 4

		@player.draw

		if @invulnerable == true
			frame = Gosu.milliseconds / 900 % @bubble.count
			@bubble[frame].draw_rot(@player.x, @player.y - 2, 2, @player.angle)
		end



		@enemies.each do |enemy|
			enemy.draw
		end
		@bullets.each do |bullet|
			bullet.draw
		end
		@explosions.each do |explosion|
			explosion.draw
		end

		@enemy_bullets.each do |bullet|
			bullet.draw
		end

		@consumables.each do |cons|
			cons.draw
		end

		posy = 10
		posy = 30 if @bomb_armed == true
		@ad_font.draw("Special Attack ready! (Press Left Control)", 160, 10, 3, 1, 1, Gosu::Color::YELLOW) if @bomb_armed == true
		@ad_font.draw("You are invulnerable!!", 160, posy, 3, 1, 1, Gosu::Color::YELLOW) if @invulnerable == true

		@background_pause.draw(0, 0, 4) if @paused == true

	end

	def draw_boss
		@boss.draw
		@hitboss.draw(@boss.x, @boss.y, 2) if @boss_damaged == true
		@background_stage_1.draw(0, 0, 0)
		@life_image.draw(10, 10, 3) if @life > 0
		@life_image.draw(40, 10, 3) if @life > 1
		@life_image.draw(70, 10, 3) if @life > 2
		@life_image.draw(100, 10, 3) if @life > 3
		@life_image.draw(130, 10, 3) if @life > 4

		@player.draw

		if @invulnerable == true
			frame = Gosu.milliseconds / 900 % @bubble.count
			@bubble[frame].draw_rot(@player.x, @player.y - 2, 2, @player.angle)
		end

		@bullets.each do |bullet|
			bullet.draw
		end
		@explosions.each do |explosion|
			explosion.draw
		end

		@boss_bullets.each do |bullet|
			bullet.draw
		end

		@boss_font.draw("Mother Ship life: #{@boss_life}", 564, 10, 3, 1, 1, Gosu::Color::RED)

		@background_pause.draw(0, 0, 4) if @paused == true
	end

	def draw_end
		clip_to(50, 140, 700, 360) do #x e y del punto di partenza e larghezza e lunghezza del rettangolo
			@credits.each do |credit|
				credit.draw
			end
		end
		draw_line(0, 140, Gosu::Color::RED, WIDTH, 140, Gosu::Color::RED)
		@message_font.draw(@message, 40, 40, 1, 1, 1, Gosu::Color::FUCHSIA)
		@message_font.draw(@message2, 40, 75, 1, 1, 1, Gosu::Color::FUCHSIA)
		draw_line(0, 500, Gosu::Color::RED, WIDTH, 500, Gosu::Color::RED)
		@message_font.draw(@bottom_message, 190, 540, 1, 1, 1, Gosu::Color::AQUA)
	end

	def button_down(id)
		case @scene
		when :start
			button_down_start(id)
		when :game
			button_down_game(id)
		when :boss
			button_down_game(id)
		when :end
			button_down_end(id)
		end
	end

	def button_down_start(id)
		initialize_game
	end

	def button_down_game(id)
		if id == Gosu::KbSpace && @paused == false
			@bullets.push Bullet.new(self, @player.x, @player.y, @player.angle, 5)
			@shooting_sound.play(0.3)
		end
		if id == Gosu::KbSpace && @ammo_length > 0 && @paused == false
				@bullets.push Bullet.new(self, @player.x, @player.y, @player.angle, 25)
				@ammo_sound.play(0.3)
		end
		if id == Gosu::KbEscape
			if @paused == false
				@paused = true
				@sounds.each do |sound|
					sound.pause
				end
				@game_music.pause
			elsif @paused == true
				@paused = false
				@sounds.each do |sound|
					sound.resume if sound.paused?
				end
				@game_music.play if @game_music.paused?
			end
		end
		if id == Gosu::KbLeftControl && @bomb_armed == true
			special_attack
		end

		#if id == Gosu::MsLeft
		#	puts "X: #{mouse_x}, Y: #{mouse_y}"
		#end
	end

	#def needs_cursor?
	#	true
	#end

	def button_down_end(id)
		if id == Gosu::KbP
			initialize_game
		elsif id == Gosu::KbQ
			close
		end
	end

	def clear_stopped_sounds
		@sounds.reject! {|sound| !sound.playing? && !sound.paused?}
	end

	def special_attack
		@enemies.dup.each do |enemy|
			distance = Gosu.distance(enemy.x, enemy.y, @player.x, @player.y)
			if distance < 300
				@enemies.delete enemy
				@explosions.push Explosion.new(self, enemy.x, enemy.y)
				@enemies_destroyed += 1
				@sounds << @bomb_sound.play
				@sounds << @explosion_sound.play
			end
		end
		@bomb_armed = false
	end
end
window = SectorFive.new
window.show