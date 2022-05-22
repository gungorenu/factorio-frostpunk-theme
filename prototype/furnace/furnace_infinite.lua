require("furnace_functions")

local furnacePowerMax = settings.startup["fpf-furnace-upgrade-power-max"].value
local furnaceEffMax = settings.startup["fpf-furnace-upgrade-eff-max"].value
local powerUpgrade = settings.startup["fpf-furnace-upgrade-power-upgrade"].value -- in MW, defaults to 3MW
local effUpgrade = settings.startup["fpf-furnace-upgrade-eff-upgrade"].value -- in %, defaults to %5

-- fake infinite entities
local furnaceEntities = {}
for i=0, furnacePowerMax, 1 do
  for j=0, furnaceEffMax, 1 do
    local power = 48 + i* powerUpgrade
    local eff = 1 + (effUpgrade * j)/100
    local furnace = get_furnace("upgraded-power-"..i.."-eff-"..j, power, eff)
    table.insert(furnaceEntities, furnace)
  end
end
data:extend(furnaceEntities)

-- fake infinite technologies
local infTechnologies = {}
for i=1, furnacePowerMax, 1 do
  local infPowerTech = get_furnace_power_upgrade_inf_tech(i, powerUpgrade)
  table.insert(infTechnologies, infPowerTech)
end
for i=1, furnaceEffMax, 1 do
  local infEffTech = get_furnace_eff_upgrade_inf_tech(i, effUpgrade)
  table.insert(infTechnologies, infEffTech)
end
data:extend(infTechnologies)


