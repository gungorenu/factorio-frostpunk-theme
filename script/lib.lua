-- source about furnace spawning: https://github.com/Bilka2/AbandonedRuins/blob/master/control.lua
-- credits go to Bilka2

require("./util/functions")
require("./prototype/furnace/furnace_functions")
local spawning = require("spawning")

-------------------------------------------------------------------------------------------------------------------------------
---- Mod State and Settings ---------------------------------------------------------------------------------------------------

-- settings
local furnacePowerUpgrade = settings.startup["fpf-furnace-upgrade-power-upgrade"].value -- in MW, defaults to 3MW
local furnaceEffUpgrade = settings.startup["fpf-furnace-upgrade-eff-upgrade"].value -- in %, defaults to %5
local furnaceSpawnBaseRate = settings.global["fpf-furnace-spawn-baserate"].value
local furnaceSpawnMinDistance = settings.global["fpf-furnace-spawn-mindistance"].value
local furnaceSpawnProbPerChunk = settings.global["fpf-furnace-spawn-rateincrement-perchunk"].value

-- mod state info
-- global.furnace_map = {}, -- any spawned furnace shall be put here, not only claimed
-- entry >> [ entity.unit_number ] = entity
-- entry >> destroyed/removed entities are removed from this list
-- global.furnace_history = {}, -- custom data, all furnaces, including destroyed ones
-- entry >> [ position as "x/y" ] = { position = {x, y}, initial = furnace type name (will not be updated), claimed = boolean, dead = boolean }
-- entry >> all entries are here, even destroyed, and spawn check shall use this, not the furnace_map
-- global.furnace_power = 12, -- starting in MW
-- global.furnace_efficiency = 1, -- starting in %, *100
-- global.furnace_name = "fpf-furnace-0", -- to spawn this furnace, when upgraded the upgraded furnace shall be spawned, all furnaces are upgraded automatically
-- global.fpf_force = nil,
-- global.furnace_spawn_queue = {}, -- any entry here shall be spawn and nil after spawn
-- entry >> global.furnace_spawn_queue[ tick ] = { chunkPos = {x, y}, surface = surface entity, force = force entity, furnace_name = furnace to spawn, spawn_complete = boolean } 
-- entry >> once spawn is complete the entry should be deleted
-- global.first_furnace_created = false

-- map center
local mapCenter = get_chunk_center({x=0, y=0})

-------------------------------------------------------------------------------------------------------------------------------
---- Development Stuff --------------------------------------------------------------------------------------------------------

-- dump state info
local function dump_stats(msg)
  if settings.global["fpf-debug"].value then
    local baseMsg = "FPF[".. global.furnace_name .."/#" .. table_length(global.furnace_map) .. "/" .. global.furnace_power .. "MW/%" .. global.furnace_efficiency * 100 .. "] >> "
    game.print({"", baseMsg .. msg })

    for _, f in pairs(global.furnace_map) do
      if not f then 
        dprint("furnace is nil")
      elseif f.valid then
        dprint("F: " .. f.unit_number .. ", name: " .. f.name .. ", at " .. f.position.x .. "/" .. f.position.y)
      else
        dprint("furnace is invalid")
      end
    end
  end
end

-------------------------------------------------------------------------------------------------------------------------------
---- Functions ----------------------------------------------------------------------------------------------------------------

-- add furnace to map
local add_furnace_record = function(furnace)
  global.furnace_map[furnace.unit_number] = furnace
  global.furnace_history["" .. furnace.position.x .. "/" .. furnace.position.y] = { position = furnace.position, initial = furnace.name, claimed = false, dead = false }

  -- attempts to prevent furnace to be operated without claim
  furnace.operable = false
  furnace.active = false
  
  dump_stats("furnace added: #".. furnace.unit_number .. ", @" .. furnace.position.x .. "/" .. furnace.position.y)
end

-- swap furnace at map
local swap_furnace_record = function(oldFurnaceId, newFurnace)
  global.furnace_map[oldFurnaceId] = nil
  global.furnace_map[newFurnace.unit_number] = newFurnace
  
  dump_stats("furnace swapped: #".. oldFurnaceId .. " >> #" .. newFurnace.unit_number .. ", @" .. newFurnace.position.x .. "/" .. newFurnace.position.y)
end

