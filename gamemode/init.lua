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
AddCSLuaFile("cl_round.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_round.lua")

include("shared.lua")
include("sh_round.lua")

include("sv_round.lua")


function GM:PlayerInitialSpawn( ply )
  print( ply:GetName().." joined the server.\n" )

  ply:SetTeam( TEAM_IRIS )

end

function GM:PlayerSpawn(ply)

  if not GAMEMODE:GetRoundState() == ROUND_STATE_PREGAME then
    ply:KillSilent()
    ply:Spectate( OBS_MODE_IN_EYE )
  end

  ply:CrosshairDisable()
  ply:SetHealth(100)
  ply:SetRunSpeed(700)
  ply:SetWalkSpeed(400)

  if ply:Team() == TEAM_IRIS then
    ply:SetModel( "models/player/police.mdl" )
    ply:Give("weapon_cs_pumpshotgun")
    ply:Give("weapon_cs_deagle")
    ply:Give("weapon_cs_p90")
    ply:Give("weapon_cs_sg552")
    ply:Give("weapon_cs_fiveseven")
    ply:Give("weapon_cs_aug")
  else
    ply:SetModel( "models/player/hidden/hidden.mdl" )
    ply:Give("empty_weapon")
  end

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
    for k, v in pairs(team.GetPlayers( TEAM_UNS )) do
      v:SetTeam( TEAM_IRIS )
    end

    if NextUnseen:IsValid() and NextUnseen:IsPlayer() then
      NextUnseen:SetTeam( TEAM_UNS )
    else
      table.Random( team.GetPlayers( TEAM_IRIS ) ):SetTeam( TEAM_UNS )
    end
  end
end

hook.Add("RoundStart", "THEUNSEEN_Choose_Unseen", ChooseUnseen)