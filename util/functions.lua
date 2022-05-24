function get_science_pack_list (red, green, black, blue, purple, yellow, white)
  local sciences = {}

  if red >0 then table.insert(sciences, {"automation-science-pack", 1} ) end

  if green >0 then table.insert(sciences, {"logistic-science-pack", 1} ) end
  
  if black >0 then table.insert(sciences, {"military-science-pack", 1} ) end
  
  if blue >0 then table.insert(sciences, {"chemical-science-pack", 1} ) end
  
  if purple >0 then table.insert(sciences, {"production-science-pack", 1} ) end
  
  if yellow >0 then table.insert(sciences, {"utility-science-pack", 1} ) end
  
  if white >0 then table.insert(sciences, {"space-science-pack", 1} ) end

  return sciences
end    

function table_length(T)
  local count = 0
  for v in pairs(T) do 
    if v then 
      count = count + 1 
    end
  end
  return count
end

function get_distance(point1, point2)
  local x2 = point1.x - point2.x
  x2 = x2 * x2

  local y2 = point1.y - point2.y
  y2 = y2 * y2

  local t2 = x2 + y2
  return math.sqrt(t2)
end

function get_chunk_center (chunkPos)
  return {x= chunkPos.x * 32 + 16, y = chunkPos.y * 32 - 16}
end