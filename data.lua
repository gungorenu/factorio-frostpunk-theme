require("prototype.shared")

-- furnace definitions
require("prototype.furnace.furnace_base")
require("prototype.furnace.furnace_infinite")

-- sbg (simple burner generator) definition
require("prototype.burner.sbg")

-- claim tool, taken from Abandoned Ruins mod
require("prototype.claim.claim")

-- water generation disabled by default
for name,tile in pairs(data.raw.tile) do
  if (string.match(name,".*water.*") == name) then
      data.raw.tile[name].autoplace = nil
  end
end

-- fpf-cliff
local fpfcliff = table.deepcopy(data.raw["cliff"]["cliff"])
fpfcliff.name = "fpf-cliff"
data:extend({fpfcliff})
