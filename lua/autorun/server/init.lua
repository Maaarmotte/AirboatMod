-- Send the files to clients
AddCSLuaFile("autorun/client/cl_init.lua")
AddCSLuaFile("utils.lua")
AddCSLuaFile("mods.lua")
AddCSLuaFile("derma.lua")
AddCSLuaFile("cl_player.lua")
AddCSLuaFile("cl_boat.lua")
AddCSLuaFile("cl_hud.lua")

for _,file in pairs(file.Find("mods/*.lua", "LUA")) do
	AddCSLuaFile("mods/" .. file)
end

if not AMMain then AMMain = {} end
AMMain.Spawns = {}

AMPowerUps          	= {}
AMPowerUps.PowerUps 	= {}
AMPowerUps.Instances	= {}


AMMods = {}
AMMods.Mods = {}

-- Run the files
include("utils.lua")
include("main.lua")
include("hooks.lua")
include("boat.lua")
include("player.lua")
include("derma.lua")
include("mods.lua")
include("db.lua")

for _,f in pairs(file.Find("mods/*.lua", "LUA")) do
	include("mods/" .. f)
end

for _,f in pairs(file.Find("powerups/*.lua", "LUA")) do
	include("powerups/" .. f)
end
