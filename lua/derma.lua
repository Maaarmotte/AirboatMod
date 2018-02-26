if AMMenu and IsValid(AMMenu.MainFrame) then
	AMMenu.MainFrame:Close()
end

AMMenu = {}
if SERVER then
	util.AddNetworkString("am_show_menu")
	util.AddNetworkString("am_start_playing")
	util.AddNetworkString("am_stop_playing")

	function AMMenu.SendMenu(amPlayer)
		if amPlayer then
			net.Start("am_show_menu")
				local active = {}
				for key, modid in pairs(amPlayer.Mods) do
					active[key] = modid
				end
				net.WriteTable(active)
				net.WriteTable(amPlayer.OwnedMods)
			net.Send(amPlayer:GetEntity())
		end
	end

	net.Receive("am_start_playing", function(_, ply)
		local amPlayer = ply.AMPlayer
		if not amPlayer then return end

		local settings = net.ReadTable()

		amPlayer:SetSettings(settings)
		amPlayer:Spawn()
	end)

	net.Receive("am_stop_playing", function(_, ply)
		local amPlayer = ply.AMPlayer
		if not amPlayer then return end

		amPlayer:Leave()
	end)
else
	AMMenu.SX = 600
	AMMenu.SY = 400

	AMMenu.MainFrame = nil
	AMMenu.Entity = NULL
	AMMenu.Props = {}
	AMMenu.Settings = {}

	surface.CreateFont("AM_Title", {
		font = "Arial",
		size = 20,
		weight = 1000
	})

	surface.CreateFont("AM_Text", {
		font = "Arial",
		size = 15,
		weight = 400
	})

	surface.CreateFont("AM_SmallText", {
		font = "Arial",
		size = 12,
		weight = 400
	})


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

	local function paint_button_light(self, w, h)
		local color = Color(234, 234, 234, 255)

		if self.Depressed or self:IsSelected() or self:GetToggle() then
			color = Color(38, 174, 255)
		elseif self.Hovered then
			color = Color(255, 255, 255, 255)
		end

		surface.SetDrawColor(color)
		surface.DrawRect(0, 0, w, h)
	end

	local function paint_button_border(self, w, h)
		local color = Color(225, 225, 225, 255)

		if self.Depressed or self:IsSelected() or self:GetToggle() then
			color = Color(38, 174, 255)
		elseif self.Hovered then
			color = Color(240, 240, 240, 255)
		end

		surface.SetDrawColor(color)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(Color(0, 0, 0, 100))
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	function AMMenu.Display(active, mods)
		AMMenu.Settings.Mods = active

		AMMenu.MainFrame = vgui.Create("DFrame")
		AMMenu.MainFrame:SetSize(AMMenu.SX, AMMenu.SY)
		AMMenu.MainFrame:Center()
		AMMenu.MainFrame:SetTitle("")
		AMMenu.MainFrame:SetDraggable(false)
		AMMenu.MainFrame:SetDeleteOnClose(true)
		AMMenu.MainFrame:MakePopup()
		AMMenu.MainFrame:ShowCloseButton(false)
		AMMenu.MainFrame:DockPadding(0, 0, 0, 0)
		AMMenu.MainFrame.Paint = function(self, w, h)
			DrawBlur(self, 2, 5)
			surface.SetDrawColor(0, 40, 55, 175)
			surface.DrawRect(0, 0, w, h)
		end

		local header = vgui.Create("DPanel", AMMenu.MainFrame)
		header:Dock(TOP)
		header:SetTall(25)
		header.Paint = function(self, w, h)
			surface.SetDrawColor(28, 33, 44, 255)
			surface.DrawRect(0, 0, w, h)
		end

		local close_but = vgui.Create("DButton", header)
		close_but:Dock(RIGHT)
		close_but:DockMargin(0, 3, 3 ,3)
		close_but:SetText("X")
		close_but:SetFont("AM_Title")
		close_but:SetWide(40)
		function close_but:DoClick()
			AMMenu.MainFrame:Close()
		end
		function close_but:Paint(w, h)
			local color = Color(234, 234, 234, 255)

			if self.Depressed or self:IsSelected() or self:GetToggle() then
				color = Color(244, 57, 40, 200)
			elseif self.Hovered then
				color = Color(255, 255, 255, 255)
			end

			surface.SetDrawColor(color)
			surface.DrawRect(0, 0, w, h)
		end

		local title = vgui.Create("DLabel", header)
		title:Dock(FILL)
		title:SetFont("AM_Title")
		title:SetText("Airboad Mod Menu")
		title:DockMargin(5, 5, 5, 5)
		title:SetWide(200)
		title:SetTextColor(Color(235, 235, 235))


		local header_menu = vgui.Create("DPanel", AMMenu.MainFrame)
		header_menu:Dock(TOP)
		header_menu:SetTall(32)
		header_menu.Paint = function(self, w, h)
			surface.SetDrawColor(38, 45, 59, 255)
			surface.DrawRect(0, 0, w, h)
		end

		local footer_menu = vgui.Create("DPanel", AMMenu.MainFrame)
		footer_menu:Dock(BOTTOM)
		footer_menu:SetTall(40)
		footer_menu.Paint = function(self, w, h)
			surface.SetDrawColor(38, 45, 59, 255)
			surface.DrawRect(0, 0, w, h)
		end

		local leave_but = vgui.Create("DButton", footer_menu)
		leave_but:Dock(RIGHT)
		leave_but:DockMargin(0, 5, 5 ,5)
		leave_but:SetText("Leave")
		leave_but:SetWide(100)
		leave_but:SetFont("AM_Title")
		leave_but.Paint = paint_button_light
		function leave_but:DoClick()
			AMMenu.MainFrame:Close()

			net.Start("am_stop_playing")
			net.SendToServer()
		end

		local play_but = vgui.Create("DButton", footer_menu)
		play_but:Dock(RIGHT)
		play_but:DockMargin(0, 5, 5 ,5)
		play_but:SetText("Play")
		play_but:SetWide(100)
		play_but:SetFont("AM_Title")
		play_but.Paint = paint_button_light
		function play_but:DoClick()
			AMMenu.MainFrame:Close()

			net.Start("am_start_playing")
				net.WriteTable(AMMenu.Settings)
			net.SendToServer()
		end

		local credit = vgui.Create("DLabel", footer_menu)
		credit:Dock(FILL)
		credit:DockMargin(5, 23, 5 ,5)
		credit:SetFont("AM_SmallText")
		credit:SetText("Developed by Marmotte, Sir Papate and sirious.")
		credit:SetTextColor(Color(255, 255, 255, 50))

		local curentpanel
		local menus = {}

		local function showmenu(id)
			if curentpanel then
				curentpanel:SetVisible(false)
				curentpanel.tab_but.selected = false
			end

			local pnl = menus[id]
			curentpanel = pnl
			pnl:SetVisible(true)
			pnl.tab_but.selected = true
		end

		local function createmenu(name, build)
			local pnl = vgui.Create("DPanel", AMMenu.MainFrame)
			pnl:Dock(FILL)
			pnl:SetVisible(false)
			function pnl:Paint()
			end

			local id = table.insert(menus, pnl)

			local but = vgui.Create("DButton", header_menu)
			but:Dock(LEFT)
			but:DockMargin(5, 5, 0, 0)
			but:SetText(name)
			but:SetWide(100)
			but:SetFont("AM_Title")

			pnl.tab_but = but

			function but:DoClick()
				showmenu(id)
			end

			function but:Paint(w, h)
				local color = Color(220, 220, 220, 255)

				if self.Depressed or self:IsSelected() or self:GetToggle() then
					color = Color(38, 174, 255)
				elseif self.Hovered or self.selected then
					color = Color(255, 255, 255, 255)
				end

				surface.SetDrawColor(color)
				surface.DrawRect(0, 0, w, h)
			end

			build(pnl)
		end

		createmenu("Mods", function(pnl)
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

			function modelFrame:DrawModel()
				self.Entity:DrawModel()

				for _, prop in pairs(AMMenu.Props) do
					if IsValid(prop) then
						prop:DrawModel()
					end
				end
			end

			AMMenu.Entity = modelFrame:GetEntity()

			timer.Simple(0.01, function()
				AMMenu.UpdateModel()
			end)

			local shiftButton = vgui.Create("DButton", optionList)
			if active.shift and AMMods.Mods[active.shift] then shiftButton:SetText("[Shift]: " .. AMMods.Mods[active.shift].FullName)
			else shiftButton:SetText("[Shift]: None") end

			shiftButton:Dock(TOP)
			shiftButton.Paint = paint_button_border
			shiftButton:SetFont("AM_Text")
			shiftButton:DockMargin(5, 5, 5, 5)
			shiftButton:SetTall(50)
			shiftButton.DoClick = function()
				local submenu = DermaMenu()
				for _, mod in ipairs(mods) do
					if AMMods.Mods[mod].Type == "shift" then
						submenu:AddOption(AMMods.Mods[mod].FullName, function()
							active.shift = mod
							AMMenu.UpdateModel()
							shiftButton:SetText("[Shift]: " .. AMMods.Mods[mod].FullName)
						end)
					end
				end

				submenu:AddOption("None", function()
					active.shift = ""
					AMMenu.UpdateModel()
					shiftButton:SetText("[Shift]: None")
				end)
				submenu:Open()
			end

			local spaceButton = vgui.Create("DButton", optionList)
			if active.space and AMMods.Mods[active.space] then spaceButton:SetText("[Space]: " .. AMMods.Mods[active.space].FullName)
			else spaceButton:SetText("[Space]: None") end

			spaceButton:Dock(TOP)
			spaceButton.Paint = paint_button_border
			spaceButton:SetFont("AM_Text")
			spaceButton:DockMargin(5, 5, 5, 5)
			spaceButton:SetTall(50)
			spaceButton.DoClick = function()
				local submenu = DermaMenu()
				for _, mod in ipairs(mods) do
					if AMMods.Mods[mod].Type == "space" then
						submenu:AddOption(AMMods.Mods[mod].FullName, function()
							active.space = mod
							AMMenu.UpdateModel()
							spaceButton:SetText("[Space]: " .. AMMods.Mods[mod].FullName)
						end)
					end
				end

				submenu:AddOption("None", function()
					active.space = ""
					AMMenu.UpdateModel()
					spaceButton:SetText("[Space]: None")
				end)
				submenu:Open()
			end

			local weaponButton = vgui.Create("DButton", optionList)
			if active.mouse1 and AMMods.Mods[active.mouse1] then weaponButton:SetText("[Mouse1]: " .. AMMods.Mods[active.mouse1].FullName)
			else weaponButton:SetText("[Mouse1]: None") end

			weaponButton:Dock(TOP)
			weaponButton.Paint = paint_button_border
			weaponButton:SetFont("AM_Text")
			weaponButton:DockMargin(5, 5, 5, 5)
			weaponButton:SetTall(50)
			weaponButton.DoClick = function()
				local submenu = DermaMenu()
				for _, mod in ipairs(mods) do
					if AMMods.Mods[mod].Type == "mouse1" then
						submenu:AddOption(AMMods.Mods[mod].FullName, function()
							active.mouse1 = mod
							AMMenu.UpdateModel()
							weaponButton:SetText("[Mouse1]: " .. AMMods.Mods[mod].FullName)
						end)
					end
				end

				submenu:AddOption("None", function()
					active.mouse1 = ""
					AMMenu.UpdateModel()
					weaponButton:SetText("[Mouse1]: None")
				end)
				submenu:Open()
			end
		end)

		createmenu("Shop", function(pnl)
			function pnl:Paint(w, h)
				surface.SetDrawColor(Color(38, 45, 59, 255))
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(Color(255, 255, 255, 255))
				surface.DrawRect(5, 0, w - 10, h)
			end
		end)

		showmenu(1)
	end

