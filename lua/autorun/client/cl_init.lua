-- Run the files
include("utils.lua")
include("derma.lua")
include("mods.lua")
include("cl_player.lua")
include("cl_boat.lua")
include("cl_hud.lua")

for _,f in pairs(file.Find("mods/*.lua", "LUA")) do
	include("mods/" .. f)
end

-- Load the particles we need!
game.AddParticles("particles/scary_ghost.pcf")
game.AddParticles("particles/smoke_blackbillow.pcf")
