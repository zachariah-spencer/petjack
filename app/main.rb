require_relative "game"

def boot args
  args.state = {}
end

def tick args
  $game ||= Game.new
  $game.args ||= args
  $game.tick
end
