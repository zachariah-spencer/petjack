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
      @dealers_hand = Hand.new(Grid.w / 2, Grid.h - 256)
      @bet = 10
      @resolutions = [
        :lost,
        :won,
        :undecided,
        :push
      ]
      @phases = [
        :betting,
        :dealing,
        :decision,
        :resolution,
        :end_of_round
      ]

      @phase = :betting
      @resolution = :undecided
    end

    def activate!

    end

    def tick
      @tickables.values.each { |tickable| tickable.tick } unless @tickables.empty?

      if state.current_scene == id
        if inputs.keyboard.key_down.e
          state.next_scene = :home
        end

          if @phase == :betting
            if inputs.keyboard.key_down.up
              @bet = (@bet + 5).clamp(10, 100)
            end

            if inputs.keyboard.key_down.down
              @bet = (@bet - 5).clamp(10, 100)
            end

            if inputs.keyboard.key_down.space
              if $coins >= @bet
                @phase = :dealing
                $coins -= @bet
              end
            end
          elsif @phase == :dealing
            @players_hand.add(@deck.draw)
            @dealers_hand.add(@deck.draw)
            @players_hand.add(@deck.draw)
            @dealers_hand.add(@deck.draw(false))
            
            if @players_hand.total_value != 21
              @phase = :decision
            else
              @resolution = :blackjack
              @phase = :resolution
            end
          elsif @phase == :decision
            if inputs.keyboard.key_down.d && @players_hand.cards.size <= 2
              # double down
              @players_hand.add(@deck.draw)
              @bet *= 2
              calc_round_outcome
              @phase = :resolution
            elsif inputs.keyboard.key_down.s
              # two identical card values means you can split
              if @players_hand.cards[0].value == @players_hand.cards[1].value
                # handle split logic here
              end
            elsif inputs.keyboard.key_down.enter
              @players_hand.add(@deck.draw)
              calc_round_outcome
            elsif inputs.keyboard.key_down.space
              @phase = :resolution
            end
        
          elsif @phase == :resolution

            if @resolution == :undecided
              @dealers_hand.cards.each { |c| c.face = true }
              while @dealers_hand.total_value < 17
                @dealers_hand.add(@deck.draw)
              end

              if @dealers_hand.total_value > 21
                @resolution = :won
              end

              if @dealers_hand.total_value == 21 && @dealers_hand.cards.size <= 2
                # both player and dealer have blackjack
                if @players_hand.total_value == 21 && @players_hand.cards.size <= 2
                  @resolution = :push
                else
                  @resolution = :lost
                end
              end
            end

            if @resolution == :undecided
              if @players_hand.total_value > @dealers_hand.total_value
                @resolution = :won
              elsif @dealers_hand.total_value > @players_hand.total_value
                @resolution = :lost
              else
                @resolution = :push
              end
            end

            if @resolution == :won
              $coins += @bet + @bet
            end
            if @resolution == :push
              $coins += @bet
            end
            if @resolution == :blackjack
              $coins += @bet + (@bet * (3/2))
            end

            @phase = :end_of_round
          elsif @phase == :end_of_round
            if inputs.keyboard.key_down.space
              @bet = 10
              @players_hand.cards.clear
              @dealers_hand.cards.clear
              @deck.reshuffle
              @phase = :betting
              @resolution = :undecided
            end
          end

        end
      end

    def calc_round_outcome
      if @players_hand.total_value > 21
        # bust
        @resolution = :lost
        @phase = :resolution
      elsif @players_hand.total_value == 21 && @players_hand.cards.size <= 2
        # blackjack
        @resolution = :blackjack
        @phase = :resolution
      else
        # other non-bust values
      end
    end

    def primitives
      all_primitives = [
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
        {
          primitive_marker: :label,
          x: 40,
          y: Grid.h - 30,
          alignment_enum: 0,
          size_enum: 3,
          r: 255,
          g: 0,
          b: 0,
          text: "Minimum Bet: 10"
        },
        {
          primitive_marker: :label,
          x: Grid.w - 40,
          y: Grid.h - 30,
          alignment_enum: 2,
          size_enum: 3,
          r: 255,
          g: 0,
          b: 0,
          text: "Maximum Bet: 100"
        },
        {
          primitive_marker: :label,
          x: Grid.w / 2,
          y: Grid.h - 100,
          alignment_enum: 1,
          size_enum: 3,
          r: 255,
          g: 0,
          b: 0,
          text: "Bet: #{@bet}"
        },

        

        {
          primitive_marker: :label,
          x: 50,
          y: Grid.h / 2,
          text: "#{@phase}",
          g: 255
        },
        @players_hand.primitives,
        @dealers_hand.primitives
      ]

      if @phase != :betting
        all_primitives << {
          primitive_marker: :label,
          x: Grid.w / 2,
          y: Grid.h / 2 - 240,
          alignment_enum: 1,
          size_enum: 5,
          r: 255,
          g: 0,
          b: 0,
          text: "#{@players_hand.total_value}"
        }

        all_primitives << {
          primitive_marker: :label,
          x: Grid.w / 2,
          y: Grid.h / 2 + 110,
          alignment_enum: 1,
          size_enum: 5,
          r: 255,
          g: 0,
          b: 0,
          text: "#{@dealers_hand.total_value}"
        }
      end

      all_primitives
    end
  end