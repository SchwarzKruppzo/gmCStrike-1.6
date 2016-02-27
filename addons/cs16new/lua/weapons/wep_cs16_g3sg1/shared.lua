if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "D3/AU-1"
	SWEP.DrawAmmo = false
end
SWEP.AnimPrefix = "mp5"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.Price = 5000
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_g3sg1.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/p_g3sg1.mdl"
SWEP.PickupModel   		= "models/cs16/w_g3sg1.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_G3SG1_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_G3SG1_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_G3SG1_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_762NATO"

SWEP.Sounds = {}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.53, sound = Sound( "OldG3SG1.Slide" )},
	[2] = {time = 1.76, sound = Sound( "OldG3SG1.Clipout" )},
	[3] = {time = 2.83, sound = Sound( "OldG3SG1.Clipin" )},
	[4] = {time = 3.86, sound = Sound( "OldG3SG1.Slide" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle1"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot", "shoot2" }

SWEP.FireSound = Sound("OldG3SG1.Shot1")

local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end
	
	if not self.FirstDeploy then
		CS16_SendWeaponAnim( self, self.Anims.Draw, 1 )
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end

	self.Owner:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )

	self:Setm_flTimeWeaponIdle( CurTime() + 3 )
	self:SetNextPrimaryFire( CurTime() + 0.5 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then 
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_G3SG1_MAX_CLIP, self.Anims.Reload, CS16_G3SG1_RELOAD_TIME, 6 ) then
		self:SetScopeZoom( 0 )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:G3SG1Fire( 0.45, 0.25 )
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:G3SG1Fire( 0.15, 0.25 )
	elseif self.Owner:Crouching() then
		self:G3SG1Fire( 0.035, 0.25 )
	else
		self:G3SG1Fire( 0.055, 0.25 )
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() then 
		return
	end

	if self:GetScopeZoom() == 0 then
		self:SetScopeZoom( 1 )
	elseif self:GetScopeZoom() == 1 then
		self:SetScopeZoom( 2 )
	else
		self:SetScopeZoom( 0 )
	end

	self:EmitSound("weapons/zoom.wav")

	self:SetNextSecondaryFire( CurTime() + 0.3 )
end

function SWEP:FireAnimation()
	CS16_SendWeaponAnim( self, self.Anims.Shoot, 1 )
end

function SWEP:G3SG1Fire( flSpread, flCycleTime )
	if self:GetScopeZoom() == 0 then
		flSpread = flSpread + 0.025
	end

	local spreadModifier = 0.02

	if self:Getm_flLastFire() == 0 then
		self:Setm_flAccuracy( 0.98 )
		self:Setm_flLastFire( CurTime() )
	else
		self:Setm_flAccuracy( ( CurTime() - self:Getm_flLastFire() ) * 0.35 + 0.65 )

		if self:Getm_flAccuracy() > 0.98 then
			self:Setm_flAccuracy( 0.98 )
		else
			spreadModifier = 1 - self:Getm_flAccuracy()
		end

		self:Setm_flLastFire( CurTime() )
	end

	if self:Clip1() <= 0 then
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) == 0 or self:Clip1() == 0 or self.Primary.ClipSize == -1 then
			self:EmitSound( Sound( "OldRifle.DryFire" ) )
			self:SetNextPrimaryFire( CurTime() + 0.2 )
		end

		return
	end

	self:FireAnimation()
	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash3", self, { DrawViewModel = true, CustomSizeVM = 24 } )
	osmes.SpawnEffect( nil, "muzzleflash1", self, { DrawWorldModel = true, CustomSizeWM = 30 } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread * spreadModifier, CS16_G3SG1_DISTANCE, CS16_G3SG1_PENETRATION, "CS16_762NATO", CS16_G3SG1_DAMAGE, CS16_G3SG1_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "rshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:SetNextSecondaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 1.8 )
	
	local angle = self.Owner:CS16_GetViewPunch( CLIENT )
	angle.p = angle.p - math.Rand( 0.75, 1.25 ) + 0.25
	angle.y = angle.y + math.Rand( -1, 1 )
	self.Owner:CS16_SetViewPunch( angle, true )
end

function SWEP:WeaponIdle()
	if self:Getm_flTimeWeaponIdle() > CurTime() then
		return
	end

	if self:Clip1() != 0 then 
		self:Setm_flTimeWeaponIdle( CurTime() + 60 )
		CS16_SendWeaponAnim( self, self.Anims.Idle, 1 )
	end
end

function SWEP:IsSniperRifle()
	return true
end

function SWEP:GetMaxSpeed()
	return self:GetScopeZoom() == 0 and CS16_G3SG1_MAX_SPEED or CS16_G3SG1_MAX_SPEED_ZOOM
end

function SWEP:AdjustMouseSensitivity()
	local var = { [0] = 1, [1] = 0.444, [2] = 0.16 }
	return var[self:GetScopeZoom()] or 1
end

function SWEP:Holster()
	if self:Getm_bInReload() then 
		self:Setm_bInReload( false )
	end
	self:SetScopeZoom( 0 )
	return true
end