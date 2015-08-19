if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "AK-47"
    SWEP.Slot = 0
    SWEP.SlotPos = 1
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_ak47.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_ak47.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_AK47_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_AK47_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_AK47_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_762NATO"

SWEP.InReload				= false
SWEP.TimeWeaponIdle			= 0
SWEP.MaxSpeed 				= 250

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.3666666666666667, sound = Sound( "OldAK47.BoltPull" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.4333333333333333, sound = Sound( "OldAK47.Clipout" )},
	[2] = {time = 1.9, sound = Sound( "OldAK47.Clipin" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle1"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2", "shoot3" }
SWEP.Anims.ShootEmpty = { "shoot1", "shoot2", "shoot3" }

SWEP.FireSound = Sound("OldAK47.Shot1")


local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end
	
	self:Setm_flAccuracy( 0.2 )
	self.MaxSpeed = CS16_AK47_MAX_SPEED

	if not self.FirstDeploy then
		if SERVER then CS16_SendWeaponAnim( self, self.Anims.Draw, 1 ) end
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

	if self:CS16_DefaultReload( CS16_AK47_MAX_CLIP, self.Anims.Reload, CS16_AK47_RELOAD_TIME, 6 ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self:Setm_flAccuracy( 0.2 )
		self:Setm_iShotsFired( 0 )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:AK47Fire( 0.04 + (0.4 * self:Getm_flAccuracy()), 0.0955 )
	elseif self.Owner:GetVelocity():Length2D() > 140 then
		self:AK47Fire( 0.04 + (0.07 * self:Getm_flAccuracy()), 0.0955 )
	else
		self:AK47Fire( 0.0275 * self:Getm_flAccuracy(), 0.0955 )
	end
end

function SWEP:FireAnimation()
	local anim = self:Clip1() == 1 and self.Anims.ShootEmpty or self.Anims.Shoot

	CS16_SendWeaponAnim( self, anim, 1 )
end

function SWEP:RecalculateAccuracy()
	self:Setm_flAccuracy( 0.35 + ( ( self:Getm_iShotsFired() * self:Getm_iShotsFired() * self:Getm_iShotsFired() ) / 200 ) )
end

function SWEP:AK47Fire( flSpread, flCycleTime )
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

	if SERVER then self:FireAnimation() end
	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash3", self, { DrawViewModel = true, CustomSizeVM = 20 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash3", self, { DrawWorldModel = true } ) 

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), flSpread, CS16_AK47_DISTANCE, CS16_AK47_PENETRATION, "CS16_762NATO", CS16_AK47_DAMAGE, CS16_AK47_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "rshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 1.9 )

	if SERVER then
		if !self.Owner:IsOnGround() then
			self:KickBack( 2.0, 1.0, 0.5, 0.35, 9.0, 6.0, 5 )
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:KickBack( 1.5, 0.45, 0.225, 0.05, 6.5, 2.5, 7 )
		elseif self.Owner:Crouching() then
			self:KickBack( 0.9, 0.35, 0.15, 0.025, 5.5, 1.5, 9 )
		else
			self:KickBack( 1.0, 0.375, 0.175, 0.0375, 5.75, 1.75, 8 )
		end
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