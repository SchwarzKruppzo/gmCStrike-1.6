if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "TMP"
    SWEP.Slot = 0
    SWEP.SlotPos = 11
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_tmp.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_tmp.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_TMP_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_TMP_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_TMP_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_9MM"

SWEP.MaxSpeed 				= 250

SWEP.Sounds = {}
SWEP.Sounds["reload"] = {
	[1] = {time = 0,48, sound = Sound( "OldTMP.ClipOut" )},
	[2] = {time = 1,28, sound = Sound( "OldTMP.ClipIn" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle1"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot_1", "shoot_2", "shoot_3" }
SWEP.Anims.ShootEmpty = { "shoot_1", "shoot_2", "shoot_3" }

SWEP.FireSound = Sound("OldTMP.Shot1")


local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end
	
	self:Setm_flAccuracy( 0.2 )
	self.MaxSpeed = CS16_TMP_MAX_SPEED

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

	if self:CS16_DefaultReload( CS16_TMP_MAX_CLIP, self.Anims.Reload, CS16_TMP_RELOAD_TIME, 2.5 ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self:Setm_flAccuracy( 0.2 )
		self:Setm_iShotsFired( 0 )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:TMPFire( 0.25  * self:Getm_flAccuracy(), 0.07 )
	else
		self:TMPFire( 0.03 * self:Getm_flAccuracy(), 0.07 )
	end
end

function SWEP:FireAnimation()
	local anim = self:Clip1() == 1 and self.Anims.ShootEmpty or self.Anims.Shoot

	CS16_SendWeaponAnim( self, anim, 1 )
end

function SWEP:RecalculateAccuracy()
	self:Setm_flAccuracy( ( ( self:Getm_iShotsFired() * self:Getm_iShotsFired() * self:Getm_iShotsFired() ) / 200 ) + 0.55 )
end

function SWEP:TMPFire( flSpread, flCycleTime )
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

	if SERVER then self:FireAnimation() end

	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, CustomSizeVM = 12 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash2", self, { DrawWorldModel = true } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), flSpread, CS16_TMP_DISTANCE, CS16_TMP_PENETRATION, "CS16_9MM", CS16_TMP_DAMAGE, CS16_TMP_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "pshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 2 )

	if SERVER then
		if !self.Owner:IsOnGround() then
			self:KickBack( 1.1, 0.5, 0.35, 0.045, 4.5, 3.5, 6 )
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:KickBack( 0.8, 0.4, 0.2, 0.03, 3.0, 2.5, 7 )
		elseif self.Owner:Crouching() then
			self:KickBack( 0.7, 0.35, 0.125, 0.025, 2.5, 2.0, 10 )
		else
			self:KickBack( 0.725, 0.375, 0.15, 0.025, 2.75, 2.25, 9 )
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