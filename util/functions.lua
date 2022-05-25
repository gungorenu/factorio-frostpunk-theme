-- table item count
function table_length(T)
  local count = 0
  for v in pairs(T) do 
    if v then 
      count = count + 1 
    end
  end
  return count
end

-- get distance between two positions
function get_distance(point1, point2)
  local x2 = point1.x - point2.x
  x2 = x2 * x2

  local y2 = point1.y - point2.y
  y2 = y2 * y2

  return math.sqrt(x2 + y2)
end

-- get chunk center
function get_chunk_center (chunkPos, modx, mody)
  return {x= chunkPos.x * 32 + 16 + (modx or 0), y = chunkPos.y * 32 - 16 + (mody or 0)}
end

-- dump print
function dprint(msg)
  if settings.global["fpf-debug"].value then
    game.print({"", msg })
  end
end

-- first in table
function table_first(T)
  for _,v in pairs(T) do 
    if v then 
      return v
    end
  end
  return nil
end
 