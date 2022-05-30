require("furnace_functions")

-- item category
data:extend({
  {
      type = "item-subgroup",
      name = "fpf-entities",
      group = "production",
      order = "e-f"
    },    
})

-- remnant
data:extend({
  {  
    type = "corpse",
    name = "fpf-furnace-remnants",
    icon = "__FPF__/graphics/icons/furnace.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "not-on-map"},
    subgroup = "energy-remnants",
    order = "a-e-a",
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    tile_width = 9,
    tile_height = 9,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation =
    {
      filename = "__FPF__/graphics/entity/furnace/remnants/furnace-remnants.png",
      line_length = 1,
      width = 320,
      height = 320,
      frame_count = 1,
      variation_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      shift = util.by_pixel(7, 4),
      hr_version =
      {
        filename = "__FPF__/graphics/entity/furnace/remnants/hr-furnace-remnants.png",
        line_length = 1,
        width = 640,
        height = 640,
        frame_count = 1,
        variation_count = 1,
        axially_symmetrical = false,
        direction_count = 1,
        shift = util.by_pixel(7, 4),
        scale = 0.5
      }
    }  
  }  
})

-- basic upgrade technologies
local baseTechnologies = {
  get_furnace_upgrade_tech_power(1, 50, 30, 1, 0, 0, 0, 0, 0, 0),
  get_furnace_upgrade_tech_power(2, 50, 30, 1, 1, 0, 0, 0, 0, 0),
  get_furnace_upgrade_tech_power(3, 100, 30, 1, 1, 0, 1, 0, 0, 0),
  get_furnace_upgrade_tech_power(4, 150, 30, 1, 1, 0, 1, 1, 0, 0),
  get_furnace_upgrade_tech_power(5, 200, 30, 1, 1, 0, 1, 1, 1, 0),
  get_furnace_upgrade_tech_power(6, 250, 30, 1, 1, 0, 1, 1, 1, 0)
}
data:extend(baseTechnologies)

-- smoke
data:extend({
  {
    type = "trivial-smoke",
    name = "fpf-furnace-smoke",
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
    affected_by_wind = false,
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
local furnaceEntities = {}
for i=0, 6, 1 do
  local power = (i+2) * 6
  local furnace = get_furnace(tostring(i), power, 1)
  table.insert(furnaceEntities, furnace)
end  

data:extend(furnaceEntities)

-- signal in case someone wants to use it
data:extend({
  {
    type = "virtual-signal",
    name = "fpf-signal",
    icon = "__FPF__/graphics/icons/furnace.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "energy",
  }
})

