local mod = {}

mod.Name      	= "powerup.strength"
mod.FullName  	= "Strength"
mod.Type 		= "powerup"
mod.BaseAmount	= 1
mod.Duration  	= 15
mod.ReloadTime	= 0

mod.Model      	= "models/pickups/pickup_powerup_strength.mdl"
mod.ModelScale 	= 1.6
mod.ModelOffset	= -Vector(0,0,36*mod.ModelScale)

function mod:Initialize()
end

function mod:OnMount()
end

function mod:OnUnmount()
end

function mod.Draw(info, w, y)
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
	surface.SetDrawColor(200, 31, 19, 255)
	surface.DrawRect(10, y + 20, bw * time, 20)

	return 40
end

function mod:Run()
	if self.isRuning then return end

	self.isRuning = true
	self.startTime = CurTime()

	self:SendInfoToClent({End=CurTime()+self.Duration})
end

function mod:Think()
	if self.isRuning and CurTime() - self.startTime > self.Duration then
		self.AMBoat:UnmountPowerUp()
	end
end

function mod:OnAttack(target, amount)
	if self.isRuning then
		return amount*2
	end
end

AMMods.Register(mod)
