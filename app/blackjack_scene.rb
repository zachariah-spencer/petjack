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
      
      @players_hands = []
      @active_hand = nil
      @dealers_hand = Hand.new(Grid.w / 2, Grid.h - 256, -1)
      @bet = 10
      @phases = [
        :betting,
        :dealing,
        :decision,
        :resolution,
        :end_of_round
      ]
      @phase = :betting
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
                @players_hands << Hand.new(Grid.w / 2, 100, @bet)
                calc_hand_positions
                @active_hand = @players_hands.first
                @phase = :dealing
                $coins -= @bet
              end
            end

          

          elsif @phase == :dealing
            @active_hand.add(@deck.draw)
            @dealers_hand.add(@deck.draw)
            @active_hand.add(@deck.draw)
            @dealers_hand.add(@deck.draw(false))
            calc_hand_positions
            
            if @active_hand.total_value != 21
              @phase = :decision
            else
              @active_hand.outcome = :blackjack
              @phase = :resolution
            end



          elsif @phase == :decision
            puts @active_hand.in_play
            unless @active_hand.in_play
              puts "here"
              prev_active_hand = @players_hands.index(@active_hand)
              @active_hand = @players_hands[prev_active_hand + 1] 
            end
            if inputs.keyboard.key_down.d && @active_hand.cards.size <= 2
              # double down
              @active_hand.add(@deck.draw)
              calc_hand_positions
              @active_hand.bet *= 2
              calc_round_outcome
              @active_hand.in_play = false
            elsif inputs.keyboard.key_down.s
              # two identical card values means you can split
              if @active_hand.cards.size > 1 && @active_hand.cards[0].value == @active_hand.cards[1].value

                # handle split
                if $coins >= @bet
                  $coins -= @bet
                  new_hand = Hand.new(100, 100, @bet)
                  new_hand.add(@active_hand.cards.delete_at(0))
                  @players_hands << new_hand
                  calc_hand_positions
                end

                
                
              end
            elsif inputs.keyboard.key_down.enter
              @active_hand.add(@deck.draw)
              calc_hand_positions
              calc_round_outcome
            elsif inputs.keyboard.key_down.space
              @active_hand.in_play = false
            end

            hands_in_play = false
            @players_hands.each { |h| hands_in_play = true if h.in_play }
            @phase = :resolution unless hands_in_play
        

            
          elsif @phase == :resolution

            @players_hands.each do |h|
              if h.outcome == :undecided
                @dealers_hand.cards.each { |c| c.face = true }
                while @dealers_hand.total_value < 17
                  @dealers_hand.add(@deck.draw)
                end

                if @dealers_hand.total_value > 21
                  h.outcome = :won
                end

                if @dealers_hand.total_value == 21 && @dealers_hand.cards.size <= 2
                  # both player and dealer have blackjack
                  if h.total_value == 21 && h.cards.size <= 2
                    h.outcome = :push
                  else
                    h.outcome = :lost
                  end
                end
              end

              if h.outcome == :undecided
                if h.total_value > @dealers_hand.total_value
                  h.outcome = :won
                elsif @dealers_hand.total_value > h.total_value
                  h.outcome = :lost
                else
                  h.outcome = :push
                end
              end
            end

            @players_hands.each do |h|
              if h.outcome == :won
                $coins += h.bet + h.bet
              end
              if h.outcome == :push
                $coins += h.bet
              end
              if h.outcome == :blackjack
                $coins += h.bet + (h.bet * (3/2))
              end
            end
            

            @phase = :end_of_round



          elsif @phase == :end_of_round
            if inputs.keyboard.key_down.space
              @bet = 10
              @active_hand = nil
              @players_hands.clear
              @dealers_hand.cards.clear
              @deck.reshuffle
              @phase = :betting
            end
          end

        end
      end

    def calc_round_outcome
      if @active_hand.total_value > 21
        # bust
        @active_hand.outcome = :lost
        @active_hand.in_play = false
      elsif @active_hand.total_value == 21 && @active_hand.cards.size <= 2
        # blackjack
        @active_hand.outcome = :blackjack
        @active_hand.in_play = false
      else
        # other non-bust values
      end
    end
    
    def calc_hand_positions
      return if @players_hands.empty?

      spacing = 64
      total_width = @players_hands.sum(&:rendered_width) + (spacing * (@players_hands.size - 1))
      current_x = (Grid.w - total_width) / 2

      @players_hands.each do |hand|
        hand.x = current_x + (hand.rendered_width / 2)
        current_x += hand.rendered_width + spacing
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
        @dealers_hand.primitives
      ]

      if !@players_hands.empty?
        @players_hands.each do |h|
          all_primitives << h.primitives
        end
      end

      all_primitives
    end
  end
