--[[
   _______ _            _    _                           
  |__   __| |          | |  | |                          
     | |  | |__   ___  | |  | |_ __  ___  ___  ___ _ __  
     | |  | '_ \ / _ \ | |  | | '_ \/ __|/ _ \/ _ \ '_ \ 
     | |  | | | |  __/ | |__| | | | \__ \  __/  __/ | | |
     |_|  |_| |_|\___|  \____/|_| |_|___/\___|\___|_| |_|                                                   
  MapVote                                          Shared                                                                                                
]]--
MapVote = {}
MapVote.Config = {
    MapLimit = 24,
    TimeLimit = 28,
    AllowCurrentMap = false,
    RTVPlayerCount = 3,
    MapPrefixes = {"hdn_"}
    }

function MapVote.HasExtraVotePower(ply)
	-- Example that gives admins more voting power
	--[[
    if ply:IsAdmin() then
		return true
	end 
    ]]

	return false
end

--Ignore this stuff!
MapVote.CurrentMaps = {}
MapVote.Votes = {}

MapVote.Allow = false

MapVote.UPDATE_VOTE = 1
MapVote.UPDATE_WIN = 3