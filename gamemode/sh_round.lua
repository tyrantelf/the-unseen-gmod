--[[
	 _______ _            _    _                           
	|__   __| |          | |  | |                          
	   | |  | |__   ___  | |  | |_ __  ___  ___  ___ _ __  
	   | |  | '_ \ / _ \ | |  | | '_ \/ __|/ _ \/ _ \ '_ \ 
	   | |  | | | |  __/ | |__| | | | \__ \  __/  __/ | | |
	   |_|  |_| |_|\___|  \____/|_| |_|___/\___|\___|_| |_|                                                   
	Round System 								 	 Shared                                                                                                
]]--

ROUND_STATE_PREGAME = 1 -- Before any players have started
ROUND_STATE_START = 2 -- Starting a new round
ROUND_STATE_INPROGRESS = 3 -- Round currently in progress
ROUND_STATE_END = 4 -- Round has ended
ROUND_STATE_ENDGAME = 5 -- The game has ended, start a vote?

GM.LastRoundChange = 0

function GM:SetRoundState(state)	
	self.RoundState = state
	self.LastRoundChange = CurTime()
	
	if (state == ROUND_STATE_PREGRAME) then
		hook.Call("RoundPreGame", self)
	elseif (state == ROUND_STATE_START) then
		hook.Call("RoundStart", self)
	elseif (state == ROUND_STATE_INPROGRESS) then
		hook.Call("RoundInProgress", self)
	elseif (state == ROUND_STATE_END) then
		hook.Call("RoundEnd", self, self.WinningTeam or 0)
	elseif (state == ROUND_STATE_ENDGAME) then
		hook.Call("RoundEndGame", self)
	end
end

function GM:GetRoundState()
	return self.RoundState or ROUND_STATE_PREGAME
end

function GM:GetRoundNumber()
	return GetGlobalInt("THEUNSEEN_RoundNumber", 0)
end