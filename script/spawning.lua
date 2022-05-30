local fposition = require("./util/position")
local ftable = require("./util/table")

-- source : https://github.com/Bilka2/AbandonedRuins/blob/master/spawning.lua
-- credits go to Bilka2

-- WHY? because within game we do not have variation count accessible so the table is hardcoded for now
local cliffVariations = {}
cliffVariations["west-to-east"]   = 8
cliffVariations["north-to-south"] = 8
cliffVariations["east-to-west"]   = 8
cliffVariations["south-to-north"] = 8
cliffVariations["west-to-north"]  = 8
cliffVariations["north-to-east"]  = 8
cliffVariations["east-to-south"]  = 8
cliffVariations["south-to-west"]  = 8
cliffVariations["west-to-south"]  = 8
cliffVariations["north-to-west"]  = 8
cliffVariations["east-to-north"]  = 8
cliffVariations["south-to-east"]  = 8
cliffVariations["west-to-none"]   = 2
cliffVariations["none-to-east"]   = 2
cliffVariations["north-to-none"]  = 2
cliffVariations["none-to-south"]  = 2
cliffVariations["east-to-none"]   = 2
cliffVariations["none-to-west"]   = 2
cliffVariations["south-to-none"]  = 2
cliffVariations["none-to-north"]  = 2

local cliffOrientationMatrix = {}
cliffOrientationMatrix["west-to-east"]   = "east-to-west"
cliffOrientationMatrix["north-to-south"] = "south-to-north"
cliffOrientationMatrix["east-to-west"]   = "west-to-east"
cliffOrientationMatrix["south-to-north"] = "north-to-south"
cliffOrientationMatrix["west-to-north"]  = "south-to-east"
cliffOrientationMatrix["north-to-east"]  = "west-to-south"
cliffOrientationMatrix["east-to-south"]  = "north-to-west"
cliffOrientationMatrix["south-to-west"]  = "east-to-north"
cliffOrientationMatrix["west-to-south"]  = "north-to-east"
cliffOrientationMatrix["north-to-west"]  = "east-to-south"
cliffOrientationMatrix["east-to-north"]  = "south-to-west"
cliffOrientationMatrix["south-to-east"]  = "west-to-north"
cliffOrientationMatrix["west-to-none"]   = "none-to-east"
cliffOrientationMatrix["none-to-east"]   = "west-to-none"
cliffOrientationMatrix["north-to-none"]  = "none-to-south"
cliffOrientationMatrix["none-to-south"]  = "north-to-none"
cliffOrientationMatrix["east-to-none"]   = "none-to-west"
cliffOrientationMatrix["none-to-west"]   = "east-to-none"
cliffOrientationMatrix["south-to-none"]  = "none-to-north"
cliffOrientationMatrix["none-to-north"]  = "south-to-none"

local function is_orientation_matching(expected, current)
  if expected == current then return true end
  if cliffOrientationMatrix[expected] == current then return true end
  return false 
end

-- attempt to clear area
local function clear_entities_of_area(area, surface)
  -- exclude tiles that we shouldn't spawn on
  if surface.count_tiles_filtered{ area = area, limit = 1, collision_mask = {"item-layer", "object-layer"} } == 1 then
    return false
  end

  for _, entity in pairs(surface.find_entities_filtered({area = area, type = {"resource"}, invert = true})) do
    if entity.valid then
      entity.destroy({do_cliff_correction = true, raise_destroy = false})
    end
  end

  return true
end

-- clear cliffs of area
local function clear_cliffs_of_area(area, surface, cliffCorrection)
  -- exclude tiles that we shouldn't spawn on
  if surface.count_tiles_filtered{ area = area, limit = 1, collision_mask = {"item-layer", "object-layer"} } == 1 then
    return false
  end

  for _, entity in pairs(surface.find_entities_filtered({area = area, type = {"cliff"}})) do
    if entity.valid and entity.destructible then
      entity.destroy({do_cliff_correction = cliffCorrection, raise_destroy = false})
    end
  end

  return true
end

local function spawn_cliff (surface, force, cliffInfo, isCorrection)
  local e = surface.create_entity {
    name = "fpf-cliff",
    position = cliffInfo.position,
    force = force,
    raise_built = false,
    create_build_effect_smoke = false,
    cliff_orientation = cliffInfo.orientation
  }

  if not e then
    dprint( "cliff creation failed @" .. cliffInfo.position.x .. "/" .. cliffInfo.position.y  )
  elseif not e.valid then 
    dprint( "cliff created but invalid @" .. cliffInfo.position.x .. "/" .. cliffInfo.position.y  )
  else
    e.destructible = false
    e.graphics_variation = cliffInfo.variation
  end

  return true
end

local function spawn_furnace (position, surface, force, entityName)
  if not game.entity_prototypes[entityName] then
    return { res =-1 }
  end
  local area = { 
    left_top = fposition.shift(position, -4.5), 
    right_bottom = fposition.shift (position, 4.5) 
  }
  clear_entities_of_area(area, surface, force)

 -- can we place entity? if not then we continue loop
  if surface.can_place_entity{ name = entityName, position= position, force = force, build_check_type = defines.build_check_type.script } then
    local e = surface.create_entity
    {
      name = entityName,
      position = position,
      force = force,
      raise_built = true,
      create_build_effect_smoke = false,
    }
   e.health = math.random(game.entity_prototypes[entityName].max_health)
   return { entity = e, res =1 }
  end
