data:extend({
  {
    type = "bool-setting",
    name = "fpftheme-namedentities",
    setting_type = "startup",
    default_value = false,
  },
  {
    type = "bool-setting",
    name = "fpftheme-dont-disable-alternate-power",
    setting_type = "startup",
    default_value = false,
  },
  {
     type = "int-setting",
     name = "fpftheme-furnace-upgrade-power-max",
     setting_type = "startup",
     default_value = 100,
     minimum_value = 0,
     maximum_value = 500
  },
  {
     type = "int-setting",
     name = "fpftheme-furnace-upgrade-eff-max",
     setting_type = "startup",
     default_value = 16,
     minimum_value = 0,
     maximum_value = 32
  },
  {
     type = "int-setting",
     name = "fpftheme-furnace-upgrade-power-upgrade",
     setting_type = "startup",
     default_value = 3,
     minimum_value = 1,
  },
  {
     type = "int-setting",
     name = "fpftheme-furnace-upgrade-eff-upgrade",
     setting_type = "startup",
     default_value = 5,
     minimum_value = 1,
  },
  {
     type = "bool-setting",
     name = "fpftheme-debug",
     setting_type = "runtime-global",
     default_value = false,
  },
  {
     type = "bool-setting",
     name = "fpftheme-furnace-spawning",
     setting_type = "runtime-global",
     default_value = true,
  },
  {
     type = "bool-setting",
     name = "fpftheme-logging",
     setting_type = "runtime-global",
     default_value = false,
  },
  {
     type = "int-setting",
     name = "fpftheme-furnace-spawn-baserate",
     setting_type = "runtime-global",
     default_value = 3,
     minimum_value = 0, -- this or rate increment per chunk must be positive or never going to spawn a furnace
     maximum_value = 100
  },
  {
     type = "int-setting",
     name = "fpftheme-furnace-spawn-mindistance",
     setting_type = "runtime-global",
     default_value = 512, -- 16 chunk
     minimum_value = 256 -- 8 chunk, some cities can be large
  },
  {
     type = "int-setting",
     name = "fpftheme-furnace-spawn-accdistance",
     setting_type = "runtime-global",
     default_value = 128, -- 4 chunk
     minimum_value = 0
  },
  {
     type = "int-setting",
     name = "fpftheme-furnace-spawn-rateincrement-perchunk",
     setting_type = "runtime-global",
     default_value = 1,
     minimum_value = 0, -- this or rate increment per chunk must be positive or never going to spawn a furnace
     maximum_value = 100
  },
  {
     type = "bool-setting",
     name = "fpftheme-dont-change-oil-recipes",
     setting_type = "startup",
     default_value = false,
  },
  {
     type = "bool-setting",
     name = "fpftheme-dont-change-effectivity-modules",
     setting_type = "startup",
     default_value = false,
  },
})