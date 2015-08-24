if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Magnum Sniper Rifle"
    SWEP.Slot = 0
    SWEP.SlotPos = 2
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_awp.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_awp.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_AWP_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_AWP_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_AWP_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_338MAGNUM"

SWEP.Sounds = {}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.86, sound = Sound( "OldAWP.Clipout" )},
	[2] = {time = 1.76, sound = Sound( "OldAWP.Clipin" )},
}
SWEP.Sounds["shoot1"] = {
	[1] = {time = 0.4285714, sound = Sound( "OldAWP.Boltup" )},
	[2] = {time = 0.5428571, sound = Sound( "OldAWP.Boltpull" )},
	[3] = {time = 0.9142857, sound = Sound( "OldAWP.Boltdown" )},
}
SWEP.Sounds["shoot2"] = {
	[1] = {time = 0.4285714, sound = Sound( "OldAWP.Boltup" )},
	[2] = {time = 0.5428571, sound = Sound( "OldAWP.Boltpull" )},
	[3] = {time = 0.9142857, sound = Sound( "OldAWP.Boltdown" )},
}
SWEP.Sounds["shoot3"] = {
	[1] = {time = 0.4285714, sound = Sound( "OldAWP.Boltup" )},
	[2] = {time = 0.5428571, sound = Sound( "OldAWP.Boltpull" )},
	[3] = {time = 0.9142857, sound = Sound( "OldAWP.Boltdown" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle1"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2", "shoot3" }

SWEP.FireSound = Sound("OldAWP.Shot1")

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

	self:SetNextPrimaryFire( CurTime() + 1.45 )
	self:SetNextSecondaryFire( CurTime() + 1 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then 
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_AWP_MAX_CLIP, self.Anims.Reload, CS16_AWP_RELOAD_TIME, 6 ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:AWPFire( 0.85, 1.45 )
	elseif self.Owner:GetVelocity():Length2D() > 170 then
		self:AWPFire( 0.25, 1.45 )
	elseif self.Owner:GetVelocity():Length2D() > 10 then
		self:AWPFire( 0.1, 1.45 )
	elseif self.Owner:Crouching() then
		self:AWPFire( 0.0, 1.45 )
	else
		self:AWPFire( 0.001, 1.45 )
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() or CurTime() < self:GetNextPrimaryFire() then 
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

function SWEP:AWPFire( flSpread, flCycleTime )
	if self:GetScopeZoom() != 0 then
		self:SetResumeZoom( true )
		self:SetLastScopeZoom( self:GetScopeZoom() )
		self:SetScopeZoom( 0 )
	else
		flSpread = flSpread + 0.08
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

	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, CustomSizeVM = 24 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash3", self, { DrawWorldModel = true } ) 

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles(), flSpread, CS16_AWP_DISTANCE, CS16_AWP_PENETRATION, "CS16_338MAGNUM", CS16_AWP_DAMAGE, CS16_AWP_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:Setm_flEjectBrass( CurTime() + 0.55 )

	self.Owner:CS16_SetViewPunch( self.Owner:CS16_GetViewPunch( CLIENT ) + Angle( -2, 0, 0 ), true )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 2 )
end

function SWEP:WeaponIdle() end

function SWEP:IsSniperRifle()
	return true
end

function SWEP:GetMaxSpeed()
	return self:GetScopeZoom() == 0 and CS16_AWP_MAX_SPEED or CS16_AWP_MAX_SPEED_ZOOM
end

function SWEP:AdjustMouseSensitivity()
	local var = { [0] = 1, [1] = 0.444, [2] = 0.133 }
	return var[self:GetScopeZoom()] or 1
end

function SWEP:Holster()
	self:SetScopeZoom( 0 )
	self:SetLastScopeZoom( 0 )
	return true
end