if AMMenu and IsValid(AMMenu.MainFrame) then
	AMMenu.MainFrame:Close()
end

AMMenu = {}
if SERVER then
	util.AddNetworkString("am_show_menu")
	util.AddNetworkString("am_start_playing")
	util.AddNetworkString("am_stop_playing")
	util.AddNetworkString("am_spawn_add")
	util.AddNetworkString("am_spawn_save")
	util.AddNetworkString("am_spawn_remove")
	util.AddNetworkString("am_spawn_update")
	util.AddNetworkString("am_spawn_teleport")

	function AMMenu.SendMenu(amPly)
		if amPly then
			net.Start("am_show_menu")
				local mods = {}
				for key, modid in pairs(amPly.Mods) do
					mods[key] = modid
				end

				local settings = {
					Mods = mods,
					OwnedMods = amPly.OwnedMods,
					Color = amPly.Color,
				}

				if AMMain.IsPlayerAdmin(amPly:GetEntity()) then
					settings.IsAdmin = true
					settings.AdminInfo = {
						Spawns = AMSpawns
					}
				end

				net.WriteTable(settings)
			net.Send(amPly:GetEntity())
		end
	end

	function AMMenu.SendSpawnsInfo(ply)
		net.Start("am_spawn_update")
			net.WriteTable(AMSpawns)
		net.Send(ply)
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

	net.Receive("am_spawn_save", function(_, ply)
		if not AMMain.IsPlayerAdmin(ply) then
			AMMenu.SendSpawnsInfo(ply)
			return
		end

		local id, v1, v2 = net.ReadInt(16), net.ReadVector(), net.ReadVector()
		v1 = Vector(math.Clamp(v1.x, -16384, 16384), math.Clamp(v1.y, -16384, 16384), math.Clamp(v1.z, -16384, 16384))
		v2 = Vector(math.Clamp(v2.x, -16384, 16384), math.Clamp(v2.y, -16384, 16384), math.Clamp(v2.z, -16384, 16384))
		local min = Vector(math.min(v1.x, v2.x), math.min(v1.y, v2.y), math.min(v1.z, v2.z))
		local max = Vector(math.max(v1.x, v2.x), math.max(v1.y, v2.y), math.max(v1.z, v2.z))


		AMSpawn.Edit(id, min, max)

		AMMenu.SendSpawnsInfo(ply)
	end)

	net.Receive("am_spawn_remove", function(_, ply)
		if not AMMain.IsPlayerAdmin(ply) then
			AMMenu.SendSpawnsInfo(ply)
			return
		end

		local id = net.ReadInt(16)

		AMSpawn.Remove(id)

		AMMenu.SendSpawnsInfo(ply)
	end)

	net.Receive("am_spawn_add", function(_, ply)
		if not AMMain.IsPlayerAdmin(ply) then
			AMMenu.SendSpawnsInfo(ply)
			return
		end

		AMSpawn.New(Vector(0,0,0), Vector(0,0,0))

		AMMenu.SendSpawnsInfo(ply)
	end)

	net.Receive("am_spawn_update", function(_, ply)
		if not AMMain.IsPlayerAdmin(ply) then
			AMMenu.SendSpawnsInfo(ply)
			return
		end

		AMMenu.SendSpawnsInfo(ply)
	end)

	net.Receive("am_spawn_teleport", function(_, ply)
		if not AMMain.IsPlayerAdmin(ply) then
			AMMenu.SendSpawnsInfo(ply)
			return
		end

		local id = net.ReadInt(16)
		print(id)
		PrintTable(AMSpawns)
		local spawn = AMSpawn.GetByID(id)

		ply:SetPos((spawn.min + spawn.max)/2)
	end)
