-- Create materials and fonts for the HUD
local params = {}
params["$basetexture"] = "phoenix_storms/trains/track_beamtop"
params["$vertexcolor"] = 1
params["$vertexalpha"] = 1
CreateMaterial("am_hud_bg", "UnlitGeneric", params)

params["$basetexture"] = "phoenix_storms/roadside"
params["$vertexcolor"] = 1
params["$vertexalpha"] = 1
CreateMaterial("am_hud_health", "UnlitGeneric", params)

local myFont = surface.CreateFont("am_hud_title", {
	font = "Tahoma", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 16,
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
})

-- HUD Object
AMHud = {}
AMHud.SizeX = 224
AMHud.SizeY = 105

function AMHud.Build()
	AMHud.Frame = vgui.Create("DPanel")
	AMHud.Frame:SetPos(37, ScrH() - 168)
	AMHud.Frame:SetSize(AMHud.SizeX, AMHud.SizeY)
	AMHud.Frame.Paint = function(self)
		local amPlayer = AMPlayer.GetPlayer(LocalPlayer())
		if not amPlayer then return end
		
		local amBoat = amPlayer:GetAirboat()
		if not amBoat or not amBoat:IsPlaying() then return end
		
		-- Background
		surface.SetMaterial(Material("!am_hud_bg"))
		surface.SetDrawColor(50, 50, 50, 240)
		surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
		
		-- Title
		surface.SetFont("am_hud_title")
		surface.SetTextColor(255, 255, 255, 100)
		surface.SetTextPos(12, 10)
		surface.DrawText("= Airboat Mod v1.0 =")
		
		-- Title
		surface.SetFont("am_hud_title")
		surface.SetTextColor(255, 255, 255, 100)
		surface.SetTextPos(12, 28)
		surface.DrawText("Total points: 0")
		
		-- Health bar
		local hx = 10
		local color = Color(0, 200, 0, 200)
		if amBoat:GetHealth() <= 5 then
			color = Color(255, 0, 0, 200)
		elseif amBoat:GetHealth() <= 10 then
			color = Color(255, 128, 0, 200)
		end
		surface.SetMaterial(Material("!am_hud_health"))
		for i=1,3 do
			local size = (math.min(5, math.max(0, (amBoat:GetHealth() or 0) - 5*(i - 1)))/5)*64
			surface.SetDrawColor(color)
			surface.DrawTexturedRect(hx, 50, size, 20)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawOutlinedRect(hx - 1, 49, 64 + 2, 22)
			hx = hx + 69
		end
		
		-- Power up
		surface.SetTextPos(11, 75)
		surface.DrawText("- PowerUp: None")
	end
end

hook.Add("InitPostEntity", "am_hud_build", AMHud.Build)
