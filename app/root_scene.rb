require_relative "event_bus"
require_relative "scene"
require_relative "home_scene"
require_relative "blackjack_scene"
require_relative "battle_scene"


# this is the root scene that controls the orchestration of the UI
  class RootScene
    attr_gtk

    def initialize args
      EventBus.new
      # construct all the scenes and set the initial scene to Home scene
      @all_scenes = {
        home: HomeScene.new,
        blackjack: BlackjackScene.new,
        battle: BattleScene.new
      }
      args.state.current_scene = :home
      args.state.current_scene_at = Kernel.tick_count
      @all_scenes[args.state.current_scene].activate_at = Kernel.tick_count
      @all_scenes[args.state.current_scene].deactivate_at = nil

      # these instance variables are used to control the scene transition animation
      @current_scene_rect = current_scene_start_rect
      @previous_scene_rect = previous_scene_start_rect

      # game variables
      $coins = 50
      
    end

    # this is the main tick function for the root scene.
    def tick
      # we capture what the current scene before invoking the active
      # scene's tick function so that we can verify that the active
      # scene didn't change mid-tick without using the proper
      # state.next_scene mechanism
      current_scene_before = args.state.current_scene

      # this function handles the re-rendering of render targets if the
      # orientation changes
      resize

      # this is where we invoke relevant tick functions for the current and previous scenes
      calc

      # this is where we handle scene changes and rendering of the
      # current scene's primitives
      render

      raise "Scene changed mid tick. Use state.next_scene." if state.current_scene != current_scene_before

      # after that we handle scene activation and deactivation
      tick_scene_change
    end

    def resize
      # in the event of an orientation change, we want to invalide the
      # current render targets given the new sizes that the Grid class will provide
      if args.events.resize_occurred
        @current_scene_rect = current_scene_end_rect
      end

      if args.events.resize_occurred
        @previous_scene_rect = previous_scene_end_rect
      end
    end

    def calc
      # set the args for the current and previous scenes and invoke
      # their tick functions
      current_scene.args = args
      current_scene.tick

      # previous scene may not exist if it's the initial load, or if
      # enough time has elapsed since the last scene change, so we use safe navigation operator here
      previous_scene&.args = args
      previous_scene&.tick
    end

    def render
      # set the background color
      outputs.background_color = [20,20,20]

      # initialize the previous_scene and current_scene render targets
      outputs[:previous_scene].set w: Grid.w,
                                   h: Grid.h,
                                   background_color: [0, 0, 0, 0]

      outputs[:current_scene].set w: Grid.w,
                                  h: Grid.h,
                                  background_color: [0, 0, 0, 0]

      # render the previous_scene and current_scene primitives to their respective render targets
      outputs[:previous_scene].primitives << previous_scene&.primitives
      outputs[:current_scene].primitives << current_scene.primitives

      # render previous and next scene to the top level outputs
      # the previous_scene_rect and current_scene_rect functions will
      # return rects that are used to create a scene transition
      # animation
      outputs.primitives << { **previous_scene_rect, path: :previous_scene, a: previous_scene_alpha }
      outputs.primitives << { **current_scene_rect, path: :current_scene, a: current_scene_alpha }

      outputs.primitives << {
        primitive_marker: :label,
        x: 40,
        y: 40,
        text: "Player Coins: #{$coins}",
        b: 255,
        g: 255,
      }

      # debug primitives to visualize control locations
      # outputs.primitives << Layout.debug_primitives(invert_colors: true, a: 32)
    end

    def tick_scene_change
      # if state.next_scene is set, that means the active scene has requested a scene change
      if state.next_scene
        state.previous_scene = state.current_scene

        # for the current scene we want to invoke deactivation logic immediately
        @all_scenes[state.current_scene]&.args = args
        @all_scenes[state.current_scene]&.activate_at = nil
        @all_scenes[state.current_scene]&.deactivate_at = Kernel.tick_count
        @all_scenes[state.current_scene]&.deactivate!

        # after that we set the new scene and reset the scene transition animation timers and rects
        state.current_scene = state.next_scene
        state.current_scene_at = Kernel.tick_count
        @current_scene_rect = current_scene_start_rect
        @previous_scene_rect = previous_scene_start_rect

        state.next_scene = nil

        @all_scenes[state.current_scene].args = args
        @all_scenes[state.current_scene].activate_at = Kernel.tick_count
        @all_scenes[state.current_scene].deactivate_at = nil
        @all_scenes[state.current_scene].activate!
      end
    end

    # these represent the start and end locations for the scene
    # transitions (the key value in these rects is the y value, which
    # creates a vertical wipe transition, but you can modify these to
    # create different transitions)
    def current_scene_end_rect
      { x: 0, y: 0, w: Grid.w, h: Grid.h }
    end

    def current_scene_start_rect
      { x: 0, y: -Grid.h, w: Grid.w, h: Grid.h }
    end

    def previous_scene_end_rect
      { x: 0, y: Grid.h, w: Grid.w, h: Grid.h }
    end

    def previous_scene_start_rect
      { x: 0, y: 0, w: Grid.w, h: Grid.h }
    end

    # this is the easing function that gives us the percentage for how
    # far along the scene transition animation is, which is used in the
    # current_scene_rect and previous_scene_rect functions to return the
    # appropriate rect for the current frame
    def current_scene_rect_prec
      Easing.smooth_stop(start_at: state.current_scene_at,
                         duration: 15,
                         tick_count: Kernel.tick_count,
                         power: 2)
    end

    def previous_scene_rect_perc
      Easing.smooth_stop(start_at: state.current_scene_at,
                         duration: 15,
                         tick_count: Kernel.tick_count,
                         power: 2)
    end

    # we use Geometry.lerp_rect to return a rect that is the appropriate
    # percentage between the start and end rects for the current scene
    # transition animation
    def current_scene_rect
      Geometry.lerp_rect(current_scene_start_rect, current_scene_end_rect, current_scene_rect_prec)
    end

    def previous_scene_rect
      Geometry.lerp_rect(previous_scene_start_rect, previous_scene_end_rect, previous_scene_rect_perc)
    end

    # we use a similar easing function to calculate the alpha for the current
    def current_scene_alpha
      255 * Easing.smooth_stop(start_at: state.current_scene_at,
                               duration: 60,
                               tick_count: Kernel.tick_count,
                               power: 2)
    end

    def previous_scene_alpha
      255 * Easing.smooth_stop(start_at: state.current_scene_at,
                               duration: 60,
                               tick_count: Kernel.tick_count,
                               power: 2,
                               flip: true)
    end

    def previous_scene
      # previous scene will return nil after enough time is passed (we
      # don't want to continue invoking tick on a scene that has fully transitioned out)
      return nil if state.current_scene_at.elapsed_time > 120
      @all_scenes[state.previous_scene]
    end

    def current_scene
      @all_scenes[state.current_scene]
    end
  end
