--[[
   _______ _            _    _                           
  |__   __| |          | |  | |                          
     | |  | |__   ___  | |  | |_ __  ___  ___  ___ _ __  
     | |  | '_ \ / _ \ | |  | | '_ \/ __|/ _ \/ _ \ '_ \ 
     | |  | | | |  __/ | |__| | | | \__ \  __/  __/ | | |
     |_|  |_| |_|\___|  \____/|_| |_|___/\___|\___|_| |_|                                                   
  Main                                         ClientSide                                                                                                
]]--
include("shared.lua")
include("util.lua")
include("sh_round.lua")
include("cl_round.lua")
include("sh_weapons.lua")
include("mapvote/config.lua")
include("mapvote/cl_mapvote.lua")

nextheartbeat = 0

function GM:HUDDrawTargetID()
	target = LocalPlayer():GetEyeTrace().Entity

	if ( target:IsValid() and target:IsPlayer() ) then
		if not target:Team() == LocalPlayer():Team() then
			return false
		end
		return true
	end
	return true
end

function AuraView()
	if LocalPlayer():IsValid() then
		if LocalPlayer():Team() == TEAM_UNS and LocalPlayer():KeyDown( KEY_Q ) then
			if not HumanEmitter then

				HumanEmitter = ParticleEmitter( LocalPlayer():GetPos() )

			end

			local pos = LocalPlayer():GetPos()

			for k, ply in pairs( team.GetPlayers( TEAM_IRIS ) ) do

				local trgpos = ply:GetPos() + Vector(0,0,50)

				if ply:KeyDown( IN_DUCK ) then

					trgpos = ply:GetPos() + Vector(0,0,20)

				end

				if ply:Alive() and trgpos:Distance( pos ) < 4000 then

					local scale = math.Clamp( ply:Health() / 100, 0, 1 )

					for i=1, math.random( 1, 3 ) do

						local par = HumanEmitter:Add( "sprites/light_glow02_add_noz.vmt", trgpos )
						par:SetVelocity( VectorRand() * 30 )
						par:SetDieTime( 0.5 )
						par:SetStartAlpha( 255 )
						par:SetEndAlpha( 0 )
						par:SetStartSize( math.random( 2, 10 ) )
						par:SetEndSize( 0 )
						par:SetColor( 255 - scale * 255, 55 + scale * 200, 50 ) 
						par:SetRoll( math.random( 0, 300 ) )

					end
				end
			end
		end
	end
end

hook.Add("Tick", "THEUNSEEN_Aura_View", AuraView )