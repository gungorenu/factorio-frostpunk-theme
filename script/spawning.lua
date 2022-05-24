-- source : https://github.com/Bilka2/AbandonedRuins/blob/master/spawning.lua
-- credits go to Bilka2

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

-- spawn functions
local spawning = {}
spawning.spawn_furnace = spawn_furnace
return spawning