-- furnace definitions
require("prototype.furnace.furnace_base")
require("prototype.furnace.furnace_infinite")

-- claim tool, taken from Abandoned Ruins mod
require("prototype.claim.claim")

-- water generation disabled by default
for name,tile in pairs(data.raw.tile) do
  if (string.match(name,".*water.*") == name) then
      data.raw.tile[name].autoplace = nil
  end
end