if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Deagle"
    SWEP.Slot = 1
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_deagle.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_deagle.mdl"
SWEP.HoldType			= "pistol"

SWEP.Weight				= CS16_DEAGLE_WEIGHT

SWEP.Primary.ClipSize		= CS16_DEAGLE_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_DEAGLE_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_50AE"

SWEP.MaxSpeed 				= CS16_DEAGLE_MAX_SPEED
SWEP.EnableIdle				= false

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.04, sound = Sound( "OldDeagle.Deploy" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.4666666666666667, sound = Sound( "OldDeagle.Clipout" )},
	[2] = {time = 1.133333333333333, sound = Sound( "OldDeagle.Clipin" )},
}

SWEP.Anims = {}
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2" }
SWEP.Anims.ShootEmpty = "shoot_empty"

SWEP.FireSound = Sound("OldDeagle.Shot1")

local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end

	self:Setm_flAccuracy( 0.9 )
	self.MaxSpeed = CS16_DEAGLE_MAX_SPEED

	if not self.FirstDeploy then
		if SERVER then CS16_SendWeaponAnim( self, self.Anims.Draw, 1 ) end
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then 
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_DEAGLE_MAX_CLIP, self.Anims.Reload, CS16_DEAGLE_RELOAD_TIME ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self:Setm_flAccuracy( 0.9 )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:DEAGLEFire( 1.5  * ( 1 - self:Getm_flAccuracy() ), 0.3 )
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:DEAGLEFire( 0.25 * ( 1 - self:Getm_flAccuracy() ), 0.3 )
	elseif self.Owner:Crouching() then
		self:DEAGLEFire( 0.115 * ( 1 - self:Getm_flAccuracy() ), 0.3 )
	else
		self:DEAGLEFire( 0.13 * ( 1 - self:Getm_flAccuracy() ), 0.3 )
	end
end

function SWEP:FireAnimation()
	local anim = self:Clip1() == 1 and self.Anims.ShootEmpty or self.Anims.Shoot

	CS16_SendWeaponAnim( self, anim, 1 )
end

function SWEP:DEAGLEFire( flSpread, flCycleTime )
	if self:Clip1() <= 0 then
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) == 0 or self:Clip1() == 0 or self.Primary.ClipSize == -1 then
			self:EmitSound( Sound( "OldPistol.DryFire" ) )
			self:SetNextPrimaryFire( CurTime() + 0.2 )
		end

		return
	end

	self:Setm_iShotsFired( self:Getm_iShotsFired() + 1 )

	if self:Getm_iShotsFired() > 1 then
		return
	end

	if self:Getm_flLastFire() == 0 then
		self:Setm_flLastFire( CurTime() )
	else
		self:Setm_flAccuracy( self:Getm_flAccuracy() - (0.4 - (CurTime() - self:Getm_flLastFire())) * 0.35 )

		if self:Getm_flAccuracy() > 0.9 then
			self:Setm_flAccuracy( 0.9 )
		elseif self:Getm_flAccuracy() < 0.55 then
			self:Setm_flAccuracy( 0.55 )
		end
		self:Setm_flLastFire( CurTime() )
	end

	if SERVER then self:FireAnimation() end

	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, CustomSizeVM = 16 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash2", self, { DrawWorldModel = true, CustomSizeWM = 18 } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), flSpread, CS16_DEAGLE_DISTANCE, CS16_DEAGLE_PENETRATION, "CS16_50AE", CS16_DEAGLE_DAMAGE, CS16_DEAGLE_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "pshell", "1" )

	flCycleTime = flCycleTime - 0.075
	if SERVER then
		self.Owner:CS16_SetViewPunch( self.Owner:CS16_GetViewPunch() + Angle( -2, 0, 0 ) )
	end

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:SetNextSecondaryFire( CurTime() + flCycleTime )
end

function SWEP:WeaponIdle()
	return
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end

function SWEP:IsPistol()
	return true
end