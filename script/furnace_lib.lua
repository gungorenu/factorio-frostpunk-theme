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
    local baseMsg = "FPF[".. script_data.furnace_name .."/#" .. table_length(script_data.furnace_map) .. "/" .. script_data.furnace_power .. "MW/%" .. script_data.furnace_efficiency * 100 .. "] >> "
    game.print({"", baseMsg .. msg })

    for _, f in pairs(script_data.furnace_map) do
      if not f then 
        game.print({"", "furnace is nil" })
      elseif f.valid then
        game.print({"", "F: " .. f.unit_number .. ", name: " .. f.name .. ", at " .. f.position.x .. "/" .. f.position.y })
      else
        game.print({"", "furnace is invalid" })
      end
    end
  end
end

-- dump print
local function dumpPrint(msg)
  if isDebug then
    game.print({"", msg })
  end
end

-- dump isnull
local function isnil(value)
  if value then
    return false
  end
  return true
end  

-- add furnace to map
local add_furnace_record = function(furnace)
  script_data.furnace_map[furnace.unit_number] = furnace
  
  local msg = "furnace added: #".. furnace.unit_number .. ", @" .. furnace.position.x .. "/" .. furnace.position.y
  dumpFurnaceStats(msg)
end

-- swap furnace at map
local swap_furnace_record = function(oldFurnaceId, newFurnace)
  script_data.furnace_map[oldFurnaceId] = nil
  script_data.furnace_map[newFurnace.unit_number] = newFurnace
  
  local msg = "furnace swapped: #".. oldFurnaceId .. " >> #" .. newFurnace.unit_number .. ", @" .. newFurnace.position.x .. "/" .. newFurnace.position.y
  dumpFurnaceStats(msg)
end

-- remove furnace from map
local remove_furnace_record = function(furnaceId)
  script_data.furnace_map[furnaceId] = nil
  
  local msg = "furnace removed: #".. furnaceId
  dumpFurnaceStats(msg)
end

-- replace existing furnace with new one
local replace_furnace_on_map = function (oldEntity, newFurnaceName)
  -- Save stats that can't be fast replaced
  local health = oldEntity.health
  local last_user = oldEntity.last_user
  local users = {}
  for _, player in pairs(game.players) do
    if player.opened == oldEntity then
      table.insert(users, player)
    end
  end

  local fuelInventory = oldEntity.get_inventory(defines.inventory.fuel).get_contents()
  local burner = oldEntity.burner
  local fuelBurning = burner.currently_burning
  local remainingBurning = burner.remaining_burning_fuel
  local oldSurface = oldEntity.surface
  local oldPosition = oldEntity.position
  local oldDirection = oldEntity.direction
  local oldForce = oldEntity.force

  -- Fast replace does not work fully, the power production does not stasify fully
  -- killing old entity and putting new entity actually works about power production but then it causes explosion which I do not want
  --oldEntity.die(oldEntity.force)

  -- destroy is silent so I am using it
  oldEntity.destroy({false,false})

  local new_entity = oldSurface.create_entity{
    fast_replace = false,
    name = newFurnaceName,
    position = oldPosition,
    direction = oldDirection,
    force = oldForce,
    spill = false,
    create_build_effect_smoke = false,
  }

  if new_entity then
    -- Update stats
    new_entity.health = health
    if last_user then
      new_entity.last_user = last_user
    end
    for _, player in pairs(users) do
      player.opened = new_entity
    end

    local newEntityInventory = new_entity.get_fuel_inventory()
    local newEntityInventoryContents = new_entity.get_fuel_inventory().get_contents() --get_inventory(defines.inventory.fuel).get_contents()
   
    for item_name, item_count in pairs(fuelInventory) do
      newEntityInventory.insert{name = item_name, count = item_count}
    end

    new_entity.burner.currently_burning = fuelBurning
    new_entity.burner.remaining_burning_fuel = remainingBurning
  end

  return new_entity
end

-- update existing furnaces
local update_furnaces = function ()
  script_data.furnace_name = get_furnace_name(script_data.furnace_power, script_data.furnace_efficiency, furnacePowerUpgrade, furnaceEffUpgrade/100)
  
  for i, entity in pairs (script_data.furnace_map) do
    if entity.valid then
      if entity.name ~= script_data.furnace_name then
        local oldId = entity.unit_number
        local newFurnace = replace_furnace_on_map(entity, script_data.furnace_name)
        swap_furnace_record(oldId, newFurnace)
      end
    end
  end
end

-- on entity created
local on_created_entity = function(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  
  local name = entity.name
  if name:find("fpf%-furnace%-") then
    add_furnace_record(entity)
  end
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

    script_data.furnace_power = script_data.furnace_power + furnacePowerUpgrade
    --dumpFurnaceStats("furnace infinite power upgrade caught, tech upgrade")
    update_furnaces()
  elseif name:find("fpf%-furnace%-eff%-upgrade%-inf%-") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index

    script_data.furnace_efficiency = script_data.furnace_efficiency + (furnaceEffUpgrade/100)
    --dumpFurnaceStats("furnace infinite efficiency upgrade caught, tech upgrade")
    update_furnaces()
  elseif name:find("fpf%-furnace%-power%-upgrade%-") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index
  
    script_data.furnace_power = 12 + 6 * number -- we know base furnace starts from 12MW and increment is 6MW
    --dumpFurnaceStats("furnace basic power upgrade caught, tech upgrade: " .. number)
    update_furnaces()
  end
end

-- on entity die/remove
local on_entity_removed = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end

  local name = entity.name
  if name:find("fpf%-furnace%-") then
    remove_furnace_record(entity.unit_number)
  end
end


-- lib register
local lib = {}

lib.events =
{
  -- we need these to track furnaces
  [defines.events.on_built_entity] = on_created_entity,
  [defines.events.on_robot_built_entity] = on_created_entity,
  [defines.events.script_raised_built] = on_created_entity,
  [defines.events.script_raised_revive] = on_created_entity,
  [defines.events.on_entity_cloned] = on_created_entity,
  [defines.events.on_entity_died] = on_entity_removed,
  [defines.events.script_raised_destroy] = on_entity_removed,
  [defines.events.on_player_mined_entity] = on_entity_removed,
  [defines.events.on_robot_mined_entity] = on_entity_removed,

  -- we need this to track our fake-infinite research
  [defines.events.on_research_finished] = on_research_finished, 



--  [defines.events.on_tick] = on_tick,
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