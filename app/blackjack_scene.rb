require_relative "scene"
require_relative "deck"
require_relative "hand"

# the game scene has the same general flow as the level select scene
  # just a place holder for where the game would so up
  class BlackjackScene < Scene
    def id = :blackjack

    def initialize
      @tickables = {}
      @deck = Deck.new
      @players_hand = Hand.new(Grid.w / 2, 100)
      @dealers_hand = Hand.new(Grid.w / 2, Grid.h - 100)
      @turn_phases = [
        :initial_deal
      ]
    end

    def activate!

    end

    def tick
      @tickables.values.each { |tickable| tickable.tick } unless @tickables.empty?

      if inputs.keyboard.key_down.e && state.current_scene == id
        state.next_scene = :home
      end

      if inputs.keyboard.key_down.space
        card_drawn = @deck.draw([true, false].sample)
        @players_hand.add(card_drawn)

        if card_drawn.face
          puts "Drew a: #{card_drawn.display_name}"
        else
          puts "Drew a card face down. (Shhh it is a #{card_drawn.display_name})"
        end
      end
    end

    def primitives
      [
        {
          primitive_marker: :label,
          x: Grid.w / 2,
          y: Grid.h - 30,
          alignment_enum: 1,
          size_enum: 15,
          r: 255,
          g: 0,
          b: 0,
          text: "Blackjack"
        },
        @players_hand.primitives,
        @dealers_hand.primitives
      ]
    end
  end