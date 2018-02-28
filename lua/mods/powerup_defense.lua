local mod = {}

mod.Name      	= "powerup.defense"
mod.FullName  	= "Defense"
mod.Type 		= "powerup"
mod.BaseAmount	= 1
mod.Duration  	= 15
mod.ReloadTime	= 0

mod.Model      	= "models/pickups/pickup_powerup_defense.mdl"
mod.ModelScale 	= 1.6
mod.ModelOffset	= -Vector(0,0,36*mod.ModelScale)

function mod.Draw(info, w, y, amBoat, amPlayer)
	surface.SetFont("am_hud_title")
	surface.SetTextColor(235, 235, 235, 255)
	surface.SetTextPos(12, y)
	surface.DrawText("PowerUp: " .. mod.FullName)

	local bw = w - 20
	local time = 1

	if info.End then
		time = ((info.End or 0) - CurTime())/mod.Duration
	end

	surface.SetDrawColor(75, 75, 75, 255)
	surface.DrawRect(10, y + 20, bw, 20)
	surface.SetDrawColor(19, 62, 200, 255)
	surface.DrawRect(10, y + 20, bw * time, 20)

	return 40
end

function mod:Mount(amBoat)
end

function mod:Unmount(amBoat)
	local boat = amBoat:GetEntity()
	boat:SetMaterial(self.oldmat)
end

function mod:Run(amPly, amBoat)
	if self.isRuning then return end

	local boat	= amBoat:GetEntity()
	self.oldmat = boat:GetMaterial()
	self.isRuning = true
	self.startTime = CurTime()

	self:SendInfoToClent(amBoat, {End=CurTime()+self.Duration})

	boat:SetMaterial("debug/env_cubemap_model")
end

function mod:OnDamage(amBoat, attacker, amount)
	if self.isRuning then
		return amount/2
	end
end

function mod:Think(amBoat)
	if self.isRuning and CurTime() - self.startTime > self.Duration then
		amBoat:UnmountPowerUp()
	end
end

AMMods.Register(mod)
