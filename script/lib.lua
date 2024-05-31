-- source about furnace spawning: https://github.com/Bilka2/AbandonedRuins/blob/master/control.lua
-- credits go to Bilka2

require("./util/functions")
require("./prototype/furnace/furnace_functions")
local fposition = require("./util/position")
local ftable = require("./util/table")
local spawning = require("spawning")

-------------------------------------------------------------------------------------------------------------------------------
---- Mod State and Settings ---------------------------------------------------------------------------------------------------

-- settings
local furnacePowerUpgrade = settings.startup["fpftheme-furnace-upgrade-power-upgrade"].value -- in MW, defaults to 3MW
local furnaceEffUpgrade = settings.startup["fpftheme-furnace-upgrade-eff-upgrade"].value -- in %, defaults to %5
local furnaceSpawnBaseRate = settings.global["fpftheme-furnace-spawn-baserate"].value
local furnaceSpawnMinDistance = settings.global["fpftheme-furnace-spawn-mindistance"].value
local furnaceSpawnAccDistance = settings.global["fpftheme-furnace-spawn-accdistance"].value
local furnaceSpawnProbPerChunk = settings.global["fpftheme-furnace-spawn-rateincrement-perchunk"].value
local furnaceSpawning = settings.global["fpftheme-furnace-spawning"].value -- disables spawning of furnaces, basically disables the mod

--[[ mod state info
global.furnace_map = furnace list, might include destroyed, unclaimed or enemy furnaces
- [id: x/y] - uses furnace position as id
- - x,y location
- - id, same as id registered itself 
- - crater info, entire definition
- - furnace, entity itself
- - surface, the furnace surface
- - proofCheck, if set then the furnace is complete, all proof check is done etc, if set to true and the final check is done then I expect no further issues about the furnace crater
- - dead: true/false, if it is dead then set to dead for simplicity
- - claimed: nil/player_index either nil or player_index, who claimed it
- - crater_chunks, creater chunk entity list
- - [id: x/y] - uses chunk position as id 
- - - position location
- - - id, same as id registered itself
- - - cliffs = { } - list of cliffs
- - - - x,y location
- - - - variation, cliff variation
global.tick_queue = registered operations we want to do on preceding ticks
global.chunk_queue = chunk list that we are interested in
- [id: x/y] - uses chunk position as id
- - x/y location of furnace as value (string) 
global.furnace_power = 12, -- starting in MW
global.furnace_efficiency = 1, -- starting in %, *100
global.furnace_name = "fpftheme-furnace-0", -- to spawn this furnace, when upgraded the upgraded furnace shall be spawned, all furnaces are upgraded automatically
global.fpftheme_force = will be force of the furnaces,
global.first_furnace = x/y id of first furnace
--]] 

-- non global stuff
-- list of known craters
-- entry >> crater definition has a special format
local approvedCraters = require("craterdata")
local excludedSurfaces = { "beltlayer", "pipelayer", "Factory floor", "ControlRoom" }
local craterForce = nil

-------------------------------------------------------------------------------------------------------------------------------
---- Functions ----------------------------------------------------------------------------------------------------------------

-- add furnace to map
local add_furnace_record = function(furnace)
  local id = fposition.id(furnace.position)
  if global.furnace_map[id] then
    global.furnace_map[id].furnace = furnace
  end
  -- attempts to prevent furnace to be operated without claim
  furnace.operable = false
  furnace.active = not furnaceSpawning
  lprint("furnace added : " .. id)
end

-- swap furnace at map
local swap_furnace_record = function(oldFurnaceId, newFurnace)
  local id = fposition.id(newFurnace.position)
  global.furnace_map[id].furnace = newFurnace
  lprint("furnace swap : " .. id)
end

