require("furnace_functions")

local furnacePowerMax = settings.startup["fpftheme-furnace-upgrade-power-max"].value
local furnaceEffMax = settings.startup["fpftheme-furnace-upgrade-eff-max"].value
local powerUpgrade = settings.startup["fpftheme-furnace-upgrade-power-upgrade"].value -- in MW, defaults to 3MW
local effUpgrade = settings.startup["fpftheme-furnace-upgrade-eff-upgrade"].value -- in %, defaults to %5

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
local infTechnologies = {
  get_furnace_power_upgrade_inf_tech(1, powerUpgrade),
  get_furnace_eff_upgrade_inf_tech(1, effUpgrade)
}

data:extend(infTechnologies)


