if script.active_mods["gvv"] then require("__gvv__.gvv")() end

local handler = require("event_handler")
handler.add_lib(require("script/furnace_lib"))