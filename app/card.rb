class Card
  attr :suit, :value, :face, :x, :y

  def initialize(suit, value)
    @x = Numeric.rand(100..1180)
    @y = Numeric.rand(100..620)
    @w = 128
    @h = 256
    @suit = suit
    @value = value
    @face = false
  end

  def flip
    @face = !@face
  end

  def display_name
    if ![1, 11, 12, 13].include?(@value)
      display_value = @value
    else
      case @value
      when 1
        display_value = "Ace"
      when 11
        display_value = "Jack"
      when 12
        display_value = "Queen"
      when 13
        display_value = "King"
      end
    end

    "#{display_value} of #{@suit.capitalize}s"
  end

  def primitives
    all_primitives = []

    all_primitives << {
      primitive_marker: :solid,
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      anchor_x: 0.5,
      anchor_y: 0.5,
      r: 0,
      g: 150,
      b: 150,
      a: 200
    }
    if @face
        all_primitives << {
          primitive_marker: :label,
          x: @x - (@w / 2),
          y: @y,
          text: "#{display_name}",
          size_enum: 3,
          r: 255
        }
    else
        all_primitives << {
          primitive_marker: :label,
          x: @x - (@w / 2),
          y: @y,
          text: "Face Down",
          size_enum: 3,
          r: 255
        }
    end

    all_primitives
  end
end