require_relative "scene"
require_relative "deck"
require_relative "hand"

# the game scene has the same general flow as the level select scene
  # just a place holder for where the game would so up
  class BlackjackScene < Scene
    def id = :blackjack

    def initialize
      @tickables = {}
      @deal_queue = []
      @next_deal_at = 0
      @deal_delay = 15
      @dealing_started = false
      @deck = Deck.new(Grid.w - 100, Grid.h - 128)
      @players_hands = []
      @active_hand = nil
      @dealers_hand = Hand.new(Grid.w / 2, Grid.h - 256, -1, 0)
      @bet = 10
      @resetting_tick = 0
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
      @dealers_hand.tick if @dealers_hand
      @players_hands.each { |h| h.tick } unless @players_hands.empty?

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

            if inputs.keyboard.key_down.space && @resetting_tick.elapsed_time >= 0.25.seconds
              if $coins >= @bet
                @players_hands.clear
                @players_hands << Hand.new(Grid.w / 2, 100, @bet)
                calc_hand_positions
                @active_hand = @players_hands.first
                @phase = :dealing
                $coins -= @bet
              end
            end

          

          elsif @phase == :dealing
            unless @dealing_started
              queue_deal { @active_hand.add(@deck.draw) } 
              queue_deal { @dealers_hand.add(@deck.draw) } 
              queue_deal { @active_hand.add(@deck.draw) } 
              queue_deal { @dealers_hand.add(@deck.draw(false)) }
              @next_deal_at = Kernel.tick_count
              @dealing_started = true
            end

            flush_one_queued_deal
            
            if @dealing_started && @deal_queue.empty?
              if @active_hand.total_value != 21
                @phase = :decision
              else
                @active_hand.outcome = :blackjack
                @phase = :resolution
              end
            end



          elsif @phase == :decision
            unless @active_hand.in_play
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

            unless @dealer_turn_started
              unless @active_hand.outcome == :blackjack
                start_dealer_turn
              else
                @dealer_turn_started = true
              end
            end

            flush_one_queued_deal

            if @dealer_turn_started && @deal_queue.empty?
              @dealer_turn_started = false

              @players_hands.each do |h|
                next unless h.outcome == :undecided

                if h.total_value > 21
                  h.outcome = :lost
                elsif @dealers_hand.total_value > 21
                  h.outcome = :won
                elsif @dealers_hand.total_value == 21 && @dealers_hand.cards.size <= 2
                  if h.total_value == 21 && h.cards.size <= 2
                    h.outcome = :push
                  else
                    h.outcome = :lost
                  end
                elsif h.total_value > @dealers_hand.total_value
                  h.outcome = :won
                elsif @dealers_hand.total_value > h.total_value
                  h.outcome = :lost
                else
                  h.outcome = :push
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
            end

          elsif @phase == :end_of_round
            if inputs.keyboard.key_down.space
              @bet = 10
              @active_hand = nil
              @resetting_tick = Kernel.tick_count
              @dealers_hand.reset
              @players_hands.each { |h| h.reset }
              @deck.reshuffle
              @dealing_started = false
              @dealer_turn_started = false
              @deal_queue.clear
              @next_deal_at = 0
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

    def queue_deal(&block)
      @deal_queue << block
    end

    def flush_one_queued_deal
      return if @deal_queue.empty?
      return if Kernel.tick_count < @next_deal_at
      @deal_queue.shift.call
      calc_hand_positions
      @next_deal_at = Kernel.tick_count + @deal_delay
    end

    def start_dealer_turn
      @dealer_turn_started = true
      @deal_queue << -> do
        face_down_card = @dealers_hand.cards.find { |c| !c.face}
        face_down_card.face = true
        queue_next_dealer_draw_if_needed
      end
      
      @next_deal_at = Kernel.tick_count + @deal_delay
    end

    def queue_next_dealer_draw_if_needed
      return if @dealers_hand.total_value >= 17

      @deal_queue << -> do
        @dealers_hand.add(@deck.draw)
        calc_hand_positions
        queue_next_dealer_draw_if_needed
      end
    end

    def primitives
      all_primitives = [
        @deck.primitives,
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
      ]

      if @dealers_hand && @phase != :betting
        all_primitives << [@dealers_hand.primitives, @dealers_hand.score_label_primitive]
      end

      if !@players_hands.empty?
        @players_hands.each do |h|
          all_primitives << h.primitives
        end

        unless @phase == :betting
          @players_hands.each { |h| all_primitives << h.score_label_primitive }
        end
      end

      if @phase == :betting && @resetting_tick && @resetting_tick.elapsed_time >= 0.25.seconds
        all_primitives << {
          primitive_marker: :label,
          x: Grid.w / 2,
          y: Grid.h / 2,
          alignment_enum: 1,
          size_enum: 15,
          r: 255,
          g: 0,
          b: 0,
          text: "Press SPACE to Play"
        }
      end

      all_primitives
    end
  end
