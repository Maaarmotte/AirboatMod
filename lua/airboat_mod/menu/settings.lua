local MENU = {}

MENU.Name = "admin"
MENU.Title = "Admin"
MENU.Position = 100

if SERVER then
	MENU.Receive = {}

	function MENU:GetSettings(ply, info)
		info.IsAdmin = AMMain.IsPlayerAdmin(ply)

		if AMMain.IsPlayerAdmin(ply) then
			info.AdminInfo = {
				Spawns = AMSpawns
			}
		end
	end

	function MENU.Receive:EditSpawn(ply, id, v1, v2, callback)
		if not AMMain.IsPlayerAdmin(ply) then
			AMMenu.SendSpawnsInfo(ply)
			return
		end

		v1 = Vector(math.Clamp(v1.x, -16384, 16384), math.Clamp(v1.y, -16384, 16384), math.Clamp(v1.z, -16384, 16384))
		v2 = Vector(math.Clamp(v2.x, -16384, 16384), math.Clamp(v2.y, -16384, 16384), math.Clamp(v2.z, -16384, 16384))
		local min = Vector(math.min(v1.x, v2.x), math.min(v1.y, v2.y), math.min(v1.z, v2.z))
		local max = Vector(math.max(v1.x, v2.x), math.max(v1.y, v2.y), math.max(v1.z, v2.z))


		AMSpawn.Edit(id, min, max)

		callback(min, max)
	end

	function MENU.Receive:EnableSpawn(ply, id, enable, callback)
		if not AMMain.IsPlayerAdmin(ply) then
			AMMenu.SendSpawnsInfo(ply)
			return
		end

		AMSpawn.Enable(id, enable)

		callback(enable)
	end

	function MENU.Receive:RemoveSpawn(ply, id, callback)
		if not AMMain.IsPlayerAdmin(ply) then
			AMMenu.SendSpawnsInfo(ply)
			return
		end

		AMSpawn.Remove(id)

		callback()
	end

	function MENU.Receive:NewSpawn(ply, callback)
		if not AMMain.IsPlayerAdmin(ply) then
			AMMenu.SendSpawnsInfo(ply)
			return
		end

		local spawn = AMSpawn.New(Vector(0,0,0), Vector(0,0,0))

		callback(spawn)
	end

	function MENU.Receive:UpdateSpawn(ply, callback)
		if not AMMain.IsPlayerAdmin(ply) then
			AMMenu.SendSpawnsInfo(ply)
			return
		end

		callback(AMSpawns)
	end

	function MENU.Receive:TeleportSpawn(ply, id)
		if not AMMain.IsPlayerAdmin(ply) then
			AMMenu.SendSpawnsInfo(ply)
			return
		end

		local spawn = AMSpawn.GetByID(id)

		ply:SetPos((spawn.min + spawn.max)/2)
	end