-- remove furnace from map
local remove_furnace_record = function(furnace)
  global.furnace_map[furnace.unit_number] = nil
  global.furnace_history["" .. furnace.position.x .. "/" .. furnace.position.y].dead = true
  
  dump_stats("furnace removed: #".. furnace.unit_number)
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
  global.furnace_name = get_furnace_name(global.furnace_power, global.furnace_efficiency, furnacePowerUpgrade, furnaceEffUpgrade/100)

  local toUpdate = {}
  for _, entity in pairs (global.furnace_map) do
    if entity.valid then
      if entity.name ~= global.furnace_name then
        table.insert(toUpdate, entity)
      end
    end
  end

  for _, entity in pairs (toUpdate) do
    local oldId = entity.unit_number
    local newFurnace = replace_furnace_on_map(entity, global.furnace_name)
    swap_furnace_record(oldId, newFurnace)
  end
end

-- calculate spawn chance for a furnace
local get_furnace_spawn_chance = function (chunkPos)
  local pos = get_chunk_center(chunkPos)
  local prob = 0

  -- 1. if within 160 (5ch) tile then we skip
  local distance = get_distance(mapCenter, pos)
  if distance < 160 then 
    return prob
  end

  -- 2. if no furnace exists then the percentage starts with triple base rate
  if table_length(global.furnace_history) < 1 then 
    prob = 3 * (furnaceSpawnBaseRate / 100) 
  end

  -- 3. if a furnace exists then get the closest distance between the furnace and the chunk center
  for _, f in pairs(global.furnace_history) do
    if f then 
      local fDistance = get_distance(pos, f.position)
      if fDistance < distance then distance = fDistance end
    end
  end
  
  -- 4. if distance is closer than min defined distance then we skip
  if distance < furnaceSpawnMinDistance then return 0 end

  -- 5. depending on the furnace closest distance the percentage shall be calculated
  prob = prob + ((distance - furnaceSpawnMinDistance) / 32) * (furnaceSpawnProbPerChunk / 100)
  return prob
end

-- queue new furnace spawn, as mentioned by Bilka2, we do it on next tick
local queue_furnace_spawn = function(chunkPos, surface, tick)
  local processing_tick = tick + 1
  if not global.furnace_spawn_queue[processing_tick] then
    global.furnace_spawn_queue[processing_tick] = { chunkPos = chunkPos, surface = surface, force = global.fpf_force, furnace_name = global.furnace_name, spawn_complete = false } 
  end
end

-- real spawning here, also check variance and minor ruins/entities besides furnace, maybe even ore etc...
local spawn_furnace = function(furnaceSpawnInfo, tick)
  if not furnaceSpawnInfo.spawn_complete then
    -- TODO -- spawn furnace and its crater

    local result = spawning.spawn_furnace(10, furnaceSpawnInfo.surface, global.fpf_force, furnaceSpawnInfo.chunkPos, furnaceSpawnInfo.furnace_name )
    if result.res == 1 then
      if result.entity and result.entity.valid then 
        dprint( "generating done (" .. furnaceSpawnInfo.furnace_name .. ") at " .. furnaceSpawnInfo.chunkPos.x .."/" .. furnaceSpawnInfo.chunkPos.y .. ", surface: " .. furnaceSpawnInfo.surface.name )
        furnaceSpawnInfo.spawn_complete = true
      else
        dprint( "attempt gave good response but no entity" )
      end
    elseif result.res == -1 then
      dprint( "doh, invalid surface" )
    elseif result.res == -2 then 
      dprint( "after countless tries we failed" )
    end
  end
end

-- locate and spawn first ever furnace
local first_furnace_spawn = function (surface, force)
  local chunkPos = {x=0, y =0}
  local angle = math.rad(math.random() * 360)
  local sin = math.sin(angle)
  local cos = math.cos(angle)
  local radius = 32 * 6 + math.random() * 128 -- 4 chunk distance variance over base, which is 6 chunk size
  chunkPos.y = math.floor(sin * radius / 32)
  chunkPos.x = math.floor(cos * radius / 32)

  local result = { chunkPos = chunkPos, surface = surface, force = force, furnace_name = global.furnace_name, spawn_complete = false }
  return result
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

    global.furnace_power = global.furnace_power + furnacePowerUpgrade
    update_furnaces()
  elseif name:find("fpf%-furnace%-eff%-upgrade%-inf%-") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index

    global.furnace_efficiency = global.furnace_efficiency + (furnaceEffUpgrade/100)
    update_furnaces()
  elseif name:find("fpf%-furnace%-power%-upgrade%-") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index
  
    global.furnace_power = 12 + 6 * number -- we know base furnace starts from 12MW and increment is 6MW
    update_furnaces()
  end
end

-- on entity die/remove
local on_entity_removed = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end

  local name = entity.name
  if name:find("fpf%-furnace%-") then
    remove_furnace_record(entity)
  end
end

-- on chunk generated
local on_chunk_generated = function (event)
  global.chunks_checked = global.chunks_checked +1
  local spawnChance = get_furnace_spawn_chance(event.position)
  local prob = math.random()

  if spawnChance > 0 and spawnChance > prob then 
    queue_furnace_spawn(event.position, event.surface, event.tick)
  end
