AMMenu = {}
if SERVER then
	util.AddNetworkString("am_show_menu")
	
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
else
	AMMenu.SX = 600
	AMMenu.SY = 300
	AMMenu.MainFrame = nil
	
	function AMMenu.Display(active, mods)
		PrintTable(mods)
		
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
		shiftButton:SetPos(AMMenu.SX*0.025, AMMenu.SY*0.05 + 25)
		shiftButton:SetText("[Shift]: " .. AMMods.Mods[active["shift"]].FullName)
		shiftButton:SetSize(AMMenu.SX*0.25, AMMenu.SY*0.15)
		shiftButton.DoClick = function()
			local submenu = DermaMenu()
			for _,v in ipairs(mods) do
				if AMMods.Mods[v].Type == "shift" then
					submenu:AddOption(AMMods.Mods[v].FullName, function()
						LocalPlayer():ConCommand("am_mod " .. v)
						shiftButton:SetText("[Shift]: " .. AMMods.Mods[v].FullName)
					end)
				end
			end
			submenu:Open()
		end
		
		local spaceButton = vgui.Create("DButton", AMMenu.MainFrame)
		spaceButton:SetPos(AMMenu.SX*0.025, AMMenu.SY*0.05*5 + 25)
		spaceButton:SetText("[Space]: " .. AMMods.Mods[active["space"]].FullName)
		spaceButton:SetSize(AMMenu.SX*0.25, AMMenu.SY*0.15)
		spaceButton.DoClick = function()
			local submenu = DermaMenu()
			for _,v in ipairs(mods) do
				if AMMods.Mods[v].Type == "space" then
					submenu:AddOption(AMMods.Mods[v].FullName, function()
						LocalPlayer():ConCommand("am_mod " .. v)
						spaceButton:SetText("[Space]: " .. AMMods.Mods[v].FullName)
					end)
				end
			end
			submenu:Open()
		end
		
		local weaponButton = vgui.Create("DButton", AMMenu.MainFrame)
		weaponButton:SetPos(AMMenu.SX*0.025, AMMenu.SY*0.05*9 + 25)
		weaponButton:SetText("[Mouse1]: None")
		weaponButton:SetSize(AMMenu.SX*0.25, AMMenu.SY*0.15)
		weaponButton.DoClick = function()
			
		end
		
		local playButton = vgui.Create("DButton", AMMenu.MainFrame)
		playButton:SetPos(AMMenu.SX*0.025, AMMenu.SY*0.05*14 + 25)
		playButton:SetText("Play !")
		playButton:SetSize(AMMenu.SX*0.25, AMMenu.SY*0.15)
		playButton.DoClick = function()
			LocalPlayer():ConCommand("am_play")
			AMMenu.MainFrame:Close()
		end
	end
	
	net.Receive("am_show_menu", function(len) 
		AMMenu.Display(net.ReadTable(), net.ReadTable())
	end)
end

