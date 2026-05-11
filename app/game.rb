require_relative "event_bus"
require_relative "pet"

$tickables = {}

class Game
  attr_gtk

  def initialize
    EventBus.new
    @pet = Pet.new
  end

  def tick
    $tickables.values.each { |tickable| tickable.tick } unless $tickables.empty?

    render
  end
  
  def render
    outputs.background_color = [20,20,20]

    outputs.solids << @pet.draw

    outputs.labels << {
      x: Grid.w / 2,
      y: Grid.h - 30,
      alignment_enum: 1,
      size_enum: 15,
      r: 255,
      g: 0,
      b: 0,
      text: "#{@pet.name}"
    }

    outputs.labels << {
      x: Grid.w / 2,
      y: Grid.h - 100,
      alignment_enum: 1,
      size_enum: 10,
      r: 255,
      g: 0,
      b: 0,
      text: "Level #{@pet.level}"
    }
  end
end