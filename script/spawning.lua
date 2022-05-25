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

-- attempt to clear area
local function clear_area(area, surface, skipforce)
  -- exclude tiles that we shouldn't spawn on
  if surface.count_tiles_filtered{ area = area, limit = 1, collision_mask = {"item-layer", "object-layer"} } == 1 then
    return false
  end

  for _, entity in pairs(surface.find_entities_filtered({area = area, type = {"resource"}, invert = true})) do
    if entity.valid and entity.type ~= "tree" and entity.force ~= skipforce then
      entity.destroy({do_cliff_correction = true, raise_destroy = true})
    end
  end

  return true
end

-- clear cliffs
local function clear_cliffs(area, surface)
  -- exclude tiles that we shouldn't spawn on
  if surface.count_tiles_filtered{ area = area, limit = 1, collision_mask = {"item-layer", "object-layer"} } == 1 then
    return false
  end

  for _, entity in pairs(surface.find_entities_filtered({area = area, type = {"cliff"}})) do
    if entity.valid then
      entity.destroy({do_cliff_correction = true, raise_destroy = false})
    end
  end

  return true
end

-- spawns a single entity, but also tries to place it if it cannot do it in first try
-- returns tuple: entity / res. if res >0 then entity is valid
local function spawn_special_entity(try, surface, force, pos, entityName, sizexy)
  if not game.entity_prototypes[entityName] then
    return { res =-1 }
  end

  for i =0, try, 1 do 
    local posvariance = { x = pos.x + i * 3, y = pos.y + i *3 }
    -- can we place entity? if not lets clear once
    if not surface.can_place_entity{ name = entityName, position= posvariance, force = force, build_check_type = defines.build_check_type.script } then
      local area = { left_top = { x = posvariance -sizexy, y = posvariance - sizexy } , right_bottom = { x = posvariance +sizexy, y = posvariance +sizexy }}
      clear_area(area, surface, force)
    end

    -- can we place entity? if not then we continue loop
    if surface.can_place_entity{ name = entityName, position= posvariance, force = force, build_check_type = defines.build_check_type.script } then
      local e = surface.create_entity
      {
        name = entityName,
        position = posvariance,
        force = force,
        raise_built = true,
        create_build_effect_smoke = false,
      }

      e.health = math.random(game.entity_prototypes[entityName].max_health)

      return { entity = e, res =1 }
    end
  end

  return { res =-2 }
end

-- spawn furnace, only furnace
-- returns tuple: entity / res. if res >0 then entity is valid
local function spawn_furnace (try, surface, force, chunkPos, furnaceType)
  if not surface.valid then return { res = -1 } end

  -- furnace center point has 0.5 modifier
  local pos = get_chunk_center(chunkPos, math.random(16) + 0.5, math.random(16) + 0.5)
  return spawn_special_entity(try, surface, force, pos, furnaceType, 4.5)
end

-- make copy of area
local copy_area = function (area, mod)
  return {
    left_top = {
      x = area.left_top.x + (mod.x or 0), 
      y = area.left_top.y + (mod.y or 0), 
    },
    right_bottom = {
      x = area.right_bottom.x + (mod.x or 0), 
      y = area.right_bottom.y + (mod.y or 0), 
    }
  }
end

-- spawn crater, furnace must be created before
local function spawn_crater (surface, force, furnacePos, craterDef)
  if not surface.valid then return -1 end

  dprint( "attempt of crater spawning: ".. craterDef.name .. "@" .. craterDef.author )
  
  -- clear area
  -- still not decided what to cleanup but first use boxed area

  local area = copy_area(craterDef.clearance.box, furnacePos)
  if not clear_cliffs(area, surface) then return -2 end
  dprint( "crater cleaning done at: ".. area.left_top.x .. "/" .. area.left_top.y .. " to " .. area.right_bottom.x .. "/" .. area.right_bottom.y )

  -- now we have to calculate reference point first, using variance and entity position
  local modifier = {x = 2* math.floor(furnacePos.x/2), y = 2* math.floor(furnacePos.y/2) }
  -- TODO: -- skip variance for now

  -- cliff ref position, should be 
  for _, cl in pairs(craterDef.cliffs) do
    local pos = { x = cl.x + modifier.x, y = cl.y + modifier.y }

    local e = surface.create_entity {
      name = "cliff",
      position = pos,
      force = force,
      raise_built = false,
      create_build_effect_smoke = false,
      cliff_orientation = cl.orientation
    }

    if not e then
      dprint( "cliff creation failed @" .. pos.x .. "/" .. pos.y  )
    elseif not e.valid then 
      dprint( "cliff created but invalid @" .. pos.x .. "/" .. pos.y  )
    else
      e.destructible = false
      e.graphics_variation = math.random(cliffVariations[cl.orientation])
    end
  end

  return 1
end


-- spawn functions
local spawning = {}
spawning.spawn_furnace = spawn_furnace
spawning.spawn_crater = spawn_crater
return spawning