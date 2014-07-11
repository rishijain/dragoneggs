require 'gosu'

EGGCOUNT = 100
GRAVITY = 5
BASKETCOUNT = 500
RINGSPEED = 4

class Game < Gosu::Window

  def initialize
    super 800, 600, false
    self.caption = 'Drop the f*ing egg.'
    @bg = Gosu::Image.new self, 'cloud.jpg'
    @logo = Gosu::Image.new self, 'logo.png'
    
    #initialize the eggs
    @eggs = []
    EGGCOUNT.times {|d| @eggs << Egg.new(self, 400*d + 400, 100)}
    
    #initialize the rings
    @rings = []
    BASKETCOUNT.times  {|d| @rings << Basket.new(self, 400*d + 600, 500 - 10*rand(20))}
    
    @fall_count = 0
    @score = 0
    
    @score_message = Gosu::Image.new self, 'score_message.png'
    @score_value = Gosu::Font.new(self, Gosu::default_font_name, 35)
    @game_track = Gosu::Song.new(self, "gametrack.mp3")
  end

  def draw
    @bg.draw(0, 0, 0)
    @eggs.each {|egg| egg.draw}
    @rings.each {|ring| ring.draw}
    @score_message.draw(0, 20 ,0)
    @logo.draw(300, 10, 0)
    @score_value.draw(@score, 150, 20, 0, 1, 1, 0xff000000)
  end

  def update
    @game_track.play(true)
    current_egg = @eggs[@fall_count]
    
    #to move the egg when it falls on the basket
    @eggs.each {|d| d.x = d.x - RINGSPEED if d.already_counted}

    #for the current egg to keep falling
    current_egg.y = current_egg.y + GRAVITY if current_egg.free_fall 
    
    #when pressed space, current egg should fall
    if button_down?(Gosu::KbSpace)
      current_egg.free_fall = true
    
    #to move the curret egg left and right only when it is at its starting position 
    elsif button_down?(Gosu::KbLeft) && current_egg.free_fall != true
      current_egg.x = current_egg.x - 10 if current_egg.x > 100
    elsif button_down?(Gosu::KbRight) && current_egg.free_fall != true
      current_egg.x = current_egg.x + 10 if current_egg.x < 700
    end

    #if current egg has fallen off the screen or is into the basket
    if free_fall_completed?(current_egg)
      @fall_count += 1 

      #find the next egg in array which should be new current egg
      next_egg = @eggs[@eggs.index(current_egg) + 1]

      #the new current egg should move -400 to come within the visible part of the screen
      next_egg.x = next_egg.x - (400 * @fall_count)
    end

    @rings.each do |d| 

      #the ring should always keep moving to left
      d.x = d.x - RINGSPEED

      #check the egg is fallen into basket only if current egg is not counted (i.e not in the basket already)
      if egg_into_basket(current_egg, d) && !current_egg.already_counted
        current_egg.already_counted = true
        current_egg.free_fall = false
        @score += 1 
      end
    end

    def button_down id
      close if id == Gosu::KbEscape
    end

  end

  def free_fall_completed?(egg)
    egg.y > 550 || egg.already_counted
  end

  def egg_into_basket(egg, basket)
    basket.x <= egg.x &&
    (egg.x-basket.x).between?(0, 35) &&
    egg.y <= basket.y &&
    (basket.y - egg.y).between?(0, 15)
  end
end


class Egg 
  
  attr_accessor :free_fall, :x, :y, :w, :h, :already_counted

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
