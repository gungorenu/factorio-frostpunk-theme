-- format file includes the expected pattern

-- add each here, add double dash to line start to remove them
local temp = {
  -- require("craters/author_example"),
  require("craters/gungorenu_base1"),
  require("craters/gungorenu_base2"),
}

local craters = { }
for _, crater in pairs (temp) do
  craters[crater.id] = crater
end

return craters