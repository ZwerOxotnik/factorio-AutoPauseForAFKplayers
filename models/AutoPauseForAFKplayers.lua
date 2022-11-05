---@class AP4AFKps : module
local M = {}


local max_AFK_time_in_ticks = settings.global["AP4AFKps_max_AFK_time"].value * 60 * 60 -- minutes to ticks
local RED_COLOR = {1, 0, 0}
local INFORM_ABOUT_PAUSE_MESSAGE = {"AutoPauseForAFKplayers.inform_about_pause"}


--#region Functions of events

local function check_AFK_time(event)
	if #game.connected_players == 0 then return end

	for _, player in pairs(game.connected_players) do
		if player.valid then
			if player.afk_time < max_AFK_time_in_ticks then
				return
			end
		end
	end

	global.is_paused = true
	game.tick_paused = true
	for _, player in pairs(game.connected_players) do
		if player.valid then
			player.print(INFORM_ABOUT_PAUSE_MESSAGE, RED_COLOR)
		end
	end
end

local MOD_SETTINGS = {
	["AP4AFKps_max_AFK_time"] = function(value)
		 -- minutes to ticks
		max_AFK_time_in_ticks = value * 60 * 60
	end,
}
local function on_runtime_mod_setting_changed(event)
	if event.setting_type ~= "runtime-global" then return end

	local setting_name = event.setting
	local f = MOD_SETTINGS[setting_name]
	if f then f(settings.global[setting_name].value) end
end

local function on_player_joined_game(event)
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	if global.is_paused then
		game.tick_paused = false
		global.is_paused = false
	end
end

--#endregion


M.on_mod_enabled = function()
	max_AFK_time_in_ticks = settings.global["AP4AFKps_max_AFK_time"].value * 60 * 60
end
M.on_mod_disabled = function()
	if global.is_paused then
		game.tick_paused = false
		global.is_paused = false
	end
end


commands.add_command("unpause", {"AutoPauseForAFKplayers.unpause_command"}, function(cmd)
	if global.is_paused then
		game.tick_paused = false
		global.is_paused = false
	end
end)


--#region Pre-game stage


local function add_remote_interface()
	-- https://lua-api.factorio.com/latest/LuaRemote.html
	remote.remove_interface("AutoPauseForAFKplayers") -- For safety
	remote.add_interface("AutoPauseForAFKplayers", {})
end
M.add_remote_interface = add_remote_interface

--#endregion


M.events = {
	[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed,
	[defines.events.on_player_joined_game] = on_player_joined_game
}
M.events_when_off = {
	[defines.events.on_player_joined_game] = on_player_joined_game
}

M.on_nth_tick = {
	[60 * 60 / 5] = check_AFK_time,
}


return M
