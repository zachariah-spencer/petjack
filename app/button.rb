class Button
  attr_reader :x, :y, :w, :h

  def initialize(x, y, w, h, text, action = nil, enabled_when: nil, &block)
    @x, @y, @w, @h = x, y, w, h
    @text = text
    @action = action || block
    @hovered = false
    @pressed = false
    @enabled_when = enabled_when || -> { true }
    @fade_event_at = Kernel.tick_count
    @a = enabled? ? 255 : 0
    @target_a = @a
  end

  def rect
    {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
    }
  end

  def enabled?
    @enabled_when.call
  end

  def tick(inputs)
    next_target_a = enabled? ? 255 : 0
    if next_target_a != @target_a
      @target_a = next_target_a
      @fade_event_at = Kernel.tick_count
    end

    fade_perc = Easing.smooth_stop(start_at: @fade_event_at, end_at: @fade_event_at + 30, power: 2.0)
    @a = @a.lerp(@target_a, fade_perc)

    unless enabled?
      @hovered = false
      @pressed = false
      return
    end

    mouse = inputs.mouse
    @hovered = mouse.inside_rect?(rect)
    @pressed = @hovered && mouse.button_left

    if @hovered && mouse.click
      @action&.call
    end
  end

  def primitives
    return [] if @a <= 0

    bg = 
    if @pressed
      { r: 180, g: 180, b: 180 }
    elsif @hovered
      { r: 220, g: 220, b: 220 }
    else
      { r: 255, g: 255, b: 255 }
    end

    [
      rect.merge(primitive_marker: :solid, a: @a, **bg),
      rect.merge(primitive_marker: :border, r: 0, g: 0, b: 0, a: @a),
      {
        primitive_marker: :label,
        x: @x + @w / 2,
        y: @y + @h / 2,
        font: $font,
        text: @text,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        r: 0, g: 0, b: 0,
        a: @a
      }
    ]
  end
end
