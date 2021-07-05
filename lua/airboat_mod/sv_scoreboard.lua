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
        for i, p in ipairs(AMDatabase.Player.FindScoreboard(AMMain.GetAllPlayers())) do
            table.insert(scoreboard, {name=p.name, score=p.kills})
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


hook.Add("AirboatMod.PostPlayerSpawn", "AirboatMod.Scoreboard.PlayerSpawn", function()
    AMScoreboard.SendScoreboardUpdate()
end)

hook.Add("AirboatMod.PostPlayerLeave", "AirboatMod.Scoreboard.PlayerLeave", function()
    AMScoreboard.SendScoreboardUpdate()
end)

hook.Add("AirboatMod.PostPlayerDeath", "AirboatMod.Scoreboard.PlayerDeath", function()
    AMScoreboard.SendScoreboardUpdate()
end)