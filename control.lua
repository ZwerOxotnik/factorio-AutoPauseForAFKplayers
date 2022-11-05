---@type table<string, module>
local modules = {}
modules.AutoPauseForAFKplayers = require("models/AutoPauseForAFKplayers")


local event_handler
if script.active_mods["switchable_mods"] then
	event_handler = require("__switchable_mods__/event_handler_vSM")
elseif script.active_mods["zk-lib"] then
	-- Same as Factorio "event_handler", but slightly better performance
	event_handler = require("__zk-lib__/static-libs/lualibs/event_handler_vZO.lua")
else
	event_handler = require("event_handler")
end
event_handler.add_libraries(modules)


-- This is a part of "gvv", "Lua API global Variable Viewer" mod. https://mods.factorio.com/mod/gvv
-- It makes possible gvv mod to read sandboxed variables in the map or other mod if following code is inserted at the end of empty line of "control.lua" of each.
if script.active_mods["gvv"] then require("__gvv__.gvv")() end
