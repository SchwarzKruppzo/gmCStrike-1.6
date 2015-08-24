if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "HE Grenade"
    SWEP.Slot = 3
    SWEP.SlotPos = 1
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_hegrenade.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_hegrenade.mdl"
SWEP.HoldType			= "grenade"

SWEP.Weight				= CS16_HEGRENADE_WEIGHT

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= CS16_HEGRENADE_MAX_CARRY
SWEP.Primary.Ammo			= "CS16_HEGRENADE"

SWEP.MaxSpeed 				= 250

SWEP.Sounds = {}
SWEP.Sounds["pullpin"] = {
	[1] = {time = 0.65853, sound = Sound( "OldDefault.PullPin_Grenade" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle"
SWEP.Anims.Draw = "deploy"
SWEP.Anims.Throw = "throw"
SWEP.Anims.PullPin = "pullpin"

local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end

	self:Setm_bRedraw( false )
	self:Setm_bPinPulled( false )
	self:Setm_flThrowTime( 0 )
	self.MaxSpeed = CS16_HEGRENADE_MAX_SPEED

	if SERVER then 
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 then
			// TODO: self:CS16_SelectBestWeapon()
			SafeRemoveEntity( self )
			return false
		end
	end

	if not self.FirstDeploy then
		CS16_SendWeaponAnim( self, self.Anims.Draw, 1 )
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end

	return true
end

function SWEP:Holster()
	self:Setm_bRedraw( false )
	self:Setm_bPinPulled( false )
	self:Setm_flThrowTime( 0 )

	self:SetNextPrimaryFire( CurTime() + 0.5 )

	if SERVER then 
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 then
			// TODO: self:CS16_SelectBestWeapon()
			SafeRemoveEntity( self )
		end
	end

	return true
end

function SWEP:Reload()
	return
end

function SWEP:PrimaryAttack()
	if self:Getm_bRedraw() or self:Getm_bPinPulled() or self:Getm_flThrowTime() > 0 then return end
	if self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 then return end

	CS16_SendWeaponAnim( self, self.Anims.PullPin, 1 )
	self:Setm_bPinPulled( true )

	self:SetNextPrimaryFire( CurTime() + 0.5 )
	self:Setm_flTimeWeaponIdle( CurTime() + 0.5 )
end

function SWEP:ShootTimed2( vecSrc, vecThrow, time )
	if CLIENT then return end

	local grenade = ents.Create("cs16_hegrenade")
	grenade:SetAngles( vecThrow:Angle() )
	grenade:SetPos( vecSrc )
	grenade:Spawn()
	grenade:SetOwner( self.Owner )
	grenade:Setm_hOwner( self.Owner )
	grenade:Setm_flTime( time )
	grenade:SetVelocity( vecThrow )
end

function SWEP:Throw()
	local angleThrow = self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch()

	if angleThrow.p < 0 then
		angleThrow.p = -10 + angleThrow.p * ( (90 - 10) / 90.0 )
	else
		angleThrow.p = -10 + angleThrow.p * ( (90 + 10) / 90.0 )
	end

	local vel = ( 90 - angleThrow.p ) * 6

	if vel > 750 then
		vel = 750
	end
	local forward = angleThrow:Forward()

	local viewOffset = self.Owner:GetViewOffset()
	if self.Owner:Crouching() then viewOffset = self.Owner:GetViewOffsetDucked() end
	local vecSrc = self.Owner:GetPos() + viewOffset

	local tracedata = {}
	tracedata.start = vecSrc
	tracedata.endpos = vecSrc + forward * 16
	tracedata.mins = Vector( -2, -2, -2 )
	tracedata.maxs = Vector( 2, 2, 2 )
	tracedata.mask = MASK_SOLID
	tracedata.filter = self.Owner
	local trace = util.TraceHull( tracedata )
		
	vecSrc = trace.HitPos
	local vecThrow = forward * vel + self.Owner:GetVelocity()

	self:ShootTimed2( vecSrc, vecThrow, 1.5 )

	CS16_SendWeaponAnim( self, self.Anims.Throw, 1 )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self:TakePrimaryAmmo( 1 )

	self:Setm_bRedraw( true )
	self:Setm_flThrowTime( 0 )
	self:SetNextPrimaryFire( CurTime() + 0.5 )
	self:Setm_flTimeWeaponIdle( CurTime() + 0.75 )

	if self.Owner:GetAmmoCount( self.Primary.Ammo ) == 0 then
		self:SetNextSecondaryFire( CurTime() + 0.5 )
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		self:Setm_flTimeWeaponIdle( CurTime() + 0.5 )
	end
end


function SWEP:WeaponIdle()
	if self:Getm_flTimeWeaponIdle() > CurTime() then
		return
	end

	if self:Getm_bRedraw() then
		self:Setm_bRedraw( false )
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1 )

			self:Setm_flTimeWeaponIdle( CurTime() + math.Rand( 10, 15 ) )
		else
			if SERVER then 
				// TODO: self:CS16_SelectBestWeapon()
				SafeRemoveEntity( self )
			end
		end
	elseif self.Owner:GetAmmoCount( self.Primary.Ammo ) != 0 and !self:Getm_bPinPulled() then
		self:Setm_flTimeWeaponIdle( CurTime() + math.Rand( 10, 15 ) )
		CS16_SendWeaponAnim( self, self.Anims.Idle, 1 )
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end