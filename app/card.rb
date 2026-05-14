class Card
  attr :suit, :value, :face, :x, :y

  def initialize(suit, value, face_sprite_path)
    @x = 0
    @y = 0
    @w = 88
    @h = 128
    @suit = suit
    @value = value
    @face = false
    @face_sprite_path = face_sprite_path
    @back_sprite_path = "sprites/cards/back01.png"
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
        "A"
      when 11
        "J"
      when 12
        "Q"
      when 13
        "K"
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
    if @face
      all_primitives << {
        primitive_marker: :sprite,
        x: @x,
        y: @y,
        anchor_x: 0.5,
        anchor_y: 0.5,
        w: @w,
        h: @h,
        path: @face_sprite_path
      }
    else
      all_primitives << {
        primitive_marker: :sprite,
        x: @x,
        y: @y,
        anchor_x: 0.5,
        anchor_y: 0.5,
        w: @w,
        h: @h,
        path: @back_sprite_path
      }
    end

    all_primitives
  end
end