-- remove furnace from map
local remove_furnace_record = function(furnace)
  local id = fposition.id(furnace.position)
  global.furnace_map[id].furnace = nil
  global.furnace_map[id].dead = true
  lprint("furnace removed : " .. id)
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
    local newEntityInventoryContents = new_entity.get_fuel_inventory().get_contents()
   
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
  local furnaceName = get_furnace_name(global.furnace_power, global.furnace_efficiency, furnacePowerUpgrade, furnaceEffUpgrade/100)
  local furnaceTypes = game.get_filtered_entity_prototypes({{ filter = "name", name = furnaceName }})
  if ftable.length(furnaceTypes) <1 then
    game.print{ "command-output.fpftheme-furnace-name-not-found" }
    return
  end
  
  global.furnace_name = furnaceName
  lprint("updating furnaces")

  local toUpdate = {}
  for _, furnaceInfo in pairs (global.furnace_map) do
    if furnaceInfo.furnace and furnaceInfo.furnace.valid then
      if furnaceInfo.furnace.name ~= global.furnace_name then
        table.insert(toUpdate, furnaceInfo.furnace)
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
  if not furnaceSpawning then 
    return 0
  end

  local id = fposition.id(chunkPos)

  local pos = fposition.chunk_center(chunkPos)
  local prob = 0

  -- 1. if within 160 (5ch) tile then we skip
  local distance = fposition.distance(fposition.chunk_center({x=0, y=0}), pos)
  if distance < 160 then 
    return prob
  end

  -- 2. if no furnace exists then the percentage starts with triple base rate
  if ftable.length(global.furnace_map) < 1 then 
    prob = 3 * (furnaceSpawnBaseRate / 100) 
  end

  -- 3. if a furnace exists then get the closest distance between the furnace and the chunk center
  for _, f in pairs(global.furnace_map) do
    if f then 
      local fDistance = fposition.distance(pos, f.position)
      if fDistance < distance then distance = fDistance end
    end
  end
  
  -- 4. every spawned furnace extends the distance
  local furnaceCount = ftable.length(global.furnace_map) -1
  if ( furnaceCount < 0 ) then 
    furnaceCount =0
  end

  local minSpawnDistance = furnaceSpawnMinDistance + (furnaceCount * furnaceSpawnAccDistance)

  -- 5. if distance is closer than min defined distance then we skip
  if distance < minSpawnDistance then return 0 end

  -- 6. depending on the furnace closest distance the percentage shall be calculated
  prob = prob + ((distance - minSpawnDistance) / 32) * (furnaceSpawnProbPerChunk / 100)
  return prob
end

-- queue to tick_queue
local append_to_tickqueue = function(furnaceId, tick, chunkId, position)
  local list = global.tick_queue[tick] or { } 
  table.insert(list, { furnaceId = furnaceId , chunkId = chunkId, position = position } )
  global.tick_queue[tick] = list
end

-- queue to tick_queue
local append_to_chunkqueue = function(furnaceId, chunkId, position)
  local list = global.chunk_queue[chunkId] or { } 
  table.insert(list, { furnaceId = furnaceId , chunkId = chunkId, position = position } )
  global.chunk_queue[chunkId] = list
end

-- prepare a furnace creation at chunk position
local prepare_furnace_at_chunk = function(chunkPos)
  local pos = fposition.chunk_to_pos(chunkPos)
  pos = { 
    x = pos.x + math.random(31) + 0.5, 
    y = pos.y + math.random(31) + 0.5 
  }
  
  local furnaceInfo = {
    position = pos,
    id = fposition.id(pos),
    furnace = nil,
    surface = nil,
    dead = false,
    claimed = nil,
    crater = nil,
    crater_chunks = { },
    crater_chunks_spawned =0
  }

  -- crater randomization
  local rand = math.random(ftable.length(approvedCraters))
  local crater = ftable.at(approvedCraters, rand)
  if not crater then 
    dprint( "crater not found")
    return nil
  end
  furnaceInfo.crater = crater

  global.furnace_map[furnaceInfo.id] = furnaceInfo

  return furnaceInfo
end

-- register furnace
local register_furnace = function (furnaceInfo, surface, tick)
  -- we registered to chunk queue
  if not surface or not surface.valid then
    dprint("Surface info is nil or invalid") 
    return nil
   end

   furnaceInfo.surface = surface

  -- register furnace itself 
  local chunkId = fposition.chunk_id(furnaceInfo.position)
  local chunkPos = fposition.chunk(furnaceInfo.position)
  if surface.is_chunk_generated(chunkPos) then 
    append_to_tickqueue(furnaceInfo.id, tick + 1, chunkId, furnaceInfo.position)
  else
    append_to_chunkqueue(furnaceInfo.id, chunkId, furnaceInfo.position)
  end

  -- register chunks
  local chunks = spawning.crater_chunks(furnaceInfo)
  local mod = 60 -- the resource generation removes my cliffs, I have to wait for some time 
  for _, chunk in pairs(chunks) do
    local chunkPos = chunk.position
    chunkId = fposition.id(chunkPos)
    -- chunk of crater is generated already, so register for spawning
    if surface.is_chunk_generated(chunkPos) then
      mod = mod +10
      append_to_tickqueue(furnaceInfo.id, tick + mod, chunkId)
    else
      -- chunk of crater is not generated yet, so we delay spawning cliffs
      append_to_chunkqueue(furnaceInfo.id, chunkId)
    end

    furnaceInfo.crater_chunks[chunkId] = chunk
  end

  lprint("new furnace registered at " .. furnaceInfo.position.x .. "/" .. furnaceInfo.position.y .. ", with " .. ftable.length(furnaceInfo.crater_chunks)  .. "chunks")
  return furnaceInfo
