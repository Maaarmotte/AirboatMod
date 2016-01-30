for _,ply in ipairs(player.GetAll()) do
	ply.AMPlayer = nil
end

hook.Remove('Tick', 'Airboat')