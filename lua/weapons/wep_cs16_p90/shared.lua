if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "ES C90"
    SWEP.Slot = 0
    SWEP.SlotPos = 8
	SWEP.DrawAmmo = false
end

SWEP.Category = "Counter-Strike 1.6"
SWEP.Base = "cs16_base"
SWEP.Author            = "Schwarz Kruppzo"
SWEP.Contact        = ""
SWEP.Purpose        = ""

SWEP.ViewModelFOV    = 73
SWEP.ViewModelFlip    = true

SWEP.Spawnable            = true
SWEP.AdminSpawnable        = true

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_p90.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_p90.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_P90_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_P90_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_P90_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_57MM"

SWEP.InReload				= false
SWEP.TimeWeaponIdle			= 0
SWEP.Accuracy				= 0.2
SWEP.MaxSpeed 				= 250
SWEP.DelayFire				= false
SWEP.ShotsFired				= 0

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.3, sound = Sound( "OldP90.BoltPull" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.4473684210526316, sound = Sound( "OldP90.ClipRelease" )},
	[2] = {time = 0.9210526315789474, sound = Sound( "OldP90.ClipOut" )},
	[3] = {time = 1.973684210526316, sound = Sound( "OldP90.ClipIn" )},
	[4] = {time = 2.842105263157895, sound = Sound( "OldP90.BoltPull" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2", "shoot3" }

SWEP.FireSound = Sound("OldP90.Shot1")


local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end
	
	self:Setm_flAccuracy( 0.2 )
	self.MaxSpeed = CS16_P90_MAX_SPEED

	if not self.FirstDeploy then
		CS16_SendWeaponAnim( self, self.Anims.Draw, 1 )
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end
	
	self:Setm_flTimeWeaponIdle( CurTime() + 1.5 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_P90_MAX_CLIP, self.Anims.Reload, CS16_P90_RELOAD_TIME, 6 ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self:Setm_flAccuracy( 0.2 )
		self:Setm_iShotsFired( 0 )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:P90Fire( 0.3  * self:Getm_flAccuracy(), 0.066 )
	elseif self.Owner:GetVelocity():Length2D() > 170 then
		self:P90Fire( 0.115 * self:Getm_flAccuracy(), 0.066 )
	else
		self:P90Fire( 0.045 * self:Getm_flAccuracy(), 0.066 )
	end
end

function SWEP:FireAnimation()
	CS16_SendWeaponAnim( self, self.Anims.Shoot, 1 )
end

function SWEP:RecalculateAccuracy()
	self:Setm_flAccuracy( ( ( self:Getm_iShotsFired() * self:Getm_iShotsFired() * self:Getm_iShotsFired() ) / 175 ) + 0.45 )
end

function SWEP:P90Fire( flSpread, flCycleTime )
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
	if self:Getm_flAccuracy() > 1 then
		self:Setm_flAccuracy( 1 )
	end

	self:FireAnimation()

	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash3", self, { DrawViewModel = true, CustomSizeVM = 11 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash3", self, { DrawWorldModel = true } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), flSpread, CS16_P90_DISTANCE, CS16_P90_PENETRATION, "CS16_57MM", CS16_P90_DAMAGE, CS16_P90_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "rshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 2 )

	if !self.Owner:IsOnGround() then
		self:KickBack( 0.9, 0.45, 0.35, 0.04, 5.25, 3.5, 4 )
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack( 0.45, 0.3, 0.2, 0.0275, 4.0, 2.25, 7 )
	elseif self.Owner:Crouching() then
		self:KickBack( 0.275, 0.2, 0.125, 0.02, 3.0, 1.0, 9 )
	else
		self:KickBack( 0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8 )
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