-- Je n'ai pas trouver d'autre facon pour créer les props sans devoir reecrire les "Mount" des mods
	local mod_mt = {
		__index = function(tab, key)
			if AMMods.Mods[tab.Name] and AMMods.Mods[tab.Name][key] then
				return AMMods.Mods[tab.Name][key]
			else
				return AMMod[key]
			end
		end
	}


	function AMMenu.UpdateModel()
		if not IsValid(AMMenu.Entity) then return end

		for _, prop in pairs(AMMenu.Props) do
			if IsValid(prop) then
				prop:Remove()
			end
		end

		for key, id in pairs(AMMenu.Settings.Mods) do
			local mod = AMMods.Mods[id]

			if mod then
				mod.Mount(setmetatable({Name = id}, mod_mt), AMMenu.Entity)
			end
		end
	end

	function AMMenu.MountHolo(airboat, model, pos, ang, scale, material, color)
		if not color then color = Color(255, 255, 255, 255) end

		if IsValid(airboat) then
			local ent = ClientsideModel(model)

			ent:SetPos(airboat:LocalToWorld(pos))
			ent:SetAngles(airboat:LocalToWorldAngles(ang))
			ent:SetModelScale(scale, 0)
			ent:SetMaterial(material)
			ent:SetColor(color)
			ent:SetParent(airboat)
			ent:SetNoDraw(true)

			table.insert(AMMenu.Props, ent)

			return ent
		end

	end

	net.Receive("am_show_menu", function(len)
		AMMenu.Display(net.ReadTable(), net.ReadTable())
	end)
end
