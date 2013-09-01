--[[
	 _______ _            _    _                           
	|__   __| |          | |  | |                          
	   | |  | |__   ___  | |  | |_ __  ___  ___  ___ _ __  
	   | |  | '_ \ / _ \ | |  | | '_ \/ __|/ _ \/ _ \ '_ \ 
	   | |  | | | |  __/ | |__| | | | \__ \  __/  __/ | | |
	   |_|  |_| |_|\___|  \____/|_| |_|___/\___|\___|_| |_|                                                   
	Round System 		 						 ServerSide                                                                                                
]]--

util.AddNetworkString("THEUNSEEN_RoundChange")

function GM:SetRoundNumber(num)
	SetGlobalInt("THEUNSEEN_RoundNumber", num)
end

local function UpdateRoundInfo(winner)
	local state = GAMEMODE:GetRoundState()
	
	net.Start("THEUNSEEN_RoundChange")
	net.WriteUInt(state, 3)

	if (winner and state == ROUND_STATE_END) then
		net.WriteUInt(winner, 2)
	end
	net.Broadcast()
end

local function CanRoundStart()
	return ((team.NumPlayers(TEAM_UNS) + team.NumPlayers(TEAM_IRIS)) >= 2)
end

hook.Add("Tick", "THEUNSEEN_Round_Tick", function()
	local state = GAMEMODE:GetRoundState()
	
	if (state == ROUND_STATE_PREGAME) then
		if (CanRoundStart() and GAMEMODE.LastRoundChange + 3 <= CurTime()) then
			GAMEMODE:SetRoundState(ROUND_STATE_START)
		end
	elseif (state == ROUND_STATE_START) then
		if (CanRoundStart() and GAMEMODE.LastRoundChange + 4 <= CurTime()) then
			GAMEMODE:SetRoundState(ROUND_STATE_INPROGRESS)
		end
	elseif (state == ROUND_STATE_INPROGRESS) then
		local IrisAlive = util.GetLivingPlayers(TEAM_IRIS)
		local UnseenAlive = util.GetLivingPlayers(TEAM_UNS)
		
		if (IrisAlive < 1) then
			GAMEMODE.WinningTeam = TEAM_UNS
			GAMEMODE:SetRoundState(ROUND_STATE_END)
		elseif (UnseenAlive < 1) then
			GAMEMODE.WinningTeam = TEAM_IRIS
			GAMEMODE:SetRoundState(ROUND_STATE_END)
		elseif (GAMEMODE.LastRoundChange + 600 <= CurTime()) then
			GAMEMODE.WinningTeam = 0
			GAMEMODE:SetRoundState(ROUND_STATE_END)
		end
	elseif (state == ROUND_STATE_END) then
		if (GAMEMODE.LastRoundChange + 10 <= CurTime()) then
			if (GAMEMODE:GetRoundNumber() >= 6) then
				GAMEMODE:SetRoundState(ROUND_STATE_ENDGAME)
			else
				GAMEMODE:SetRoundState(ROUND_STATE_START)
			end
		end
	end
end)

hook.Add("RoundStart", "THEUNSEEN_Round_Start", function()
	UpdateRoundInfo()
	GAMEMODE:SetRoundNumber(GAMEMODE:GetRoundNumber() + 1)
end)

hook.Add("RoundInProgress", "THEUNSEEN_Round_InProgress", function()
	UpdateRoundInfo()
	for k, v in pairs( player.GetAll() ) do
		v:KillSilent()
		v:UnSpectate()
		v:Spawn()
	end
end)

hook.Add("RoundEnd", "THEUNSEEN_Round_End", function()
	UpdateRoundInfo(GAMEMODE.WinningTeam)
end)

hook.Add("RoundEndGame", "THEUNSEEN_Round_EndGame", function()
	UpdateRoundInfo()
	MapVote.Start(nil, nil, nil, nil)
end)