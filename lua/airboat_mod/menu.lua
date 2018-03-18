AMMenu = AMMenu or {}
AMMenu.SubMenus = AMMenu.SubMenus or {}
AMMenu.Callbacks = AMMenu.Callbacks or {}

AMMenu.PlayButtonEnabled = true

local SubMenu = {}
local SubMenu_mt = {__index = function(tab, key) return

	SubMenu[key]
end}

if SERVER then
	function SubMenu:Send(ply, action, ...)
		AMMenu.Send(ply, self.Name, action, ...)
	end


	AMMenu.Receive = {}

	util.AddNetworkString("AirboatMod.Menu.Action")
	util.AddNetworkString("AirboatMod.Menu.Callback")

	function AMMenu.Register(menu)
		AMMenu.SubMenus[menu.Name] = setmetatable(menu, SubMenu_mt)
	end

	function AMMenu.ShowMenu(ply)
		local settings = {}

		for _, menu in pairs(AMMenu.SubMenus) do
			if isfunction(menu.GetSettings) then
				menu:GetSettings(ply, settings)
			end
		end


		AMMenu.Send(ply, "Main", "Create", settings)
	end

	function AMMenu.Send(ply, env, action, ...)
		local args = {...}
		local key

		if isfunction(args[#args]) then
			key = util.CRC(env .. action .. CurTime())

			AMMenu.Callbacks[key] = {
				Name = env,
				Action = action,
				Key = key,
				Callback = table.Remove(args, #args),
				Player = ply,
				Time = CurTime()
			}
		end

		net.Start("AirboatMod.Menu.Action")
			net.WriteString(env)
			net.WriteString(action)
			net.WriteTable(args)
			net.WriteString(key or "")
		net.Send(ply)
	end

	net.Receive("AirboatMod.Menu.Action", function(_, ply)
		env = net.ReadString()
		action = net.ReadString()
		args = net.ReadTable()
		key = net.ReadString()

		if isstring(key) and key ~= "" then
			table.insert(args, function(...)
				net.Start("AirboatMod.Menu.Callback")
					net.WriteString(key)
					net.WriteTable({...})
				net.Send(ply)
			end)
		end

		if env == "Main" and isfunction(AMMenu.Receive[action]) then
			AMMenu.Receive[action](ply, unpack(args))
		elseif AMMenu.SubMenus[env] and isfunction(AMMenu.SubMenus[env].Receive[action]) then
			local menu = AMMenu.SubMenus[env]

			menu.Receive[action](menu, ply, unpack(args))
		end
	end)

	net.Receive("AirboatMod.Menu.Callback", function(_, ply)
		local key = net.ReadString()
		local args = net.ReadTable()

		local callback = AMMenu.Callbacks[key]

		if callback then
			if callback.Player ~= ply then return end

			callback.Callback(unpack(args))

			AMMenu.Callbacks[key] = nil
		end
	end)


	function AMMenu.Receive.Play(ply, settings)
		local amPly = AMPlayer.GetPlayer(ply)
		if not amPly then return end

		amPly:SetSettings(settings)

		if not amPly:GetPlaying() or amPly:CanRespawn() then
			amPly:Spawn()
		end
	end

	function AMMenu.Receive.Leave(ply, settings)
		local amPly = AMPlayer.GetPlayer(ply)
		if not amPly then return end

		amPly:Leave()
	end

	function AMMenu.Receive.Respawn(ply, settings)
		local amPly = AMPlayer.GetPlayer(ply)
		if not amPly then return end

		amPly:SetSettings(settings)

		if amPly:IsAlive() then
			amPly:Suicide()
		end
	end
else
	function SubMenu:Send(action, ...)
		AMMenu.Send(self.Name, action, ...)
	end



	AMMenu.SizeX = 650
	AMMenu.SizeY = 450

	AMMenu.MainFrame = nil
	AMMenu.Settings = {}
	AMMenu.DisplaySpawn = nil
	AMMenu.CurrentSubMenu = nil

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

	surface.CreateFont("AM_LargeText", {
		font = "Arial",
		size = 16,
		weight = 1000
	})

	surface.CreateFont("AM_SmallText", {
		font = "Arial",
		size = 12,
		weight = 400
	})

	local blur = Material("pp/blurscreen")
	function AMMenu.DrawBlur(pnl, a, d)
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
-- paint_button_light
	function AMMenu.StyleButtonLight(self, w, h)
		local color = Color(234, 234, 234, 255)

		if not self:IsEnabled() then
			color = Color(210, 210, 210, 255)
		elseif self.Depressed or self:IsSelected() or self:GetToggle() then
			color = Color(38, 174, 255)
		elseif self.Hovered then
			color = Color(245, 245, 245, 255)
		end

		surface.SetDrawColor(color)
		surface.DrawRect(0, 0, w, h)
	end
-- paint_button_border
	function AMMenu.StyleButtonBorder(self, w, h)
		local color = Color(235, 235, 235, 255)

		if self.Depressed or self:IsSelected() or self:GetToggle()  then
			color = Color(38, 174, 255)
		elseif self.Hovered or self.Selected then
			color = Color(255, 255, 255, 255)
		end

		surface.SetDrawColor(color)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 50)
		surface.DrawRect(5, h-1, w - 10, 1)
	end

	function AMMenu.Register(menu)
		AMMenu.SubMenus[menu.Name] = setmetatable(menu, SubMenu_mt)
	end

	function AMMenu.Create(settings)
		AMMenu.Settings = settings

		AMMenu.Build()

		local keys = table.GetKeys(AMMenu.SubMenus)

		table.sort(keys, function(a, b)
			return AMMenu.SubMenus[a].Position < AMMenu.SubMenus[b].Position
		end)

		table.SortByMember(AMMenu.SubMenus, "Position", true)

		for _, name in pairs(keys) do
			local menu = AMMenu.SubMenus[name]

			if not isfunction(menu.CanSee) or menu:CanSee() then
				AMMenu.BuildSubMenu(name)
			end
		end

		AMMenu.SelectedSubMenu(keys[1])
	end

	function AMMenu.Build()
		AMMenu.CurrentSubMenu = nil

		main = vgui.Create("DFrame")
		AMMenu.MainFrame = main

		main:SetSize(AMMenu.SizeX, AMMenu.SizeY)
		main:Center()
		main:SetTitle("")
		main:SetDraggable(false)
		main:SetDeleteOnClose(true)
		main:MakePopup()
		main:ShowCloseButton(false)
		main:DockPadding(0, 0, 0, 0)
		main.Paint = function(self, w, h)
			AMMenu.DrawBlur(self, 2, 5)
			surface.SetDrawColor(0, 40, 55, 175)
			surface.DrawRect(0, 0, w, h)
		end

		local header = vgui.Create("DPanel", main)
		header:Dock(TOP)
		header:SetTall(25)
		header.Paint = function(self, w, h)
			surface.SetDrawColor(28, 33, 44, 255)
			surface.DrawRect(0, 0, w, h)
		end

		local closeBtn = vgui.Create("DButton", header)
		closeBtn:Dock(RIGHT)
		closeBtn:DockMargin(0, 3, 3 ,3)
		closeBtn:SetText("X")
		closeBtn:SetFont("AM_Title")
		closeBtn:SetWide(40)
		function closeBtn:DoClick()
			main:Close()
		end
		function closeBtn:Paint(w, h)
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
		title:SetText("Airboat Mod Menu")
		title:DockMargin(5, 5, 5, 5)
		title:SetWide(200)
		title:SetTextColor(Color(235, 235, 235))


		local headerMenu = vgui.Create("DPanel", main)
		AMMenu.TabList = headerMenu
		headerMenu:Dock(TOP)
		headerMenu:SetTall(32)
		headerMenu.Paint = function(self, w, h)
			surface.SetDrawColor(38, 45, 59, 255)
			surface.DrawRect(0, 0, w, h)
		end

		local footerMenu = vgui.Create("DPanel", main)
		footerMenu:Dock(BOTTOM)
		footerMenu:SetTall(40)
		footerMenu.Paint = function(self, w, h)
			surface.SetDrawColor(38, 45, 59, 255)
			surface.DrawRect(0, 0, w, h)
		end

		local leaveBtn = vgui.Create("DButton", footerMenu)
		leaveBtn:Dock(RIGHT)
		leaveBtn:DockMargin(0, 5, 5 ,5)
		leaveBtn:SetText("Leave")
		leaveBtn:SetWide(100)
		leaveBtn:SetFont("AM_Title")
		leaveBtn:SetEnabled(AMMenu.LeaveButtonEnable)
		leaveBtn.Paint = AMMenu.StyleButtonLight
		function leaveBtn:DoClick()
			main:Close()

			AMMenu.Send("Main", "Leave", AMMenu.Settings)
		end

		AMMenu.LeaveButton = leaveBtn

		local playBtn = vgui.Create("DButton", footerMenu)
		playBtn:Dock(RIGHT)
		playBtn:DockMargin(0, 5, 5 ,5)
		playBtn:SetText("Play")
		playBtn:SetWide(100)
		playBtn:SetFont("AM_Title")
		playBtn:SetEnabled(AMMenu.PlayButtonEnabled)
		playBtn.Paint = AMMenu.StyleButtonLight
		function playBtn:DoClick()
			main:Close()

			AMMenu.Settings.Playing = true
			AMMenu.Send("Main", "Play", AMMenu.Settings)
		end

		AMMenu.PlayButton = playBtn
		AMMenu.Leaveto = true

		local respawnBtn = vgui.Create("DButton", footerMenu)
		respawnBtn:Dock(RIGHT)
		respawnBtn:DockMargin(0, 5, 5 ,5)
		respawnBtn:SetText("Suicide")
		respawnBtn:SetWide(100)
		respawnBtn:SetFont("AM_Title")
		respawnBtn:SetEnabled(AMMenu.RespawnButtonEnabled)
		respawnBtn.Paint = AMMenu.StyleButtonLight
		function respawnBtn:DoClick()
			main:Close()

			AMMenu.Send("Main", "Respawn", AMMenu.Settings)
		end

		AMMenu.RespawnButton = respawnBtn

		local credit = vgui.Create("DLabel", footerMenu)
		credit:Dock(FILL)
		credit:DockMargin(5, 23, 5 ,5)
		credit:SetFont("AM_SmallText")
		credit:SetText("Developed by Marmotte, Sir Papate, sirious and mandrac.")
		credit:SetTextColor(Color(255, 255, 255, 50))
	end

	function AMMenu.BuildSubMenu(name)
		local menu = AMMenu.SubMenus[name]

		menu.Panel = vgui.Create("DPanel", AMMenu.MainFrame)
		menu.Panel:Dock(FILL)
		menu.Panel:SetVisible(false)

		function menu.Panel:Paint()
		end

		menu.Tab = vgui.Create("DButton", AMMenu.TabList)
		menu.Tab:Dock(LEFT)
		menu.Tab:DockMargin(5, 5, 0, 2)
		menu.Tab:SetText(menu.Title)
		menu.Tab:SetWide(100)
		menu.Tab:SetFont("AM_Title")

		function menu.Tab:DoClick()
			AMMenu.SelectedSubMenu(name)
		end

		function menu.Tab:Paint(w, h)
			local color = Color(220, 220, 220, 255)

			if self.Depressed or self:IsSelected() or self:GetToggle() then
				color = Color(38, 174, 255)
			elseif self.Hovered or self.Selected then
				color = Color(255, 255, 255, 255)
			end

			surface.SetDrawColor(color)
			surface.DrawRect(0, 0, w, h)
		end

		menu:Build(menu.Panel)
	end

	function AMMenu.SelectedSubMenu(name)
		if AMMenu.CurrentSubMenu then
			AMMenu.CurrentSubMenu.Panel:SetVisible(false)
			AMMenu.CurrentSubMenu.Tab.Selected = false
		end

		local menu = AMMenu.SubMenus[name]
		AMMenu.CurrentSubMenu = menu
		menu.Panel:SetVisible(true)
		menu.Tab.Selected = true
	end


	function AMMenu.SetStatus(status, info)
		AMMenu.Status = status

		AMHud.SetStatus(status, info)

		if status == "playing" then
			AMMenu.PlayButtonEnabled = false
			AMMenu.RespawnButtonEnabled = true
			AMMenu.LeaveButtonEnable = true

			if IsValid(AMMenu.MainFrame) then
				AMMenu.PlayButton:SetEnabled(false)
				AMMenu.RespawnButton:SetEnabled(true)
				AMMenu.LeaveButton:SetEnabled(true)
			end
		elseif status == "suicide" then
			AMMenu.PlayButtonEnabled = false
			AMMenu.RespawnButtonEnabled = false
			AMMenu.LeaveButtonEnable = true

			if IsValid(AMMenu.MainFrame) then
				AMMenu.PlayButton:SetEnabled(false)
				AMMenu.RespawnButton:SetEnabled(false)
				AMMenu.LeaveButton:SetEnabled(true)
			end
		elseif status == "dead" then
			AMMenu.PlayButtonEnabled = info.CanRespawn
			AMMenu.RespawnButtonEnabled = false
			AMMenu.LeaveButtonEnable = true

			if IsValid(AMMenu.MainFrame) then
				AMMenu.PlayButton:SetEnabled(info.CanRespawn)
				AMMenu.RespawnButton:SetEnabled(false)
				AMMenu.LeaveButton:SetEnabled(true)
			end
		elseif status == "notplaying" then
			AMMenu.PlayButtonEnabled = true
			AMMenu.RespawnButtonEnabled = false
			AMMenu.LeaveButtonEnable = false

			if IsValid(AMMenu.MainFrame) then
				AMMenu.PlayButton:SetEnabled(true)
				AMMenu.RespawnButton:SetEnabled(false)
				AMMenu.LeaveButton:SetEnabled(false)
			end
		end
	end



	function AMMenu.Send(env, action, ...)
		local args = {...}
		local key

		if isfunction(args[#args]) then
			key = util.CRC(env .. action .. CurTime())

			AMMenu.Callbacks[key] = {
				Name = env,
				Action = action,
				Key = key,
				Callback = table.remove(args, #args),
				Time = CurTime()
			}
		end

		net.Start("AirboatMod.Menu.Action")
			net.WriteString(env)
			net.WriteString(action)
			net.WriteTable(args)

			if key then
				net.WriteString(key)
			end
		net.SendToServer()
	end


	net.Receive("AirboatMod.Menu.Action", function()
		env = net.ReadString()
		action = net.ReadString()
		args = net.ReadTable()
		key = net.ReadString()

		if isstring(key) and key ~= "" then
			table.insert(args, function(...)
				net.Start("AirboatMod.Menu.Callback")
					net.WriteString(key)
					net.WriteTable({...})
				net.SendToServer()
			end)
		end

		if env == "Main" and isfunction(AMMenu[action]) then
			AMMenu[action](unpack(args))
		elseif env == "HUD" and isfunction(AMHud[action]) then
			AMHud[action](unpack(args))
		elseif AMMenu.SubMenus[env] then
			local menu = AMMenu.SubMenus[env]

			menu[action](menu, unpack(args))
		end
	end)

	net.Receive("AirboatMod.Menu.Callback", function()
		local key = net.ReadString()
		local args = net.ReadTable()

		local callback = AMMenu.Callbacks[key]

		if callback then
			callback.Callback(unpack(args))

			AMMenu.Callbacks[key] = nil
		end
	end)
end
