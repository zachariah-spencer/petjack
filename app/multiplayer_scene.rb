require_relative "scene"

# the game scene has the same general flow as the level select scene
  # just a place holder for where the game would so up
  class MultiplayerScene < Scene
    def id = :multiplayer

    def initialize
      @tickables = {}
      build_buttons
    end

    def activate!

    end

    def build_buttons
      @buttons = [
        Button.new(8, Grid.h - 32 - 8, 32, 32, 
        sprite: "sprites/garden_cozy/assets/menu_buttons/clear/button-arrow-left.png", 
        sprite_pressed: "sprites/garden_cozy/assets/menu_buttons/clear/pressed/button-arrow-left-pressed.png", 
        enabled_when: -> { true }) { leave_multiplayer },
      ]
    end

    def leave_multiplayer
      return unless accepts_input?
      state.next_scene = :home
    end

    def tick
      @tickables.values.each { |tickable| tickable.tick } unless @tickables.empty?
      @buttons.each { |b| b.tick(inputs) }

      if inputs.keyboard.key_down.space
        puts "Pressed input in blackjack scene"
      end

      if inputs.keyboard.key_down.q && state.current_scene == id
        state.next_scene = :home
      end
    end

    def primitives
      all_primitives = [

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
          text: "Multiplayer"
        },
      ]
      @buttons.each { |b| all_primitives << b.primitives }

      all_primitives
    end
  end