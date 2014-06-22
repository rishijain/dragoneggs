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
    BASKETCOUNT.times  {|d| @rings << Basket.new(self, 400*d + 600, 500)}
    @fall_count = 0
    @bg = Gosu::Image.new self, 'cloud.jpg'
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

    @rings.each {|d| d.x = d.x - 7}
  end

  def free_fall_completed?(egg)
    egg.y > 550
  end
end


class Egg 
  
  attr_accessor :free_fall, :x, :y, :w, :h

  def initialize(window, x, y)
    @x = x
    @y = y
    @w = 10
    @h = 20
    @image = Gosu::Image.new(window, 'red-balloon.png', false)
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
    @image = Gosu::Image.new(window, 'red-balloon.png', false)
  end

  def draw
    @image.draw(@x, @y, 1)
  end

  def update
  end
end

game = Game.new
game.show
