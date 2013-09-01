--[[
   _______ _            _    _                           
  |__   __| |          | |  | |                          
     | |  | |__   ___  | |  | |_ __  ___  ___  ___ _ __  
     | |  | '_ \ / _ \ | |  | | '_ \/ __|/ _ \/ _ \ '_ \ 
     | |  | | | |  __/ | |__| | | | \__ \  __/  __/ | | |
     |_|  |_| |_|\___|  \____/|_| |_|___/\___|\___|_| |_|                                                   
  Main                                         ServerSide                                                                                                
]]--

--Main Gamemode Files
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--Adding Resources (Resource.AddFile stuff)
include("resources.lua")

--Round System
AddCSLuaFile("cl_round.lua")
AddCSLuaFile("sh_round.lua")
include("sh_round.lua")
include("sv_round.lua")

--Weapons Tables
AddCSLuaFile("sh_weapons.lua")
include("sh_weapons.lua")

--Utils
AddCSLuaFile("util.lua")
include("util.lua")

--Map Voting System
AddCSLuaFile("mapvote/cl_mapvote.lua")
include("mapvote/config.lua")
include("mapvote/sv_mapvote.lua")
include("mapvote/rtv.lua")

function GM:PlayerInitialSpawn( ply )
  print( ply:GetName().." joined the server.\n" )

  ply.PrimaryWep = "weapon_cs_p90"
  ply.SecondaryWep = "weapon_cs_fiveseven"

  ply:SetTeam( TEAM_IRIS )
  --ply:SetTeam( TEAM_IRIS )
end


function GM:PlayerSpawn(ply)

  if not GAMEMODE:GetRoundState() == ROUND_STATE_PREGAME then
    ply:KillSilent()
    ply:Spectate( OBS_MODE_IN_EYE )
  end

  ply:DrawShadow( false )
  ply:CrosshairDisable()
  ply:SetHealth(100)
  ply:SetRunSpeed(350)
  ply:SetWalkSpeed(250)
  ply:SetCrouchedWalkSpeed( .5 )


  if ply:Team() == TEAM_IRIS then
    ply:SetModel( GetRandomPlayerModel() )
    ply:Give( ply.PrimaryWep )
    ply:Give( ply.SecondaryWep )
  else
    ply:SetModel( "models/player/hidden/hidden.mdl" )
    ply:Give("weapon_hidden")
  end

end


function GM:PlayerSelectSpawn(pl)
  if self.unsSpawns == nil then
    self.redSpawns = table.Add(self.redSpawns,ents.FindByClass("info_hidden_spawn"))
  end
  if self.irisSpawns == nil then
    self.irisSpawns = table.Add(self.blueSpawns,ents.FindByClass("info_marine_spawn"))
  end
  
  local numSpwn = 0
  local cSpawnList = {}
  if pl:Team() == TEAM_IRIS then
    cSpawnList = self.irisSpawns
  else
    cSpawnList = self.unsSpawns
  end
  
  numSpwn = #cSpawnList
  if numSpwn == 0 then
    Msg("PlayerSelectSpawn error: no spawn available\n")
    return nil
  end
  
  local ChosenSpawnPoint = nil
  
  for i=0,6 do
    ChosenSpawnPoint = cSpawnList[math.random(1,numSpwn)]
    if ChosenSpawnPoint && ChosenSpawnPoint:IsValid() && ChosenSpawnPoint:IsInWorld() && ChosenSpawnPoint != pl:GetVar( "LastSpawnpoint" ) then 
      pl:SetVar( "LastSpawnpoint", ChosenSpawnPoint )
      return ChosenSpawnPoint
    end
  end
  return ChosenSpawnPoint
end


function GM:PlayerDeath( ply, wep, attacker )
  ply:StripWeapons()
  ply:Spectate( OBS_MODE_IN_EYE )
  if ply:Team() == TEAM_UNS then
    NextUnseen = attacker
  end
  if ply:Team() == attacker:Team() then
    local curteamkills = attacker.teamkills or 0
    attacker.teamkills = curteamkills + 1
  end
end


hook.Add("PlayerHurt", "THEUNSEEN_Stop_Decal", function( ply )
  if ply:Team() == TEAM_UNS then
    ply:RemoveAllDecals()
  end
end)


function ChooseUnseen()
  if not (GAMEMODE.WinningTeam == TEAM_UNS and #team.GetPlayers( TEAM_UNS ) == 1) then
    for k, v in pairs(team.GetPlayers( TEAM_UNS )) do
      v:SetTeam( TEAM_IRIS )
    end

    if NextUnseen and NextUnseen:IsValid() and NextUnseen:IsPlayer() then
      NextUnseen:SetTeam( TEAM_UNS )
    else
      table.Random( team.GetPlayers( TEAM_IRIS ) ):SetTeam( TEAM_UNS )
    end
  end
end


function KickTeamKillers()
  for k, v in pairs( player.GetAll() ) do
    if v.teamkills and v:teamkills:IsValid() and v.teamkills > 2 then
      v:Kick( "Kicked for TeamKilling" )
    end
  end
end


hook.Add("RoundStart", "THEUNSEEN_Choose_Unseen", ChooseUnseen)
hook.Add("RoundEnd", "THEUNSEEN_Kick_TeamKillers", KickTeamKillers)