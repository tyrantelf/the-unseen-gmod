
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 75
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	
	surface.CreateFont("CSKillIcons", { font="csd", weight="500", size=ScreenScale(30),antialiasing=true,additive=true })
	surface.CreateFont("CSSelectIcons", { font="csd", weight="500", size=ScreenScale(60),antialiasing=true,additive=true })

end

SWEP.Author			= "Counter-Strike"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
---------------------------------
---------------------------------
-- Variable layout... have fun.--
---------------------------------
---------------------------------
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.15

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo			= "none"




/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end

	
	self.Weapon:SetNetworkedBool( "Ironsights", false )

self.Reloadaftershoot = 0 
self.nextreload = 0 		
	--Spread Change
	self:SetNWInt("crouchcone", self.CrouchCone)
	self:SetNWInt("crouchwalkcone", self.CrouchWalkCone)
	self:SetNWInt("walkcone", self.WalkCone)
	self:SetNWInt("aircone", self.AirCone)
	self:SetNWInt("standcone", self.StandCone)
	self:SetNWInt("ironsightscone", self.IronsightsCone)
	--Recoil change
	self:SetNWInt("recoil", self.Recoil)
	self:SetNWInt("recoilzoom", self.RecoilZoom)
	--Delay change
	self:SetNWInt("delay", self.Delay)
	self:SetNWInt("delayzoom", self.DelayZoom)
self:SetWeaponHoldType( self.HoldType )
	
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()



	if self.Owner:OnGround() and (self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_MOVERIGHT) or self.Owner:KeyDown(IN_MOVELEFT)) then
		if self.Owner:KeyDown(IN_DUCK) then
			self.Primary.Cone = self:GetNWInt("crouchwalkcone")
		else
			self.Primary.Cone = self:GetNWInt("walkcone")
		end
	elseif self.Owner:OnGround() and self.Owner:KeyDown(IN_DUCK) then
		self.Primary.Cone = self:GetNWInt("crouchcone")
	elseif not self.Owner:OnGround() then
		self.Primary.Cone = self:GetNWInt("aircone")
	else
		if (self:SetIronsights() == true) then
			self.Primary.Cone = self:GetNWInt("ironsightscone")
		else
			self.Primary.Cone = self:GetNWInt("standcone")
	end

	end

end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()
	
	if self.Weapon:GetNetworkedBool("Silenced") == true then
			self.Weapon:SendWeaponAnim( ACT_VM_DRAW_SILENCED );
		else
			self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
		end
	//If silenced blah blah

	self.Reloadaftershoot = CurTime() + 1
	// Can't shoot while deploying

	self:SetIronsights(false)
	// Set the ironsight mod to false

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	// Set the next primary fire to 1 second after deploying

	return true
end 

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
	
	if ( self.Reloadaftershoot > CurTime() ) then return end 
	-- If you're firing, you can't reload

	
	if self.Weapon:GetNetworkedBool("Silenced") == true then
			self.Weapon:DefaultReload( ACT_VM_RELOAD_SILENCED );
		else
			self.Weapon:DefaultReload( ACT_VM_RELOAD );
		end
	self:SetIronsights( false )
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	// If Swep Data is Silenced Play Silenced else Unsilenced
	if self.Weapon:GetNetworkedBool("Silenced") == true then
		self.Weapon:EmitSound( self.SilencedSound )
		self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	else	
		self.Weapon:EmitSound( self.Primary.Sound )
		self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	end

	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
end

/*---------------------------------------------------------
   Name: SWEP:CSShootBullet( )
---------------------------------------------------------*/
function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()				// Source
	bullet.Dir 		= self.Owner:GetAimVector()				// Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )					// Aim Cone
	bullet.Tracer	= 4								// Show a tracer on every x bullets 
	bullet.Force	= 10								// Amount of force to give to phys objects
	bullet.Damage	= dmg
	
	self.Owner:FireBullets( bullet )
	self.Owner:MuzzleFlash()							// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 ) 					//3rd Person Animation
	if self.Weapon:GetNetworkedBool("Silenced") == true then			//Silenced or Unsilenced Animation
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_SILENCED ) 
	else
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 
	end

	if ( self.Owner:IsNPC() ) then return end
	
	// CUSTOM RECOIL !
	if ( (game.SinglePlayer() && SERVER) || ( !game.SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
	
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil / 1.5
		self.Owner:SetEyeAngles( eyeang )
	
	end

end


/*---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	
	// try to fool them into thinking they're playing a Tony Hawks game
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-14, 14), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-9, 9), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	
end

local IRONSIGHT_TIME = 0.25

/*---------------------------------------------------------
   Name: GetViewModelPosition
   Desc: Allows you to re-position the view model
---------------------------------------------------------*/
function SWEP:GetViewModelPosition( pos, ang )

	if ( !self.IronSightsPos ) then return pos, ang end

	local bIron = self.Weapon:GetNetworkedBool( "Ironsights" )
	
	if ( bIron != self.bLastIron ) then
	
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
		
		if ( bIron ) then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	
	end
	
	local fIronTime = self.fIronTime or 0

	if ( !bIron && fIronTime < CurTime() - IRONSIGHT_TIME ) then 
		return pos, ang 
	end
	
	local Mul = 1.0
	
	if ( fIronTime > CurTime() - IRONSIGHT_TIME ) then
	
		Mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )
		
		if (!bIron) then Mul = 1 - Mul end
	
	end

	local Offset	= self.IronSightsPos
	
	if ( self.IronSightsAng ) then
	
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )
	
	
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
	
end


/*---------------------------------------------------------
	SetIronsights
---------------------------------------------------------*/
function SWEP:SetIronsights( b )

	self.Weapon:SetNetworkedBool( "Ironsights", b )

end


SWEP.NextSecondaryAttack = 0
/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	if ( !self.IronSightsPos ) then return end
	if ( self.NextSecondaryAttack > CurTime() ) then return end
	
	bIronsights = !self.Weapon:GetNetworkedBool( "Ironsights", false )
	
	self:SetIronsights( bIronsights )
	
	self.NextSecondaryAttack = CurTime() + 0.3
	
end

/*---------------------------------------------------------
	onRestore
	Loaded a saved game (or changelevel)
---------------------------------------------------------*/
function SWEP:OnRestore()

	self.NextSecondaryAttack = 0
	self:SetIronsights( false )
	
end

