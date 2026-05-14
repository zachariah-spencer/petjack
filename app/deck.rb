require_relative "card"

class Deck
  attr :deck
  def initialize
    @deck = [
      Card.new(:heart, 13, "sprites/cards/hearts_king.png"),
      Card.new(:heart, 12, "sprites/cards/hearts_queen.png"),
      Card.new(:heart, 11, "sprites/cards/hearts_jack.png"),
      Card.new(:heart, 10, "sprites/cards/hearts_10.png"),
      Card.new(:heart, 9, "sprites/cards/hearts_09.png"),
      Card.new(:heart, 8, "sprites/cards/hearts_08.png"),
      Card.new(:heart, 7, "sprites/cards/hearts_07.png"),
      Card.new(:heart, 6, "sprites/cards/hearts_06.png"),
      Card.new(:heart, 5, "sprites/cards/hearts_05.png"),
      Card.new(:heart, 4, "sprites/cards/hearts_04.png"),
      Card.new(:heart, 3, "sprites/cards/hearts_03.png"),
      Card.new(:heart, 2, "sprites/cards/hearts_02.png"),
      Card.new(:heart, 1, "sprites/cards/hearts_ace.png"),

      Card.new(:diamond, 13, "sprites/cards/diamonds_king.png"),
      Card.new(:diamond, 12, "sprites/cards/diamonds_queen.png"),
      Card.new(:diamond, 11, "sprites/cards/diamonds_jack.png"),
      Card.new(:diamond, 10, "sprites/cards/diamonds_10.png"),
      Card.new(:diamond, 9, "sprites/cards/diamonds_09.png"),
      Card.new(:diamond, 8, "sprites/cards/diamonds_08.png"),
      Card.new(:diamond, 7, "sprites/cards/diamonds_07.png"),
      Card.new(:diamond, 6, "sprites/cards/diamonds_06.png"),
      Card.new(:diamond, 5, "sprites/cards/diamonds_05.png"),
      Card.new(:diamond, 4, "sprites/cards/diamonds_04.png"),
      Card.new(:diamond, 3, "sprites/cards/diamonds_03.png"),
      Card.new(:diamond, 2, "sprites/cards/diamonds_02.png"),
      Card.new(:diamond, 1, "sprites/cards/diamonds_ace.png"),

      Card.new(:club, 13, "sprites/cards/clubs_king.png"),
      Card.new(:club, 12, "sprites/cards/clubs_queen.png"),
      Card.new(:club, 11, "sprites/cards/clubs_jack.png"),
      Card.new(:club, 10, "sprites/cards/clubs_10.png"),
      Card.new(:club, 9, "sprites/cards/clubs_09.png"),
      Card.new(:club, 8, "sprites/cards/clubs_08.png"),
      Card.new(:club, 7, "sprites/cards/clubs_07.png"),
      Card.new(:club, 6, "sprites/cards/clubs_06.png"),
      Card.new(:club, 5, "sprites/cards/clubs_05.png"),
      Card.new(:club, 4, "sprites/cards/clubs_04.png"),
      Card.new(:club, 3, "sprites/cards/clubs_03.png"),
      Card.new(:club, 2, "sprites/cards/clubs_02.png"),
      Card.new(:club, 1, "sprites/cards/clubs_ace.png"),

      Card.new(:spade, 13, "sprites/cards/spades_king.png"),
      Card.new(:spade, 12, "sprites/cards/spades_queen.png"),
      Card.new(:spade, 11, "sprites/cards/spades_jack.png"),
      Card.new(:spade, 10, "sprites/cards/spades_10.png"),
      Card.new(:spade, 9, "sprites/cards/spades_09.png"),
      Card.new(:spade, 8, "sprites/cards/spades_08.png"),
      Card.new(:spade, 7, "sprites/cards/spades_07.png"),
      Card.new(:spade, 6, "sprites/cards/spades_06.png"),
      Card.new(:spade, 5, "sprites/cards/spades_05.png"),
      Card.new(:spade, 4, "sprites/cards/spades_04.png"),
      Card.new(:spade, 3, "sprites/cards/spades_03.png"),
      Card.new(:spade, 2, "sprites/cards/spades_02.png"),
      Card.new(:spade, 1, "sprites/cards/spades_ace.png"),
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

  def draw_specific(value, face = true)
    reshuffle if @deck.empty?

    if @deck.find { |c| c.value == value }
      drawn = @deck.find { |c| c.value == value }

      @deck.delete_if { |c| c.value == drawn.value && c.suit == drawn.suit }
      @discards << drawn

      drawn.face = face

      drawn
    end
  end

  def reshuffle
    puts "Reshuffling discard into deck"
    @deck = @deck + @discards
    @discards.clear
    @deck.shuffle
  end
  
end