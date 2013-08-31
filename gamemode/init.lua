AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("resources.lua")
include("shared.lua")

function GM:PlayerInitialSpawn(ply)

    ply:SetTeam(TEAM_IRIS)

  self.BaseClass:PlayerInitialSpawn(ply)
end
 
function GM:PlayerLoadout(ply)
  return
end

/*---------------------------------------------------------
   Weapons & playermodels system when you start the game by phpmysql
---------------------------------------------------------*/

function GM:PlayerSpawn(ply)
  self.BaseClass:PlayerSpawn(ply)

  ply:CrosshairDisable()

  if ply:Team() == TEAM_IRIS then
  
    ply:SetModel( GetRandomPlayerModel() or "models/player/police.mdl" )
  	ply:SetHealth(100)
	  ply:SetRunSpeed(700) 
  	ply:SetWalkSpeed(400)
    ply:Give("empty_weapon")
    ply:Give("empty_weapon")
  
  else
  	
  	local numplayers = #( player.GetAll() )
  	local unsHealth = 100 + ( math.floor( numplayers/5 ) * 25 )
    
    ply:SetModel("models/player/hidden/hidden.mdl")
	  ply:SetHealth( unsHealth )
	  ply:SetRunSpeed(750) 
	  ply:SetWalkSpeed(450)
    ply:Give("weapon_hidden")
  
  end
end


/*---------------------------------------------------------
   Text when you start the game
---------------------------------------------------------*/

function GM:PlayerInitialSpawn( pl )
	
	pl:PrintMessage(HUD_PRINTCENTER,"Welcome to The Unseen!");
	
end

/*---------------------------------------------------------
   Player Spawn selects spawn points on hidden maps
---------------------------------------------------------*/

function GM:PlayerDeath( ply, wep, attacker )
	if ply:Team() == TEAM_UNS then
		
	end 
end

