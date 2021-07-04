local mod = {}

mod.Name = "cage"
mod.FullName = "Cage"
mod.Type = "skin"

function mod:OnMount()
    self:MountHolo("models/props_wasteland/exterior_fence002a.mdl", Vector(0, -20, 60), Angle(90, 90, 0), 1)
    self:MountHolo("models/props_wasteland/interior_fence002a.mdl", Vector(18, -20, 35), Angle(0, 180, 90), 1)
    self:MountHolo("models/props_wasteland/interior_fence002a.mdl", Vector(-18, -20, 35), Angle(0, -180, 90), 1)
end

function mod:OnUnmount()
end

function mod.Draw(info, w, y)
end

function mod:Run()
end

AMMods.Register(mod)