else
	function MENU:CanSee()
		return AMMenu.Settings.IsAdmin
	end

	function MENU:Build(pnl)
		local settings = AMMenu.Settings

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
			button.Paint = AMMenu.StyleButtonBorder
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

			local list = vgui.Create("DScrollPanel", pnl)
			list:Dock(FILL)
			list:DockMargin(5, 5, 5, 0)
			AMMenu.SpawnList = list

			function list:Paint(w, h)
				surface.SetDrawColor(240, 240, 240, 255)
				surface.DrawRect(0, 0, w, h)
			end


			local btnAdd = vgui.Create("DButton", btnsPanel)
			btnAdd:Dock(RIGHT)
			btnAdd:SetText("New spawn")
			btnAdd:DockMargin(5, 0, 0 ,0)
			btnAdd:SetWide(150)
			btnAdd:SetFont("AM_Title")
			btnAdd.Paint = AMMenu.StyleButtonLight

			function btnAdd:DoClick()
				MENU:Send("NewSpawn", function(spawn)
					if istable(spawn) and spawn.id then
						list:AddSpawn(spawn)
					end
				end)
			end

			local btnRefresh = vgui.Create("DButton", btnsPanel)
			btnRefresh:Dock(RIGHT)
			btnRefresh:SetText("Refresh")
			btnRefresh:DockMargin(5, 0, 0 ,0)
			btnRefresh:SetWide(150)
			btnRefresh:SetFont("AM_Title")
			btnRefresh.Paint = AMMenu.StyleButtonLight

			function btnRefresh:DoClick()
				MENU:Send("UpdateSpawn", function(spawns)
					settings.AdminInfo.Spawns = spawns
					list:Clear()

					for _, spawn in pairs(spawns) do
						list:AddSpawn(spawn)
					end
				end)
			end

			function list:AddSpawn(spawn)
				local fram = list:Add("DPanel")
				fram:Dock(TOP)
				fram:DockMargin(3, 3, 3, 0)
				fram:SetTall(24)
				fram.spawnId = spawn.id

				function fram:Paint(w, h)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawRect(0, 0, w, h)
				end

				local activeCheck = vgui.Create("DCheckBox", fram)
				activeCheck:Dock(LEFT)
				activeCheck:DockMargin(5, 4, 0, 5)
				activeCheck:SetWide(15)
				activeCheck:SetChecked(spawn.enabled)

				function activeCheck:OnChange(val)
					self:SetChecked(not val)

					MENU:Send("EnableSpawn", fram.spawnId, val, function(enable)
						self:SetChecked(enable)
						spawn.enabled = enable
					end)
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
				minX:SetText(spawn.min.x)

				local minY = vgui.Create("DTextEntry", fram)
				minY:Dock(LEFT)
				minY:DockMargin(2, 4, 0, 4)
				minY:SetWide(40)
				minY:SetNumeric(true)
				minY:SetText(spawn.min.y)

				local minZ = vgui.Create("DTextEntry", fram)
				minZ:Dock(LEFT)
				minZ:DockMargin(2, 4, 0, 4)
				minZ:SetWide(40)
				minZ:SetNumeric(true)
				minZ:SetText(spawn.min.z)


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
				maxX:SetText(spawn.max.x)

				local maxY = vgui.Create("DTextEntry", fram)
				maxY:Dock(LEFT)
				maxY:DockMargin(2, 4, 0, 4)
				maxY:SetWide(40)
				maxY:SetNumeric(true)
				maxY:SetText(spawn.max.y)

				local maxZ = vgui.Create("DTextEntry", fram)
				maxZ:Dock(LEFT)
				maxZ:DockMargin(2, 4, 0, 4)
				maxZ:SetWide(40)
				maxZ:SetNumeric(true)
				maxZ:SetText(spawn.max.z)

				local btnRemove = vgui.Create("DImageButton", fram)
				btnRemove:Dock(RIGHT)
				btnRemove:DockMargin(0, 4, 4, 4)
				btnRemove:SetWide(16)
				btnRemove:SetIcon("icon16/delete.png")

				function btnRemove:DoClick()
					MENU:Send("RemoveSpawn", fram.spawnId, function()
						fram:Remove()
					end)
				end

				local btnSave = vgui.Create("DImageButton", fram)
				btnSave:Dock(RIGHT)
				btnSave:DockMargin(0, 4, 4, 4)
				btnSave:SetWide(16)
				btnSave:SetIcon("icon16/disk.png")

				function btnSave:DoClick()
					MENU:Send("EditSpawn", fram.spawnId, Vector(minX:GetValue(), minY:GetValue(), minZ:GetValue()), Vector(maxX:GetValue(), maxY:GetValue(), maxZ:GetValue()), function(min, max)
						minX:SetText(min.x) minY:SetText(min.y) minZ:SetText(min.z)
						maxX:SetText(max.x) maxY:SetText(max.y) maxZ:SetText(max.z)
						spawn.min = min
						spawn.max = max
					end)
				end

				local btnView = vgui.Create("DImageButton", fram)
				btnView:Dock(RIGHT)
				btnView:DockMargin(0, 4, 4, 4)
				btnView:SetWide(16)
				btnView:SetIcon("icon16/magnifier.png")

				function btnView:DoClick()
					if MENU.DisplaySpawn == fram.spawnId then
						MENU.DisplaySpawn = nil
					else
						MENU.DisplaySpawn = fram.spawnId
					end
				end

				local btnTeleport = vgui.Create("DImageButton", fram)
				btnTeleport:Dock(RIGHT)
				btnTeleport:DockMargin(0, 4, 4, 4)
				btnTeleport:SetWide(16)
				btnTeleport:SetIcon("icon16/lightning_go.png")

				function btnTeleport:DoClick()
					MENU:Send("TeleportSpawn", fram.spawnId)
				end

				return fram
			end

			for _, spawn in pairs(settings.AdminInfo.Spawns) do
				list:AddSpawn(spawn)
			end
		end)


		optionList:addOption("Settings", function(pnl)

		end)

		optionList:showMenu(1)
	end

	hook.Add("PostDrawTranslucentRenderables", "AirboatMod.SpawnView", function()
		if MENU.DisplaySpawn and AMMenu.Settings.AdminInfo then
			for _, spawn in pairs(AMMenu.Settings.AdminInfo.Spawns) do
				if spawn.id == MENU.DisplaySpawn then
					local color = Color(0, 255, 0)

					if not spawn.enabled then
						color = Color(255, 0, 0)
					end

					local pos = (spawn.min + spawn.max)/2
					render.DrawWireframeBox( pos, Angle(0, 0, 0), spawn.min - pos, spawn.max - pos, color, true )
					break
				end
			end
		end
	end)
end

AMMenu.Register(MENU)
