
AMMods = {}
AMMods.Mods = {}

-- Run the files
include("airboat_mod/utils.lua")
include("airboat_mod/menu.lua")
include("airboat_mod/mods.lua")
include("airboat_mod/cl_player.lua")
include("airboat_mod/cl_boat.lua")
include("airboat_mod/cl_hud.lua")
include("airboat_mod/cl_scoreboard.lua")

local files, folders = file.Find("airboat_mod/mods/*", "LUA")
for _, folderName in pairs(folders) do
	for _, fileName in pairs(file.Find("airboat_mod/mods/" .. folderName .. "/*.lua", "LUA")) do
		include("airboat_mod/mods/" .. folderName .. "/" .. fileName)
	end
end

for _,f in pairs(file.Find("airboat_mod/menu/*.lua", "LUA")) do
	include("airboat_mod/menu/" .. f)
end

-- Load the particles we need!
game.AddParticles("particles/scary_ghost.pcf")
game.AddParticles("particles/smoke_blackbillow.pcf")
game.AddParticles("particles/flamethrower.pcf")
game.AddParticles("particles/marmottes.pcf")
