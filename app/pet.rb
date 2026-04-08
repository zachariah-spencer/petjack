class Pet
  def initialize
    @x = 50
    @y = 50
    @w = 64
    @h = 64

    @color = { r: 255, g: 0, b: 0 }

    @wander_timer = Kernel.tick_count
    @state_change_time = Numeric.rand(1..5)
    @state = :idle

    $tickables[self] = self
  end

  def tick
    if @wander_timer.elapsed_time >= @state_change_time.seconds
      @wander_timer = Kernel.tick_count
      @state_change_time = Numeric.rand(1..5)

      if @state == :idle
        @state = :moving
      elsif @state == :moving
        @state = :idle
      end
    end
  end

  def draw
    {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      r: @color[:r],
      g: @color[:g],
      b: @color[:b]
    }
  end
end