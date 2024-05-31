-- source: Torches mod by Klonan and Old Boiler by Haq1 
-- https://mods.factorio.com/mod/Torches
-- https://mods.factorio.com/mod/old-boiler

-- smoke
data:extend({
  {
    type = "trivial-smoke",
    name = "fpftheme-torch-smoke",
    flags = {"not-on-map"},
    duration = 170,
    fade_in_duration = 20,
    fade_away_duration = 100,
    spread_duration = 200,
    slow_down_factor = 0.5,
    start_scale = 1,
    end_scale = 0,
    color = {r = 1, g = 0.4, b = 0.4, a = 0.1},
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
  }
})

-- entity
data:extend({
  {
    type = "burner-generator",
    name = "fpftheme-torch",
    icon = "__FPFTheme__/graphics/icons/torch.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation", "not-rotatable"},
    minable = {mining_time = 0.2, result = "fpftheme-torch"},
    max_health = 100,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    damaged_trigger_effect = hit_effects_entity(),
    resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    },
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.45, -0.45}, {0.45, 0.45}},
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-output"
    },
    burner =
    {
      fuel_category = "chemical",
      effectivity = 0.00001,
      fuel_inventory_size = 1,
      emissions_per_minute = 1,
      smoke =
      {
        {
          name = "smoke",
          deviation = {0, 0},
          position = {0.1, -1.3},
          frequency = 1
        },
        {
          name = "fpftheme-torch-smoke",
          frequency = 20,
          position = {0.1, -1.3},
          deviation = {0.1, 0.1},
          starting_vertical_speed = 0.1,
          starting_vertical_speed_deviation = 0.1,
          starting_frame_deviation = 3,
          slow_down_factor = 0.1
        }
      },
      light_flicker =
      {
        color = {1, 0.55, 0},
        minimum_light_size = 4,
        minimum_intensity = 0.35,
        maximum_intensity = 0.75
      }
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-output",
      buffer_capacity = "1GW",
      render_no_network_icon = false
    },
    animation =
    {
      layers =
      {
        {
          filename = "__FPFTheme__/graphics/entity/torch/torch.png",
          priority = "extra-high",
          width = 66,
          height = 74,
          repeat_count= 48,
          frame_count = 1,
          scale = 1
        },
        {
          filename = "__FPFTheme__/graphics/entity/torch/torch-fire.png",
          priority = "extra-high",
          frame_count = 48,
          line_length = 8,
          width = 21,
          height = 34,
          animation_speed = 0.5,
          shift = util.by_pixel(4.5, -3),
          draw_as_glow = true,
        }
      }
    },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/steam-engine-90bpm.ogg",
        volume = 0.25
      },
      match_speed_to_activity = true,
    },
    min_perceived_performance = 0.25,
    performance_to_sound_speedup = 0.5,
    max_power_output = "1W",
  },
})

-- item
data:extend({
  {
    type = "item",
    name = "fpftheme-torch",
    icon = "__FPFTheme__/graphics/icons/torch.png",
    icon_size = 32,
    flags = {},
    subgroup = "energy",
    order = "b[lamp]-c[fpftheme-torch]",
    place_result = "fpftheme-torch",
    stack_size = 10
  },
})

-- recipe
data:extend({
  {
    type = "recipe",
    name = "fpftheme-torch",
    enabled = "true",
    ingredients =
    {
      {"stone-furnace", 1},
      {"pipe", 1},
      {"iron-plate", 2}
    },
    result = "fpftheme-torch"
  },
})
