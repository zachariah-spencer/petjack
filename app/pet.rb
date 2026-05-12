class Pet
  attr_reader :level, :name, :coins, :coins_needed, :coins, :coins_needed

  def initialize
    # core render vars
    @x = 50
    @y = 50
    @w = 64
    @h = 64
    @color = { r: 200, g: 0, b: 0 }

    # physics vars
    @jump_velocity = Numeric.rand(10..20)
    @acceleration = 0.1
    @gravity = 0.66
    @dx = 0
    @dy = 0
    @target_dx = 0
    @target_dy = 0

    # AI vars
    @state = :idle
    @state_timer = Kernel.tick_count
    @state_change_time = Numeric.rand(1..3)
    @jump_timer = Kernel.tick_count
    @jump_time = Numeric.rand(1..5)

    # game vars
    @name = "Dick Johnson"
    @level = 1
    @coins = 0
    @coins_needed = 10
    @level_chart = {
      1 => 10,
      2 => 20,
      3 => 35,
      4 => 50,
      5 => 75,
      6 => 110,
      7 => 150,
      8 => 200,
      9 => 250,
      10 => 300
    }
  end

  def tick

    # handle AI
    if @state_timer.elapsed_time >= @state_change_time.seconds
      puts @state_change_time.seconds
      @state_timer = Kernel.tick_count
      @state_change_time = Numeric.rand(1..5)

      if @state == :idle
        @state = :moving

        direction = [-1, 1].sample
        speed = Numeric.rand(2..10)

        @target_dx = direction * speed

      elsif @state == :moving
        @state = :idle
        @target_dx = 0
      end
    end

    if @jump_timer.elapsed_time >= @jump_time.seconds
      @jump_timer = Kernel.tick_count
      @jump_time = Numeric.rand(1..8)
      @jump_height = Numeric.rand(10..30)

      @dy = @jump_velocity
    end

    # apply physics
    @dx = @dx.lerp(@target_dx, @acceleration)
    @dy -= @gravity

    @x += @dx
    @y += @dy

    # handle collisions
    if @x > Grid.w - @w
      @x = Grid.w - @w
      @dx = @dx * -1
      @target_dx = @target_dx * -1
    end
    if @x < 0
      @x = 0
      @dx = @dx * -1
      @target_dx = @target_dx * -1
    end

    if @y > Grid.h - @h
      @y = Grid.h - @h
      @dy = @dy * -1
      @target_dy = @target_dy * -1
    end
    if @y < 50
      @y = 50
      @dy = 0
      @target_dy = 0
    end

  end

  def level_up()
    @level += 1
    @coins -= @coins_needed

    if @level_chart[@level]
      @coins_needed = @level_chart[@level]
    else
      @coins_needed = 300
    end

    case @level
    when 1
      @color = { r: 255, g: 0, b: 0 }
    when 2
      @color = { r: 255, g: 165, b: 0 }
    when 3
      @color = { r: 255, g: 255, b: 0 }
    when 4
      @color = { r: 0, g: 255, b: 0 }
    when 5
      @color = { r: 255, g: 0, b: 255 }
    end
  end

  def coins=(new_coins)
    @coins = new_coins
    if @coins >= @coins_needed
      level_up
    end
  end

  def draw
    {
      primitive_marker: :solid,
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