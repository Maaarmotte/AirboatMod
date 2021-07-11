local mod = {}

mod.Name		= "powerup.banana"
mod.FullName	= "Banana"
mod.Type		= "powerup"
mod.BaseAmount	= 3
mod.Delay 		= 1
mod.Model		= "models/pickups/pickup_powerup_regen.mdl"
mod.ModelScale	= 1.6
mod.ModelOffset	= -Vector(0,0,36*mod.ModelScale)
mod.Damage		= 2

function mod:Initialize()
	self.Amount = self.BaseAmount
	self:SendInfoToClent({Amount = self.Amount})
end

function mod:OnMount()
end

function mod:OnUnmount()
end

function mod.Draw(info, w, y)
	local bw = (w - 15)/mod.BaseAmount - 5

	surface.SetFont("am_hud_title")
	surface.SetTextColor(235, 235, 235, 255)
	surface.SetTextPos(12, y)
	surface.DrawText("PowerUp: " .. mod.FullName)

	for i = 0, mod.BaseAmount - 1 do
		local x = 10 + bw*i + 5*i

		surface.SetDrawColor(75, 75, 75, 255)
		surface.DrawRect(x, y + 20, bw, 20)
	end

	for i = 0, info.Amount - 1 do
		local x = 10 + bw*i + 5*i

		surface.SetDrawColor(194, 162, 18, 255)
		surface.DrawRect(x, y + 20, bw, 20)
	end

	return 40
end

function mod:Run()
	local ent = self.AMBoat:GetEntity()
	local banana = ents.Create("am_banana")
	
	self.Amount = self.Amount - 1
	self:SendInfoToClent({Amount = self.Amount})

	banana:SetPos(ent:GetPos() - ent:GetForward()*130)
	banana:SetAngles(self.AMBoat:GetEntity():GetAngles())
	banana:SetDamageAmmount(mod.Damage)
	banana.SetBoatOwner(self.AMBoat)

	banana:Spawn()
	ent:EmitSound("misc/halloween/spelltick_01.wav")
	
	if self.Amount <= 0 then
		self.AMBoat:UnmountPowerUp()
	end
end

AMMods.Register(mod)
