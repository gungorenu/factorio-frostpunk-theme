-- source: SBG mod by Ondra420 
-- https://mods.factorio.com/mod/Simple-Burner-Generator

--require("./shared")

-- smoke
data:extend(
{
  {
    type = "trivial-smoke",
    name = "fpf-simple-burner-generator-smoke",
    flags = {"not-on-map"},
    duration = 100,
    fade_in_duration = 0,
    fade_away_duration = 20,
    spread_duration = 200,
    slow_down_factor = 0.5,
    start_scale = 1,
    end_scale = 0,
    color = {r = 1, g = 1, b = 1, a = 1},
    cyclic = false,
    affected_by_wind = true,
    animation =
    {
      filename = "__base__/graphics/entity/flamethrower-fire-stream/flamethrower-explosion.png",
      priority = "extra-high",
      width = 64,
      height = 64,
      frame_count = 32,
      line_length = 8,
      scale = 0.5,
      animation_speed = 32 / 100,
      blend_mode = "additive",
      draw_as_glow = true,
    },
  },
})

-- entity
data:extend({
  {
    type = "burner-generator",
    name = "fpf-simple-burner-generator",
    icon = "__FPF__/graphics/icons/sbg.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 0.3, result = "fpf-simple-burner-generator"},
    max_health = 450,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    damaged_trigger_effect = hit_effects_entity(),
    resistances =
    {
      {
        type = "fire",
        percent = 85
      }
    },
    collision_box = {{-1.2, -0.8}, {1.2, 0.8}},
    selection_box = {{-1.5, -1}, {1.5, 1}},
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-output"
    },
    burner =
    {
      type = "burner",
      fuel_inventory_size = 1,
      effectivity = 0.5,
      emissions_per_minute = 30,
      light_flicker =
      {
        color = { 1, 0.75, 0},
        minimum_light_size = 1,
        minimum_intensity = 0.45,
        maximum_intensity = 0.95
      },
      smoke =
      {
        {
          name = "smoke",
          frequency = 10,
          north_position = {0.05, 0.9},
          east_position = {0.05, 0.9},
          starting_vertical_speed = 0.05,
        },
        {
          name = "fpf-simple-burner-generator-smoke",
          frequency = 60,
          north_position = {0.05, 0.9},
          east_position = {0.05, 0.8},
          starting_vertical_speed = 0.05,
          starting_vertical_speed_deviation = 0.02,
          deviation = {0.1, 0.1}
        },
      }
    },
    animation =
    {
      north = 
      {
        layers =
        {
          {
            filename = "__FPF__/graphics/entity/sbg/sbg-h.png",
            priority = "extra-high",
            width = 121,
            height = 80,
            shift = util.by_pixel(20, 4),
            frame_count = 1
          },
        }
      },
      east = 
      {
        layers = 
        {
          {
            filename = "__FPF__/graphics/entity/sbg/sbg-v.png",
            priority = "extra-high",
            width = 93,
            height = 112,
            shift = util.by_pixel(12, -0.5),
            frame_count = 1,
          }
        }
      }
    },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/steam-engine-90bpm.ogg",
        volume = 0.5
      },
      match_speed_to_activity = true,
    },
    min_perceived_performance = 0.25,
    performance_to_sound_speedup = 0.5,
    max_power_output = "1.2MW",
  },
})

-- item
data:extend({
  {
    type = "item",
    name = "fpf-simple-burner-generator",
    icon = "__FPF__/graphics/icons/sbg.png",
    icon_size = 32,
    flags = {},
    subgroup = "energy",
    order = "b[steam-power]-c[simple-burner-generator]",
    place_result = "fpf-simple-burner-generator",
    stack_size = 10
  },
})

-- recipe
data:extend({
  {
    type = "recipe",
    name = "fpf-simple-burner-generator",
    enabled = "true",
    ingredients =
    {
      {"boiler", 1},
      {"iron-plate", 4},
      {"iron-gear-wheel", 5},
      {"pipe", 3}
    },
    result = "fpf-simple-burner-generator"
  },
})
