require_relative "card"

class Deck
  attr :deck
  def initialize
    @deck = [
      Card.new(:heart, 13),
      Card.new(:heart, 12),
      Card.new(:heart, 11),
      Card.new(:heart, 10),
      Card.new(:heart, 9),
      Card.new(:heart, 8),
      Card.new(:heart, 7),
      Card.new(:heart, 6),
      Card.new(:heart, 5),
      Card.new(:heart, 4),
      Card.new(:heart, 3),
      Card.new(:heart, 2),
      Card.new(:heart, 1),

      Card.new(:diamond, 13),
      Card.new(:diamond, 12),
      Card.new(:diamond, 11),
      Card.new(:diamond, 10),
      Card.new(:diamond, 9),
      Card.new(:diamond, 8),
      Card.new(:diamond, 7),
      Card.new(:diamond, 6),
      Card.new(:diamond, 5),
      Card.new(:diamond, 4),
      Card.new(:diamond, 3),
      Card.new(:diamond, 2),
      Card.new(:diamond, 1),

      Card.new(:club, 13),
      Card.new(:club, 12),
      Card.new(:club, 11),
      Card.new(:club, 10),
      Card.new(:club, 9),
      Card.new(:club, 8),
      Card.new(:club, 7),
      Card.new(:club, 6),
      Card.new(:club, 5),
      Card.new(:club, 4),
      Card.new(:club, 3),
      Card.new(:club, 2),
      Card.new(:club, 1),

      Card.new(:spade, 13),
      Card.new(:spade, 12),
      Card.new(:spade, 11),
      Card.new(:spade, 10),
      Card.new(:spade, 9),
      Card.new(:spade, 8),
      Card.new(:spade, 7),
      Card.new(:spade, 6),
      Card.new(:spade, 5),
      Card.new(:spade, 4),
      Card.new(:spade, 3),
      Card.new(:spade, 2),
      Card.new(:spade, 1),
    ]

    @discards = []
  end

  def draw(face = true)
    reshuffle if @deck.empty?

    drawn = @deck.sample
    
    @deck.delete_if { |c| c.value == drawn.value && c.suit == drawn.suit }
    @discards << drawn

    drawn.face = face

    drawn
  end

  def reshuffle
    puts "Reshuffling discard into deck"
    @deck = @deck + @discards
    @discards.clear
    @deck.shuffle
  end
  
end