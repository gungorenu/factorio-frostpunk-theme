-- format file includes the expected pattern

-- add each here, add double dash to line start to remove them
local temp = {
  -- require("craters/author_example"),
  require("craters/gungorenu_base1"),
  require("craters/gungorenu_base2"),
  require("craters/gungorenu_base3"),
  require("craters/gungorenu_base4"),
  require("craters/gungorenu_base5"),
  require("craters/gungorenu_base6"),
  require("craters/gungorenu_base7"),
  require("craters/gungorenu_base8"),
}

local craters = { }
for _, crater in pairs (temp) do
  craters[crater.id] = crater
end

return craters