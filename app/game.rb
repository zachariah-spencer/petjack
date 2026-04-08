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
    

    outputs.background_color = [20,20,20]
    outputs.solids << @pet.draw
  end
  
end