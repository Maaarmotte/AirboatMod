AMMenu = AMMenu or {}
AMMenu.SubMenus = AMMenu.SubMenus or {}
AMMenu.Callbacks = AMMenu.Callbacks or {}

local SubMenu = {}
local SubMenu_mt = {__index = function(tab, key) return SubMenu[key] end}

if SERVER then
	AMMenu.Receive = {}

	util.AddNetworkString("AirboatMod.Menu.Action")
	util.AddNetworkString("AirboatMod.Menu.Callback")

	function AMMenu.Register(menu)
		AMMenu.SubMenus[menu.Name] = setmetatable(menu, SubMenu_mt)
		menu.Receive = {}
	end

	function AMMenu.ShowMenu(ply)
		local settings = {asd = 123}

		for _, menu in pairs(AMMenu.SubMenus) do
			menu:GetSettings(ply, settings)
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
				Time = CurTime()
			}
		end

		PrintTable(args)

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
else
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

	function AMMenu.Register(menu)
		AMMenu.SubMenus[menu.Name] = setmetatable(menu, SubMenu_mt)
	end

	function AMMenu.Create(settings)
		AMMenu.Settings = settings

		AMMenu.Build()

		table.SortByMember(AMMenu.SubMenus, "Position", true)

		for name, menu in pairs(AMMenu.SubMenus) do
			if not isfunction(menu.CanSee) or menu:CanSee() then
				AMMenu.BuildSubMenu(name)
			end
		end
	end

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

	function AMMenu.Build()
		AMMenu.Settings = settings

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

		local LeaveBtn = vgui.Create("DButton", footerMenu)
		LeaveBtn:Dock(RIGHT)
		LeaveBtn:DockMargin(0, 5, 5 ,5)
		LeaveBtn:SetText("Leave")
		LeaveBtn:SetWide(100)
		LeaveBtn:SetFont("AM_Title")
		LeaveBtn.Paint = paint_button_light
		function LeaveBtn:DoClick()
			main:Close()

			net.Start("am_stop_playing")
			net.SendToServer()
		end

		local playBtn = vgui.Create("DButton", footerMenu)
		playBtn:Dock(RIGHT)
		playBtn:DockMargin(0, 5, 5 ,5)
		playBtn:SetText("Play")
		playBtn:SetWide(100)
		playBtn:SetFont("AM_Title")
		playBtn.Paint = paint_button_light
		function playBtn:DoClick()
			main:Close()

			AMMenu.Settings.Playing = true
			net.Start("am_start_playing")
				net.WriteTable(AMMenu.Settings)
			net.SendToServer()
		end

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

		menu.Tab = vgui.Create("DButton", header_menu)
		menu.Tab:Dock(LEFT)
		menu.Tab:DockMargin(5, 5, 0, 2)
		menu.Tab:SetText(name)
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
			AMMenu.CurrentSubMenu:SetVisible(false)
			AMMenu.CurrentSubMenu.Tab.Selected = false
		end

		local menu = AMMenu.SubMenus[name]
		AMMenu.CurrentSubMenu = menu
		menu.Panel:SetVisible(true)
		menu.Tab.Selected = true
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
				Callback = table.Remove(args, #args),
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


	net.Receive("AirboatMod.Menu.Action", function(_, ply)
		env = net.ReadString()
		action = net.ReadString()
		args = net.ReadTable()
		key = net.ReadString()

		print(env, action, unpack(args))

		if isstring(key) and key ~= "" then
			table.insert(args, function(...)
				net.Start("AirboatMod.Menu.Callback")
					net.WriteString(key)
					net.WriteTable({...})
				net.Send(ply)
			end)
		end

		if env == "Main" and isfunction(AMMenu[action]) then
			AMMenu[action](unpack(args))
		elseif AMMenu.SubMenus[env] then
			local menu = AMMenu.SubMenus[env]

			menu[action](menu, ply, unpack(args))
		end
	end)
end
