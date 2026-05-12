# this is the default scene structure that every child scene inherits from
  class Scene
    attr_gtk

    attr :activate_at, :deactivate_at

    # a scene must have an idea
    def id = raise "Set the scene's id by overriding the id method on #{self.class}."

    # when a scene transitions in, this function will be called on the scene
    def activate! = puts "Scene #{id} activated. Override activate! on #{self.class} to add custom behavior."

    # when a scene transitions out, this function will be called on the scene
    def deactivate! = puts "Scene #{id} deactivated. Override deactivate! on #{self.class} to add custom behavior."

    # this is invoked for the current active scene
    def tick = puts "Scene #{id} tick. Override tick on #{self.class} to add custom behavior."

    # this function returns primitives the scene created so that they can be rendered
    def primitives = puts "Scene #{id} primitives. Override primitives on #{self.class} to add custom behavior."

    # this function returns whether the scene is currently active (used
    # to gate input and ticking)
    def active?
      activate_at && !deactivate_at
    end

    # signifies that the scene is ready to accept inputs
    def accepts_input?
      active? && state.current_scene_at.elapsed_time > 30
    end
  end