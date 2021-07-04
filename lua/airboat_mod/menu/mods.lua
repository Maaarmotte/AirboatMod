local MENU = {}

MENU.Name = "mods"
MENU.Title = "Mods"

MENU.Position = 1

if SERVER then
	MENU.Receive = {}

	function MENU:GetSettings(ply, info)
		local amPly = AMPlayer.GetPlayer(ply)

		local mods = {}
		for key, modid in pairs(amPly.Mods) do
			mods[key] = modid
		end

		info.Mods = mods
		info.OwnedMods = amPly.OwnedMods
		info.Color = amPly.Color
	end

	function MENU.Receive:SetMod(ply, mod)
		local amPly = AMPlayer.GetPlayer(ply)

		if amPly:IsOwningMod(mod) then
			amPly:SetMod(mod)
		end
	end

	function MENU.Receive:UnsetKey(ply, key)
		local amPly = AMPlayer.GetPlayer(ply)

		amPly:UnsetKey(key)
	end

	function MENU.Receive:SetColor(ply, color)
		local amPly = AMPlayer.GetPlayer(ply)

		if istable(color) and color.r and color.g and color.b then
			color.a = 255
			PrintTable(color)
			amPly.Color = color
		end
	end
else
	MENU.Props = {}
	MENU.Entity = NULL

	function MENU:Build(pnl)
		local settings = AMMenu.Settings

		function pnl:Paint(w, h)
			surface.SetDrawColor(Color(38, 45, 59, 255))
			surface.DrawRect(0, 0, 5, h)
		end

		local optionList = vgui.Create("DPanel", pnl)
		optionList:Dock(LEFT)
		optionList:DockMargin(5, 0, 0, 0)
		optionList:SetWide(175)
		function optionList:Paint(w, h)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawRect(0, 0, w, h)
		end

		local modelFrame = vgui.Create("DModelPanel", pnl)
		modelFrame:Dock(FILL)
		modelFrame:SetModel("models/airboat.mdl")
		modelFrame:SetCamPos(Vector(-185, -185, 85))
		modelFrame:SetFOV(50)
		modelFrame:SetColor(settings.Color)

		function modelFrame:DrawModel()
			self.Entity:DrawModel()

			for _, prop in pairs(MENU.Props) do
				if IsValid(prop) then
					local c = prop:GetColor()
					render.SetColorModulation(c.r/255, c.g/255, c.b/255)
					prop:DrawModel()
				end
			end
		end

		MENU.Entity = modelFrame:GetEntity()
		MENU.Entity:SetSubMaterial(0, "models/airboat-mod/airboat001")

		timer.Simple(0.01, function()
			MENU:UpdateModel()
		end)

		local selectList = vgui.Create("DPanel", modelFrame)
		selectList:Dock(LEFT)
		selectList:DockMargin(0, 0, 0, 0)
		selectList:SetWide(0)
		selectList.IsOpened = name

		function selectList:Paint(w, h)
			AMMenu.DrawBlur(self, 2, 2)

			surface.SetDrawColor(0, 0, 0, 100)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(0, 0, 0, 100)
			surface.DrawRect(0, 0, 3, h)
		end

		function selectList:Open(name, but, callback)
			if self.IsOpened and self.IsOpened ~= name then
				self:Close(function()
					self:Open(name, but, callback)
				end)
			elseif self.IsOpened == name then
				self:Close()
			elseif not self.IsOpened then
				self.IsOpened = name

				if but then
					but.Selected = true
					self.SelectedBut = but
				end

				selectList:Clear()
				selectList:SizeTo(175, selectList:GetTall(), 0.4)

				callback()
			end
		end

		function selectList:Close(callback)
			if self.SelectedBut then
				self.SelectedBut.Selected = nil
				self.SelectedBut = nil
			end

			self.IsOpened = nil
			selectList:SizeTo(0, selectList:GetTall(), 0.4, 0, -1, callback)
		end

		function selectList:AddBut(name, description, callback)
			local button = vgui.Create("DButton", selectList)
			button:Dock(TOP)
			button:SetTall(60)
			button:SetText("")

			function button:DoClick()
				selectList:Close()

				callback(self)
			end

			function button:Paint(w, h)
				local color = Color(220, 220, 220, 0)

				if self.Depressed or self:IsSelected() or self:GetToggle() then
					color = Color(55, 174, 255)
				elseif self.Hovered or self.selected then
					color = Color(255, 255, 255, 5)
				end

				surface.SetDrawColor(color)
				surface.DrawRect(0, 0, w, h)


				surface.SetDrawColor(255, 255, 255, 20)
				surface.DrawRect(10, h-1, w - 20, 1)
			end

			local title = vgui.Create("DLabel", button)
			title:Dock(FILL)
			title:DockMargin(10, 5, 5, 0)
			title:SetText(name)
			title:SetFont("AM_LargeText")
		end

		for _, nicekey in pairs({"Shift", "Space", "Mouse1", "Skin"}) do
			local key = string.lower(nicekey)

			local button = vgui.Create("DButton", optionList)
			if settings.Mods[key] and AMMods.Mods[settings.Mods[key]] then button:SetText("[" .. nicekey .. "]: " .. AMMods.Mods[settings.Mods[key]].FullName)
			else button:SetText("[" .. nicekey .. "]: None") end

			button:Dock(TOP)
			button.Paint = AMMenu.StyleButtonBorder
			button:SetFont("AM_Text")
			button:DockMargin(0, 0, 0, 0)
			button:SetTall(60)
			button.DoClick = function()
				selectList:Open(key, button, function()
					for _, mod in ipairs(settings.OwnedMods) do
						if AMMods.Mods[mod].Type == key then
							selectList:AddBut(AMMods.Mods[mod].FullName, nil, function()
								MENU:Send("SetMod", mod)

								settings.Mods[key] = mod
								MENU:UpdateModel()

								button:SetText("[" .. nicekey .. "]: " .. AMMods.Mods[mod].FullName)
							end)
						end
					end

					selectList:AddBut("None", nil, function()
						MENU:Send("UnsetKey", key)

						settings.Mods[key] = ""
						MENU:UpdateModel()

						button:SetText("[" .. nicekey .. "]: None")
					end)
				end)
			end
		end

		colors = {
			Color(196, 185, 155),
			Color(211, 48, 48),
			Color(230, 84, 140),
			Color(152, 34, 175),
			Color(68, 52, 238),
			Color(30, 144, 209),
			Color(76, 213, 213),
			Color(67, 190, 94),
			Color(198, 203, 75),
			Color(200, 160, 51)
		}

		local button = vgui.Create("DButton", optionList)
		button:SetText("Color")
		button:Dock(TOP)
		button.Paint = AMMenu.StyleButtonBorder
		button:SetFont("AM_Text")
		button:DockMargin(0, 0, 0, 0)
		button:SetTall(60)
		button.DoClick = function()
			selectList:Open("color", button, function()
				for _, color in pairs(colors) do
					local button = vgui.Create("DButton", selectList)
					button:Dock(TOP)
					button:DockMargin(10, 5, 10, 0)
					button:SetTall(20)
					button:SetText("")

					function button:Paint(w, h)
						surface.SetDrawColor(color)
						surface.DrawRect(0, 0, w, h)
					end

					function button:DoClick()
						modelFrame:SetColor(color)
						selectList:Close()

						settings.Color = color

						MENU:Send("SetColor", color)
					end
				end

				local button = vgui.Create("DButton", selectList)
				button:Dock(TOP)
				button:DockMargin(10, 10, 10, 0)
				button:SetTall(20)
				button:SetText("Custom color")
				button.Paint = AMMenu.StyleButtonBorder
				button:SetFont("AM_Text")

				button.DoClick = function()
					selectList:Open("colopicker", nil, function()
						local mixer = vgui.Create("DColorMixer", selectList)
						mixer:Dock(TOP)
						mixer:SetTall(120)
						mixer:DockMargin(10, 10, 10, 0)
						mixer:SetPalette(false)
						mixer:SetAlphaBar(false)
						mixer:SetWangs(false)

						mixer.RGB:SetWide(20)

						local button = vgui.Create("DButton", selectList)
						button:Dock(TOP)
						button:DockMargin(10, 10, 10, 0)
						button:SetTall(20)
						button:SetText("Close")
						button.Paint = AMMenu.StyleButtonBorder
						button:SetFont("AM_Text")

						function button:DoClick()
							selectList:Close()
						end

						function mixer:ValueChanged(color)
							color.r = math.Clamp(color.r, 50	, 220)
							color.g = math.Clamp(color.g, 50	, 220)
							color.b = math.Clamp(color.b, 50	, 220)

							modelFrame:SetColor(color)
							settings.Color = color
						end

						function mixer.HSV:OnMouseReleased(mcode)
							self:SetDragging(false)
							self:MouseCapture(false)

							MENU:Send("SetColor", settings.Color)
						end

						function mixer.RGB:OnMouseReleased(mcode)
							self:MouseCapture(false)
							self:OnCursorMoved(self:CursorPos())

							MENU:Send("SetColor", settings.Color)
						end
					end)
				end
			end)
		end
	end

	local mod_mt = {
		__index = function(tab, key)
			if rawget(tab, "Name") and AMMods.Mods[tab.Name] and AMMods.Mods[tab.Name][key] then
				return AMMods.Mods[tab.Name][key]
			else
				return AMMod[key]
			end
		end
	}


	function MENU.UpdateModel()
		if not IsValid(MENU.Entity) then return end

		for _, prop in pairs(MENU.Props) do
			if IsValid(prop) then
				prop:Remove()
			end
		end

		for key, id in pairs(AMMenu.Settings.Mods) do
			if id ~= "" then
				local mod = AMMods.Mods[id]

				if mod then
					mod.OnMount(setmetatable({Name = id, MountHolo = MENU.MountHolo}, mod_mt))
				end
			end
		end
	end

	function MENU.MountHolo(mod, model, pos, ang, scale, material, color)
		if not color then color = Color(255, 255, 255, 255) end
		local boat = MENU.Entity

		if IsValid(boat) then
			local ent = ClientsideModel(model)

			ent:SetPos(boat:LocalToWorld(pos))
			ent:SetAngles(boat:LocalToWorldAngles(ang))

			-- ent:SetModelScale(scale, 0)			
			local scaleMat = isnumber(scale) and Vector(scale, scale, scale) or scale
			local mat = Matrix()
			mat:Scale(scaleMat)
			ent:EnableMatrix("RenderMultiply", mat)


			ent:SetMaterial(material)
			ent:SetColor(color)
		    ent:SetParent(boat)
			ent:SetNoDraw(true)

			table.insert(MENU.Props, ent)

			return ent
		end
	end
end

AMMenu.Register(MENU)
