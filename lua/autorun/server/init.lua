-- Send the files to clients
AddCSLuaFile("autorun/client/cl_init.lua")
AddCSLuaFile("utils.lua")
AddCSLuaFile("mods.lua")
AddCSLuaFile("derma.lua")

for _,file in pairs(file.Find("mods/*.lua", "LUA")) do
	AddCSLuaFile("mods/" .. file)
end

-- Run the files
include("utils.lua")
include("main.lua")
include("hooks.lua")
include("boat.lua")
include("player.lua")
include("derma.lua")
include("mods.lua")

for _,f in pairs(file.Find("mods/*.lua", "LUA")) do
	include("mods/" .. f)
end
