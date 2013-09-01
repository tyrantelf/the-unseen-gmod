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
include("sh_round.lua")
include("cl_round.lua")
include("sh_weapons.lua")
include("util.lua")
include("mapvote/cl_mapvote.lua")

nextheartbeat = 0

function GM:SpawnMenuOpen()
	return false	
end

function GM:ContextMenuOpen()
	return false	
end

function GM:HUDDrawTargetID()
	target = LocalPlayer():GetEyeTrace().Entity

	if target:IsValid() and not target:Team() == LocalPlayer():Team() then
		return false
	end
end

function AuraView(ply, key)
	if ( LocalPlayer():KeyDown( KEY_C ) ) and LocalPlayer():Team() == TEAM_UNS then
		if CurTime() > nextheartbeat then
			nextheartbeat = CurTime() + 1
			for k,v in pairs( ents.GetAll() ) do
				if v:IsNPC() or v:IsPlayer() and v:Alive() and v ~= LocalPlayer() then
					ply.emitter = ParticleEmitter( ply:GetPos() )
					local heartbeat = ply.emitter:Add( "sprites/light_glow02_add_noz", v:GetPos() + Vector(0,0,50) )
					heartbeat:SetDieTime( 0.5 )
					heartbeat:SetStartAlpha( 255 )
					heartbeat:SetEndAlpha( 0 )
					heartbeat:SetStartSize( 50 )
					heartbeat:SetEndSize( 0 )
					if v:Health() > 75 then
						heartbeat:SetColor(255,0,0)
					elseif v:Health() > 50 then
						heartbeat:SetColor(153,0,0)
					elseif v:Health() > 25 then
						heartbeat:SetColor(255,0,0)
					else
						heartbeat:SetColor(153,0,0)
					end
				end
			end
		end
	end
end

hook.Add( "Thnk", "AuraViewThink", AuraView )