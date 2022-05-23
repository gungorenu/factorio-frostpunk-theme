require("./util/functions")
require("./prototype/furnace/furnace_functions")

-------------------------------------------------------------------------------------------------------------------------------
---- Mod State and Settings ---------------------------------------------------------------------------------------------------

-- settings
local isDebug = settings.startup["fpf-debug"].value
local furnacePowerUpgrade = settings.startup["fpf-furnace-upgrade-power-upgrade"].value -- in MW, defaults to 3MW
local furnaceEffUpgrade = settings.startup["fpf-furnace-upgrade-eff-upgrade"].value -- in %, defaults to %5
local furnaceSpawnBaseRate = settings.global["fpf-furnace-spawn-baserate"].value
local furnaceSpawnMinDistance = settings.global["fpf-furnace-spawn-mindistance"].value
local furnaceSpawnProbPerChunk = settings.global["fpf-furnace-spawn-rateincrement-perchunk"].value

-- mod state info
local script_data =
{
  furnace_map = {},
  furnace_power = 12,
  furnace_efficiency = 1,
  furnace_name = "fpf-furnace-0",
  fpf_force = nil
}

-------------------------------------------------------------------------------------------------------------------------------
---- Development Stuff --------------------------------------------------------------------------------------------------------

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
local function dump(value)
  if value then
    return value
  end
  return "nil"
end  

-------------------------------------------------------------------------------------------------------------------------------
---- Functions ----------------------------------------------------------------------------------------------------------------

-- add furnace to map
local add_furnace_record = function(furnace)
  script_data.furnace_map[furnace.unit_number] = furnace
  -- attempts to prevent furnace to be operated without claim
  furnace.operable = false
  furnace.active = false
  
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
  local operable = oldEntity.operable
  local wasActive = oldEntity.active
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

  -- Fast replace does not work fully, the power production does not satisfy fully
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
    new_entity.operable = operable
    new_entity.active = wasActive
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

-------------------------------------------------------------------------------------------------------------------------------
---- Event Handlers -----------------------------------------------------------------------------------------------------------

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
    update_furnaces()
  elseif name:find("fpf%-furnace%-eff%-upgrade%-inf%-") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index

    script_data.furnace_efficiency = script_data.furnace_efficiency + (furnaceEffUpgrade/100)
    update_furnaces()
  elseif name:find("fpf%-furnace%-power%-upgrade%-") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index
  
    script_data.furnace_power = 12 + 6 * number -- we know base furnace starts from 12MW and increment is 6MW
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

-- on chunk generated
local on_chunk_generated = function (event)
  -- TODO
  



end

-- on area selected, for claim
local on_area_selected = function (event)
  if event.item ~= "fpf-claim" then return end

  -- force change
  local claimants_force = game.get_player(event.player_index).force
  for _, entity in pairs(event.entities) do
    if entity.valid and entity.force.name == script_data.fpf_force.name then
      entity.force = claimants_force
      entity.operable = true
      entity.active = true
    end
  end

  -- remnant destruction
  if event.name == defines.events.on_player_alt_selected_area then
    local remnants = event.surface.find_entities_filtered{area = event.area, type = {"corpse", "rail-remnants"}}
    for _, remnant in pairs(remnants) do
      remnant.destroy({raise_destroy = true})
    end
  end
end

-------------------------------------------------------------------------------------------------------------------------------
---- Library Registration -----------------------------------------------------------------------------------------------------

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

  -- we need these for claim tool
  [defines.events.on_player_selected_area] = on_area_selected,
  [defines.events.on_player_alt_selected_area] = on_area_selected,

  -- we need this to spawn furnaces randomly
  [defines.events.on_chunk_generated ] = on_chunk_generated,


--  [defines.events.on_post_entity_died] = on_post_entity_died,
--  [defines.events.on_surface_cleared] = clear_cache,
--  [defines.events.on_surface_deleted] = clear_cache,
--  [defines.events.on_marked_for_deconstruction] = on_marked_for_deconstruction,
}

local self_init = function()
  global.fpf_furnace = global.fpf_furnace or script_data
  local fpf_force = game.forces["fpf-force"]
  if fpf_force == nil then
    fpf_force = game.create_force("fpf-force")
    local enemy = game.forces["enemy"]
    fpf_force.set_cease_fire(enemy, true)
    enemy.set_cease_fire(fpf_force, true)

    global.fpf_furnace.fpf_force = fpf_force
  end
end

lib.on_init = function()
  self_init()
end
  
lib.on_configuration_changed = function ()
  self_init()
end

lib.on_load = function()
  script_data = global.fpf_furnace or script_data
end

-------------------------------------------------------------------------------------------------------------------------------

return lib