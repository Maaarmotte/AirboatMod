-- Create materials and fonts for the HUD
local blur = Material("pp/blurscreen")

local function DrawBlur(pnl, a, d)
	local x, y = pnl:LocalToScreen(0, 0)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)

	for i = 1, d do
		blur:SetFloat("$blur", (i / d) * (a))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
	end
end

local myFont = surface.CreateFont("am_hud_title", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 16,
	weight = 800,
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

if AMHud and AMHud.Frame then
	AMHud.Remove()
end

AMHud = AMHud or {}
AMHud.SizeX = 224
AMHud.SizeY = 80

local mod_order = {"space", "shift", "mouse1", "powerup"}

function AMHud.Build()
	if AMHud.Frame then return end

	AMHud.DynamicSizeY = AMHud.SizeY

	AMHud.Frame = vgui.Create("DPanel")
	AMHud.Frame:SetPos(30, ScrH() - 30 - AMHud.SizeY)
	AMHud.Frame:SetSize(AMHud.SizeX, AMHud.SizeY)
	AMHud.Frame.Paint = function(self, w, h)
		local amPlayer = AMPlayer.GetPlayer(LocalPlayer())
		if not amPlayer then return end

		local amBoat = amPlayer:GetAirboat()
		if not amBoat or not amBoat:IsPlaying() then return end

		-- Background
		surface.SetDrawColor(38, 45, 59, 255)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(28, 33, 44, 255)
		surface.DrawRect(0, 0, w, 25)

		-- Title
		surface.SetFont("am_hud_title")
		surface.SetTextColor(235, 235, 235)
		surface.SetTextPos(10, 5)
		surface.DrawText("Airboat Mod")

		-- Points
		surface.SetTextPos(10, 28)
		surface.DrawText("Score : 0")

		-- Health bar
		local hx = 10
		local color = Color(87, 194, 18, 255)
		if amBoat:GetHealth() <= 5 then
			color = Color(200, 31, 19, 255)
		elseif amBoat:GetHealth() <= 10 then
			color = Color(194, 162, 18, 255)
		end

		for i=1,3 do
			local size = (math.min(5, math.max(0, (amBoat:GetHealth() or 0) - 5*(i - 1)))/5)*64

			surface.SetDrawColor(75, 75, 75, 255)
			surface.DrawRect(hx, 50, 64, 20)

			surface.SetDrawColor(color)
			surface.DrawRect(hx, 50, size, 20)
			hx = hx + 70
		end

		local totalHight = 0

		for _, key in pairs(mod_order) do
			local modinfo = amBoat:GetMods()[key]

			if modinfo then
				local mod = AMMods.Mods[modinfo.Name]

				if mod and isfunction(mod.Draw) then
					local hight = mod.Draw(modinfo.Info, AMHud.SizeX, 75 + totalHight + 5, amBoat, amPlayer)

					if hight > 0 then
						totalHight = totalHight + hight + 5
					end
				end
			end
		end

		if totalHight > 0 then
			totalHight = totalHight + 5
		end

		if AMHud.SizeY + totalHight ~= AMHud.DynamicSizeY then
			AMHud.DynamicSizeY = AMHud.SizeY + totalHight

			AMHud.Frame:SizeTo(AMHud.SizeX, AMHud.DynamicSizeY, 0.2)
			AMHud.Frame:MoveTo(30, ScrH() - 30 - AMHud.DynamicSizeY, 0.2)
		end
	end
end

function AMHud.Remove()
	if AMHud.Frame then
		AMHud.Frame:Remove()
		AMHud.Frame = nil
	end
end


function AMHud.SetStatus(status, info)
	AMHud.Status = info
	info.Status = status
	info.Start = CurTime()
end

AMHud.BigCountdown = {
	Enabled = false,
	Text = "",
	Start = 0,
	Time = 0
}

function AMHud.StartBigCountdown(text, time)
	AMHud.BigCountdown.Enabled = true
	AMHud.BigCountdown.Text = text
	AMHud.BigCountdown.Start = CurTime()
	AMHud.BigCountdown.Time = time
end

function AMHud.StopBigCountdown()
	AMHud.BigCountdown.Enabled = false
end


surface.CreateFont("AM_HUD_Big", {
	font = "Arial",
	size = 50,
	weight = 1000
})

surface.CreateFont("AM_HUD_Medium", {
	font = "Arial",
	size = 35,
	weight = 1000
})

surface.CreateFont("AM_HUD_Small", {
	font = "Arial",
	size = 20,
	weight = 1000
})


local blur = Material("pp/blurscreen")
function AMHud.PaintBigCountdown(w, h)
	local info = AMHud.Status

	if info.Status == "dead" or info.Status == "suicide" then
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(blur)

		for i = 1, 5 do
			blur:SetFloat("$blur", (i / 5) * (2))
			blur:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(0, 0, w, h)
		end

		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawRect(0, 0, w, h)

		if info.Status == "dead" then
			local time = math.ceil(info.Start + info.RespawnTime - CurTime())

			if time > 0 then
				draw.Text({text = string.format("Respawn in %s second%s", time, time>1 and "s" or ""), pos = {ScrW()/2, 400}, xalign = TEXT_ALIGN_CENTER, yalign = TEXT_ALIGN_CENTER, font = "AM_HUD_Big"})
			else
				draw.Text({text = "Press [ ".. string.upper(input.LookupBinding("jump")) .. " ] to respawn", pos = {ScrW()/2, 400}, xalign = TEXT_ALIGN_CENTER, yalign = TEXT_ALIGN_CENTER, font = "AM_HUD_Medium"})
				draw.Text({text = "or [ ".. string.upper(input.LookupBinding("use")) .. " ] to show the menu.", pos = {ScrW()/2, 430}, xalign = TEXT_ALIGN_CENTER, yalign = TEXT_ALIGN_CENTER, font = "AM_HUD_Small"})
			end
		elseif info.Status == "suicide" then
			local time = math.ceil(info.Start + info.SuicideTime - CurTime())

			draw.Text({text = string.format("Suicide in %s second%s", time, time>1 and "s" or ""), pos = {ScrW()/2, 400}, xalign = TEXT_ALIGN_CENTER, yalign = TEXT_ALIGN_CENTER, font = "AM_HUD_Big"})
			draw.Text({text = "Press [ ".. string.upper(input.LookupBinding("jump")) .. " ] to cancel.", pos = {ScrW()/2, 430}, xalign = TEXT_ALIGN_CENTER, yalign = TEXT_ALIGN_CENTER, font = "AM_HUD_Small"})
		end
	end
end

-- Don't draw undo list when playing

local bock = {
	PHudUndoList = true,
	PHudHealth = true,
	PHudArmor = true,
	CHudHealth = true,
	CHudBattery = true,
	FancyHUDHealth = true,
	FancyHUDArmor = true,
	FancyHUDAmmo = true
}

hook.Add("HUDShouldDraw", "am_disable_papate_hud", function(name)
	local amPly = AMPlayer.GetPlayer(LocalPlayer())

	if amPly and amPly:GetPlaying() then
		return not bock[name]
	end
end)

hook.Add("HUDPaint", "AirboatMod", function()
	local amPly = AMPlayer.GetPlayer(LocalPlayer())

	if amPly and amPly:GetPlaying() then
		AMHud.PaintBigCountdown(ScrW(), ScrH())
	end
end)