else
	AMMenu.SX = 650
	AMMenu.SY = 450

	AMMenu.MainFrame = nil
	AMMenu.Entity = NULL
	AMMenu.Props = {}
	AMMenu.Settings = {}
	AMMenu.DisplaySpawn = nil

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
			color = Color(245, 245, 245, 255)
		end

		surface.SetDrawColor(color)
		surface.DrawRect(0, 0, w, h)
	end

	local function paint_button_border(self, w, h)
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

	function AMMenu.Display(settings)
		AMMenu.Settings = settings

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
		title:SetText("Airboat Mod Menu")
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

			AMMenu.Settings.Playing = true
			net.Start("am_start_playing")
				net.WriteTable(AMMenu.Settings)
			net.SendToServer()
		end

		local credit = vgui.Create("DLabel", footer_menu)
		credit:Dock(FILL)
		credit:DockMargin(5, 23, 5 ,5)
		credit:SetFont("AM_SmallText")
		credit:SetText("Developed by Marmotte, Sir Papate, sirious and mandrac.")
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
			but:DockMargin(5, 5, 0, 2)
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
			modelFrame:SetColor(settings.Color)

			function modelFrame:DrawModel()
				self.Entity:DrawModel()

				for _, prop in pairs(AMMenu.Props) do
					if IsValid(prop) then
						local c = prop:GetColor()
						render.SetColorModulation(c.r/255, c.g/255, c.b/255)
						prop:DrawModel()
					end
				end
			end

			AMMenu.Entity = modelFrame:GetEntity()
			AMMenu.Entity:SetSubMaterial(0, "models/airboat-mod/airboat001")

			timer.Simple(0.01, function()
				AMMenu.UpdateModel()
			end)

			local selectList = vgui.Create("DPanel", modelFrame)
			selectList:Dock(LEFT)
			selectList:DockMargin(0, 0, 0, 0)
			selectList:SetWide(0)
			selectList.IsOpened = name

			function selectList:Paint(w, h)
				DrawBlur(self, 2, 2)

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
					but.Selected = true
					self.SelectedBut = but

					selectList:Clear()
					selectList:SizeTo(175, selectList:GetTall(), 0.4)

					callback()
				end
			end

			function selectList:Close(callback)
				self.SelectedBut.Selected = nil
				self.SelectedBut = nil
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

			for _, nicekey in pairs({"Shift", "Space", "Mouse1"}) do
				local key = string.lower(nicekey)

				local button = vgui.Create("DButton", optionList)
				if settings.Mods[key] and AMMods.Mods[settings.Mods[key]] then button:SetText("[" .. nicekey .. "]: " .. AMMods.Mods[settings.Mods[key]].FullName)
				else button:SetText("[" .. nicekey .. "]: None") end

				button:Dock(TOP)
				button.Paint = paint_button_border
				button:SetFont("AM_Text")
				button:DockMargin(0, 0, 0, 0)
				button:SetTall(60)
				button.DoClick = function()
					selectList:Open(key, button, function()
						for _, mod in ipairs(settings.OwnedMods) do
							if AMMods.Mods[mod].Type == key then
								selectList:AddBut(AMMods.Mods[mod].FullName, nil, function()
									settings.Mods[key] = mod
									AMMenu.UpdateModel()
									button:SetText("[" .. nicekey .. "]: " .. AMMods.Mods[mod].FullName)
								end)
							end
						end

						selectList:AddBut("None", nil, function()
							settings.Mods[key] = ""
							AMMenu.UpdateModel()
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
			button.Paint = paint_button_border
			button:SetFont("AM_Text")
			button:DockMargin(0, 0, 0, 0)
			button:SetTall(60)
			button.DoClick = function()
				selectList:Open("color", button, function()
					for _, c in pairs(colors) do
						local button = vgui.Create("DButton", selectList)
						button:Dock(TOP)
						button:DockMargin(10, 10, 10, 0)
						button:SetTall(20)
						button:SetText("")

						function button:Paint(w, h)
							surface.SetDrawColor(c)
							surface.DrawRect(0, 0, w, h)
						end

						function button:DoClick()
							modelFrame:SetColor(c)
							selectList:Close()

							settings.Color = c
						end
					end
				end)
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

		if settings.IsAdmin then
			createmenu("Admin", function(pnl)
				function pnl:Paint(w, h)
					surface.SetDrawColor(Color(38, 45, 59, 255))
					surface.DrawRect(0, 0, w, h)
				end


				local optionList = vgui.Create("DPanel", pnl)
				optionList:Dock(LEFT)
				optionList:DockMargin(5, 0, 0, 0)
				optionList:SetWide(175)
				function optionList:Paint(w, h)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawRect(0, 0, w, h)
				end

				optionList.PanelList = {}
				optionList.LastPanel = nil

				function optionList:addOption(name, build)
					local button = vgui.Create("DButton", self)
					button:Dock(TOP)
					button.Paint = paint_button_border
					button:SetFont("AM_Text")
					button:DockMargin(0, 0, 0, 0)
					button:SetTall(35)
					button:SetText(name)

					local panel = vgui.Create("DPanel", pnl)
					panel:Dock(FILL)
					panel:DockMargin(5, 0, 5, 0)
					panel:SetVisible(false)

					panel.Button = button

					local id = table.insert(optionList.PanelList, panel)

					function button.DoClick()
						self:showMenu(id)
					end

					function panel:Paint(w, h)
						surface.SetDrawColor(255, 255, 255, 255)
						surface.DrawRect(0, 0, w, h)
					end

					build(panel, button)
				end

				function optionList:showMenu(id)
					if optionList.LastPanel then
						optionList.LastPanel:SetVisible(false)
						optionList.LastPanel.Button.Selected = false
					end

					local panel = optionList.PanelList[id]

					panel:SetVisible(true)
					panel.Button.Selected = true

					optionList.LastPanel = panel
				end


				optionList:addOption("Spawn Zones", function(pnl)
					local btnsPanel = vgui.Create("DPanel", pnl)
					btnsPanel:Dock(BOTTOM)
					btnsPanel:DockMargin(5, 5, 5, 5)
					btnsPanel:SetTall(30)

					function btnsPanel:Paint(w, h)
						-- surface.SetDrawColor(240, 240, 240, 255)
						-- surface.DrawRect(0, 0, w, h)
					end

					local btnAdd = vgui.Create("DButton", btnsPanel)
					btnAdd:Dock(RIGHT)
					btnAdd:SetText("New spawn")
					btnAdd:DockMargin(5, 0, 0 ,0)
					btnAdd:SetWide(150)
					btnAdd:SetFont("AM_Title")
					btnAdd.Paint = paint_button_light

					function btnAdd:DoClick()
						net.Start("am_spawn_add")
						net.SendToServer()
					end

					local btnRefresh = vgui.Create("DButton", btnsPanel)
					btnRefresh:Dock(RIGHT)
					btnRefresh:SetText("Refresh")
					btnRefresh:DockMargin(5, 0, 0 ,0)
					btnRefresh:SetWide(150)
					btnRefresh:SetFont("AM_Title")
					btnRefresh.Paint = paint_button_light

					function btnRefresh:DoClick()
						net.Start("am_spawn_update")
						net.SendToServer()
					end

					local list = vgui.Create("DScrollPanel", pnl)
					list:Dock(FILL)
					list:DockMargin(5, 5, 5, 0)
					AMMenu.SpawnList = list

					function list:Paint(w, h)
						surface.SetDrawColor(240, 240, 240, 255)
						surface.DrawRect(0, 0, w, h)
					end

					function list:AddSpawn(id, min, max)
						local fram = list:Add("DPanel")
						fram:Dock(TOP)
						fram:DockMargin(3, 3, 3, 0)
						fram:SetTall(24)
						fram.spawnId = id

						function fram:Paint(w, h)
							surface.SetDrawColor(255, 255, 255, 255)
							surface.DrawRect(0, 0, w, h)
						end

						local minLabel = vgui.Create("DLabel", fram)
						minLabel:Dock(LEFT)
						minLabel:DockMargin(5, 5, 0, 5)
						minLabel:SetText("Min :")
						minLabel:SetWide(25)
						minLabel:SetTextColor(Color(50, 50, 50))

						local minX = vgui.Create("DTextEntry", fram)
						minX:Dock(LEFT)
						minX:DockMargin(2, 4, 0, 4)
						minX:SetWide(40)
						minX:SetNumeric(true)
						minX:SetText(min.x)

						local minY = vgui.Create("DTextEntry", fram)
						minY:Dock(LEFT)
						minY:DockMargin(2, 4, 0, 4)
						minY:SetWide(40)
						minY:SetNumeric(true)
						minY:SetText(min.y)

						local minZ = vgui.Create("DTextEntry", fram)
						minZ:Dock(LEFT)
						minZ:DockMargin(2, 4, 0, 4)
						minZ:SetWide(40)
						minZ:SetNumeric(true)
						minZ:SetText(min.z)


						local maxLabel = vgui.Create("DLabel", fram)
						maxLabel:Dock(LEFT)
						maxLabel:DockMargin(10, 5, 0, 5)
						maxLabel:SetText("Max :")
						maxLabel:SetWide(28)
						maxLabel:SetTextColor(Color(50, 50, 50))

						local maxX = vgui.Create("DTextEntry", fram)
						maxX:Dock(LEFT)
						maxX:DockMargin(2, 4, 0, 4)
						maxX:SetWide(40)
						maxX:SetNumeric(true)
						maxX:SetText(max.x)

						local maxY = vgui.Create("DTextEntry", fram)
						maxY:Dock(LEFT)
						maxY:DockMargin(2, 4, 0, 4)
						maxY:SetWide(40)
						maxY:SetNumeric(true)
						maxY:SetText(max.y)

						local maxZ = vgui.Create("DTextEntry", fram)
						maxZ:Dock(LEFT)
						maxZ:DockMargin(2, 4, 0, 4)
						maxZ:SetWide(40)
						maxZ:SetNumeric(true)
						maxZ:SetText(max.z)

						local btnRemove = vgui.Create("DImageButton", fram)
						btnRemove:Dock(RIGHT)
						btnRemove:DockMargin(0, 4, 4, 4)
						btnRemove:SetWide(16)
						btnRemove:SetIcon("icon16/delete.png")

						function btnRemove:DoClick()
							net.Start("am_spawn_remove")
								net.WriteInt(fram.spawnId, 16)
							net.SendToServer()
						end

						local btnSave = vgui.Create("DImageButton", fram)
						btnSave:Dock(RIGHT)
						btnSave:DockMargin(0, 4, 4, 4)
						btnSave:SetWide(16)
						btnSave:SetIcon("icon16/disk.png")

						function btnSave:DoClick()
							net.Start("am_spawn_save")
								net.WriteInt(fram.spawnId, 16)
								net.WriteVector(Vector(minX:GetValue(), minY:GetValue(), minZ:GetValue()))
								net.WriteVector(Vector(maxX:GetValue(), maxY:GetValue(), maxZ:GetValue()))
							net.SendToServer()
						end

						local btnView = vgui.Create("DImageButton", fram)
						btnView:Dock(RIGHT)
						btnView:DockMargin(0, 4, 4, 4)
						btnView:SetWide(16)
						btnView:SetIcon("icon16/magnifier.png")

						function btnView:DoClick()
							if AMMenu.DisplaySpawn == fram.spawnId then
								AMMenu.DisplaySpawn = nil
							else
								AMMenu.DisplaySpawn = fram.spawnId
							end
						end

						local btnTeleport = vgui.Create("DImageButton", fram)
						btnTeleport:Dock(RIGHT)
						btnTeleport:DockMargin(0, 4, 4, 4)
						btnTeleport:SetWide(16)
						btnTeleport:SetIcon("icon16/lightning_go.png")

						function btnTeleport:DoClick()
							net.Start("am_spawn_teleport")
								net.WriteInt(fram.spawnId, 16)
							net.SendToServer()
						end

						return fram
					end

					for _, info in pairs(settings.AdminInfo.Spawns) do
						list:AddSpawn(info.id, info.min, info.max)
					end
				end)


				optionList:addOption("Settings", function(pnl)

				end)

				optionList:showMenu(1)
			end)
		end

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
		AMMenu.Display(net.ReadTable())
	end)

	net.Receive("am_spawn_update", function()
		local list = AMMenu.SpawnList
		local spawns = net.ReadTable()

		AMMenu.Settings.AdminInfo.Spawns = spawns

		if not list then return end

		list:Clear()

		for _, info in pairs(spawns) do
			list:AddSpawn(info.id, info.min, info.max)
		end
	end)


	hook.Add("PostDrawTranslucentRenderables", "Airboat_SpawnVisualisation", function()
		if AMMenu.DisplaySpawn then
			for _, spawn in pairs(AMMenu.Settings.AdminInfo.Spawns) do
				if spawn.id == AMMenu.DisplaySpawn then
					local pos = (spawn.min + spawn.max)/2
					render.DrawWireframeBox( pos, Angle(0, 0, 0), spawn.min - pos, spawn.max - pos, Color(0, 255, 0), true )
					break
				end
			end
		end
	end)
end
