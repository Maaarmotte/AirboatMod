AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName     	= "Banana"
ENT.Author        	= "Sir Taupe"
ENT.Contact       	= "NO!"
ENT.Purpose       	= ""
ENT.Instructions  	= ""
ENT.Spawnable     	= false
ENT.AdminSpawnable	= true
ENT.RenderGroup   	= RENDERGROUP_TRANSLUCENT

if SERVER then
	function ENT:Initialize()
		self:SetModel( "models/props_junk/wood_crate001a_damaged.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetNoDraw(true)

		self:SetPos(self:LocalToWorld(Vector(0,0,20)))

		local phys = self:GetPhysicsObject()
		phys:SetBuoyancyRatio(0.05)

		if (phys:IsValid()) then
			phys:Wake()
		end

		self.effect = ents.Create("prop_physics")
		self.effect:SetNoDraw(true)
		self.effect:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
		self.effect:SetRenderMode(RENDERMODE_TRANSALPHA)
		self.effect:SetNotSolid(true)
		self.effect:DrawShadow(false)

		self.effect:SetPos(self:LocalToWorld(Vector(0,0,-20)))
		self.effect:SetAngles(Angle(0,CurTime()*60*2,0))
		self.effect:SetModelScale(2.5, 0)
		self.effect:SetParent(self, -1)

		self.effect:Spawn()
		self.effect:SetNoDraw(false)
		self.effect:SetModel("models/props_farm/scenes/bananana_peel.mdl")

		sound.Play(Sound("garrysmod/balloon_pop_cute.wav"), self:GetPos(), 75)
	end

	function ENT:Spin(amBoat)
		local physObj = amBoat:GetPhysicsObject()
        local left = amBoat:GetRight()*-1
        local yaw = amBoat:GetForward()*8000000

        physObj:ApplyForceOffset(left, yaw)
        physObj:ApplyForceOffset(left*-1, yaw*-1)
        amBoat:EmitSound("misc/banana_slip.wav")
	end

	function ENT:PhysicsCollide(colData, physobj)
		local ent = colData.HitEntity

		if ent.AMBoat and ent.AMBoat:IsPlaying() then
			local delay = 0.1
			local repetitions = 8

			timer.Create("amboat_spin_start_"..math.random(0, 1000) , delay, repetitions, function()
				self:Spin(ent)
			end)

			self:SetNotSolid(true)
			self.effect:SetNoDraw(true)

			if self.DamageAmmount and self.DamageAmmount > 0 then
				ent.AMBoat:Damage(self.DamageAmmount, self.AMBoatOwner)
			end

			timer.Simple(delay*repetitions+1, function() self:Remove() end)
			--warning from console : Changing collision rules within a callback is likely to cause crashes!
		end
	end

	function ENT:OnRemove()
		self.effect:Remove()
	end

	function ENT:SetDamageAmmount(damage)
		self.DamageAmmount = damage
	end

	function ENT:SetBoatOwner(boat)
		self.AMBoatOwner = boat
	end
else
	function ENT:Draw()
		self:DrawModel()
	end
end
