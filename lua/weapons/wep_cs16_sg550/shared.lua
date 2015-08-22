if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Krieg 550 Commando"
    SWEP.Slot = 0
    SWEP.SlotPos = 16
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_sg550.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_sg550.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_SG550_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_SG550_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_SG550_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_556NATO"

SWEP.Sounds = {}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.7857142, sound = Sound( "OldSG550.Clipout" )},
	[2] = {time = 1.6428571, sound = Sound( "OldSG550.Clipin" )},
	[3] = {time = 2.9285714, sound = Sound( "OldSG550.Boltpull" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle1"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot", "shoot2" }

SWEP.FireSound = Sound("OldSG550.Shot1")

local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end
	
	if not self.FirstDeploy then
		if SERVER then CS16_SendWeaponAnim( self, self.Anims.Draw, 1 ) end
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end

	self:Setm_flTimeWeaponIdle( CurTime() + 3 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then 
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_SG550_MAX_CLIP, self.Anims.Reload, CS16_SG550_RELOAD_TIME, 6 ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self:SetScopeZoom( 0 )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:SG550Fire( 0.45 * (1 - self:Getm_flAccuracy()), 0.25 )
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:SG550Fire( 0.15, 0.25 )
	elseif self.Owner:Crouching() then
		self:SG550Fire( 0.04 * (1 - self:Getm_flAccuracy()), 0.25 )
	else
		self:SG550Fire( 0.05 * (1 - self:Getm_flAccuracy()), 0.25 )
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

function SWEP:SG550Fire( flSpread, flCycleTime )
	if self:GetScopeZoom() == 0 then
		flSpread = flSpread + 0.025
	end

	if self:Getm_flLastFire() == 0 then
		self:Setm_flLastFire( CurTime() )
	else
		self:Setm_flAccuracy( ( CurTime() - self:Getm_flLastFire() ) * 0.35 + 0.65 )

		if self:Getm_flAccuracy() > 0.98 then
			self:Setm_flAccuracy( 0.98 )
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

	if SERVER then self:FireAnimation() end
	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash3", self, { DrawViewModel = true, CustomSizeVM = 24 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash3", self, { DrawWorldModel = true } ) 

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_SG550_DISTANCE, CS16_SG550_PENETRATION, "CS16_556NATO", CS16_SG550_DAMAGE, CS16_SG550_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "rshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:SetNextSecondaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 1.8 )

	if SERVER then
		local angle = self.Owner:CS16_GetViewPunch()
		angle.p = angle.p - math.Rand( 1.5, 1.75 ) + ( angle.p / 4 )
		angle.y = angle.y + math.Rand( -1, 1 )
		self.Owner:CS16_SetViewPunch( angle )
	end
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
	return self:GetScopeZoom() == 0 and CS16_SG550_MAX_SPEED or CS16_SG550_MAX_SPEED_ZOOM
end

function SWEP:AdjustMouseSensitivity()
	local var = { [0] = 1, [1] = 0.444, [2] = 0.16 }
	return var[self:GetScopeZoom()] or 1
end

function SWEP:Holster()
	self:SetScopeZoom( 0 )
	return true
end