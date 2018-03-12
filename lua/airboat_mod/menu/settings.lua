local MENU = {}
MENU.Title = "Admin"
MENU.Position = 100

if SERVER then
	function MENU:GetSettings(ply, info)
		info.IsAdmin = AMMain.IsPlayerAdmin(ply)

		if AMMain.IsPlayerAdmin(ply) then
			info.AdminInfo = {
				Spawns = AMSpawns
			}
		end
	end
else
	function MENU:CanSee()
		return AMMenu.Settings.IsAdmin
	end

	function MENU:Build(pnl)
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
	end
end

AMMenu.Register(MENU)
