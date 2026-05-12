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

  def value_string
    if ![1, 11, 12, 13].include?(@value)
      @value
    else
      case @value
      when 1
        "Ace"
      when 11
        "Jack"
      when 12
        "Queen"
      when 13
        "King"
      end
    end
  end

  def actual_value
    if ![1, 11, 12, 13].include?(@value)
      @value
    else
      case @value
      when 1
        11
      when 11
        10
      when 12
        10
      when 13
        10
      end
    end
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
          x: @x,
          y: @y,
          alignment_enum: 1,
          text: "#{value_string}",
          size_enum: 3,
          r: 255
        }

        all_primitives << {
          primitive_marker: :label,
          x: @x,
          y: @y - 50,
          alignment_enum: 1,
          text: "#{@suit}",
          size_enum: 3,
          r: 255
        }
    else
        all_primitives << {
          primitive_marker: :label,
          x: @x,
          y: @y,
          alignment_enum: 1,
          text: "Face Down",
          size_enum: 3,
          r: 255
        }
    end

    all_primitives
  end
end