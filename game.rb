require 'gosu'
require 'yaml'

class Game < Gosu::Window

  def initialize
    #load all constants
    @config = YAML.load_file('config.yml')

    super @config['game']['x_par'], @config['game']['y_par'], false
    self.caption = 'Drop the f*ing egg.'
    
    @bg = Gosu::Image.new self, 'cloud.jpg'
    @logo = Gosu::Image.new self, 'logo.png'
    
    #initialize the eggs
    @eggs = []
    @config['eggs']['count'].times {|d| @eggs << Egg.new(self, 400*d + 400, 100)}
    
    #initialize the rings
    @rings = []
    @config['baskets']['count'].times  {|d| @rings << Basket.new(self, 400*d + 600, 500 - 10*rand(20))}
    
    @fall_count = 0
    @score = 0
    
    @score_message = Gosu::Image.new self, 'score_message.png'
    @score_value = Gosu::Font.new(self, Gosu::default_font_name, 35)
    @game_track = Gosu::Song.new(self, "gametrack.mp3")
  end

  def display_score
    @score_message.draw(0, 20 ,0)
    @score_value.draw(@score, 150, 20, 0, 1, 1, 0xff000000)
  end

  def draw_object(objects, object_type = nil)
    objects.each(&:draw)
  end
  
  def draw_background_and_logo
    @bg.draw(0, 0, 0)
    @logo.draw(300, 10, 0)
  end

  def draw
    draw_background_and_logo
    draw_object(@eggs)
    draw_object(@rings)
    display_score
  end

  def get_egg(position)
    @eggs[position]
  end

  def update_next_egg_position(position)
    @fall_count += 1  #the egg has fallen, so increase fall count by 1

    #find the next egg in array which should be new current egg
    next_egg = get_egg(position + 1)

    #the new current egg should move -400 to come within the visible part of the screen
    next_egg.x = next_egg.x - (400 * @fall_count)
  end

  def update_current_egg(egg)
    egg.y = egg.y + @config['game']['gravity'] if egg.free_fall 
    #when pressed space, current egg should fall
    if button_down?(Gosu::KbSpace)
     egg.free_fall!
    #to move the curret egg left and right only when it is at its starting position 
    elsif button_down?(Gosu::KbLeft) && !egg.free_fall
      egg.x = egg.x - 10 if egg.x > 100
    elsif button_down?(Gosu::KbRight) && !egg.free_fall
      egg.x = egg.x + 10 if egg.x < 700
    end
  end

  def update_rings(current_egg)
    @rings.each do |d| 

      #the ring should always keep moving to left
      d.x = d.x - @config['baskets']['speed']

      #check the egg is fallen into basket only if current egg is not counted (i.e not in the basket already)
      if !current_egg.has_fallen_into_a_basket && egg_into_basket(current_egg, d)
        current_egg.has_fallen_into_a_basket = true
        current_egg.free_fall = false
        @score += 1 
      end
    end
  end
  
  def button_down(id)
    close if id == Gosu::KbEscape
  end

  def free_fall_completed?(egg)
    egg.y > 550 || egg.has_fallen_into_a_basket
  end

  def egg_into_basket(egg, basket)
    basket.x <= egg.x &&
    (egg.x-basket.x).between?(0, 35) &&
    egg.y <= basket.y &&
    (basket.y - egg.y).between?(0, 15)
  end

  def update
    #play the gametrack on loop
    @game_track.play(true)

    #find current egg and current position
    current_egg = get_egg(@fall_count)
    current_position = @fall_count
    
    #move the egg along with the basket when it falls upon one
    @eggs.each {|d| d.x = d.x - @config['baskets']['speed'] if d.has_fallen_into_a_basket}

    #check for user input 
    update_current_egg(current_egg)

    #if current egg has fallen off the screen or is into the basket
    update_next_egg_position(@fall_count) if free_fall_completed?(current_egg)
    
    #update the rign state
    update_rings(current_egg)
  end
end


class Egg 
  
  attr_accessor :free_fall, :x, :y, :w, :h, :has_fallen_into_a_basket

  def initialize(window, x, y)
    @x = x
    @y = y
    @w = 10
    @h = 20
    @image = Gosu::Image.new(window, 'bad_egg.png', false)
  end

  def draw
    @image.draw(@x, @y, 1)
  end

  def update
  end

  def free_fall!
    self.free_fall = true
  end
end

class Basket
  attr_accessor :x, :y, :w, :h

  def initialize(window, x, y)
    @x = x
    @y = y
    @w = 10
    @h = 20
    @image = Gosu::Image.new(window, 'basket.png', false)
  end

  def draw
    @image.draw(@x, @y, 1)
  end

  def update
  end
end

game = Game.new
game.show