end

-- runs a proof check in case the cliffs are not spawned properly
local run_proof = function (furnaceInfo, chunkId)
  local chunkData = furnaceInfo.crater_chunks[chunkId]
  if not chunkData then 
    lprint("furnace " .. furnaceInfo.id .. " has no such a chunk to prove: " .. chunkId )
    return
  end

  if not chunkData.proof_needed then
    lprint("furnace " .. furnaceInfo.id .. " and chunk " .. chunkId .. " did not need proof")
    return
  end
  chunkData.proof_needed = nil

  if not furnaceInfo.surface.is_chunk_generated(chunkData.position) then
    lprint("furnace " .. furnaceInfo.id .. " and chunk " .. chunkId .. " was not generated yet")
  end

  for _, cl in pairs(chunkData.entities) do
    local list = furnaceInfo.surface.find_entities_filtered{position= cl.position, radius =2, type="cliff", name="fpftheme-cliff"}
    local current = nil
    for _, cliff in pairs(list) do 
      if cliff and cliff.valid and cliff.cliff_orientation == cl.orientation then
        current = cliff
        break
      end
    end

    local hasFault = false
    if not current then
      lprint("ERR: cliff [inside chunk " .. chunkId .. "] with ".. cl.orientation .. " orientation does not exist:" .. cl.position.x .. "/" .. cl.position.y )
      hasFault = true
    end 

    chunkData.proof_needed = hasFault or chunkData.proof_needed
    if hasFault then 
      local res = spawning.spawn_cliff (furnaceInfo.surface, craterForce, cl, true)
      if not res then
        lprint("ERR: cliff correction still failed:" .. cl.position.x .. "/" .. cl.position.y .. ", orientation: " .. cl.orientation )
      end
    end
  end

  -- we need another proof after 2sec
  if chunkData.proof_needed then
    append_to_tickqueue(furnaceInfo.id, game.tick +120, chunkId)
  else
    lprint("furnace " .. furnaceInfo.id .. " and chunk " .. chunkId .. " proof is completed without further issues")
  end

end

-- registers a call to perform chunk spawning
local spawn_furnace_chunk = function( furnaceInfo, cliffChunk, tick)
  local chunkPos = cliffChunk.position
  if not furnaceInfo.surface.is_chunk_generated(chunkPos) then
    lprint("furnace cliff was not generated but was called on chunk " .. entry.chunkId .. " for furnace " .. entry.furnaceId .. " completed")
  end

  spawning.spawn_crater(cliffChunk, furnaceInfo.surface, craterForce)
  furnaceInfo.crater_chunks_spawned = furnaceInfo.crater_chunks_spawned +1 

  -- proof
  cliffChunk.proof_needed = true
  append_to_tickqueue(furnaceInfo.id, tick +10, chunkId, furnaceInfo.position)
end

-------------------------------------------------------------------------------------------------------------------------------
---- Event Handlers -----------------------------------------------------------------------------------------------------------

