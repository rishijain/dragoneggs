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
