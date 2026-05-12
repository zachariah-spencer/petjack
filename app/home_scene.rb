require_relative "scene"
require_relative "pet"
require_relative "root_scene"

# the game scene has the same general flow as the level select scene
  # just a place holder for where the game would so up
  class HomeScene < Scene
    def id = :home

    def initialize
      @tickables = {}

      @pet = Pet.new

      @tickables[@pet] = @pet
    end

    def activate!

    end

    def tick
      @tickables.values.each { |tickable| tickable.tick } unless @tickables.empty?

      if state.current_scene == id
        if inputs.keyboard.key_down.q
          state.next_scene = :blackjack
        end

        if inputs.keyboard.key_down.e
          state.next_scene = :battle
        end

        if inputs.keyboard.key_down.space
          @pet.coins = @pet.coins + 2
        end
      end
    end

    def primitives
      [
        @pet.draw,

        {
          primitive_marker: :label,
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
    end
  end