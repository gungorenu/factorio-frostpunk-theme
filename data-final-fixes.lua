require ("util/functions")

local collision_util = require("collision-mask-util")
local fpf_layer = collision_util.get_first_unused_layer()

-- disable power options
local function make_unplaceable(entity)
  entity.collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile", "resource-layer" , fpf_layer, "ground-tile", "doodad-layer", "floor-layer", "rail-layer", "transport-belt-layer","ghost-layer", "train-layer" }      
end

local alternatePowerEnabled = settings.startup["fpf-dont-disable-alternate-power"].value

if not alternatePowerEnabled then
  make_unplaceable(data.raw["generator"]["steam-engine"])
  make_unplaceable(data.raw["solar-panel"]["solar-panel"])
  make_unplaceable(data.raw["reactor"]["nuclear-reactor"])
  make_unplaceable(data.raw["boiler"]["heat-exchanger"]) 
  make_unplaceable(data.raw["boiler"]["heat-exchanger"])
  make_unplaceable(data.raw["generator"]["steam-turbine"])
  make_unplaceable(data.raw["heat-pipe"]["heat-pipe"])
end

-- use steam instead of water
local oilProcessingUseWater = settings.startup["fpf-dont-change-oil-recipes"].value
if not oilProcessingUseWater then
  if settings.startup["superexpensivemode-satellite-rocket-product-match-one-thousand-science-per-min"] == nil then
    swap_ingredient_in_recipe( data.raw.recipe["advanced-oil-processing"], "water", {type = "fluid", name = "steam", amount = 50} )
    swap_ingredient_in_recipe( data.raw.recipe["heavy-oil-cracking"], "water", {type = "fluid", name = "steam", amount = 30} )
    swap_ingredient_in_recipe( data.raw.recipe["light-oil-cracking"], "water", {type = "fluid", name = "steam", amount = 30} )
    swap_ingredient_in_recipe( data.raw.recipe["sulfur"], "water", {type = "fluid", name = "steam", amount = 30} )
  end
end

-- change effectivity module 2 and 3
local effectivityModuleNotAltered = settings.startup["fpf-dont-change-effectivity-modules"].value
if not effectivityModuleNotAltered then
  data.raw["module"]["effectivity-module-2"].effect = { speed = {bonus = 0.1}, consumption = {bonus = -0.5}}
  data.raw["module"]["effectivity-module-3"].effect = { speed = {bonus = 0.2}, consumption = {bonus = -0.7}}
end