AMUtils = {}

function AMUtils.AimPosClamp(ply, maxDist)
	local hitPos = ply:GetEyeTrace().HitPos
	local hitPosDist = (ply:GetShootPos() - hitPos):Length()
	
	if hitPosDist < maxDist then
		return hitPos
	else
		return ply:GetShootPos() + ply:GetAimVector()*maxDist
	end
end