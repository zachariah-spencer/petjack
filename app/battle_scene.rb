require_relative "scene"

# the game scene has the same general flow as the level select scene
  # just a place holder for where the game would so up
  class BattleScene < Scene
    def id = :battle

    def initialize
      @tickables = {}
    end

    def activate!

    end

    def tick
      @tickables.values.each { |tickable| tickable.tick } unless @tickables.empty?

      if inputs.keyboard.key_down.space
        puts "Pressed input in blackjack scene"
      end

      if inputs.keyboard.key_down.q && state.current_scene == id
        state.next_scene = :home
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
          text: "Battle"
        },
      ]
    end
  end