if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "IDF Defender"
	SWEP.DrawAmmo = false
end
SWEP.AnimPrefix = "ak47"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.Price = 2000
SWEP.iTeam = 2

SWEP.Category = "Counter-Strike 1.6"
SWEP.Base = "cs16_base"
SWEP.Author            = "Schwarz Kruppzo"
SWEP.Contact        = ""
SWEP.Purpose        = ""

SWEP.ViewModelFOV    = 73
SWEP.ViewModelFlip    = true

SWEP.Spawnable            = true
SWEP.AdminSpawnable        = true

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_galil.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/p_galil.mdl"
SWEP.PickupModel   		= "models/cs16/w_galil.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_GALIL_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_GALIL_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_GALIL_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_556NATO"

SWEP.MaxSpeed 				= 250

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.2857142857142857, sound = Sound( "OldGalil.Boltpull" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.4285714285714286, sound = Sound( "OldGalil.Clipout" )},
	[2] = {time = 1.342857142857143, sound = Sound( "OldGalil.Clipin" )},
	[3] = {time = 1.857142857142857, sound = Sound( "OldGalil.Boltpull" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2", "shoot3" }

SWEP.FireSound = Sound("OldGalil.Shot1")


local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end
	
	self:Setm_flAccuracy( 0.2 )
	self.MaxSpeed = CS16_GALIL_MAX_SPEED

	if not self.FirstDeploy then
		CS16_SendWeaponAnim( self, self.Anims.Draw, 1 )
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end

	self.Owner:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
	
	self:Setm_flTimeWeaponIdle( CurTime() + 1.5 )
	self:SetNextPrimaryFire( CurTime() + 0.5 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_GALIL_MAX_CLIP, self.Anims.Reload, CS16_GALIL_RELOAD_TIME, 6 ) then
		self:Setm_flAccuracy( 0.2 )
		self:Setm_iShotsFired( 0 )
		self:Setm_bDelayFire( false )
	end
end

function SWEP:PrimaryAttack()
	if self.Owner:WaterLevel() == 3 then
		self:EmitSound( Sound( "OldRifle.DryFire" ) )
		self:SetNextPrimaryFire( CurTime() + 0.15 )

		return
	end

	if !self.Owner:IsOnGround() then
		self:GalilFire( 0.04 + (0.3 * self:Getm_flAccuracy()), 0.0875 )
	elseif self.Owner:GetVelocity():Length2D() > 140 then
		self:GalilFire( 0.04 + (0.07 * self:Getm_flAccuracy()), 0.0875 )
	else
		self:GalilFire( 0.0375 * self:Getm_flAccuracy(), 0.0875 )
	end
end

function SWEP:FireAnimation()
	CS16_SendWeaponAnim( self, self.Anims.Shoot, 1 )
end

function SWEP:RecalculateAccuracy()
	self:Setm_flAccuracy( ( ( self:Getm_iShotsFired() * self:Getm_iShotsFired() * self:Getm_iShotsFired() ) / 200 ) + 0.35 )
end

function SWEP:GalilFire( flSpread, flCycleTime )
	if self:Clip1() <= 0 then
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) == 0 or self:Clip1() == 0 or self.Primary.ClipSize == -1 then
			self:EmitSound( Sound( "OldRifle.DryFire" ) )
			self:SetNextPrimaryFire( CurTime() + 0.2 )
		end

		return
	end

	self:Setm_bDelayFire( true )
	self:Setm_iShotsFired( self:Getm_iShotsFired() + 1 )
	self:RecalculateAccuracy()
	if self:Getm_flAccuracy() > 1.25 then
		self:Setm_flAccuracy( 1.25 )
	end

	self:FireAnimation()

	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash3", self, { DrawViewModel = true, CustomSizeVM = 20 } )
	osmes.SpawnEffect( nil, "muzzleflash1", self, { DrawWorldModel = true, CustomSizeWM = 32 } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), flSpread, CS16_GALIL_DISTANCE, CS16_GALIL_PENETRATION, "CS16_556NATO", CS16_GALIL_DAMAGE, CS16_GALIL_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "rshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:SetNextSecondaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 1.9 )

	if !self.Owner:IsOnGround() then
		self:KickBack( 1.2, 0.5, 0.23, 0.15, 5.5, 3.5, 6 )
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack( 1.0, 0.45, 0.28, 0.045, 3.75, 3.0, 7 )
	elseif self.Owner:Crouching() then
		self:KickBack( 0.6, 0.3, 0.2, 0.0125, 3.25, 2.0, 7 )
	else
		self:KickBack( 0.65, 0.35, 0.25, 0.015, 3.5, 2.25, 7 )
	end
end

function SWEP:WeaponIdle()
	if self:Getm_flTimeWeaponIdle() > CurTime() then
		return
	end

	if self:Clip1() != 0 then 
		self:Setm_flTimeWeaponIdle( CurTime() + 3.0625 )
		CS16_SendWeaponAnim( self, self.Anims.Idle, 1 )
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end
