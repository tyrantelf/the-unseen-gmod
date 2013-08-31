
if (SERVER) then
	AddCSLuaFile("cl_init.lua")
	AddCSLuaFile("shared.lua")
end

/*---------------------------------------------------------
	Sniper Layout
/*-------------------------------------------------------*/

SWEP.Base				= "btw_cs_base"
SWEP.ViewModelFOV			= 75

SWEP.Spawnable 			= false
SWEP.AdminSpawnable 		= false

SWEP.Primary.Sound 		= Sound("Weapon_AK47.Single")
SWEP.Primary.Recoil 		= 0
SWEP.Primary.Damage 		= 0
SWEP.Primary.NumShots 		= 0
SWEP.Primary.Cone 		= 0
SWEP.Primary.Delay 		= 0

SWEP.Primary.ClipSize 		= 0
SWEP.Primary.DefaultClip 	= 0
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 		= "none"

SWEP.Secondary.ClipSize 	= 0
SWEP.Secondary.DefaultClip 	= 0
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"


-- Weapon Variations

SWEP.UseScope				= true -- Use a scope instead of iron sights.
SWEP.ScopeScale 			= 0.55 -- The scale of the scope's reticle in relation to the player's screen size.

SWEP.WalkCone				= 0.05 -- Accuracy when we're walking
SWEP.StandCone				= 0.001 -- Accuracy when we're standing still
/*---------------------------------------------------------
	ResetVars
---------------------------------------------------------*/
function SWEP:ResetVars()

	self.NextSecondaryAttack = 0
	
	self.bLastIron = false
	self.Weapon:SetNetworkedBool("Ironsights", false)
	
	if self.UseScope then
		self.CurScopeZoom = 1
		self.fLastScopeZoom = 1
		self.bLastScope = false
		self.Weapon:SetNetworkedBool("Scope", false)
		self.Weapon:SetNetworkedBool("ScopeZoom", self.ScopeZooms[1])
	end
	
	if self.Owner then
		self.OwnerIsNPC = self.Owner:IsNPC() -- This ought to be better than getting it every time we fire
	end
	
end

-- We need to call ResetVars() on these functions so we don't whip out a weapon with scope mode or insane recoil right of the bat or whatnot
function SWEP:Holster(wep) 		self:ResetVars() return true end
function SWEP:Equip(NewOwner) 	self:ResetVars() return true end
function SWEP:OnRemove() 		self:ResetVars() return true end
function SWEP:OnDrop() 			self:ResetVars() return true end
function SWEP:OwnerChanged() 	self:ResetVars() return true end
function SWEP:OnRestore() 		self:ResetVars() return true end

/*---------------------------------------------------------
	Initialize
---------------------------------------------------------*/
local sndZoomIn = Sound("Weapon_AR2.Special1")
local sndZoomOut = Sound("Weapon_AR2.Special2")
local sndCycleZoom = Sound("Default.Zoom")

function SWEP:Initialize()

	self:SetWeaponHoldType(self.HoldType)

	if CLIENT then
	
		-- We need to get these so we can scale everything to the player's current resolution.
		local iScreenWidth = surface.ScreenWidth()
		local iScreenHeight = surface.ScreenHeight()
		
		-- The following code is only slightly riped off from Night Eagle
		-- These tables are used to draw things like scopes and crosshairs to the HUD.
		self.ScopeTable = {}
		self.ScopeTable.l = iScreenHeight*self.ScopeScale
		self.ScopeTable.x1 = 0.5*(iScreenWidth + self.ScopeTable.l)
		self.ScopeTable.y1 = 0.5*(iScreenHeight - self.ScopeTable.l)
		self.ScopeTable.x2 = self.ScopeTable.x1
		self.ScopeTable.y2 = 0.5*(iScreenHeight + self.ScopeTable.l)
		self.ScopeTable.x3 = 0.5*(iScreenWidth - self.ScopeTable.l)
		self.ScopeTable.y3 = self.ScopeTable.y2
		self.ScopeTable.x4 = self.ScopeTable.x3
		self.ScopeTable.y4 = self.ScopeTable.y1
				
		self.ParaScopeTable = {}
		self.ParaScopeTable.x = 0.5*iScreenWidth - self.ScopeTable.l
		self.ParaScopeTable.y = 0.5*iScreenHeight - self.ScopeTable.l
		self.ParaScopeTable.w = 2*self.ScopeTable.l
		self.ParaScopeTable.h = 2*self.ScopeTable.l
		
		self.ScopeTable.l = (iScreenHeight + 1)*self.ScopeScale -- I don't know why this works, but it does.

		self.QuadTable = {}
		self.QuadTable.x1 = 0
		self.QuadTable.y1 = 0
		self.QuadTable.w1 = iScreenWidth
		self.QuadTable.h1 = 0.5*iScreenHeight - self.ScopeTable.l
		self.QuadTable.x2 = 0
		self.QuadTable.y2 = 0.5*iScreenHeight + self.ScopeTable.l
		self.QuadTable.w2 = self.QuadTable.w1
		self.QuadTable.h2 = self.QuadTable.h1
		self.QuadTable.x3 = 0
		self.QuadTable.y3 = 0
		self.QuadTable.w3 = 0.5*iScreenWidth - self.ScopeTable.l
		self.QuadTable.h3 = iScreenHeight
		self.QuadTable.x4 = 0.5*iScreenWidth + self.ScopeTable.l
		self.QuadTable.y4 = 0
		self.QuadTable.w4 = self.QuadTable.w3
		self.QuadTable.h4 = self.QuadTable.h3

		self.LensTable = {}
		self.LensTable.x = self.QuadTable.w3
		self.LensTable.y = self.QuadTable.h1
		self.LensTable.w = 2*self.ScopeTable.l
		self.LensTable.h = 2*self.ScopeTable.l
		
	end

	self.ScopeZooms 		= self.ScopeZooms or {5}
	if self.UseScope then
		self.CurScopeZoom	= 1 -- Another index, this time for ScopeZooms
	end

	self:ResetVars()
	self.Weapon:SetNetworkedBool("Ironsights", false)
	self.Reloadaftershoot = 0

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
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	// Play shoot sound
	self.Weapon:EmitSound( self.Primary.Sound )

	// Shoot the bullet
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.2) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()

	if CLIENT and self.Weapon:GetNetworkedBool("Scope") then
		self.MouseSensitivity = self.Owner:GetFOV() / 80 -- scale sensitivity
	else
		self.MouseSensitivity = 1
	end

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
		self.Primary.Cone = self:GetNWInt("standcone")
	end

	if self.Weapon:GetNetworkedBool( "Scope", false ) then
		self.Primary.Delay = self:GetNWInt("delayzoom") -- Delay On Zoom
		self.Primary.Recoil = self:GetNWInt("recoilzoom") -- Same but recoil
	else
		self.Primary.Delay = self:GetNWInt("delay") -- Delay on unzoom
		self.Primary.Recoil = self:GetNWInt("recoil") -- Same but recoil
	end	
		
