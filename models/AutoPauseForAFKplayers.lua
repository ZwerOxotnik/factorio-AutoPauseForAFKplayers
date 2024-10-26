---@class AP4AFKps : module
local M = {
	__max_AFK_time_in_ticks = settings.global["AP4AFKps_max_AFK_time"].value * 60 * 60 -- minutes to ticks
}


local RED_COLOR = {1, 0, 0}
local INFORM_ABOUT_PAUSE_MESSAGE = {"AutoPauseForAFKplayers.inform_about_pause"}


--#region Functions of events

local function enable_game()
	if not storage.is_paused then return end

	game.tick_paused = false
	storage.is_paused = false
end

local function check_AFK_time(event)
	if #game.connected_players == 0 then return end

	local __max_AFK_time_in_ticks = M.__max_AFK_time_in_ticks
	for _, player in pairs(game.connected_players) do
		if player.valid then
			if player.afk_time < __max_AFK_time_in_ticks then
				return
			end
		end
	end

	storage.is_paused = true
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
		M.__max_AFK_time_in_ticks = value * 60 * 60
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

	enable_game()
end

--#endregion


M.on_mod_enabled = function()
	M.__max_AFK_time_in_ticks = settings.global["AP4AFKps_max_AFK_time"].value * 60 * 60
end
M.on_mod_disabled = function()
	enable_game()
end


commands.add_command("unpause", {"AutoPauseForAFKplayers.unpause_command"}, function(cmd)
	enable_game()
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
	[defines.events.on_player_joined_game] = on_player_joined_game,
	[defines.events.on_player_toggled_alt_mode] = enable_game,
	[defines.events.on_gui_click] = enable_game,
	[defines.events.on_console_command] = enable_game,
	[defines.events.on_console_chat] = enable_game
}
M.events_when_off = {
	[defines.events.on_player_joined_game] = on_player_joined_game
}

M.on_nth_tick = {
	[60 * 60] = check_AFK_time,
}


return M
