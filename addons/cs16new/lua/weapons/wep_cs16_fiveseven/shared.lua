if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "ES Five-Seven"
	SWEP.DrawAmmo = false
end
SWEP.AnimPrefix = "pistol"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.Price = 750
SWEP.iTeam = 3

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
SWEP.ViewModelMDLShield = "models/weapons/cs16/shield/v_shield_fiveseven.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/p_fiveseven.mdl"
SWEP.WorldModelShield	= "models/weapons/cs16/shield/p_shield_fiveseven.mdl"
SWEP.PickupModel   		= "models/cs16/w_fiveseven.mdl"
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
SWEP.Sounds["reload_shield"] = {
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
SWEP.Anims.IdleShield = "idle1"
SWEP.Anims.DrawShield = "draw"
SWEP.Anims.ShootShield = { "shoot1", "shoot2" }
SWEP.Anims.ShootEmptyShield = "shoot_empty"
SWEP.Anims.ReloadShield = "reload"
SWEP.Anims.ShieldIdle = "shield_idle"
SWEP.Anims.ShieldUp = "shield_up"
SWEP.Anims.ShieldDown = "shield_down"

SWEP.FireSound = Sound("OldSeven.Shot1")


local SP = game.SinglePlayer()

if CLIENT then 
	function SWEP:ChangeViewModel( strBool )
		local anim = self:GetSilenced() and self.Anims.DrawSilenced or self.Anims.Draw
		anim = self.Owner:HasShield() and self.Anims.DrawShield or anim

		if strBool == "1" and self.viewmodel:GetModel() == self.ViewModelMDLShield then return end
		if strBool == "0" and self.viewmodel:GetModel() == self.ViewModelMDL then return end
		
		if strBool == "1" then
			self.viewmodel:SetModel( self.ViewModelMDLShield )
			CS16_SendWeaponAnim( self, anim, 1 )
		else
			self.viewmodel:SetModel( self.ViewModelMDL )
			CS16_SendWeaponAnim( self, anim, 1 )
		end
	end
end
function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end

	if SERVER then
		if self.Owner:HasShield() then
			self:CallOnClient( "ChangeViewModel", "1" )
		else
			self:CallOnClient( "ChangeViewModel", "0" )
		end
	end

	self:Setm_flAccuracy( 0.92 )
	self.MaxSpeed = CS16_FIVESEVEN_MAX_SPEED

	local anim = self.Owner:HasShield() and self.Anims.DrawShield or self.Anims.Draw

	if not self.FirstDeploy then
		if SERVER then CS16_SendWeaponAnim( self, anim, 1, 0, 0, true, self.Owner:HasShield() and "draw_shield" or nil ) end
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, anim, 1, 0, self.Owner:Ping() / 1000 )
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

	local anim = self.Owner:HasShield() and self.Anims.ReloadShield or self.Anims.Reload
	if self:CS16_DefaultReload( CS16_FIVESEVEN_MAX_CLIP, anim, CS16_FIVESEVEN_RELOAD_TIME, 3.5, self.Owner:HasShield() and "reload_shield" or nil ) then
		self:Setm_flAccuracy( 0.92 )
	end
end

function SWEP:PrimaryAttack()
	if self.Owner:IsShieldDrawn() then return end
	
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
	anim = self.Owner:HasShield() and (self:Clip1() == 1 and self.Anims.ShootEmptyShield or self.Anims.ShootShield) or anim

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

	self:FireAnimation()

	self:TakePrimaryAmmo( 1 )

	local attachment = self.Owner:HasShield() and "1" or nil
	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, atID = attachment } )
	osmes.SpawnEffect( nil, "muzzleflash1", self, { DrawWorldModel = true, CustomSizeWM = 10 } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_FIVESEVEN_DISTANCE, CS16_FIVESEVEN_PENETRATION, "CS16_57MM", CS16_FIVESEVEN_DAMAGE, CS16_FIVESEVEN_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	local eject = self.Owner:HasShield() and "0" or "1"
	self:CreateShell( "pshell", eject )

	flCycleTime = flCycleTime - 0.05
	
	self.Owner:CS16_SetViewPunch( self.Owner:CS16_GetViewPunch( CLIENT ) + Angle( -2, 0, 0 ), true )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 2 )
end

function SWEP:WeaponIdle()
	if self:Getm_flTimeWeaponIdle() > CurTime() then
		return
	end

	if self.Owner.HasShield and self.Owner:HasShield() then
		self:Setm_flTimeWeaponIdle( CurTime() + 20 )

		if self.Owner:IsShieldDrawn() then
			CS16_SendWeaponAnim( self, self.Anims.ShieldIdle, 1 )
		end
	elseif self:Clip1() != 0 then 
		local anim = self.Owner:HasShield() and self.Anims.IdleShield or self.Anims.Idle

		self:Setm_flTimeWeaponIdle( CurTime() + 3.0625 )
		CS16_SendWeaponAnim( self, anim, 1 )
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end

function SWEP:IsPistol()
	return true
end