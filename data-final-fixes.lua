local collision_util = require("collision-mask-util")
local fpf_layer = collision_util.get_first_unused_layer()

-- disable power options
local function make_unplaceable(entity)
  entity.collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile", "resource-layer" , fpf_layer, "ground-tile", "doodad-layer", "floor-layer", "rail-layer", "transport-belt-layer","ghost-layer", "train-layer" }      
end

local alternatePowerEnabled = settings.startup["fpf-dont-disable-alternate-power"].value or false -- in MW, defaults to 3MW

if not alternatePowerEnabled then
  make_unplaceable(data.raw["generator"]["steam-engine"])
  make_unplaceable(data.raw["solar-panel"]["solar-panel"])
  make_unplaceable(data.raw["reactor"]["nuclear-reactor"])
  make_unplaceable(data.raw["boiler"]["heat-exchanger"]) 
  make_unplaceable(data.raw["boiler"]["heat-exchanger"])
  make_unplaceable(data.raw["generator"]["steam-turbine"])
  make_unplaceable(data.raw["heat-pipe"]["heat-pipe"])
end