-- on entity created
local on_created_entity = function(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  
  local name = entity.name
  if name:find("fpftheme%-furnace%-") then
    add_furnace_record(entity)
  end
end

-- capture tech upgrades
local on_research_finished = function(event)
  local research = event.research
  if not (research and research.valid) then return end

  local name = research.name

  if name:find("fpftheme%-furnace%-inf%-power%-upgrade%-") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index

    global.furnace_power = global.furnace_power + furnacePowerUpgrade
    lprint("furnace infinite power upgrade tech captured")
    update_furnaces()
  elseif name:find("fpftheme%-furnace%-inf%-eff%-upgrade%-") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index

    global.furnace_efficiency = global.furnace_efficiency + (furnaceEffUpgrade/100)
    lprint("furnace infinite efficiency upgrade tech captured")
    update_furnaces()
  elseif name:find("fpftheme%-furnace%-power%-upgrade%-") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index
  
    global.furnace_power = 12 + 6 * number -- we know base furnace starts from 12MW and increment is 6MW
    lprint("furnace power upgrade tech captured")
    update_furnaces()
  end
end

-- on entity die/remove
local on_entity_removed = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end

  local name = entity.name
  if name:find("fpftheme%-furnace%-") then
    remove_furnace_record(entity)
  end

  -- my cliff is destroyed
  if name:find("fpftheme%-cliff") then
    lprint("FPFTheme-Cliff at " .. entity.position.x .. "/" .. entity.position.y .." with " .. entity.cliff_orientation .." is destroyed")
  end
end

-- on chunk generated
local on_chunk_generated = function (event)
  if ftable.contains(excludedSurfaces, event.surface.name) then return end
  
  local chunkId = fposition.id(event.position)
  --lprint("chunk generated: " .. chunkId)
  local entries = global.chunk_queue[chunkId]
  if entries then
    for _, entry in pairs(entries) do
      local furnaceInfo = global.furnace_map[entry.furnaceId]
      -- only if furnace is known and valid
      if furnaceInfo then
        if event.surface == furnaceInfo.surface then
          append_to_tickqueue(furnaceInfo.id, event.tick +1, chunkId, furnaceInfo.position)
        end
      else
        dprint("furnace id was registered for chunk generation but it was not found: " .. furnaceId )
      end
    end
  end

  global.chunk_queue[chunkId] = nil

  global.chunks_checked = global.chunks_checked +1
  local spawnChance = get_furnace_spawn_chance(event.position)
  local prob = math.random()

  if spawnChance > 0 and spawnChance > prob then 
    local furnaceInfo = prepare_furnace_at_chunk(event.position)
    register_furnace(furnaceInfo, event.surface, event.tick +300)
  end
end

-- on area selected, for claim
local on_area_selected = function (event)
  if event.item ~= "fpftheme-claim" then return end

  -- force change
  local claimants_force = game.get_player(event.player_index).force
  local claimants_position = game.get_player(event.player_index).position
  for _, entity in pairs(event.entities) do
    if entity.valid and entity.force.name == global.fpftheme_force.name and 
      entity.name ~= "cliff" then

      -- only allow claiming if player is nearby, otherwise it can be done via map, which is not intended
      local distance = fposition.distance(entity.position, claimants_position)
      if distance < 32 then 
        entity.force = claimants_force
        entity.operable = true
        entity.active = true
        local id = fposition.id(entity.position)
        if global.furnace_map[id] then 
          global.furnace_map[id].claimed = true
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
  local tickOps = global.tick_queue[event.tick]
  if not tickOps then return end
  
  for _, entry in pairs(tickOps) do
    local furnaceInfo = global.furnace_map[entry.furnaceId]
    if not furnaceInfo then
      dprint("furnace id was registered for chunk generation but it was not found: " .. entry.furnaceId )
    else
      -- spawn furnace if not spawned but can be spawned
      if furnaceInfo.position then
        local furnaceChunkPos = fposition.chunk(furnaceInfo.position)
        if furnaceInfo.surface.is_chunk_generated(furnaceChunkPos) and not furnaceInfo.furnace then
          local res = spawning.spawn_furnace(furnaceInfo.position, furnaceInfo.surface, global.fpftheme_force, global.furnace_name)
          if not res.entity then
            dprint("furnace could not be spawned at location: " .. furnaceInfo.id)
          else
            furnaceInfo.furnace = res.entity
          end
        end
      end
      
      -- spawn crater
      if entry.chunkId then
        local cliffChunk = furnaceInfo.crater_chunks[entry.chunkId]
        if cliffChunk then
          if cliffChunk.proof_needed or furnaceInfo.proofCheck then
            lprint("furnace " .. furnaceInfo.id .. " is proving chunk " .. entry.chunkId)
            run_proof(furnaceInfo, entry.chunkId)
          else
            lprint("furnace " .. furnaceInfo.id .. " is spawning chunk " .. entry.chunkId)
            spawn_furnace_chunk( furnaceInfo, cliffChunk, event.tick)
            cliffChunk.proof_needed = true
            append_to_tickqueue(furnaceInfo.id, event.tick +300, entry.chunkId)
          end
        end
      end
    end

    -- every cliff chunk is also spawned (which includes furnace itself as well since it is inside crater) now queue a final clearance
    if ftable.length(furnaceInfo.crater_chunks) == furnaceInfo.crater_chunks_spawned then
      local chunkId = fposition.id(furnaceInfo.position)
      spawning.clear_crater(furnaceInfo.crater.clearance, furnaceInfo.position, furnaceInfo.surface)

      -- my final final attempt of fixing craters
      if not furnaceInfo.proofCheck then 
        furnaceInfo.proofCheck = true
        lprint("furnace ".. furnaceInfo.id .. " crater is completed, a final proof check is registered")
        for chunkId, chunkInfo in pairs(furnaceInfo.crater_chunks) do
          chunkInfo.proof_needed = true
          append_to_tickqueue(furnaceInfo.id, event.tick +600, chunkId)
        end
      end
    end
  end

  global.tick_queue[event.tick] = nil
end

-------------------------------------------------------------------------------------------------------------------------------
---- Command Registration -----------------------------------------------------------------------------------------------------

-- reads a creater (cliffs) from map and then outputs to a file
local read_crater_command = function (command)
  local f = loadstring("return " .. command.parameter)
  local arg = f()
  local name = arg.name
  local radius = arg.radius
  local version = arg.version or "0"

  if not name then
    game.print{ "command-output.fpftheme-read-crater-no-name"}
    return
  end

  if not radius then
    game.print{ "command-output.fpftheme-read-crater-no-radius" }
    return
  end

  if radius < 64 then
    game.print{ "command-output.fpftheme-read-crater-low-radius"}
    return
  end

  local variance = arg.variance or { north=0, south=0, west=0, east=0 }
  local author = game.players[command.player_index].name
  local surface = game.players[command.player_index].surface
  local pos = game.players[command.player_index].position

  local area = { 
    left_top = { 
      x = pos.x-16, 
      y = pos.y-16
    },
    right_bottom = {
      x = pos.x+16, 
      y = pos.y+16
    }
  }

  -- find the closest wooden chest
  local temp = surface.find_entities_filtered{ 
    area = area, 
    name = "wooden-chest",
    type= "container",
    force = game.players[command.player_index].force,
    limit = 1
  }

  if not temp then 
    game.print{ "command-output.fpftheme-read-crater-no-reference"}
    return
  end

  temp = table_first(temp)
  if not temp then 
    game.print{ "command-output.fpftheme-read-crater-reference-empty"}
    return
  end

  if not temp.valid then
    game.print{ "command-output.fpftheme-read-crater-reference-invalid"}
    return
  end

  -- we found the wooden chest, so now is the time to find cliffs within radius
  local reference = temp.position
  local cliffs = surface.find_entities_filtered{ 
    position = temp.position,
    radius = radius,
    type= "cliff"
  }

  -- starting the file writing
  local filename = author .. "_" .. name .. ".lua"
  game.write_file(filename, { "", "-- generated by " .. author .. "\r\n" } , false, command.player_index)
  local wf = function(msg)
    game.write_file(filename, { "", msg .. "\r\n" }, true, command.player_index)
  end

  wf( "local crater = {")
  wf( "  name = \"" .. name .. "\",")
  wf( "  author = \"" .. author .. "\",")
  wf( "  id = \"" .. author .. "_" .. name .. "\", ")
  wf( "  version = \"" .. version .. "\",")
  wf( "  variance = {")
  wf( "    north = " .. (variance.north or 0) .. ", ")
  wf( "    east = " .. (variance.east or 0) .. ", ")
  wf( "    south = " .. (variance.south or 0) .. ", ")
  wf( "    west = " .. (variance.west or 0) .. ", ")
  wf( "  },")
  wf( "  cliffs = {")

  -- cliff section, also calculates the radius here
  local minx = reference.x
  local maxx = reference.x
  local miny = reference.y
  local maxy = reference.y

  local craterCliffs = {}
  local positionInfo = nil
  -- merged list for positions and cliffs
  for _, cliff in pairs (cliffs) do
    pos = { x = cliff.position.x - reference.x + 0.5, y = cliff.position.y - reference.y -0.5 }
    local craterCliffId = "cl_" .. pos.x .. "/" .. pos.y
    positionInfo = craterCliffs[craterCliffId] or { x = pos.x, y = pos.y, cliffs = {} }
    if not ftable.contains(positionInfo.cliffs, cliff.cliff_orientation) then
      table.insert(positionInfo.cliffs, cliff.cliff_orientation)
    end
    craterCliffs[craterCliffId] = positionInfo

    if cliff.position.x < minx then minx = cliff.position.x end
    if cliff.position.x > maxx then maxx = cliff.position.x end
    if cliff.position.y < miny then miny = cliff.position.y end
    if cliff.position.y > maxy then maxy = cliff.position.y end
  end

  for key, _ in pairs (craterCliffs) do
    local positionInfo = craterCliffs[key]
    local craterCliffId = "cl_" .. positionInfo.x .. "/" .. positionInfo.y
    local line = "    [\"" .. craterCliffId .."\"] = { x = " .. positionInfo.x .. ", y = " .. positionInfo.y .. ", cliffs = { " 
    for _, orientation in pairs(positionInfo.cliffs) do
      line = line .. "\"" .. orientation .. "\", "
    end
    line = line .. " } }, "
    wf(line)
  end
  wf( "  },")
 
  game.print({ "command-output.fpftheme-read-crater-range", minx, maxx, miny, maxy} )

  -- find center of area
  local center = { x = maxx - (maxx - minx) /2, y = maxy - (maxy - miny)/2 }
  -- we found center of crater, now check radius (max distance) for all cliffs again
  local radius =0
  for _, cliff in pairs (cliffs) do
    pos = {x = cliff.position.x, y = cliff.position.y}
    local dis = fposition.distance(center, pos)
    if dis > radius then radius = dis end
  end
  radius = math.floor(radius +8) -- add some slack

  -- add center and radius
  game.print({ "command-output.fpftheme-read-crater-center", center.x, center.y, radius})
  wf( "  clearance = {")
  wf( "    center = { x = " .. math.floor(center.x - reference.x) .. ", y = " .. math.floor(center.y - reference.y) .. "},")
  wf( "    radius = " .. radius .. ",")
  wf( "    box = { ")
  wf( "      left_top = { x = " .. math.floor(minx - reference.x - 8 ) .. ", y = " .. math.floor(miny - reference.y - 8 ) .. " },")
  wf( "      right_bottom = { x = " .. math.floor(maxx - reference.x + 8 ) .. ", y = " .. math.floor(maxy - reference.y + 8 ) .. " }")
  wf( "    }")
  wf( "  }")
  wf( "}")
  wf( "return crater")

  game.print({ "command-output.fpftheme-read-crater-done", filename})
end

-- gives information about the nearby furnace
local give_furnace_info_command = function (command)
  local surface = game.players[command.player_index].surface
  local entities = surface.find_entities_filtered{ 
    position = game.players[command.player_index].position, 
    radius = 32,
    type= "burner-generator",
  }

  for _, entity in pairs (entities) do
    if entity and entity.valid and entity.name:find("fpftheme%-furnace%-") then
      local id = fposition.id(entity.position)
      local furnaceInfo = global.furnace_map[id]
      if furnaceInfo then
        game.print{ "command-output.fpftheme-furnaceinfo-command", entity.position.x, entity.position.y, entity.name, furnaceInfo.claimed, (furnaceInfo.crater or "nil") }
        return
      end
    end
  end
end

-- force replace furnaces to current one
local replace_furnaces_command = function(command)
  local furnaceType = game.entity_prototypes[command.parameter or "fpftheme-furnace-0"]
  if not furnaceType then 
    game.print{ "command-output.fpftheme-spawn-furnace-type-unknown"}
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

-- runs a proof check on the all chunks 
local prove_crater_command = function(command)
  local surface = game.players[command.player_index].surface
  local entities = surface.find_entities_filtered{ 
    position = game.players[command.player_index].position, 
    radius = 32,
    type= "burner-generator",
  }

  local furnaceInfo = nil
  for _, entity in pairs (entities) do
    if entity and entity.valid and entity.name:find("fpftheme%-furnace%-") then
      local id = fposition.id(entity.position)
      furnaceInfo = global.furnace_map[id]
      if furnaceInfo then
        break
      end
    end
  end

  for chunkId, chunkInfo in pairs(furnaceInfo.crater_chunks) do
    chunkInfo.proof_needed = true
    run_proof(furnaceInfo, chunkId)
  end
end

-- spawns surface at mentioned position,  
local spawn_furnace_command = function (command)
  local f = loadstring("return " .. (command.parameter or "{ }"))
  local arg = f()
  local surface = game.surfaces[arg.surface or game.players[command.player_index].surface.name ]
  if not surface then 
    game.print{"command-output.fpftheme-spawn-furnace-surface-not-found"}
    return
  end

  local craterName = arg.crater
  local crater = nil
  if not craterName then 
    local rand = math.random(ftable.length(approvedCraters))
    crater = ftable.at(approvedCraters, rand)
  else
    local fname = function(c)
      return (c.author .. "_" .. c.name) == craterName
    end

    crater = ftable.first(approvedCraters, fname)
    if not crater then 
      game.print{"command-output.fpftheme-spawn-furnace-crater-not-found"}
      return
    end
  end

  local chunkPos = arg.chunkPos or fposition.chunk(game.players[command.player_index].position)
  local pos = fposition.chunk_to_pos(chunkPos)
  pos = { 
    x = pos.x + math.random(31) + 0.5, 
    y = pos.y + math.random(31) + 0.5 
  }

  local furnaceInfo = {
    position = pos,
    id = fposition.id(pos),
    furnace = nil,
    surface = surface,
    dead = false,
    claimed = nil,
    crater = crater,
    crater_chunks = { },
    crater_chunks_spawned =0
  }

  global.furnace_map[furnaceInfo.id] = furnaceInfo

  register_furnace(furnaceInfo, surface, 10 + game.tick)
end

commands.add_command("fpftheme-replace-furnaces", {"command-help.fpftheme-replace-furnaces"} , replace_furnaces_command )
commands.add_command("fpftheme-furnace-info", {"command-help.fpftheme-furnace-info"}, give_furnace_info_command )
commands.add_command("fpftheme-read-crater", {"command-help.fpftheme-read-crater"}, read_crater_command )
commands.add_command("fpftheme-prove-crater", {"command-help.fpftheme-prove-crater"}, prove_crater_command )
commands.add_command("fpftheme-spawn-furnace", {"command-help.fpftheme-spawn-furnace"}, spawn_furnace_command )

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
  global.furnace_power = global.furnace_power or 12
  global.furnace_efficiency = global.furnace_efficiency or 1
  global.furnace_name = global.furnace_name or "fpftheme-furnace-0"
  global.fpftheme_force = global.fpftheme_force or nil
  global.first_furnace = global.first_furnace or nil
  global.tick_queue = global.tick_queue or {}
  global.chunk_queue = global.chunk_queue or {}
  global.chunks_checked = global.chunks_checked or 1
  global.cliff_correction = global.cliff_correction or {} 
end

local self_init = function()
  local fpftheme_force = game.forces["fpftheme-force"]
  if fpftheme_force == nil then
    fpftheme_force = game.create_force("fpftheme-force")
    local enemy = game.forces["enemy"]
    fpftheme_force.set_cease_fire(enemy, true)
    enemy.set_cease_fire(fpftheme_force, true)

    global.fpftheme_force = fpftheme_force
  end

  craterForce = game.forces["neutral"]

  -- first ever furnace is kind of free, but once only
  if not global.first_furnace and furnaceSpawning then
    local surface = game.surfaces["nauvis"] -- default surface
    local fpos = fposition.random_direction({x=0, y=0}, 32 * 6 + math.random() * 128)
    fpos = fposition.chunk(fpos)
    local furnaceInfo = prepare_furnace_at_chunk(fpos)
    register_furnace(furnaceInfo, surface, game.tick)
    global.first_furnace = fposition.id(furnaceInfo.position)
  end

  if global.first_furnace and not furnaceSpawning then
    game.print{"mod-setting-description.fpftheme-spawn-warning"}
  elseif furnaceSpawning then
    game.print{"mod-setting-description.fpftheme-spawn-enabled"}
  else 
    game.print{"mod-setting-description.fpftheme-spawn-disabled"}
  end

end

lib.on_init = function()
  lprint("on_init")
  defaults()
  self_init()
end
  
lib.on_configuration_changed = function ()
  lprint("on_configuration_changed")
  self_init()
end

lib.on_load = function()
  lprint("on_load")
  defaults()
end

-------------------------------------------------------------------------------------------------------------------------------

return lib