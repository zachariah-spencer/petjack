require_relative "scene"
require_relative "deck"
require_relative "hand"
require_relative "button"

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
      @buttons = []
      @players_hands = []
      @active_hand = nil
      @dealers_hand = Hand.new(Grid.w / 2, Grid.h - 256, -1, 0)
      @bet = 10
      @insurance_bet = 0
      @insurance_offered = false
      @resetting_tick = 0
      @phases = [
        :betting,
        :dealing,
        :insurance,
        :decision,
        :resolution,
        :end_of_round
      ]
      @phase = :betting
      build_buttons
    end

    def activate!

    end

    def tick
      @tickables.values.each { |tickable| tickable.tick } unless @tickables.empty?
      @dealers_hand.tick if @dealers_hand
      @players_hands.each { |h| h.tick } unless @players_hands.empty?
      @buttons.each { |button| button.tick(inputs) }

      if state.current_scene == id
        leave_blackjack if inputs.keyboard.key_down.e

          if @phase == :betting
            increase_bet if inputs.keyboard.key_down.up

            decrease_bet if inputs.keyboard.key_down.down

            start_round if inputs.keyboard.key_down.space

          

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
              if can_offer_insurance?
                @phase = :insurance
              elsif @active_hand.total_value != 21
                @phase = :decision
              else
                @active_hand.outcome = :blackjack
                @phase = :resolution
              end
            end

          elsif @phase == :insurance
            take_insurance if inputs.keyboard.key_down.y
            decline_insurance if inputs.keyboard.key_down.n



          elsif @phase == :decision
            unless @active_hand.in_play
              prev_active_hand = @players_hands.index(@active_hand)
              @active_hand = @players_hands[prev_active_hand + 1] 
            end
            double_down if inputs.keyboard.key_down.d
            split_hand if inputs.keyboard.key_down.s
            hit if inputs.keyboard.key_down.enter
            stand if inputs.keyboard.key_down.space

            hands_in_play = false
            @players_hands.each { |h| hands_in_play = true if h.in_play }
            @phase = :resolution unless hands_in_play
        

            
          elsif @phase == :resolution

            unless @dealer_turn_started
              if dealer_turn_needed?
                start_dealer_turn
              else
                @dealer_turn_started = true
              end
            end

            flush_one_queued_deal

            if @dealer_turn_started && @deal_queue.empty?
              @dealer_turn_started = false
              reveal_dealer_cards

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

              settle_main_bets
              settle_insurance

              @phase = :end_of_round
            end

          elsif @phase == :end_of_round
            reset_round if inputs.keyboard.key_down.space
          end

        end
      end

    def build_buttons
      @buttons = [
        Button.new(Grid.w - 32 - 8, Grid.h - 32 - 8, 32, 32, 
        sprite: "sprites/garden_cozy/assets/menu_buttons/clear/button-arrow-right.png", 
        sprite_pressed: "sprites/garden_cozy/assets/menu_buttons/clear/pressed/button-arrow-right-pressed.png", 
        enabled_when: -> { true }) { leave_blackjack },

        Button.new(Grid.w / 2 - 52 - 10, Grid.h / 2 - 50 - 44, 52, 44, "-", enabled_when: -> { can_decrease_bet? }) { decrease_bet },
        Button.new(Grid.w / 2 + 10, Grid.h / 2 - 50 - 44, 52, 44, "+", enabled_when: -> { can_increase_bet? }) { increase_bet },
        Button.new(Grid.w / 2 - 100, Grid.h / 2 - 40, 200, 80, "Deal", enabled_when: -> { can_start_round? }) { start_round },
        Button.new(32, 32 + 20 + (70 * 0), 120, 44, "Hit", enabled_when: -> { can_hit? }) { hit },
        Button.new(32, 32 + 20 + (70 * 1), 120, 44, "Stand", enabled_when: -> { can_stand? }) { stand },
        Button.new(32, 32 + 20 + (70 * 2), 120, 44, "Double", enabled_when: -> { can_double_down? }) { double_down },
        Button.new(42, 32 + 20 + (70 * 3), 120, 44, "Split", enabled_when: -> { can_split? }) { split_hand },
        Button.new(Grid.w - 172, 32, 140, 44, "Next Round", enabled_when: -> { can_reset_round? }) { reset_round },
        Button.new(Grid.w / 2 - 150, Grid.h / 2 - 14, 120, 40, "Yes", enabled_when: -> { can_take_insurance? }) { take_insurance },
        Button.new(Grid.w / 2 + 10, Grid.h / 2 - 14, 120, 40, "No", enabled_when: -> { can_decline_insurance? }) { decline_insurance }
      ]
    end

    def can_change_bet?
        @phase == :betting &&
        @resetting_tick.elapsed_time >= 0.25.seconds
    end

    def can_increase_bet?
      can_change_bet? && @bet < 100 && @bet < ($coins || 0)
    end

    def can_decrease_bet?
      can_change_bet? && @bet > 10
    end

    def can_start_round?
      can_change_bet? && $coins >= @bet
    end

    def can_take_turn_actions?
        @phase == :decision &&
        @active_hand &&
        @active_hand.in_play
    end

    def can_offer_insurance?
      return false unless @phase == :dealing
      return false if @insurance_offered

      dealer_upcard = @dealers_hand.cards.find(&:face)
      dealer_upcard && dealer_upcard.value == 1
    end

    def insurance_wager
      [(@bet / 2), ($coins || 0)].min
    end

    def can_take_insurance?
        @phase == :insurance &&
        insurance_wager > 0
    end

    def can_decline_insurance?
      @phase == :insurance
    end

    def can_hit?
      can_take_turn_actions?
    end

    def can_stand?
      can_take_turn_actions?
    end

    def can_double_down?
      can_take_turn_actions? &&
        @active_hand.cards.size <= 2 &&
        $coins >= @active_hand.bet
    end

    def can_split?
      can_take_turn_actions? &&
        @active_hand.cards.size > 1 &&
        @active_hand.cards[0].value == @active_hand.cards[1].value &&
        $coins >= @active_hand.bet
    end

    def can_reset_round?
      @phase == :end_of_round
    end

    def dealer_turn_needed?
      @players_hands.any? { |hand| hand.outcome == :undecided }
    end

    def leave_blackjack

      state.next_scene = :home
    end

    def increase_bet
      return unless can_increase_bet?

      @bet = (@bet + 5).clamp(10, 100)
    end

    def decrease_bet
      return unless can_decrease_bet?

      @bet = (@bet - 5).clamp(10, 100)
    end

    def start_round
      return unless can_start_round?

      @players_hands.clear
      @players_hands << Hand.new(Grid.w / 2, 100, @bet)
      calc_hand_positions
      @active_hand = @players_hands.first
      @phase = :dealing
      $coins -= @bet
    end

    def hit
      return unless can_hit?

      @active_hand.add(@deck.draw)
      calc_hand_positions
      calc_round_outcome
    end

    def stand
      return unless can_stand?

      @active_hand.in_play = false
    end

    def take_insurance
      return unless can_take_insurance?

      @insurance_bet = insurance_wager
      $coins -= @insurance_bet
      finish_insurance_offer
    end

    def decline_insurance
      return unless can_decline_insurance?

      @insurance_bet = 0
      finish_insurance_offer
    end

    def double_down
      return unless can_double_down?

      $coins -= @active_hand.bet
      @active_hand.add(@deck.draw)
      calc_hand_positions
      @active_hand.bet *= 2
      calc_round_outcome
      @active_hand.in_play = false
    end

    def split_hand
      return unless can_split?

      $coins -= @active_hand.bet
      new_hand = Hand.new(100, 100, @active_hand.bet)
      new_hand.add(@active_hand.cards.delete_at(0))
      @players_hands << new_hand
      calc_hand_positions
    end

    def reset_round
      return unless can_reset_round?

      @bet = 10
      @insurance_bet = 0
      @insurance_offered = false
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

    def dealer_blackjack?
      total = 0
      aces = 0

      @dealers_hand.cards.each do |card|
        total += card.actual_value
        aces += 1 if card.value == 1
      end

      while total > 21 && aces > 0
        total -= 10
        aces -= 1
      end

      total == 21 && @dealers_hand.cards.size <= 2
    end

    def reveal_dealer_cards
      @dealers_hand.cards.each { |card| card.face = true }
    end

    def settle_main_bets
      @players_hands.each do |h|
        if h.outcome == :won
          $coins += h.bet + h.bet
        end
        if h.outcome == :push
          $coins += h.bet
        end
        if h.outcome == :blackjack
          $coins += h.bet + (h.bet * 3 / 2.0)
        end
      end
    end

    def settle_insurance
      @insurance_bet ||= 0
      return if @insurance_bet <= 0

      $coins += @insurance_bet * 3 if dealer_blackjack?
      @insurance_bet = 0
    end

    def finish_insurance_offer
      @insurance_offered = true

      if dealer_blackjack?
        reveal_dealer_cards
        settle_insurance

        @players_hands.each do |h|
          h.outcome =
            if h.total_value == 21 && h.cards.size <= 2
              :push
            else
              :lost
            end
        end

        settle_main_bets
        @phase = :end_of_round
      elsif @active_hand.total_value != 21
        @phase = :decision
      else
        @active_hand.outcome = :blackjack
        @phase = :resolution
      end
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
      dealer_total = @dealers_hand.total_value

      return if dealer_total > 17
      return if dealer_total == 17 && !@dealers_hand.soft_total?

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
          font: $font,
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
          font: $font,
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
          font: $font,
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
          font: $font,
          x: Grid.w / 2,
          y: Grid.h - 100,
          alignment_enum: 1,
          size_enum: 3,
          r: 255,
          g: 0,
          b: 0,
          text: "Bet: #{@bet}"
        },
        
        # debug phase watch
        # {
        #   primitive_marker: :label,
        #   font: $font,
        #   x: 50,
        #   y: Grid.h / 2,
        #   text: "#{@phase}",
        #   g: 255
        # },
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

      all_primitives << insurance_prompt_primitives

      @buttons.each { |b| all_primitives << b.primitives }

      all_primitives
    end

    def insurance_prompt_primitives
      return [] unless @phase == :insurance

      [
        {
          x: Grid.w / 2 - 220,
          y: Grid.h / 2 - 24,
          w: 440,
          h: 150,
          primitive_marker: :solid,
          r: 20,
          g: 20,
          b: 20,
          a: 220
        },
        {
          x: Grid.w / 2 - 220,
          y: Grid.h / 2 - 24,
          w: 440,
          h: 150,
          primitive_marker: :border,
          r: 255,
          g: 255,
          b: 255
        },
        {
          primitive_marker: :label,
          font: $font,
          x: Grid.w / 2,
          y: Grid.h / 2 + 92,
          alignment_enum: 1,
          size_enum: 5,
          r: 255,
          g: 255,
          b: 255,
          text: "Dealer is showing an ace"
        },
        {
          primitive_marker: :label,
          font: $font,
          x: Grid.w / 2,
          y: Grid.h / 2 + 60,
          alignment_enum: 1,
          size_enum: 2,
          r: 255,
          g: 255,
          b: 255,
          text: "Take insurance for #{insurance_wager} coins?"
        },
      ]
    end
  end
