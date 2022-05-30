local function position_id (pos) 
  return "" .. math.floor(pos.x) .. "/" .. math.floor(pos.y)
end
  
local function chunk_id_of_pos (pos) 
  return "" .. math.floor(pos.x / 32) .. "/" .. math.floor(pos.y / 32)
end
  
local function chunk_of_pos (pos) 
  return { x = math.floor(pos.x / 32), y = math.floor(pos.y / 32) }
end
  
local function get_chunk_center (chunkPos, modx, mody)
  return {x= chunkPos.x * 32 + 16 + (modx or 0), y = chunkPos.y * 32 - 16 + (mody or 0)}
end

local function get_distance(point1, point2)
  local x2 = point1.x - point2.x
  x2 = x2 * x2
  
  local y2 = point1.y - point2.y
  y2 = y2 * y2
  
  return math.sqrt(x2 + y2)
end

local function shift_position (pos, value)
  return { x = pos.x + value, y = pos.y + value}
end

local function recoordinate_position (pos, ref)
  return { x = pos.x + ref.x, y = pos.y + ref.y}
end

local function align(pos, value)
  local mod = value or 2
  return { x = math.floor(pos.x/mod) * mod, y = math.floor(pos.y/mod) * mod }
end

local function chunk_area (pos)
  local left_top = { x = math.floor(pos.x) * 32, y = math.floor(pos.y) * 32 }
  local right_bottom = shift_position(left_top, 32)
  return { left_top, right_bottom }
end

local function to_area(pos, size)
    local left_top = { x = math.floor(pos.x), y = math.floor(pos.y) }
    local right_bottom = shift_position(left_top, size)
    return { left_top, right_bottom }
  end

local function chunk_to_pos(chunkPos)
    return { x = chunkPos.x * 32, y = chunkPos.y * 32}
end

local function random_direction(center, radius)
  local angle = math.rad(math.random() * 360)
  local sin = math.sin(angle)
  local cos = math.cos(angle)
  local vector = { x = math.floor(cos * radius), y = math.floor(sin * radius) }
  return recoordinate_position(center, vector)
end

local fposition = {}
fposition.id = position_id -- pos : returns x/y string
fposition.chunk_id = chunk_id_of_pos -- pos : returns x/y string of chunk of the position
fposition.chunk = chunk_of_pos -- pos : chunk position of the position given 
fposition.chunk_center = get_chunk_center -- chunkPos, modx [int], mody [int] : chunk position of the position given and some modifier
fposition.distance = get_distance -- point1, point2 : direct distance between two positions 
fposition.shift = shift_position -- pos, value [int] : shifts both x and y by given value
fposition.recoordinate = recoordinate_position -- pos, ref : merges position with reference to given position (adds both) 
fposition.align = align -- pos, value [int] : aligns the given position to nth value (align like rail) 
fposition.chunk_area = chunk_area -- pos : gets the chunk area of given chunk position
fposition.chunk_to_pos = chunk_to_pos -- chunkPos : gets left_top point of given chunk position
fposition.random_direction = random_direction -- center, radius [int] : gets a random direction and moves towards there by given radius 
fposition.to_area = to_area -- pos, size [int] : converts position to an area with size

return fposition

