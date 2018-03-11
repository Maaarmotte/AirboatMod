AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName     	= "Pumpkin"
ENT.Author        	= "Sir Taupe"
ENT.Contact       	= "NO!"
ENT.Purpose       	= ""
ENT.Instructions  	= ""
ENT.Spawnable     	= true
ENT.AdminSpawnable	= true
ENT.RenderGroup   	= RENDERGROUP_TRANSLUCENT

if SERVER then
	function ENT:Initialize()
		self:SetModel( "models/harvest/pumpkin/pumpkin_small.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetNoDraw(false)
		self:SetRenderMode(RENDERGROUP_TRANSLUCENT)
		self:SetPos(self:LocalToWorld(Vector(0,0,10)))

		local phys = self:GetPhysicsObject()
		phys:SetBuoyancyRatio(0.05)
		phys:SetMass(1000)

		if (phys:IsValid()) then
			phys:Wake()
		end
		
		sound.Play(Sound("garrysmod/balloon_pop_cute.wav"), self:GetPos(), 75)
		timer.Simple(4, function() if self:IsValid() then self:Remove() end end)
	end
	
	function ENT:Backflip(amBoat)
		local physObj = amBoat:GetPhysicsObject()
        local up = amBoat:GetUp()*1
        local pitch = amBoat:GetForward()*3000000
 
        physObj:ApplyForceOffset(up, pitch)
        physObj:ApplyForceOffset(up*-1, pitch*-1)
        amBoat:EmitSound("misc/banana_slip.wav")
	end
	
	function ENT:PhysicsCollide(colData, physobj)
		local ent = colData.HitEntity

		if ent.AMBoat and ent.AMBoat:IsPlaying() then
			local delay = 0.1
			local repetitions = 4
			
			timer.Create("amboat_backflip_start_"..math.random(0, 1000) , delay, repetitions, function()
				self:Backflip(ent)
			end)
			
			self:SetNotSolid(true)
			self:SetNoDraw(true)
			
			timer.Simple(delay*repetitions+1, function() self:Remove() end)
			--warning from console : Changing collision rules within a callback is likely to cause crashes!
		end
	end
else
	function ENT:Draw()
		self:DrawModel()
	end
end