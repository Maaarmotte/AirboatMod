local mod = {}

mod.Name = "boost"
mod.FullName = "Standard Boost"
mod.Delay = 5
mod.Type = "shift"

local function makeHolo(model)
	local ent = ents.Create("prop_physics")
	ent:SetModel(model)
	ent:SetMoveType(MOVETYPE_NONE)
	ent:PhysicsInit(SOLID_NONE)
	ent:Spawn()
	ent:Activate()
	return ent
end

function mod:Mount(amBoat)
	print("[AM] Mounting mod: " .. mod.Name)

	local boat = amBoat:GetEntity()

	self.Entities = {}
	if IsValid(boat) then
		local ent = makeHolo("models/xqm/jetengine.mdl")
		ent:SetPos(boat:LocalToWorld(Vector(35, -30, 50)))
		ent:SetAngles(boat:LocalToWorldAngles(Angle(0, 90, 0)))
		ent:SetModelScale(0.8, 0)
		ent:SetParent(boat)
		table.insert(self.Entities, ent)

		ent = makeHolo("models/xqm/jetengine.mdl")
		ent:SetPos(boat:LocalToWorld(Vector(-35, -30, 50)))
		ent:SetAngles(boat:LocalToWorldAngles(Angle(0, 90, 0)))
		ent:SetModelScale(0.8, 0)
		ent:SetParent(boat)
		table.insert(self.Entities, ent)

		ent = makeHolo("models/props_trainstation/mount_connection001a.mdl")
		ent:SetPos(boat:LocalToWorld(Vector(25, -40, 40)))
		ent:SetAngles(boat:LocalToWorldAngles(Angle(0, 0, 0)))
		ent:SetModelScale(0.5, 0)
		ent:SetMaterial("models/props_canal/metalwall005b")
		ent:SetParent(boat)
		table.insert(self.Entities, ent)

		ent = makeHolo("models/props_trainstation/mount_connection001a.mdl")
		ent:SetPos(boat:LocalToWorld(Vector(-25, -40, 40)))
		ent:SetAngles(boat:LocalToWorldAngles(Angle(0, -180, 0)))
		ent:SetModelScale(0.5, 0)
		ent:SetMaterial("models/props_canal/metalwall005b")
		ent:SetParent(boat)
		table.insert(self.Entities, ent)
	end
end

function mod:Unmount(amBoat)
	for _,v in ipairs(self.Entities) do
		if IsValid(v) then
			v:Remove()
		end
	end
	self.Entities = {}
end

function mod:Run(amPly, amBoat)
	local boat = amBoat:GetEntity()
	local physobj = boat:GetPhysicsObject()
    physobj:SetVelocity(boat:GetVelocity() + boat:GetForward()*1000)
    boat:EmitSound("weapons/bumper_car_speed_boost_start.wav")
    ParticleEffectAttach("smoke_whitebillow", PATTACH_ABSORIGIN_FOLLOW, amBoat:GetSmokeEntity(), 0)
    timer.Simple(1, function()
        amBoat:GetSmokeEntity():StopParticles()
    end)
end

AMMods.Register(mod)