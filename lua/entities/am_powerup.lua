AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName     	= "Power Up"
ENT.Author        	= "Sir Papate"
ENT.Contact       	= "NO!"
ENT.Purpose       	= ""
ENT.Instructions  	= ""
ENT.Spawnable     	= true
ENT.AdminSpawnable	= true
ENT.RenderGroup   	= RENDERGROUP_TRANSLUCENT

if SERVER then
	function ENT:Initialize()
		self:SetMaterial("models/player/shared/gold_player")
		self:SetModel( "models/props_lakeside/wood_crate_01.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )    
		self:SetMoveType( MOVETYPE_VPHYSICS )  
		self:SetSolid( SOLID_VPHYSICS )        

		self:SetRenderMode(RENDERGROUP_TRANSLUCENT)
		self:SetColor(Color(255,255,255,150))

		local phys = self:GetPhysicsObject()
		phys:SetBuoyancyRatio(0.05)

		if (phys:IsValid()) then
			phys:Wake()
		end

		e = ents.Create("prop_physics")
		e:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
		e:Spawn()
		e:SetRenderMode(RENDERMODE_TRANSALPHA)
		e:SetNotSolid(true)
		e:SetMoveType(MOVETYPE_NONE)
		e:DrawShadow(false)
		e:SetNoDraw(true)

		self.effect = e
		self:InitPowerUp()
	end

	function ENT:InitPowerUp()
		self.powerup = AMPowerUps.GetRandom()

		if not self.powerup then 
			timer.Simple(10, function() 
				if self then
					self:InitPowerUp()
				end 
			end)
			return 
		end

		self.effect:SetNoDraw(false)
		self.effect:SetModel(self.powerup.Model)
		e:SetModelScale(self.powerup.ModelScale, 0)
		
		sound.Play(Sound("garrysmod/balloon_pop_cute.wav"), self:GetPos(), 75)
	end

	function ENT:TakePowerUp(amBoad)

	end


	function ENT:Think()
		local phys = self:GetPhysicsObject()
		phys:SetBuoyancyRatio(0.006)

		if self.powerup then
			self.effect:SetPos(self:LocalToWorld(Vector(0,0,50)) + self.powerup.ModelOffset)
			self.effect:SetAngles(Angle(0,CurTime()*60*2,0))

			self:NextThink(CurTime())
			return true
		end
	end

	function ENT:OnRemove()
		self.effect:Remove()
	end

	function ENT:PhysicsCollide(colData, physobj)
		local ent = colData.HitEntity

		if ent.AMBoat and ent.AMBoat:IsPlaying() then
			if self.powerup then
				local amBoad = ent.AMBoat

				if not amBoad.AMPowerUp then
					local cantake = hook.Call('AMPowerUp_Take', GM, amBoad) or true

					if cantake then
						amBoad.AMPowerUp = AMPowerUps.Instantiate(self.powerup.Name, amBoad)

						sound.Play(Sound("garrysmod/balloon_pop_cute.wav"), self:GetPos(), 75)
						self.powerup = nil
						self.effect:SetNoDraw(true)
						
						timer.Simple(10, function()
							if self then
								self:InitPowerUp()
							end
						end)
					end
				end
			end
		end
	end
else
	function ENT:Draw()
		self:DrawModel()
	end
end
