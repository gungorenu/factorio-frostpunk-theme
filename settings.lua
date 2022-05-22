data:extend({
    {
       type = "int-setting",
       name = "fpf-furnace-upgrade-power-max",
       setting_type = "startup",
       default_value = 100,
       minimum_value = 0,
       maximum_value = 500
    },
    {
        type = "int-setting",
        name = "fpf-furnace-upgrade-eff-max",
        setting_type = "startup",
        default_value = 16,
        minimum_value = 0,
        maximum_value = 32
    },
    {
        type = "int-setting",
        name = "fpf-furnace-upgrade-power-upgrade",
        setting_type = "startup",
        default_value = 3,
        minimum_value = 1,
     },
     {
         type = "int-setting",
         name = "fpf-furnace-upgrade-eff-upgrade",
         setting_type = "startup",
         default_value = 5,
         minimum_value = 1,
     },
     {
        type = "bool-setting",
        name = "fpf-debug",
        setting_type = "startup",
        default_value = false,
    },
  })