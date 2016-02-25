if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Night Hawk .50c"
	SWEP.DrawAmmo = false
end
SWEP.AnimPrefix = "pistol"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.Price = 650

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
SWEP.ViewModelMDLShield = "models/weapons/cs16/shield/v_shield_deagle.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/p_deagle.mdl"
SWEP.WorldModelShield	= "models/weapons/cs16/shield/p_shield_deagle.mdl"
SWEP.PickupModel   		= "models/cs16/w_deagle.mdl"
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
SWEP.Sounds["reload_shield"] = {
	[1] = {time = 0.4666666666666667, sound = Sound( "OldDeagle.Clipout" )},
	[2] = {time = 1.133333333333333, sound = Sound( "OldDeagle.Clipin" )},
	[3] = {time = 2.5, sound = Sound( "OldSeven.SlideRelease" )},
}

SWEP.Anims = {}
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

SWEP.FireSound = Sound("OldDeagle.Shot1")

local SP = game.SinglePlayer()

if CLIENT then 
	function SWEP:ChangeViewModel( strBool )
		local anim = self.Owner:HasShield() and self.Anims.DrawShield or self.Anims.Draw

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

	self:Setm_flAccuracy( 0.9 )
	self.MaxSpeed = CS16_DEAGLE_MAX_SPEED

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
	
	self:SetNextPrimaryFire( CurTime() + 0.5 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then 
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	local anim = self.Owner:HasShield() and self.Anims.ReloadShield or self.Anims.Reload
	if self:CS16_DefaultReload( CS16_DEAGLE_MAX_CLIP, anim, CS16_DEAGLE_RELOAD_TIME, nil, self.Owner:HasShield() and "reload_shield" or nil ) then
		self:Setm_flAccuracy( 0.9 )
	end
end

function SWEP:PrimaryAttack()
	if self.Owner:IsShieldDrawn() then return end

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
	anim = self.Owner:HasShield() and (self:Clip1() == 1 and self.Anims.ShootEmptyShield or self.Anims.ShootShield) or anim

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

	self:FireAnimation()

	self:TakePrimaryAmmo( 1 )

	local attachment = self.Owner:HasShield() and "1" or nil
	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, atID = attachment, CustomSizeVM = 16 } )
	osmes.SpawnEffect( nil, "muzzleflash1", self, { DrawWorldModel = true, CustomSizeWM = 10 } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_DEAGLE_DISTANCE, CS16_DEAGLE_PENETRATION, "CS16_50AE", CS16_DEAGLE_DAMAGE, CS16_DEAGLE_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	local eject = self.Owner:HasShield() and "0" or "1"
	self:CreateShell( "pshell", eject )

	flCycleTime = flCycleTime - 0.075

	self.Owner:CS16_SetViewPunch( self.Owner:CS16_GetViewPunch( CLIENT ) + Angle( -2, 0, 0 ), true )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:SetNextSecondaryFire( CurTime() + flCycleTime )
end

function SWEP:WeaponIdle()
	if self.Owner.HasShield and self.Owner:HasShield() then
		if self.Owner:IsShieldDrawn() then
			self:Setm_flTimeWeaponIdle( CurTime() + 20 )
			CS16_SendWeaponAnim( self, self.Anims.ShieldIdle, 1 )
		else
			local anim = self.Owner:HasShield() and self.Anims.IdleShield or self.Anims.Idle

			self:Setm_flTimeWeaponIdle( CurTime() + 3.0625 )
			CS16_SendWeaponAnim( self, anim, 1 )
		end
	else
		return
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end

function SWEP:IsPistol()
	return true
end