--[[
   _______ _            _    _                           
  |__   __| |          | |  | |                          
     | |  | |__   ___  | |  | |_ __  ___  ___  ___ _ __  
     | |  | '_ \ / _ \ | |  | | '_ \/ __|/ _ \/ _ \ '_ \ 
     | |  | | | |  __/ | |__| | | | \__ \  __/  __/ | | |
     |_|  |_| |_|\___|  \____/|_| |_|___/\___|\___|_| |_|                                                   
  Main                                             Shared                                                                                                
]]--
GM.Name 	= "The Unseen"
GM.Author 	= "Willox & Tyrantelf"
GM.Email 	= "Tyrantelf@iongaming.org"
GM.Website 	= "http://iongaming.org/"

TEAM_UNS = 1
TEAM_IRIS = 2

team.SetUp(TEAM_UNS, "The Unseen", Color(255, 0, 0, 255))
team.SetUp(TEAM_IRIS, "I.R.I.S", Color(0, 0, 255, 255))

team.SetSpawnPoint( TEAM_UNS, {"info_hidden_spawn"} )
team.SetSpawnPoint( TEAM_IRIS, {"info_marine_spawn"} )