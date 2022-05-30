-- table item count, optional parameter is a function pointer for conditional count
function table_length(table, f)
  local count = 0
  local func = f or (function(a) return true end)
  for v in pairs(table) do 
    if func(v) then 
      count = count + 1 
    end
  end
  return count
end

-- first in table
function table_first(table, f)
  local func = f or (function(a) return true end)

  for _,v in pairs(table) do 
    if func(v) then 
      return v
    end
  end
  return nil
end


-- checks if table contains element
function table_contains(table, entry, f)
  local func = f or (function(a,b) return a == b end)
  for _,v in pairs(table) do 
    if func(v, entry) then 
      return true
    end
  end
  return false
end
  
-- gets Nth element
function table_at(table, n)
  local counter =1
  for _,v in pairs(table) do
    if counter == n then
      return v
    end
    counter = counter +1
  end
  return nil
end

local ftable = {}
ftable.length = table_length
ftable.first = table_first
ftable.contains = table_contains
ftable.at = table_at
return ftable