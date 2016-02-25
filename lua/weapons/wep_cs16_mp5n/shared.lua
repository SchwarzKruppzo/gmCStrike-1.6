if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "KM Sub-Machine Gun"
	SWEP.DrawAmmo = false
end
SWEP.AnimPrefix = "mp5"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.Price = 1500

SWEP.Category = "Counter-Strike 1.6"
SWEP.Base = "cs16_base"
SWEP.Author            = "Schwarz Kruppzo"
SWEP.Contact        = ""
SWEP.Purpose        = ""

SWEP.ViewModelFOV    = 73
SWEP.ViewModelFlip    = true

SWEP.Spawnable            = true
SWEP.AdminSpawnable        = true

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_mp5.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/p_mp5.mdl"
SWEP.PickupModel   		= "models/cs16/w_mp3.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_MP5NAVY_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_MP5N_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_MP5N_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_9MM"

SWEP.MaxSpeed 				= 250

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.3714285714285714, sound = Sound( "OldMP5.SlideBack" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.3947368421052632, sound = Sound( "OldMP5.ClipOut" )},
	[2] = {time = 1.210526315789474, sound = Sound( "OldMP5.ClipIn" )},
	[3] = {time = 2.026315789473684, sound = Sound( "OldMP5.SlideRelease" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle1"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2", "shoot3" }

SWEP.FireSound = Sound("OldMP5.Shot1")


local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end
	
	self:Setm_flAccuracy( 0 )
	self.MaxSpeed = CS16_MP5N_MAX_SPEED

	if not self.FirstDeploy then
		CS16_SendWeaponAnim( self, self.Anims.Draw, 1 )
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end

	self.Owner:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
	
	self:Setm_flTimeWeaponIdle( CurTime() + 4 )
	self:SetNextPrimaryFire( CurTime() + 0.5 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_MP5N_MAX_CLIP, self.Anims.Reload, CS16_MP5N_RELOAD_TIME, 6 ) then
		self:Setm_flAccuracy( 0 )
		self:Setm_iShotsFired( 0 )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:MP5NFire( 0.2  * self:Getm_flAccuracy(), 0.075 )
	else
		self:MP5NFire( 0.04 * self:Getm_flAccuracy(), 0.075 )
	end
end

function SWEP:FireAnimation()
	CS16_SendWeaponAnim( self, self.Anims.Shoot, 1 )
end

function SWEP:RecalculateAccuracy()
	self:Setm_flAccuracy( ( ( self:Getm_iShotsFired() * self:Getm_iShotsFired() * self:Getm_iShotsFired() ) / 220 ) + 0.45 )
end

function SWEP:MP5NFire( flSpread, flCycleTime )
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
	if self:Getm_flAccuracy() > 0.75 then
		self:Setm_flAccuracy( 0.75 )
	end

	self:FireAnimation()

	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true } )
	osmes.SpawnEffect( nil, "muzzleflash1", self, { DrawWorldModel = true, CustomSizeWM = 24 } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), flSpread, CS16_MP5N_DISTANCE, CS16_MP5N_PENETRATION, "CS16_9MM", CS16_MP5N_DAMAGE, CS16_MP5N_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "pshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 2 )

	if !self.Owner:IsOnGround() then
		self:KickBack( 0.9, 0.475, 0.35, 0.0425, 5.0, 3.0, 6 )
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack( 0.5, 0.275, 0.2, 0.03, 3.0, 2.0, 10 )
	elseif self.Owner:Crouching() then
		self:KickBack( 0.225, 0.15, 0.1, 0.015, 2.0, 1.0, 10 )
	else
		self:KickBack( 0.25, 0.175, 0.125, 0.02, 2.25, 1.25, 10 )
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