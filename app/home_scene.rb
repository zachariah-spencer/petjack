require_relative "scene"
require_relative "pet"
require_relative "root_scene"
require_relative "button"

# the game scene has the same general flow as the level select scene
  # just a place holder for where the game would so up
  class HomeScene < Scene
    def id = :home

    def initialize
      @tickables = {}

      @pet = Pet.new
      build_buttons

      @tickables[@pet] = @pet
    end

    def activate!

    end

    def build_buttons
      @buttons = [
        Button.new(Grid.w - 32 - 8, Grid.h - 32 - 8, 32, 32, 
        sprite: "sprites/garden_cozy/assets/menu_buttons/clear/button-arrow-right.png", 
        sprite_pressed: "sprites/garden_cozy/assets/menu_buttons/clear/pressed/button-arrow-right-pressed.png", 
        enabled_when: -> { true }) { go_to_battle },

        Button.new(8, Grid.h - 32 - 8, 32, 32, 
        sprite: "sprites/garden_cozy/assets/menu_buttons/clear/button-arrow-left.png", 
        sprite_pressed: "sprites/garden_cozy/assets/menu_buttons/clear/pressed/button-arrow-left-pressed.png", 
        enabled_when: -> { true }) { go_to_blackjack },
      ]
    end

    def go_to_blackjack
      return unless accepts_input?
      state.next_scene = :blackjack
    end

    def go_to_battle
      return unless accepts_input?
      state.next_scene = :multiplayer
    end

    def tick
      @tickables.values.each { |tickable| tickable.tick } unless @tickables.empty?
      @buttons.each { |b| b.tick(inputs) }

      if state.current_scene == id
        if inputs.keyboard.key_down.q
          state.next_scene = :blackjack
        end

        if inputs.keyboard.key_down.e
          state.next_scene = :multiplayer
        end

        if inputs.keyboard.key_down.space && $coins > 0
          @pet.coins = @pet.coins + 1
          $coins -= 1
        end
      end
    end

    def primitives
      all_primitives = [
        @pet.draw,

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
          text: "#{@pet.name}"
        },

        {
          primitive_marker: :label,
          font: $font,
          x: Grid.w / 2,
          y: Grid.h - 77,
          alignment_enum: 1,
          size_enum: 10,
          r: 255,
          g: 0,
          b: 0,
          text: "Level #{@pet.level}"
        },

        {
          primitive_marker: :label,
          font: $font,
          x: Grid.w / 2,
          y: Grid.h - 120,
          alignment_enum: 1,
          size_enum: 5,
          r: 255,
          g: 0,
          b: 0,
          text: "Coins Eaten: #{@pet.coins} / #{@pet.coins_needed}"
        }
      ]

      @buttons.each { |b| all_primitives << b.primitives }

      all_primitives
    end
  end
