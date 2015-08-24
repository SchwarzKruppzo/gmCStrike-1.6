if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Bullpup"
    SWEP.Slot = 0
    SWEP.SlotPos = 14
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_aug.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_aug.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_AUG_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_AUG_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_AUG_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_556NATO"

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.2571428571428571, sound = Sound( "OldAUG.Forearm" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.25, sound = Sound( "OldAUG.Boltpul" )},
	[2] = {time = 1.25, sound = Sound( "OldAUG.Clipout" )},
	[3] = {time = 2.2, sound = Sound( "OldAUG.Clipin" )},
	[4] = {time = 2.8, sound = Sound( "OldAUG.Boltslap" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2", "shoot3" }

SWEP.FireSound = Sound("OldAUG.Shot1")


local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end
	
	self:Setm_flAccuracy( 0.2 )

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

	if self:CS16_DefaultReload( CS16_AUG_MAX_CLIP, self.Anims.Reload, CS16_AUG_RELOAD_TIME, 6 ) then
		if self:GetIsInScope() then
			self:SetIsInScope( false )
		end
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self:Setm_flAccuracy( 0 )
		self:Setm_iShotsFired( 0 )
		self:Setm_bDelayFire( false )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:AUGFire( 0.035 + 0.4 * self:Getm_flAccuracy(), 0.0825 )
	elseif self.Owner:GetVelocity():Length2D() > 140 then
		self:AUGFire( 0.035 + 0.07 * self:Getm_flAccuracy(), 0.0825 )
	elseif !self:GetIsInScope() then
		self:AUGFire( 0.02 * self:Getm_flAccuracy(), 0.0825 )
	else
		self:AUGFire( 0.02 * self:Getm_flAccuracy(), 0.135 )
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() then 
		return
	end

	if self:GetIsInScope() then
		self:SetIsInScope( false )
	else
		self:SetIsInScope( true )
	end

	self:SetNextSecondaryFire( CurTime() + 0.3)
end

function SWEP:FireAnimation()
	CS16_SendWeaponAnim( self, self.Anims.Shoot, 1 )
end

function SWEP:RecalculateAccuracy()
	self:Setm_flAccuracy( ( self:Getm_iShotsFired() * self:Getm_iShotsFired() * self:Getm_iShotsFired() / 215 ) + 0.3 )
end

function SWEP:AUGFire( flSpread, flCycleTime )
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

	osmes.SpawnEffect( self.Owner, "muzzleflash3", self, { DrawViewModel = true, CustomSizeVM = 20 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash3", self, { DrawWorldModel = true } ) 

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), flSpread, CS16_AUG_DISTANCE, CS16_AUG_PENETRATION, "CS16_556NATO", CS16_AUG_DAMAGE, CS16_AUG_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "rshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 1 )
	
	if !self.Owner:IsOnGround() then
		self:KickBack( 1.25, 0.45, 0.22, 0.18, 5.5, 4.0, 5 )
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack( 1.0, 0.45, 0.275, 0.05, 4.0, 2.5, 7 )
	elseif self.Owner:Crouching() then
		self:KickBack( 0.575, 0.325, 0.2, 0.011, 3.25, 2.0, 8 )
	else
		self:KickBack( 0.625, 0.375, 0.25, 0.0125, 3.5, 2.25, 8 )
	end
end

function SWEP:WeaponIdle()
	if self:Getm_flTimeWeaponIdle() > CurTime() then
		return
	end

	if self:Clip1() != 0 then 
		self:Setm_flTimeWeaponIdle( CurTime() + 20 )
		CS16_SendWeaponAnim( self, self.Anims.Idle, 1 )
	end
end

function SWEP:GetMaxSpeed()
	return self:GetIsInScope() and CS16_AUG_MAX_SPEED_ZOOM or CS16_AUG_MAX_SPEED
end