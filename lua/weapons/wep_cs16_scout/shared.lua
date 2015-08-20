if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Schmidt Scout"
    SWEP.Slot = 0
    SWEP.SlotPos = 9
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_scout.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_scout.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_SCOUT_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_SCOUT_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_SCOUT_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_762NATO"

SWEP.Sounds = {}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.43, sound = Sound( "OldScout.Clipout" )},
	[2] = {time = 1.23, sound = Sound( "OldScout.Clipin" )},
}
SWEP.Sounds["shoot_1"] = {
	[1] = {time = 0.37142857, sound = Sound( "OldScout.Bolt" )},
}
SWEP.Sounds["shoot_2"] = {
	[1] = {time = 0.37142857, sound = Sound( "OldScout.Bolt" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle1"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot_1", "shoot_2" }

SWEP.FireSound = Sound("OldScout.Shot1")

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

	self:SetNextPrimaryFire( CurTime() + 1.25 )
	self:SetNextSecondaryFire( CurTime() + 1 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then 
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_SCOUT_MAX_CLIP, self.Anims.Reload, CS16_SCOUT_RELOAD_TIME, 6 ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:SCOUTFire( 0.2, 1.25 )
	elseif self.Owner:GetVelocity():Length2D() > 170 then
		self:SCOUTFire( 0.075, 1.25 )
	elseif self.Owner:Crouching() then
		self:SCOUTFire( 0.0, 1.25 )
	else
		self:SCOUTFire( 0.007, 1.25 )
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

	self:SetNextSecondaryFire( CurTime() + 0.3)
end

function SWEP:FireAnimation()
	CS16_SendWeaponAnim( self, self.Anims.Shoot, 1 )
end

function SWEP:SCOUTFire( flSpread, flCycleTime )
	if self:GetScopeZoom() != 0 then
		self:SetResumeZoom( true )
		self:SetLastScopeZoom( self:GetScopeZoom() )
		self:SetScopeZoom( 0 )
	else
		flSpread = flSpread + 0.025
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

	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, CustomSizeVM = 20 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash3", self, { DrawWorldModel = true } ) 

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles(), flSpread, CS16_SCOUT_DISTANCE, CS16_SCOUT_PENETRATION, "CS16_762NATO", CS16_SCOUT_DAMAGE, CS16_SCOUT_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:Setm_flEjectBrass( CurTime() + 0.56 )

	if SERVER then
		self.Owner:CS16_SetViewPunch( self.Owner:CS16_GetViewPunch() + Angle( -2, 0, 0 ) )
	end

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 1.8 )
end

function SWEP:WeaponIdle() end

function SWEP:IsSniperRifle()
	return true
end

function SWEP:GetMaxSpeed()
	return self:GetScopeZoom() == 0 and CS16_SCOUT_MAX_SPEED or CS16_SCOUT_MAX_SPEED_ZOOM
end

function SWEP:AdjustMouseSensitivity()
	local var = { [0] = 1, [1] = 0.444, [2] = 0.16 }
	return var[self:GetScopeZoom()] or 1
end

function SWEP:Holster()
	self:SetScopeZoom( 0 )
	self:SetLastScopeZoom( 0 )
	return true
end