class Hand
  attr :cards, :bet, :outcome, :in_play
  attr_accessor :value_pos_enum

  #TODO: MAKE CARDS EASE VIA TICK

  def initialize(x, y, bet, value_pos_enum = 2)
    @cards = []
    @x = x
    @y = y
    @bet = bet
    @outcome = :undecided
    @in_play = true
    @value_pos_enum = value_pos_enum
    @resetting = false
    @reset_at = 0
  end

  def tick
    @cards.each { |c| c.tick}

    if @resetting && @reset_at.elapsed_time >= 0.25.seconds
      @resetting = false
      @cards.clear
    end
  end

  def reset
    @cards.each { |c| c.fade_destroy }
    @reset_at = Kernel.tick_count
    @resetting = true
  end

  def x=(value)
    @x = value
    calc_card_positions
  end

  def add(card)
    @cards << card
    calc_card_positions
  end

  def clear
    @card.clear
  end

  def calc_card_positions
    card_w = 128
    spacing = 32
    step = card_w + spacing

    total_width = 
      if @cards.size <= 1
        card_w
      else
        card_w + ((@cards.size - 1) * step)
      end

    starting_x = 
    if @cards.size <= 1
      @x
    else
      @x - (total_width / 2) + (card_w / 2)
    end

    @cards.each_with_index do |c, i|
      new_x = starting_x + (i * step)
      c.move_event_at = Kernel.tick_count
      c.target_x = new_x
      c.target_y = @y
    end
  end

  def rendered_width
    card_w = 128
    spacing = 32

    return card_w if @cards.size <= 1

    card_w + ((@cards.size - 1) * (card_w + spacing))
  end

  def total_value
    sum = 0

    @cards.each do |c|
        sum += c.actual_value if c.face
    end

    @cards.each do |c|
      if c.value == 1 && sum > 21 && c.face
        sum -= 10
      end
    end

    sum
  end

  def soft_total?
    total = 0
    aces = 0

    @cards.each do |c|
      next unless c.face

      total += c.actual_value
      aces += 1 if c.value == 1
    end

    while total > 21 && aces > 0
      total -= 10
      aces -= 1
    end

    aces > 0
  end

  def primitives
    [
      @cards.flat_map { |c| c.primitives },
    ]
  end

  def score_label_primitive
    case @value_pos_enum
      when 0
        value_pos = @y - 135
      when 1
        value_pos = @y + 64
      when 2
        value_pos = @y + 135 + 24
      else
        value_pos = @y
    end

    {
      primitive_marker: :label,
      font: $font,
      x: @x,
      y: value_pos,
      alignment_enum: 1,
      size_enum: 5,
      r: 255,
      g: 0,
      b: 0,
      text: "#{total_value}"
    }
  end
end
