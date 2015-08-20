if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "M249"
    SWEP.Slot = 0
    SWEP.SlotPos = 4
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_m249.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_m249.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_M249_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_M249_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_M249_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_556NATOBOX"

SWEP.InReload				= false
SWEP.TimeWeaponIdle			= 0
SWEP.Accuracy				= 0.2
SWEP.MaxSpeed 				= 250
SWEP.DelayFire				= false
SWEP.ShotsFired				= 0

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.7, sound = Sound( "OldM249.SlideBack" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 1.166666666666667, sound = Sound( "OldM249.CoverUp" )},
	[2] = {time = 1.533333333333333, sound = Sound( "OldM249.BoxOut" )},
	[3] = {time = 2.233333333333333, sound = Sound( "OldM249.BoxIn" )},
	[4] = {time = 2.9, sound = Sound( "OldM249.Chain" )},
	[5] = {time = 3.566666666666667, sound = Sound( "OldM249.CoverDown" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle1"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2" }

SWEP.FireSound = Sound("OldM249.Shot1")


local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end
	
	self:Setm_flAccuracy( 0.2 )
	self.MaxSpeed = CS16_M249_MAX_SPEED

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

	if self:CS16_DefaultReload( CS16_M249_MAX_CLIP, self.Anims.Reload, CS16_M249_RELOAD_TIME, 6 ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self:Setm_flAccuracy( 0.2 )
		self:Setm_iShotsFired( 0 )
		self:Setm_bDelayFire( false )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:M249Fire( 0.045 + (0.5 * self:Getm_flAccuracy()), 0.1 )
	elseif self.Owner:GetVelocity():Length2D() > 140 then
		self:M249Fire( 0.045 + (0.095 * self:Getm_flAccuracy()), 0.1 )
	else
		self:M249Fire( 0.03 * self:Getm_flAccuracy(), 0.1 )
	end
end

function SWEP:FireAnimation()
	CS16_SendWeaponAnim( self, self.Anims.Shoot, 1 )
end

function SWEP:RecalculateAccuracy()
	self:Setm_flAccuracy( ( ( self:Getm_iShotsFired() * self:Getm_iShotsFired() * self:Getm_iShotsFired() ) / 175 ) + 0.4 )
end

function SWEP:M249Fire( flSpread, flCycleTime )
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
	if self:Getm_flAccuracy() > 0.9 then
		self:Setm_flAccuracy( 0.9 )
	end

	if SERVER then self:FireAnimation() end

	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash3", self, { DrawViewModel = true, CustomSizeVM = 16 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash3", self, { DrawWorldModel = true } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), flSpread, CS16_M249_DISTANCE, CS16_M249_PENETRATION, "CS16_556NATOBOX", CS16_M249_DAMAGE, CS16_M249_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "rshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 1.6 )

	if SERVER then
		if !self.Owner:IsOnGround() then
			self:KickBack( 1.8, 0.65, 0.45, 0.125, 5.0, 3.5, 8 )
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:KickBack( 1.1, 0.5, 0.3, 0.06, 4.0, 3.0, 8 )
		elseif self.Owner:Crouching() then
			self:KickBack( 0.75, 0.325, 0.25, 0.025, 3.5, 2.5, 9 )
		else
			self:KickBack( 0.8, 0.35, 0.3, 0.03, 3.75, 3.0, 9 )
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