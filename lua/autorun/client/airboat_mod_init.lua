
AMMods = {}
AMMods.Mods = {}

-- Run the files
include("airboat_mod/utils.lua")
include("airboat_mod/derma.lua")
include("airboat_mod/mods.lua")
include("airboat_mod/cl_player.lua")
include("airboat_mod/cl_boat.lua")
include("airboat_mod/cl_hud.lua")

for _,f in pairs(file.Find("airboat_mod/mods/*.lua", "LUA")) do
	include("airboat_mod/mods/" .. f)
end

-- Load the particles we need!
game.AddParticles("particles/scary_ghost.pcf")
game.AddParticles("particles/smoke_blackbillow.pcf")
game.AddParticles("particles/flamethrower.pcf")
game.AddParticles("particles/marmottes.pcf")
