util.AddNetworkString("AirboatMod.Scoreboard.Update")

AMScoreboard = AMScoreboard or {}

function AMScoreboard.SendScoreboardUpdate(ply)		
	net.Start("AirboatMod.Scoreboard.Update")
		local leaderboard = {}
		for i, p in ipairs(AMDatabase.Player.FindLeaderboard()) do
			table.insert(leaderboard, {name=p.name, score=p.kills})	
		end
		net.WriteTable(leaderboard)
		
		local scoreboard = {}
		for _, ply in pairs(player.GetAll()) do
			local amPly = AMPlayer.GetPlayer(ply)
			
			if amPly and amPly:GetPlaying() then
				table.insert(scoreboard, {name=ply:Name(), score=amPly:GetSessionKills()})
			end
		end

		net.WriteTable(scoreboard)
	if ply and ply:IsValid() then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

hook.Add("PlayerInitialSpawn", "AirboatMod.Scoreboard.PlayerInitialSpawn", function(ply)
	AMScoreboard.SendScoreboardUpdate(ply)
end)

hook.Add("AirboatMod.PostPlayerSpawn", "AirboatMod.Scoreboard.PlayerSpawn", function(ply)
    AMScoreboard.SendScoreboardUpdate()
end)

hook.Add("AirboatMod.PostPlayerLeft", "AirboatMod.Scoreboard.PlayerLeave", function(ply)
    AMScoreboard.SendScoreboardUpdate()
end)

hook.Add("AirboatMod.PostPlayerKilled", "AirboatMod.Scoreboard.PlayerKilled", function(ply)
    AMScoreboard.SendScoreboardUpdate()
end)