end

-- on area selected, for claim
local on_area_selected = function (event)
  if event.item ~= "fpf-claim" then return end

  -- force change
  local claimants_force = game.get_player(event.player_index).force
  local claimants_position = game.get_player(event.player_index).position
  for _, entity in pairs(event.entities) do
    if entity.valid and entity.force.name == global.fpf_force.name then

      -- only allow claiming if player is nearby, otherwise it can be done via map, which is not intended
      local distance = get_distance(entity.position, claimants_position)
      if distance < 32 then 
        entity.force = claimants_force
        entity.operable = true
        entity.active = true
        if global.furnace_history["" .. entity.position.x .. "/" .. entity.position.y] then 
          global.furnace_history["" .. entity.position.x .. "/" .. entity.position.y].claimed = true
        end
      end
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

-- on tick
local on_tick = function (event)
  local furnaceSpawnInfo = global.furnace_spawn_queue[event.tick]
  if not furnaceSpawnInfo then return end
  
  if not furnaceSpawnInfo.spawn_complete then 
    spawn_furnace(furnaceSpawnInfo, event.tick)
  end

  global.furnace_spawn_queue[event.tick] = nil
end

-------------------------------------------------------------------------------------------------------------------------------
---- Command Registration -----------------------------------------------------------------------------------------------------

-- manual entry to furnace spawn queue 
local spawn_furnace_command = function (command)
  local f = loadstring("return " .. command.parameter)
  local arg = f()
  local surface = game.surfaces[arg.surface or game.players[command.player_index].surface.name ]
  if not surface then 
    game.print{ "" .. "surface not known"}
    return
  end

  local myarg = {
    chunkPos = arg.chunkPos or {x=0, y=0},
    surface = surface,
    furnace_name = arg.furnace_name or global.furnace_name,
    spawn_complete = false
  }

  spawn_furnace(myarg, command.tick +1) 
end

-- force replace furnaces to current one
local replace_furnaces_command = function(command)
  local furnaceType = game.entity_prototypes[command.parameter or "fpf-furnace-0"]
  if not furnaceType then 
    game.print{ "" .. "furnace type not known"}
    return
  end

  for i, entity in pairs (global.furnace_map) do
    if entity.valid then
      if entity.name ~= furnaceType.name then
        local oldId = entity.unit_number
        local newFurnace = replace_furnace_on_map(entity, furnaceType.name)
        swap_furnace_record(oldId, newFurnace)
      end
    end
  end
end

-- register commands
commands.add_command("fpf_spawn_furnace", "spawns a furnace at specified chunk. expects arg: { chunkPos = <position of chunk, {x = #, y = #} >, surface = <surface name, nil for player surface>, furnace_name = <name of furnace if set, or nil for default one> } ", spawn_furnace_command )
commands.add_command("fpf_replace_furnaces", "replaces all furnaces to mentioned type. expects arg: furnace entity type name or empty for current one", replace_furnaces_command )

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
  [defines.events.on_chunk_generated] = on_chunk_generated,
  [defines.events.on_tick] = on_tick
}

local defaults = function ()
  global.furnace_map = global.furnace_map or {}
  global.furnace_history = global.furnace_history or {}
  global.furnace_power = global.furnace_power or 12
  global.furnace_efficiency = global.furnace_efficiency or 1
  global.furnace_name = global.furnace_name or "fpf-furnace-0"
  global.fpf_force = global.fpf_force or nil
  global.furnace_spawn_queue = global.furnace_spawn_queue or {}
  global.first_furnace = global.first_furnace or nil
  global.chunks_checked = global.chunks_checked or 0
end

local self_init = function()
  local fpf_force = game.forces["fpf-force"]
  if fpf_force == nil then
    fpf_force = game.create_force("fpf-force")
    local enemy = game.forces["enemy"]
    fpf_force.set_cease_fire(enemy, true)
    enemy.set_cease_fire(fpf_force, true)

    global.fpf_force = fpf_force
  end

  -- first ever furnace is kind of free, but once only
  if not global.first_furnace then
    local surface = game.surfaces["nauvis"] -- default surface
    local spawnInfo = first_furnace_spawn(surface, fpf_force)
    global.furnace_spawn_queue[0] = spawnInfo -- register for first tick
    global.first_furnace = spawnInfo
  end
end

lib.on_init = function()
  defaults()
  self_init()
end
  
lib.on_configuration_changed = function ()
  self_init()
end

lib.on_load = function()
  defaults()
end

-------------------------------------------------------------------------------------------------------------------------------

return lib