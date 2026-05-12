class Hand
  attr :cards, :bet, :outcome, :in_play

  def initialize(x, y, bet)
    @cards = []
    @x = x
    @y = y
    @bet = bet
    @outcome = :undecided
    @in_play = true
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
      c.x = starting_x + (i * step)
      c.y = @y
    end
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

  def primitives
    [
      @cards.flat_map { |c| c.primitives }
    ]
  end
end