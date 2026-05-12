require_relative "root_scene"

def boot args
  args.state = {}
end

def tick args
  $root_scene ||= RootScene.new args
  $root_scene.args = args
  $root_scene.tick
end

def reset args
  $root_scene = nil
end