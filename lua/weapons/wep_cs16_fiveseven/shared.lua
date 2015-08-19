if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Fiveseven"
    SWEP.Slot = 1
    SWEP.SlotPos = 6
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_fiveseven.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_fiveseven.mdl"
SWEP.HoldType			= "pistol"

SWEP.Weight				= CS16_FIVESEVEN_WEIGHT

SWEP.Primary.ClipSize		= CS16_FIVESEVEN_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_FIVESEVEN_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_57MM"

SWEP.MaxSpeed 				= 250

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.4333333333333333, sound = Sound( "OldSeven.SlidePull" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.5, sound = Sound( "OldSeven.ClipOut" )},
	[2] = {time = 1.366666666666667, sound = Sound( "OldSeven.ClipIn" )},
	[3] = {time = 2.5, sound = Sound( "OldSeven.SlideRelease" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle1"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2" }
SWEP.Anims.ShootEmpty = "shoot_empty"

SWEP.FireSound = Sound("OldSeven.Shot1")


local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end

	self:Setm_flAccuracy( 0.92 )
	self.MaxSpeed = CS16_FIVESEVEN_MAX_SPEED

	if not self.FirstDeploy then
		if SERVER then CS16_SendWeaponAnim( self, self.Anims.Draw, 1 ) end
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end

	self:Setm_flTimeWeaponIdle( CurTime() + 4 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then 
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_FIVESEVEN_MAX_CLIP, self.Anims.Reload, CS16_FIVESEVEN_RELOAD_TIME, 3.5 ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self:Setm_flAccuracy( 0.92 )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:FiveSevenFire( 1.5  * ( 1 - self:Getm_flAccuracy() ), 0.2 )
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:FiveSevenFire( 0.255 * ( 1 - self:Getm_flAccuracy() ), 0.2 )
	elseif self.Owner:Crouching() then
		self:FiveSevenFire( 0.075 * ( 1 - self:Getm_flAccuracy() ), 0.2 )
	else
		self:FiveSevenFire( 0.15 * ( 1 - self:Getm_flAccuracy() ), 0.2 )
	end
end

function SWEP:FireAnimation()
	local anim = self:Clip1() == 1 and self.Anims.ShootEmpty or self.Anims.Shoot

	CS16_SendWeaponAnim( self, anim, 1 )
end
function SWEP:FiveSevenFire( flSpread, flCycleTime )
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
		self:Setm_flAccuracy( self:Getm_flAccuracy() - (0.275 - (CurTime() - self:Getm_flLastFire())) * 0.25 )

		if self:Getm_flAccuracy() > 0.92 then
			self:Setm_flAccuracy( 0.92 )
		elseif self:Getm_flAccuracy() < 0.725 then
			self:Setm_flAccuracy( 0.725 )
		end
		self:Setm_flLastFire( CurTime() )
	end

	if SERVER then self:FireAnimation() end

	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash2", self, { DrawWorldModel = true } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), flSpread, CS16_FIVESEVEN_DISTANCE, CS16_FIVESEVEN_PENETRATION, "CS16_57MM", CS16_FIVESEVEN_DAMAGE, CS16_FIVESEVEN_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "pshell", "1" )

	flCycleTime = flCycleTime - 0.05
	if SERVER then
		self.Owner:CS16_SetViewPunch( self.Owner:CS16_GetViewPunch() + Angle( -2, 0, 0 ) )
	end

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 2 )
end

function SWEP:WeaponIdle()
	if self:Getm_flTimeWeaponIdle() > CurTime() then
		return
	end

	if self.Owner.HasCS16Shield and self.Owner:HasCS16Shield() then
		self:Setm_flTimeWeaponIdle( CurTime() + 20 )

		//if (FBitSet(m_iWeaponState, WPNSTATE_SHIELD_DRAWN))
		//{
		//	SendWeaponAnim(P228_SHIELD_IDLE_UP, UseDecrement() != FALSE);
		//}
	elseif self:Clip1() != 0 then 
		self:Setm_flTimeWeaponIdle( CurTime() + 3.0625 )
		CS16_SendWeaponAnim( self, self.Anims.Idle, 1 )
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end

function SWEP:IsPistol()
	return true
end