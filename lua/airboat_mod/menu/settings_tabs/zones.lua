local TAB = {}


TAB.Name = "zones"
TAB.Title = "Spawn Zones"


if SERVER then

else
    function TAB:Build(parent)
        local btnsPanel = vgui.Create("DPanel", parent)
        btnsPanel:Dock(BOTTOM)
        btnsPanel:DockMargin(5, 5, 5, 5)
        btnsPanel:SetTall(30)

        function btnsPanel:Paint(w, h)
            -- surface.SetDrawColor(240, 240, 240, 255)
            -- surface.DrawRect(0, 0, w, h)
        end

        local list = vgui.Create("DScrollPanel", parent)
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
            self.MENU:Send("NewSpawn", function(spawn)
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
            self.MENU:Send("UpdateSpawn", function(spawns)
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

                self.MENU:Send("EnableSpawn", fram.spawnId, val, function(enable)
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
                self.MENU:Send("RemoveSpawn", fram.spawnId, function()
                    fram:Remove()
                end)
            end

            local btnSave = vgui.Create("DImageButton", fram)
            btnSave:Dock(RIGHT)
            btnSave:DockMargin(0, 4, 4, 4)
            btnSave:SetWide(16)
            btnSave:SetIcon("icon16/disk.png")

            function btnSave:DoClick()
                self.MENU:Send("EditSpawn", fram.spawnId, Vector(minX:GetValue(), minY:GetValue(), minZ:GetValue()), Vector(maxX:GetValue(), maxY:GetValue(), maxZ:GetValue()), function(min, max)
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
                self.MENU:Send("TeleportSpawn", fram.spawnId)
            end

            return fram
        end

        for _, spawn in pairs(settings.AdminInfo.Spawns) do
            list:AddSpawn(spawn)
        end
    end


end