local mod = {}

mod.Name		= "powerup.pumpkin"
mod.FullName	= "Pumpkin"
mod.Type		= "powerup"
mod.BaseAmount	= 1
mod.Delay 		= 1

mod.Model		= "models/pickups/pickup_powerup_knockout.mdl"
mod.ModelScale	= 1.6
mod.ModelOffset	= -Vector(0,0,36*mod.ModelScale)

function mod:Mount(amBoat)
	self.Amount = self.BaseAmount
	self:SendInfoToClent(amBoat, {Amount = self.Amount})
end

function mod:Unmount(amBoat)
end

function mod.Draw(info, w, y, amBoat, amPlayer)
	local bw = (w - 20 - 10)/mod.BaseAmount

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

function mod:Run(amPly, amBoat)	
	local ent = amBoat:GetEntity()
	local pumpkin = ents.Create("am_pumpkin")
	
	pumpkin:SetPos(ent:GetPos() + ent:GetForward()*100)
	pumpkin:SetAngles(amBoat:GetEntity():GetAngles())

	self:SendInfoToClent(amBoat, {Amount = self.Amount})
	pumpkin:Spawn()
	pumpkin:GetPhysicsObject():SetVelocity(ent:GetVelocity() + ent:GetForward()*100000)
	ent:EmitSound("misc/halloween/spelltick_01.wav")
	
	amBoat:UnmountPowerUp()
end

AMMods.Register(mod)