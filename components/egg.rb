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
