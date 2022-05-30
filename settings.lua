data:extend({
   {
     type = "bool-setting",
     name = "fpf-namedentities",
     setting_type = "startup",
     default_value = false,
   },
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
      setting_type = "runtime-global",
      default_value = false,
   },
   {
      type = "bool-setting",
      name = "fpf-furnace-spawning",
      setting_type = "runtime-global",
      default_value = true,
   },
   {
      type = "bool-setting",
      name = "fpf-logging",
      setting_type = "runtime-global",
      default_value = false,
   },
   {
      type = "int-setting",
      name = "fpf-furnace-spawn-baserate",
      setting_type = "runtime-global",
      default_value = 3,
      minimum_value = 0, -- this or rate increment per chunk must be positive or never going to spawn a furnace
      maximum_value = 100
   },
   {
      type = "int-setting",
      name = "fpf-furnace-spawn-mindistance",
      setting_type = "runtime-global",
      default_value = 512, -- 16 chunk
      minimum_value = 256 -- 8 chunk, some cities can be large
   },
   {
      type = "int-setting",
      name = "fpf-furnace-spawn-rateincrement-perchunk",
      setting_type = "runtime-global",
      default_value = 1,
      minimum_value = 0, -- this or rate increment per chunk must be positive or never going to spawn a furnace
      maximum_value = 100
   },

  })