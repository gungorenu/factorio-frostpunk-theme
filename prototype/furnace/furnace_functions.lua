require("././util/functions")

local named_entities = settings.startup["fpf-namedentities"].value

local function hit_effects_entity(offset_deviation, offset)
  local offset = offset or {0, 1}
  return
  {
    type = "create-entity",
    entity_name = "spark-explosion",
    offset_deviation = offset_deviation or {{-0.5, -0.5}, {0.5, 0.5}},
    offsets = {offset},
    damage_type_filters = "fire"
  }
end

local function get_emission( furnacePower, furnaceEffectivity)
  local def = 480
  local effModifier = 1 + (furnaceEffectivity -1) * 3 -- effectivity bonus applies trippled
  local emission = (def * furnacePower / 48) / effModifier
  return emission
end  

function get_furnace(nameSuffix, furnacePower, furnaceEffectivity)
  local localisedName = "entity-name.fpf-furnace"
  local localisedDesc = "entity-description.fpf-furnace"
  if named_entities then
    localisedName = "entity-name.fpf-furnace-named"
    localisedDesc = "entity-description.fpf-furnace-named"
  end

  local furnace = {
    type = "burner-generator",
    name = "fpf-furnace-"..nameSuffix,
    icon  = "__FPF__/graphics/icons/furnace.png",
    icon_size = 64, icon_mipmaps = 4,
    localised_name = {localisedName, furnacePower, furnaceEffectivity*100},
    localised_description = {localisedDesc, furnacePower, furnaceEffectivity*100 },
    flags = {"placeable-neutral", "not-rotatable", "not-deconstructable", "not-blueprintable", "not-upgradable" },
    minable = nil,
    max_health = 1000,
    rotate = false,
    corpse = "fpf-furnace-remnants",
    dying_explosion = "nuclear-reactor-explosion", -- << this does not work
    fast_replaceable_group  = "fpf-furnace",
    resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    },
    max_power_output = tostring(furnacePower).."MW",
    scale_energy_usage = false,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-output"
    },

    map_color = {r = 0.2, g = 0, b = 0},
    friendly_map_color = {r = 0.2, g = 0, b = 0},
    enemy_map_color = {r = 0.6, g = 0.3, b = 0},
    burner = {
      type = "burner",
      fuel_category = "chemical",
      effectivity = furnaceEffectivity,
      fuel_inventory_size = 1,
      emissions_per_minute = get_emission(furnacePower, furnaceEffectivity),
      light_flicker =
      {
        color = {1,0.75,0},
        minimum_light_size = 2,
        minimum_intensity = 0.45,
        maximum_intensity = 0.95
      },
      smoke =
      {
        {
          name = "smoke",
          frequency = 25,
          north_position = {-2.5, -1.4},
          south_position = {-2.5, -1.4},
          east_position = {-2.5, -1.4},
          west_position = {-2.5, -1.4},
          deviation = {0.2, 0.2},
          starting_vertical_speed = 0.02,
          starting_vertical_speed_deviation = 0.03,
          starting_frame_deviation = 3,
          slow_down_factor = 0.1
        },
        {
          name = "fpf-furnace-smoke",
          frequency = 25,
          north_position = {-2.5, -1.4},
          south_position = {-2.5, -1.4},
          east_position = {-2.5, -1.4},
          west_position = {-2.5, -1.4},
          deviation = {0.1, 0.1},
          starting_vertical_speed = 0.01,
          starting_vertical_speed_deviation = 0.01,
          starting_frame_deviation = 3,
          slow_down_factor = 0.1
        }        
      }
    },
    collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},

    damaged_trigger_effect = hit_effects_entity(),

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
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    
    animation = {
      layers =
      {
        {
          filename = "__FPF__/graphics/entity/furnace/furnace.png",
          width = 320,
          height = 320,
          shift = { -0.03125 *2, -0.1875 *2 },
          hr_version = {
            filename = "__FPF__/graphics/entity/furnace/hr-furnace.png",
            width = 640,
            height = 640,
            scale = 0.5,
            shift = { -0.03125 *2, -0.1875 *2 },
          }
        },
        {
          filename = "__FPF__/graphics/entity/furnace/furnace-shadow.png",
          width = 525,
          height = 323,
          shift = { 1.625 * 2, 0 },
          draw_as_shadow = true,
          hr_version = {
            filename = "__FPF__/graphics/entity/furnace/hr-furnace-shadow.png",
            width = 525*2,
            height = 323*2,
            scale = 0.5,
            shift = { 1.625 * 2, 0 },
            draw_as_shadow = true,
          }
        }
      }
    },
  }
  return furnace
end

local function get_science_pack_list (red, green, black, blue, purple, yellow, white)
  local sciences = {}

  if red >0 then table.insert(sciences, {"automation-science-pack", 1} ) end

  if green >0 then table.insert(sciences, {"logistic-science-pack", 1} ) end
  
  if black >0 then table.insert(sciences, {"military-science-pack", 1} ) end
  
  if blue >0 then table.insert(sciences, {"chemical-science-pack", 1} ) end
  
  if purple >0 then table.insert(sciences, {"production-science-pack", 1} ) end
  
  if yellow >0 then table.insert(sciences, {"utility-science-pack", 1} ) end
  
  if white >0 then table.insert(sciences, {"space-science-pack", 1} ) end

  return sciences
end    