end

/*---------------------------------------------------------
Sensibility
---------------------------------------------------------*/
local LastViewAng = false

local function SimilarizeAngles (ang1, ang2) --this function makes angle-play a little easier on the mind, damn the overhead I say

	ang1.y = math.fmod (ang1.y, 360)
	ang2.y = math.fmod (ang2.y, 360)

	if math.abs (ang1.y - ang2.y) > 180 then
		if ang1.y - ang2.y < 0 then
			ang1.y = ang1.y + 360
		else
			ang1.y = ang1.y - 360
		end
	end
end

local function ReduceScopeSensitivity (uCmd)

	if LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon():IsValid() then
		local newAng = uCmd:GetViewAngles()
			if LastViewAng then
				SimilarizeAngles (LastViewAng, newAng)

				local diff = newAng - LastViewAng

				diff = diff * (LocalPlayer():GetActiveWeapon().MouseSensitivity or 1)
				uCmd:SetViewAngles (LastViewAng + diff)
			end
	end
	LastViewAng = uCmd:GetViewAngles()
end
 
hook.Add ("CreateMove", "RSS", ReduceScopeSensitivity)


/*---------------------------------------------------------
	SetIronsights
---------------------------------------------------------*/
function SWEP:SetIronsights( b )

	self.Weapon:SetNetworkedBool( "Scope", b )

end


SWEP.NextSecondaryAttack = 0

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	if ( self.NextSecondaryAttack > CurTime() ) then return end
	
	bIronsights = !self.Weapon:GetNetworkedBool( "Scope", false )
	
	self:SetIronsights( bIronsights )
	
	self.NextSecondaryAttack = CurTime() + 0.3
	
end


/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()

	if ( self.Reloadaftershoot > CurTime() ) then return end 
	-- If you're firering, you can't reload

	self.Weapon:DefaultReload(ACT_VM_RELOAD);

	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then

		self:SetIronsights(false, self.Owner)
		-- Set the ironsight to false

		self.Owner:SetFOV( 0, 0 )
		-- Set the Fov back to normal if zoomed

		self.MouseSensitivity = 1
		-- Set MouseSens Back to one

		self.Primary.Delay = self:GetNWInt("delay")
		-- Set Delay back to normal

		self.Primary.Recoil = self:GetNWInt("recoil")
		--Set Recoil to normal
		if not CLIENT then
			self.Owner:DrawViewModel(true)
		end
	end

	return true
end


/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	-- Set the deploy animation when deploying

	self.Reloadaftershoot = CurTime() + 1
	-- Can't shoot while deploying

	self:SetIronsights(false)
	-- Set the ironsight mod to false

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	-- Set the next primary fire to 1 second after deploying

	self.Primary.Delay = self:GetNWInt("delay")
	--Set Delay back to normal
		
	self.Primary.Recoil = self:GetNWInt("recoil")
	--Set Recoil to normal
	return true
end

/*---------------------------------------------------------
SetScope
---------------------------------------------------------*/
function SWEP:SetScope(b, player)

if CLIENT then return end

	local PlaySound = b ~= self.Weapon:GetNetworkedBool("Scope", not b) -- Only play zoom sounds when chaning in/out of scope mode
	self.CurScopeZoom = 1 -- Just in case...
	self.Weapon:SetNetworkedFloat("ScopeZoom", self.ScopeZooms[self.CurScopeZoom])

	if b then 
--		player:DrawViewModel(true)
		if PlaySound then
			self.Weapon:EmitSound(sndZoomIn)
		end
	else
--		player:DrawViewModel(true)
	end
	
	-- Send the scope state to the client, so it can adjust the player's fov/HUD accordingly
	self.Weapon:SetNetworkedBool("Scope", b) 
end
