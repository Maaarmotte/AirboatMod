local mod = {}

mod.Name = "bathroom"
mod.FullName = "Bathroom"
mod.Type = "skin"

function mod:OnMount()
    self:MountHolo("models/props_interiors/BathTub01a.mdl", Vector(7, 12, 20), Angle(0, 90, 0), Vector(1, 1, 1.2))
    self:MountHolo("models/props_c17/FurnitureSink001a.mdl", Vector(27, -40, 35), Angle(0, 0, 0), Vector(1, 1, 1))
    self:MountHolo("models/props_lab/desklamp01.mdl", Vector(0, -17, 80), Angle(0, 90, 0), Vector(1, 1, 1))
    self:MountHolo("models/props_pipes/pipe03_lcurve01_long.mdl", Vector(0, -24, 37), Angle(0, 180, 90), Vector(0.5, 0.5, 0.5))
    self:MountHolo("models/props_pipes/pipe02_tjoint01.mdl", Vector(0, -40, 30), Angle(0, 0, 180), Vector(1.2, 1.2, 1.2))
    self:MountHolo("models/props_pipes/valve003.mdl", Vector(-10, -40, 30), Angle(-90, 0, 0), Vector(2, 2, 2))
end

function mod:OnUnmount()
end

function mod.Draw(info, w, y)
end

function mod:Run()
end

AMMods.Register(mod)