function get_furnace_upgrade_tech_power(id, count, time, red, green, black, blue, purple, yellow, white)
  local powerUpgrade = 6
  local tech = {
      type = "technology",
      name = "fpf-furnace-power-upgrade-"..id,
      icons = {
        {
          icon = "__FPF__/graphics/technology/furnace.png",
          icon_size = 256, icon_mipmaps = 1
        },
        {
          icon = "__FPF__/graphics/technology/furnace-power.png",
          icon_size = 128,
          icon_mipmaps = 3,
          shift = {100, 100}
        }
      },
      localised_name = {"technology-name.fpf-furnace-power-upgrade", id },
      localised_description = {"technology-description.fpf-furnace-power-upgrade", (12 + powerUpgrade * id)},
      prerequisites = {},
      upgrade = true,
      effects =
      {
        {
          type = "nothing",
          effect_description = {"fpf-furnace-power-upgrade-bonus", powerUpgrade},
          icons = {
            {
              icon = "__FPF__/graphics/technology/furnace.png",
              icon_size = 256, icon_mipmaps = 1
            },
            {
              icon = "__FPF__/graphics/technology/furnace-power.png",
              icon_size = 128,
              icon_mipmaps = 3,
              scale = 0.25,
              shift = {11, 9}
            }
          }        
        }      
      },
      unit = {
        count = count,
        ingredients = get_science_pack_list(red, green, black, blue, purple, yellow, white),
        time = time
      }
    }    

  if id > 1 then
    table.insert(tech.prerequisites, "fpf-furnace-power-upgrade-"..(id-1))
  end
  return tech
end

function get_furnace_power_upgrade_inf_tech(id, powerUpgrade)
  local tech = {
    type = "technology",
    name = "fpf-furnace-power-upgrade-inf-1",
    icons = {
      {
        icon = "__FPF__/graphics/technology/furnace.png",
        icon_size = 256, icon_mipmaps = 1
      },
      {
        icon = "__FPF__/graphics/technology/furnace-power.png",
        icon_size = 128,
        icon_mipmaps = 3,
        shift = {100, 100}
      }
    },
    localised_name = {"technology-name.fpf-furnace-power-upgrade-inf", id },
    localised_description = {"technology-description.fpf-furnace-power-upgrade-inf", powerUpgrade},
    prerequisites = {"fpf-furnace-power-upgrade-6", "space-science-pack"},
    max_level = "infinite",
    effects =
    {
      {
        type = "nothing",
        effect_description = {"fpf-furnace-power-upgrade-inf-bonus", powerUpgrade},
        icons = {
          {
            icon = "__FPF__/graphics/technology/furnace.png",
            icon_size = 256, icon_mipmaps = 1
          },
          {
            icon = "__FPF__/graphics/technology/furnace-power.png",
            icon_size = 128,
            icon_mipmaps = 3,
            scale = 0.25,
            shift = {11, 9}
          }
        }        
      }      
    },
    unit = {
      count_formula = "2500*(L)",
      ingredients = get_science_pack_list(1, 1, 0, 1, 1, 1, 1),
      time = 30
    }
  }    

  if id > 1 then
    table.insert(tech.prerequisites, "fpf-furnace-power-upgrade-inf-"..(id-1))
  end
  return tech
end

function get_furnace_eff_upgrade_inf_tech(id, effUpgrade)
  local tech = {
    type = "technology",
    name = "fpf-furnace-eff-upgrade-inf-1",
    icons = {
      {
        icon = "__FPF__/graphics/technology/furnace.png",
        icon_size = 256, icon_mipmaps = 1
      },
      {
        icon = "__FPF__/graphics/technology/furnace-eff.png",
        icon_size = 128,
        icon_mipmaps = 3,
        shift = {100, 100}
      }
    },
    --localised_name = {"technology-name.fpf-furnace-eff-upgrade-inf", id },
    localised_description = {"technology-description.fpf-furnace-eff-upgrade-inf", effUpgrade},
    prerequisites = {"fpf-furnace-power-upgrade-6", "space-science-pack"},
    max_level = "infinite",
    effects =
    {
      {
        type = "nothing",
        effect_description = {"fpf-furnace-eff-upgrade-inf-bonus", effUpgrade},
        icons = {
          {
            icon = "__FPF__/graphics/technology/furnace.png",
            icon_size = 256, icon_mipmaps = 1
          },
          {
            icon = "__FPF__/graphics/technology/furnace-eff.png",
            icon_size = 128,
            icon_mipmaps = 3,
            scale = 0.25,
            shift = {11, 9}
          }
        }
      }      
    },
    unit = {
      count_formula = "2^(L-1)*1000",
      ingredients = get_science_pack_list(1, 1, 0, 1, 1, 1, 1),
      time = 30
    }
  }    

  if id > 1 then
    table.insert(tech.prerequisites, "fpf-furnace-eff-upgrade-inf-"..(id-1))
  end
  return tech
end

function get_furnace_name(power,eff, powerUpgradeBonus, effUpgradeBonus)
  -- partially upgraded furnace
  if power <48 and eff == 1 then
    local version = (power/6) -2
    return "fpf-furnace-" .. version
  end

  -- fully upgraded furnace
  if power ==48 and eff == 1 then return "fpf-furnace-6" end

  -- infinite furnaces
  local powerId = 0
  if powerUpgradeBonus > 0 then
    powerId = (power - 48) / powerUpgradeBonus
  end
  local effId = 0
  if eff > 1 then
    effId = (eff - 1) / effUpgradeBonus
  end

  return "fpf-furnace-upgraded-power-"..powerId .."-eff-".. effId
end