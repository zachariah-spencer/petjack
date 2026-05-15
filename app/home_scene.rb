require_relative "scene"
require_relative "pet"
require_relative "root_scene"
require_relative "button"

# the game scene has the same general flow as the level select scene
  # just a place holder for where the game would so up
  class HomeScene < Scene
    KEYBOARD_BUTTON_W = 72
    KEYBOARD_BUTTON_H = 56
    KEYBOARD_BUTTON_GAP = 10
    KEYBOARD_ROWS = [
      %w[Q W E R T Y U I O P],
      %w[A S D F G H J K L],
      ["BACK", "Z", "X", "C", "V", "B", "N", "M", "OK"]
    ].freeze
    LETTER_KEYS = ("A".."Z").to_a.freeze

    def id
      :home
    end

    def initialize
      @tickables = {}

      @pet = Pet.new
      build_buttons
      build_name_keyboard
      reset_name_prompt

      @tickables[@pet] = @pet
    end

    def activate!

    end

    def reset_name_prompt
      @naming_pet = true
      @pending_pet_name = ""
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

    def build_name_keyboard
      start_y = Grid.h / 2 - 96

      @name_keyboard = KEYBOARD_ROWS.each_with_index.flat_map do |chars, row_index|
        row_width = chars.sum { |char| key_width_for(char) } + KEYBOARD_BUTTON_GAP * (chars.length - 1)
        x = (Grid.w - row_width) / 2.0
        y = start_y - row_index * (KEYBOARD_BUTTON_H + KEYBOARD_BUTTON_GAP)

        chars.map do |char|
          button = {
            char: char,
            rect: {
              x: x,
              y: y,
              w: key_width_for(char),
              h: KEYBOARD_BUTTON_H
            }
          }
          x += button[:rect][:w] + KEYBOARD_BUTTON_GAP
          button
        end
      end
    end

    def key_width_for(char)
      return 108 if char == "BACK"
      return 96 if char == "OK"

      KEYBOARD_BUTTON_W
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

      if state.current_scene == id
        if naming_pet?
          handle_name_input
          return
        end

        @buttons.each { |b| b.tick(inputs) }

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

    def naming_pet?
      @naming_pet
    end

    def handle_name_input
      handle_name_mouse_input if inputs.mouse.click
      handle_name_keyboard_input
    end

    def handle_name_mouse_input
      key = Geometry.find_intersect_rect(inputs.mouse, @name_keyboard, using: :rect)
      apply_name_key(key[:char]) if key
    end

    def handle_name_keyboard_input
      key = inputs.keyboard.key_up
      return unless key

      if key.char == "\b"
        apply_name_key("BACK")
      elsif key.char == "\r"
        apply_name_key("OK")
      elsif key.char
        char = key.char.upcase
        apply_name_key(char) if LETTER_KEYS.include?(char)
      end
    end

    def apply_name_key(char)
      case char
      when "BACK"
        @pending_pet_name = @pending_pet_name[0...-1] || ""
      when "OK"
        confirm_pet_name
      else
        return if @pending_pet_name.length >= 12

        @pending_pet_name += char
      end
    end

    def confirm_pet_name
      return if @pending_pet_name.strip.empty?

      @pet.name = @pending_pet_name
      @naming_pet = false
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

      @buttons.each { |b| all_primitives << b.primitives } unless naming_pet?
      all_primitives.concat(name_prompt_primitives) if naming_pet?

      all_primitives
    end

    def name_prompt_primitives
      panel_w = 920
      panel_h = 520
      panel_x = (Grid.w - panel_w) / 2
      panel_y = (Grid.h - panel_h) / 2
      caret_visible = (Kernel.tick_count.idiv(30) % 2).zero?
      display_name = @pending_pet_name.empty? ? "" : @pending_pet_name
      display_name += "_" if caret_visible && @pending_pet_name.length < 12

      [
        { x: 0, y: 0, w: Grid.w, h: Grid.h, primitive_marker: :solid, r: 10, g: 10, b: 10, a: 220 },
        { x: panel_x, y: panel_y, w: panel_w, h: panel_h, primitive_marker: :solid, r: 244, g: 230, b: 200 },
        { x: panel_x + 18, y: panel_y + 18, w: panel_w - 36, h: panel_h - 36, primitive_marker: :solid, r: 95, g: 59, b: 34 },
        {
          primitive_marker: :label,
          font: $font,
          x: Grid.w / 2,
          y: panel_y + panel_h - 70,
          alignment_enum: 1,
          size_enum: 12,
          r: 255,
          g: 244,
          b: 214,
          text: "Name Your Little Freak"
        },
        { x: panel_x + 140, y: panel_y + 320, w: panel_w - 280, h: 72, primitive_marker: :solid, r: 245, g: 239, b: 224 },
        { x: panel_x + 146, y: panel_y + 326, w: panel_w - 292, h: 60, primitive_marker: :solid, r: 54, g: 34, b: 20 },
        {
          primitive_marker: :label,
          font: $font,
          x: Grid.w / 2,
          y: panel_y + 374,
          alignment_enum: 1,
          size_enum: 8,
          r: 255,
          g: 244,
          b: 214,
          text: display_name
        },
        {
          primitive_marker: :label,
          font: $font,
          x: Grid.w / 2,
          y: panel_y + 282,
          alignment_enum: 1,
          size_enum: 3,
          r: 255,
          g: 221,
          b: 161,
          text: "Maximum 12 letters"
        }
      ] + keyboard_primitives
    end

    def keyboard_primitives
      @name_keyboard.flat_map do |key|
        color = if inputs.mouse.inside_rect?(key[:rect])
                  { r: 255, g: 213, b: 117 }
                else
                  { r: 232, g: 187, b: 86 }
                end

        [
          key[:rect].merge(primitive_marker: :solid, **color),
          {
            primitive_marker: :label,
            font: $font,
            x: key[:rect][:x] + key[:rect][:w] / 2.0,
            y: key[:rect][:y] + key[:rect][:h] / 2.0 + 4,
            alignment_enum: 1,
            vertical_alignment_enum: 1,
            size_enum: 4,
            r: 74,
            g: 43,
            b: 19,
            text: key[:char]
          }
        ]
      end
    end
  end
