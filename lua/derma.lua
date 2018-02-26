AMMenu = {}
if SERVER then
	util.AddNetworkString("am_show_menu")
	util.AddNetworkString("am_start_playing")

	function AMMenu.SendMenu(amPlayer, amBoat)
		if amBoat then
			net.Start("am_show_menu")
				local active = {}
				for k,v in pairs(amBoat.Mods) do
					active[k] = v.Name
				end
				net.WriteTable(active)
				net.WriteTable(amPlayer.Mods)
			net.Send(amPlayer:GetEntity())
		end
	end



	net.Receive("am_start_playing", function(_, ply)
		local amPlayer = ply.AMPlayer
		if not amPlayer then return end

		local settings = net.ReadTable()

		for key, mod in pairs(settings.Mods) do
			if not AMMods.Mods[mod] then
				amPlayer:UnmountMod(key)
			else
				amPlayer:MountMod(mod)
			end
		end

		amPlayer:Spawn()
	end)
else
	AMMenu.SX = 600
	AMMenu.SY = 300
	AMMenu.MainFrame = nil
	
	AMMenu.Settings = {}
	function AMMenu.Display(active, mods)
		AMMenu.Settings.Mods = active

		if not mods then
			print("[AMBoat] No mods for this player !")
			return
		end
		
		AMMenu.MainFrame = vgui.Create("DFrame")
		AMMenu.MainFrame:SetPos(ScrW()/2 - AMMenu.SX/2, ScrH()/2 - AMMenu.SY/2)
		AMMenu.MainFrame:SetSize(AMMenu.SX, AMMenu.SY)
		AMMenu.MainFrame:SetTitle("Airboat customization")
		AMMenu.MainFrame:SetDraggable(true)
		AMMenu.MainFrame:MakePopup()
		AMMenu.MainFrame.Paint = function()
			surface.SetDrawColor( 50, 50, 50, 200 )
			surface.DrawRect( 0, 0, AMMenu.MainFrame:GetWide(), AMMenu.MainFrame:GetTall() )
			surface.SetDrawColor( 255, 255, 255, 200 )
			surface.DrawOutlinedRect( 0, 0, AMMenu.MainFrame:GetWide(), AMMenu.MainFrame:GetTall() )
		end
		
		local modelFrame = vgui.Create("DModelPanel", AMMenu.MainFrame)
		modelFrame:SetSize(2*AMMenu.SX/3 - 15, AMMenu.SY - 25)
		modelFrame:SetPos(AMMenu.SX/3, 25)
		modelFrame:SetModel("models/airboat.mdl")
		modelFrame:SetCamPos(Vector(-185, -185, 50))
		modelFrame:SetFOV(45)
		
		local shiftButton = vgui.Create("DButton", AMMenu.MainFrame)
		if active.shift then shiftButton:SetText("[Shift]: " .. AMMods.Mods[active.shift].FullName)
		else shiftButton:SetText("[Shift]: None") end
		shiftButton:SetPos(AMMenu.SX*0.025, AMMenu.SY*0.05 + 25)
		shiftButton:SetSize(AMMenu.SX*0.25, AMMenu.SY*0.15)
		shiftButton.DoClick = function()
			local submenu = DermaMenu()
			for _, mod in ipairs(mods) do
				if AMMods.Mods[mod].Type == "shift" then
					submenu:AddOption(AMMods.Mods[mod].FullName, function()
						active.shift = mod
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
		
		local spaceButton = vgui.Create("DButton", AMMenu.MainFrame)
		if active.space then spaceButton:SetText("[Space]: " .. AMMods.Mods[active.space].FullName)
		else spaceButton:SetText("[Space]: None") end
		spaceButton:SetPos(AMMenu.SX*0.025, AMMenu.SY*0.05*5 + 25)
		spaceButton:SetSize(AMMenu.SX*0.25, AMMenu.SY*0.15)
		spaceButton.DoClick = function()
			local submenu = DermaMenu()
			for _, mod in ipairs(mods) do
				if AMMods.Mods[mod].Type == "space" then
					submenu:AddOption(AMMods.Mods[mod].FullName, function()
						active.space = mod
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
		
		local weaponButton = vgui.Create("DButton", AMMenu.MainFrame)
		if active.mouse1 then weaponButton:SetText("[Mouse1]: " .. AMMods.Mods[active.mouse1].FullName)
		else weaponButton:SetText("[Mouse1]: None") end
		weaponButton:SetPos(AMMenu.SX*0.025, AMMenu.SY*0.05*9 + 25)
		weaponButton:SetSize(AMMenu.SX*0.25, AMMenu.SY*0.15)
		weaponButton.DoClick = function()
			local submenu = DermaMenu()
			for _, mod in ipairs(mods) do
				if AMMods.Mods[mod].Type == "mouse1" then
					submenu:AddOption(AMMods.Mods[mod].FullName, function()
						active.mouse1 = mod
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
		
		local playButton = vgui.Create("DButton", AMMenu.MainFrame)
		playButton:SetPos(AMMenu.SX*0.025, AMMenu.SY*0.05*14 + 25)
		playButton:SetText("Play !")
		playButton:SetSize(AMMenu.SX*0.25, AMMenu.SY*0.15)
		playButton.DoClick = function()
			AMMenu.MainFrame:Close()

			net.Start("am_start_playing")
				net.WriteTable(AMMenu.Settings)
			net.SendToServer()
		end
	end
		end
	end
	
	net.Receive("am_show_menu", function(len) 
		AMMenu.Display(net.ReadTable(), net.ReadTable())
	end)
end

