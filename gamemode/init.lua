--[[
   _______ _            _    _                           
  |__   __| |          | |  | |                          
     | |  | |__   ___  | |  | |_ __  ___  ___  ___ _ __  
     | |  | '_ \ / _ \ | |  | | '_ \/ __|/ _ \/ _ \ '_ \ 
     | |  | | | |  __/ | |__| | | | \__ \  __/  __/ | | |
     |_|  |_| |_|\___|  \____/|_| |_|___/\___|\___|_| |_|                                                   
  Main                                         ServerSide                                                                                                
]]--
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("resources.lua")
include("shared.lua")

function GM:PlayerInitialSpawn(ply)
  print( ply:GetName().." joined the server.\n" )

  ply:SetTeam( TEAM_IRIS )

  if GAMEMODE:GetRoundState() == ROUND_STATE_PREGAME then
    ply:Spawn()
  end

end

function GM:PlayerSpawn(ply)
  ply:CrosshairDisable()
  ply:SetHealth(100)
  ply:SetRunSpeed(700)
  ply:SetWalkSpeed(400)

  if ply:Team() == TEAM_IRIS then
    ply:SetModel( "models/player/police.mdl" )
    ply:Give("empty_weapon")
    ply:Give("empty_weapon")
  else
    ply:SetModel( "models/player/hidden/hidden.mdl" )
    ply:Give("weapon_hidden")
  end

end

function GM:PlayerInitialSpawn( pl )

 pl:PrintMessage(HUD_PRINTCENTER,"Welcome to The Unseen!");

end

function GM:PlayerDeath( ply, wep, attacker )
  ply:StripWeapons()
  ply:Spectate( OBS_MODE_IN_EYE )
  if ply:Team() == TEAM_UNS then
    NextUnseen = attacker
  end
end

function ChooseUnseen()
  if not (GAMEMODE.WinningTeam == TEAM_UNS and #team.GetPlayers( TEAM_UNS ) == 1) then
    for k, v in team.GetPlayers( TEAM_UNS ) do
      v:SetTeam( TEAM_IRIS )
    end

    if NextUnseen:IsValid() and NextUnseen:IsPlayer() then
      NextUnseen:SetTeam( TEAM_UNS )
    else
      table.random( team.GetPlayers( TEAM_IRIS ) ):SetTeam( TEAM_UNS )
    end
  end
end

hook.Add("RoundStart", "THEUNSEEN_Choose_Unseen", ChooseUnseen)