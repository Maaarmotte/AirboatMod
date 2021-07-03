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
include("airboat_mod/main.lua")
include("airboat_mod/hooks.lua")
include("airboat_mod/boat.lua")
include("airboat_mod/player.lua")
include("airboat_mod/menu.lua")
include("airboat_mod/mods.lua")
include("airboat_mod/db.lua")
include("airboat_mod/spawn.lua")

for _, f in pairs(file.Find("airboat_mod/mods/*.lua", "LUA")) do
	AddCSLuaFile("airboat_mod/mods/" .. f)
	include("airboat_mod/mods/" .. f)
end

for _, f in pairs(file.Find("airboat_mod/menu/*.lua", "LUA")) do
	AddCSLuaFile("airboat_mod/menu/" .. f)
	include("airboat_mod/menu/" .. f)
end

for _, f in pairs(file.Find("airboat_mod/powerups/*.lua", "LUA")) do
	include("airboat_mod/powerups/" .. f)
end

PrintMessage(HUD_PRINTTALK, "-> AirBoat mod loaded!")