end

local function calculateAlignment(position, first)
  local pos = fposition.shift(position, -0.5)
  pos = fposition.recoordinate(pos, { x =first.x, y = first.y - 0.5 } )
  lprint("alignment initial is at " .. pos.x .. "/" .. pos.y )

  -- x alignment 
  local rem = pos.x %4
  if rem == 1 then
    pos.x = pos.x +1
  elseif rem == 3 then
    pos.x = pos.x -1
  elseif rem == 0 then 
    pos.x = pos.x +2
  end

  -- y alignment
  rem = pos.y %4
  if rem == 1 then
    pos.y = pos.y +1
  elseif rem == 3 then
    pos.y = pos.y -1
  elseif rem == 0 then 
    pos.y = pos.y +2
  end

  -- y always has 0.5 more
  pos.y = pos.y +0.5
  local alignmentPos = { x = pos.x - first.x, y = pos.y - first.y }

  lprint("alignment is done at " .. alignmentPos.x .. "/" .. alignmentPos.y .. " using " .. first.x .. "/" .. first.y .. " making first cliff at : " .. pos.x .. "/" .. pos.y )
  return alignmentPos
end

local function crater_chunks (furnaceInfo)
  -- calculate the random direction to shift 
  local dir = math.random(4)
  local reference = { x =0, y =0 }
  local position = { x = furnaceInfo.position.x, y = furnaceInfo.position.y }
  
  -- directions are reversed, this is not furnace direction, we move crater
  if dir == 1 and furnaceInfo.crater.variance.north >0 then
    position = fposition.recoordinate( position, { x=0, y = 1 * math.random(furnaceInfo.crater.variance.north) } )
  end
  if dir == 2 and furnaceInfo.crater.variance.east >0 then 
    position = fposition.recoordinate( position, { y=0, x = -1 * math.random(furnaceInfo.crater.variance.east) } )
  end
  if dir == 3 and furnaceInfo.crater.variance.south >0 then
    position = fposition.recoordinate( position, { x=0, y = -1 * math.random(furnaceInfo.crater.variance.south) } )
  end
  if dir == 4 and furnaceInfo.crater.variance.west >0 then
    position = fposition.recoordinate( position, { y=0, x = math.random(furnaceInfo.crater.variance.west) } )
  end

  -- this position has to conform some special rules so we have to make it fit a zone that cliffs can be put at
  -- the first cliff has to be on 2X / 2X.5 position in which X is odd number, so the positions (2X) should not be able to be divided by 4 
  -- just aligning with 2 does not fix the problem, we have to move
  local first = ftable.first(furnaceInfo.crater.cliffs) 
  local alignmentPos = calculateAlignment(position, first)

  local chunks = {}

  -- cliff ref position, should be 
  for _, cl in pairs(furnaceInfo.crater.cliffs) do
    pos =  fposition.recoordinate(alignmentPos, { x =cl.x, y = cl.y } )
    local chunkId = fposition.chunk_id(pos)
    local chunkData = chunks[chunkId] or {
      position = fposition.chunk(pos),
      entities = {}
    }

    for _, orientation in pairs(cl.cliffs) do
      table.insert(chunkData.entities, {
        position = pos,
        orientation = orientation,
        variation = math.random(cliffVariations[orientation])
      })
    end
    
    chunks[chunkId] = chunkData
  end

  return chunks
end

local function spawn_crater (cliffChunk, surface, force)

  local area = fposition.chunk_area(cliffChunk.position)
  clear_cliffs_of_area(area, surface, false)

  for _, cl in pairs(cliffChunk.entities) do
    local e = surface.create_entity {
      name = "fpf-cliff",
      position = cl.position,
      force = force,
      raise_built = false,
      create_build_effect_smoke = false,
      cliff_orientation = cl.orientation
    }
  
    if not e then
      dprint( "cliff creation failed @" .. cl.position.x .. "/" .. cl.position.y  )
    elseif not e.valid then 
      dprint( "cliff created but invalid @" .. cl.position.x .. "/" .. cl.position.y  )
    else
      e.destructible = false
      e.graphics_variation = cl.variation
    end
  end
end

local function clear_crater (clearance, reference, surface)
  local left_top = fposition.recoordinate(reference, clearance.box.left_top)
  local right_bottom = fposition.recoordinate(reference, clearance.box.right_bottom)
  clear_cliffs_of_area( {left_top, right_bottom}, surface, true )
end

----

local spawning = {}
spawning.spawn_furnace = spawn_furnace -- position, surface, force, entityName : spawn furnace at position using surface and force, also clears area of furnace
spawning.crater_chunks = crater_chunks -- furnaceInfo : calculates the chunk list where the crater cliffs are supposed to be spawned at
spawning.spawn_crater = spawn_crater -- cliffChunk, surface, force : spawn cliffs/entities of the given chunk cliff info
spawning.clear_crater = clear_crater -- clearance, reference, surface : clears the clearance area of crater from cliffs with reference to given point
spawning.spawn_cliff = spawn_cliff -- position, surface, force, orientation, isCorrection : can spawn a cliff at specified position, and can also remove entities at previous location
spawning.is_orientation_matching = is_orientation_matching -- expected, current : checks two cliff orientation, including alternating directions
return spawning