-- source: https://github.com/Bilka2/AbandonedRuins/blob/master/data.lua
-- credits go to Bilka2

local base_util = require("__core__/lualib/util")
data.raw["utility-constants"]["default"].default_other_force_color = base_util.copy(data.raw["utility-constants"]["default"].default_enemy_force_color)

data:extend
{
  {
    type = "selection-tool",
    name = "fpf-claim",
    icon = "__FPF__/graphics/icons/claim.png",
    icon_size = 64,
    stack_size = 1,
    selection_color = {1, 1, 1},
    alt_selection_color = {1, 1, 1},
    selection_mode = {"buildable-type", "not-same-force"},
    alt_selection_mode = {"any-entity", "not-same-force"},
    selection_cursor_box_type = "train-visualization",
    alt_selection_cursor_box_type = "train-visualization",
    always_include_tiles = true,
    flags = {"only-in-cursor", "spawnable"},
    subgroup = "tool",
  },
  {
    type = "shortcut",
    name = "fpf-claim",
    action = "spawn-item",
    icon =
    {
      filename = "__FPF__/graphics/icons/claim-shortcut.png",
      size = 32
    },
    item_to_spawn = "fpf-claim",
    associated_control_input = "fpf-claim"
  },
  {
    type = "custom-input",
    name = "fpf-claim",
    key_sequence = "SHIFT + C",
    action = "spawn-item",
    item_to_spawn = "fpf-claim"
  }
}