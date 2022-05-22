require("./util/functions")
require("./prototype/furnace/furnace_functions")

-- settings
local isDebug = settings.startup["fpf-debug"].value
local furnacePowerUpgrade = settings.startup["fpf-furnace-upgrade-power-upgrade"].value -- in MW, defaults to 3MW
local furnaceEffUpgrade = settings.startup["fpf-furnace-upgrade-eff-upgrade"].value -- in %, defaults to %5

-- mod state info
local script_data =
{
  furnace_map = {},
  furnace_power = 12,
  furnace_efficiency = 1,
  furnace_name = "fpf-furnace-0"
}

-- dump state info
local function dumpFurnaceStats(msg)
  if isDebug then
    local baseMsg = "FPF[".. global.fpf_furnace.furnace_name .."/#" .. table_length(global.fpf_furnace.furnace_map) .. "/" .. global.fpf_furnace.furnace_power .. "MW/%" .. global.fpf_furnace.furnace_efficiency * 100 .. "] >> "
    game.print({"", baseMsg .. msg })
  end
end

local to_map_position = function(position)
  local x = floor(position.x / map_resolution)
  local y = floor(position.y / map_resolution)
  return x, y
end

-- add furnace to map
local add_to_furnace_map = function(furnace)
  script_data.furnace_map[furnace.unit_number] = furnace
  
  local msg = "new furnace to be added: ".. furnace.unit_number .. ", at position: " .. furnace.position.x .. "/" .. furnace.position.y
  dumpFurnaceStats(msg)
end

-- replace existing furnaces
local update_furnaces = function ()
  -- TODO

  script_data.furnace_name = get_furnace_name(script_data.furnace_power, script_data.furnace_efficiency, furnacePowerUpgrade, furnaceEffUpgrade/100)
  dumpFurnaceStats("furnace update code here")
end

-- on entity created
local on_created_entity = function(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  
  local name = entity.name
  if name:find("fpf-furnace%-") then
    add_to_furnace_map(entity)
  end
end
  
-- check furnace update if needed
local check_furnace_update = function(event)
    -- local active_furnaces = script_data.active_furnaces
    -- if not next(active_furnaces) then return end
  
    -- local turret_update_mod = event.tick % turret_update_interval
    -- for k, turret_data in pairs (active_turrets) do
    --   if (k * 8) % turret_update_interval == turret_update_mod then
    --     if update_turret(turret_data) then
    --         active_furnaces[k] = nil
    --     end
    --   end
    -- end
end
  
-- on every tick
local on_tick = function(event)
--  check_furnace_update(event)
end

-- capture tech upgrades
local on_research_finished = function(event)
  local research = event.research
  if not (research and research.valid) then return end

  local name = research.name

  if name:find("fpf%-furnace%-power%-upgrade%-inf%-") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index

    script_data.furnace_power = 48 + furnacePowerUpgrade * number -- we know infinite furnace starts from 48MW
    dumpFurnaceStats("furnace infinite power upgrade caught, tech upgrade: " .. number)
    update_furnaces()
  elseif name:find("fpf%-furnace%-eff%-upgrade%-inf%-") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index

    script_data.furnace_efficiency = 1 + (furnaceEffUpgrade/100) * number
    dumpFurnaceStats("furnace infinite efficiency upgrade caught, tech upgrade: " .. number)
    update_furnaces()
  elseif name:find("fpf%-furnace%-power%-upgrade%-") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index
  
    script_data.furnace_power = 12 + 6 * number -- we know base furnace starts from 12MW and increment is 6MW
    dumpFurnaceStats("furnace basic power upgrade caught, tech upgrade: " .. number)
    update_furnaces()
  end
end

-- lib register
local lib = {}

lib.events =
{
  [defines.events.on_built_entity] = on_created_entity,
  [defines.events.on_robot_built_entity] = on_created_entity,
  [defines.events.script_raised_built] = on_created_entity,
  [defines.events.script_raised_revive] = on_created_entity,
  [defines.events.on_entity_cloned] = on_created_entity,

--  [defines.events.on_tick] = on_tick,
--  [defines.events.on_entity_damaged] = on_entity_damaged,
  [defines.events.on_research_finished] = on_research_finished,

--  [defines.events.on_entity_died] = on_entity_removed,
--  [defines.events.script_raised_destroy] = on_entity_removed,
--  [defines.events.on_player_mined_entity] = on_entity_removed,
--  [defines.events.on_robot_mined_entity] = on_entity_removed,

--  [defines.events.on_post_entity_died] = on_post_entity_died,

--  [defines.events.on_surface_cleared] = clear_cache,
--  [defines.events.on_surface_deleted] = clear_cache,

--  [defines.events.on_marked_for_deconstruction] = on_marked_for_deconstruction,
}

lib.on_init = function()
  global.fpf_furnace = global.fpf_furnace or script_data
end
  
lib.on_load = function()
  script_data = global.fpf_furnace or script_data
end
 
return lib