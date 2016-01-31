-- Run the files
include("utils.lua")
include("derma.lua")
include("mods.lua")

for _,f in pairs(file.Find("mods/*.lua", "LUA")) do
	include("mods/" .. f)
end
