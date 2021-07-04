-- Send the files to clients
AddCSLuaFile("airboat_mod/utils.lua")
AddCSLuaFile("airboat_mod/mods.lua")
AddCSLuaFile("airboat_mod/menu.lua")
AddCSLuaFile("airboat_mod/cl_player.lua")
AddCSLuaFile("airboat_mod/cl_boat.lua")
AddCSLuaFile("airboat_mod/cl_hud.lua")

if not AMMain then AMMain = {} end
AMMain.Spawns = {}

AMPowerUps          	= {}
AMPowerUps.PowerUps 	= {}
AMPowerUps.Instances	= {}


AMMods = {}
AMMods.Mods = {}

-- Run the files
include("airboat_mod/utils.lua")
include("airboat_mod/sv_main.lua")
include("airboat_mod/sv_hooks.lua")
include("airboat_mod/sv_boat.lua")
include("airboat_mod/sv_player.lua")
include("airboat_mod/sv_db.lua")
include("airboat_mod/sv_spawn.lua")
include("airboat_mod/menu.lua")
include("airboat_mod/mods.lua")

local files, folders = file.Find("airboat_mod/mods/*", "LUA")
for _, folderName in pairs(folders) do
	for _, fileName in pairs(file.Find("airboat_mod/mods/" .. folderName .. "/*.lua", "LUA")) do
		AddCSLuaFile("airboat_mod/mods/" .. folderName .. "/" .. fileName)
		include("airboat_mod/mods/" .. folderName .. "/" .. fileName)
	end
end

for _, f in pairs(file.Find("airboat_mod/menu/*.lua", "LUA")) do
	AddCSLuaFile("airboat_mod/menu/" .. f)
	include("airboat_mod/menu/" .. f)
end

for _, f in pairs(file.Find("airboat_mod/powerups/*.lua", "LUA")) do
	include("airboat_mod/powerups/" .. f)
end
