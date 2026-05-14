class Card
  attr :suit, :value, :face, :x, :y, :target_x, :target_y, :move_event_at

  def initialize(suit, value, face_sprite_path)
    @x = Grid.w - 100
    @y = Grid.h - 128
    @target_x = Grid.w - 100
    @target_y = Grid.h - 128
    @move_event_at = Kernel.tick_count
    @fade_event_at = Kernel.tick_count
    @w = 88
    @h = 128
    @suit = suit
    @value = value
    @face = false
    @face_sprite_path = face_sprite_path
    @back_sprite_path = "sprites/cards/back01.png"
    @a = 255
    @target_a = 255
  end

  def tick
    perc = Easing.smooth_stop(start_at: @move_event_at, end_at: @move_event_at + 60, power: 2.0)
    fade_perc = Easing.smooth_stop(start_at: @fade_event_at, end_at: @fade_event_at + 60, power: 2.0)
    @x = @x.lerp(@target_x, perc)
    @y = @y.lerp(@target_y, perc)
    @a = @a.lerp(@target_a, fade_perc)
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

  def reset_for_draw(face)
    @face = face
    @a = 255
    @target_a = 255
    @fade_event_at = Kernel.tick_count
    @x = Grid.w - 100
    @y = Grid.h - 128
    @target_x = Grid.w - 100
    @target_y = Grid.h - 128
  end

  def fade_destroy
    @target_a = 0
    @fade_event_at = Kernel.tick_count
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
        a: @a,
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
        a: @a,
        path: @back_sprite_path
      }
    end

    all_primitives
  end
end