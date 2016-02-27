if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Ingram MAC-10"
	SWEP.DrawAmmo = false
end
SWEP.AnimPrefix = "pistol"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.Price = 1400
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_mac10.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/p_mac10.mdl"
SWEP.PickupModel   		= "models/cs16/w_mac10.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_MAC10_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_MAC10_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_MAC10_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_45ACP"

SWEP.MaxSpeed 				= 250

SWEP.Sounds = {}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.6285714285714286, sound = Sound( "OldMAC10.ClipOut" )},
	[2] = {time = 1.571428571428571, sound = Sound( "OldMAC10.ClipIn" )},
	[3] = {time = 2.485714285714286, sound = Sound( "OldMAC10.BoltPull" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle1"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2", "shoot3" }

SWEP.FireSound = Sound("OldMAC10.Shot1")


local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end
	
	self:Setm_flAccuracy( 0.15 )
	self.MaxSpeed = CS16_MAC10_MAX_SPEED

	if not self.FirstDeploy then
		CS16_SendWeaponAnim( self, self.Anims.Draw, 1 )
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end

	self.Owner:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
	
	self:Setm_flTimeWeaponIdle( CurTime() + 1 )
	self:SetNextPrimaryFire( CurTime() + 0.5 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_MAC10_MAX_CLIP, self.Anims.Reload, CS16_MAC10_RELOAD_TIME, 6 ) then
		self:Setm_flAccuracy( 0.15 )
		self:Setm_iShotsFired( 0 )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:MAC10Fire( 0.375  * self:Getm_flAccuracy(), 0.07 )
	else
		self:MAC10Fire( 0.03 * self:Getm_flAccuracy(), 0.07 )
	end
end

function SWEP:FireAnimation()
	CS16_SendWeaponAnim( self, self.Anims.Shoot, 1 )
end
function SWEP:RecalculateAccuracy()
	self:Setm_flAccuracy( ( ( self:Getm_iShotsFired() * self:Getm_iShotsFired() * self:Getm_iShotsFired() ) / 200 ) + 0.6 )
end

function SWEP:MAC10Fire( flSpread, flCycleTime )
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
	if self:Getm_flAccuracy() > 1.65 then
		self:Setm_flAccuracy( 1.65 )
	end

	self:FireAnimation()

	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, CustomSizeVM = 10 } )
	osmes.SpawnEffect( nil, "muzzleflash1", self, { DrawWorldModel = true, CustomSizeWM = 10 } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), flSpread, CS16_MAC10_DISTANCE, CS16_MAC10_PENETRATION, "CS16_45ACP", CS16_MAC10_DAMAGE, CS16_MAC10_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "pshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 2 )

	if !self.Owner:IsOnGround() then
		self:KickBack( 1.3, 0.55, 0.4, 0.05, 4.75, 3.75, 5 )
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack( 0.9, 0.45, 0.25, 0.035, 3.5, 2.75, 7 )
	elseif self.Owner:Crouching() then
		self:KickBack( 0.75, 0.4, 0.175, 0.03, 2.75, 2.5, 10 )
	else
		self:KickBack( 0.775, 0.425, 0.2, 0.03, 3.0, 2.75, 9 )
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