require 'gosu'
EGGCOUNT = 10
GRAVITY = 5
BASKETCOUNT = 50
class Game < Gosu::Window
  def initialize
    super 800, 600, false
    self.caption = 'Drop the f*ing egg.'
    @eggs = []
    EGGCOUNT.times {|d| @eggs << Egg.new(self, 400*d + 400, 100)}
    @rings = []
    BASKETCOUNT.times  {|d| @rings << Basket.new(self, 400*d + 600, 500 - 10*rand(20))}
    @fall_count = 0
    @bg = Gosu::Image.new self, 'cloud.jpg'
    @score = 0
  end

  def draw
    @bg.draw(0, 0, 0)
    @eggs.each {|egg| egg.draw}
    @rings.each {|ring| ring.draw}
  end

  def update
    current_egg = @eggs.select {|d| d if d.x < 750}[0]
    current_egg.y = current_egg.y + GRAVITY if current_egg.free_fall
    if button_down?(Gosu::KbSpace)
      current_egg.free_fall = true
    elsif button_down?(Gosu::KbLeft)
      current_egg.x = current_egg.x - 10 if current_egg.x > 100
    elsif button_down?(Gosu::KbRight)
      current_egg.x = current_egg.x + 10 if current_egg.x < 700
    end

    if free_fall_completed?(current_egg)
      @fall_count += 1
      next_egg = @eggs[@eggs.index(current_egg) + 1]
      next_egg.x = next_egg.x - (400 * @fall_count)
      @eggs.delete current_egg
    end

    @rings.each do |d| 
      d.x = d.x - 4
      if egg_into_basket(current_egg, d) && !current_egg.already_counted
        current_egg.already_counted = true
        @score += 1 
      end
    end
  end

  def free_fall_completed?(egg)
    egg.y > 550
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
