--[[
	 _______ _            _    _                           
	|__   __| |          | |  | |                          
	   | |  | |__   ___  | |  | |_ __  ___  ___  ___ _ __  
	   | |  | '_ \ / _ \ | |  | | '_ \/ __|/ _ \/ _ \ '_ \ 
	   | |  | | | |  __/ | |__| | | | \__ \  __/  __/ | | |
	   |_|  |_| |_|\___|  \____/|_| |_|___/\___|\___|_| |_|
	Round System 								 ClientSide
]]--

net.Receive("THEUNSEEN_RoundChange", function()
	local state = net.ReadUInt(3)
	local winner = net.ReadUInt(2)
	
	if (winner) then
		GAMEMODE.WinningTeam = winner
	end
	
	GAMEMODE:SetRoundState(state)
end)