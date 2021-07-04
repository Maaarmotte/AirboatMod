
local mod = {}

mod.Name = "combine"
mod.FullName = "Combine"
mod.Type = "skin"

function mod:OnMount()
    self:MountHolo("models/Combine_Scanner.mdl", Vector(0, 40, 33), Angle(0, 90, 0), Vector(1, 1, 1))
    self:MountHolo("models/props_combine/breenconsole.mdl", Vector(0, 20, 20), Angle(0, 0, 0), Vector(0.8, 0.8, 0.6))
    self:MountHolo("models/props_combine/combine_intmonitor003.mdl", Vector(5, -40, 35), Angle(0, 0, 0), Vector(0.5, 0.5, 0.5))
    self:MountHolo("models/props_combine/combine_intwallunit.mdl", Vector(-15, -40, 45), Angle(0, 180, 0), Vector(1.5, 1, 1))
    self:MountHolo("models/props_combine/combine_bunker01.mdl", Vector(0, -50, 55), Angle(0, 0, 0), Vector(0.15, 0.15, 0.15))
    self:MountHolo("models/props_combine/combine_bunker_shield01b.mdl", Vector(0, -50, -2), Angle(0, 0, 0), Vector(0.15, 0.45, 0.5))
end

function mod:OnUnmount()
end

function mod.Draw(info, w, y)
end

function mod:Run()
end

AMMods.Register(mod)