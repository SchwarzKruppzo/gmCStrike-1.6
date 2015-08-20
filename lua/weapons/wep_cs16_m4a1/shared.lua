if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Maverick M4A1 Carbine"
    SWEP.Slot = 0
    SWEP.SlotPos = 6
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_m4a1.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_m4a1.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_M4A1_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_M4A1_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_M4A1_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_556NATO"

SWEP.MaxSpeed 				= 250

SWEP.Sounds = {} 
SWEP.Sounds["draw"] = {
	[1] = {time = 0.025, sound = Sound( "OldM4A1.Deploy" )},
	[2] = {time = 0.425, sound = Sound( "OldM4A1.BoltPull" )},
}
SWEP.Sounds["draw_unsil"] = {
	[1] = {time = 0.025, sound = Sound( "OldM4A1.Deploy" )},
	[2] = {time = 0.425, sound = Sound( "OldM4A1.BoltPull" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.6756756756756757, sound = Sound( "OldM4A1.ClipOut" )},
	[2] = {time = 1.432432432432432, sound = Sound( "OldM4A1.ClipIn" )},
	[3] = {time = 2.378378378378378, sound = Sound( "OldM4A1.BoltPull" )},
}
SWEP.Sounds["reload_unsil"] = {
	[1] = {time = 0.6756756756756757, sound = Sound( "OldM4A1.ClipOut" )},
	[2] = {time = 1.432432432432432, sound = Sound( "OldM4A1.ClipIn" )},
	[3] = {time = 2.378378378378378, sound = Sound( "OldM4A1.BoltPull" )},
}
SWEP.Sounds["add_silencer"] = {
	[1] = {time = 1.26, sound = Sound( "OldM4A1.AddSilencer" )},
}
SWEP.Sounds["detach_silencer"] = {
	[1] = {time = 0.7, sound = Sound( "OldM4A1.DetachSilencer" )},
}

SWEP.Anims = {}
SWEP.Anims.IdleSilenced = "idle"
SWEP.Anims.DrawSilenced = "draw"
SWEP.Anims.ReloadSilenced = "reload"
SWEP.Anims.ShootSilenced = { "shoot1", "shoot2", "shoot3" }
SWEP.Anims.ShootEmptySilenced = { "shoot1", "shoot2", "shoot3" }
SWEP.Anims.Idle = "idle_unsil"
SWEP.Anims.Draw = "draw_unsil"
SWEP.Anims.Reload = "reload_unsil"
SWEP.Anims.Shoot = { "shoot1_unsil", "shoot2_unsil", "shoot3_unsil" }
SWEP.Anims.ShootEmpty = { "shoot1_unsil", "shoot2_unsil", "shoot3_unsil" }
SWEP.Anims.AttachSilencer = "add_silencer"
SWEP.Anims.DetachSilencer = "detach_silencer"

SWEP.FireSound = Sound("OldM4A1.Shot1")
SWEP.FireSoundSilenced = Sound("OldM4A1.Shot1_Silenced")

local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end
	
	self:Setm_flAccuracy( 0.2 )
	self.MaxSpeed = CS16_M4A1_MAX_SPEED

	local anim = self:GetSilenced() and self.Anims.DrawSilenced or self.Anims.Draw

	if not self.FirstDeploy then
		if SERVER then CS16_SendWeaponAnim( self, anim, 1 ) end
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, anim, 1, 0, self.Owner:Ping() / 1000 )
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

	local anim = self:GetSilenced() and self.Anims.ReloadSilenced or self.Anims.Reload
	if self:CS16_DefaultReload( CS16_M4A1_MAX_CLIP, anim, CS16_M4A1_RELOAD_TIME, 6 ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self:Setm_flAccuracy( 0.2 )
		self:Setm_iShotsFired( 0 )
	end
end

function SWEP:PrimaryAttack()
	if self:GetSilenced() then
		if !self.Owner:IsOnGround() then
			self:M4A1Fire( 0.035 + (0.4 * self:Getm_flAccuracy()), 0.0875 )
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:M4A1Fire( 0.035 + (0.07  * self:Getm_flAccuracy()), 0.0875 )
		else
			self:M4A1Fire( 0.025 * self:Getm_flAccuracy(), 0.0875 )
		end
	else
		if !self.Owner:IsOnGround() then
			self:M4A1Fire( 0.035 + (0.4 * self:Getm_flAccuracy()), 0.0875 )
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:M4A1Fire( 0.035 + (0.07 * self:Getm_flAccuracy()), 0.0875 )
		else
			self:M4A1Fire( 0.02 * self:Getm_flAccuracy(), 0.0875 )
		end
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire()  then 
		return
	end

	if self:GetSilenced() then
		self:SetSilenced( false )
		if SERVER then CS16_SendWeaponAnim( self, self.Anims.DetachSilencer, 1 ) end
	else
		self:SetSilenced( true )
		if SERVER then CS16_SendWeaponAnim( self, self.Anims.AttachSilencer, 1 ) end
	end

	self:Setm_flTimeWeaponIdle( CurTime() + 2.0 )
	self:SetNextSecondaryFire( CurTime() + 2.0 )
	self:SetNextPrimaryFire( CurTime() + 2.0 )
end

function SWEP:FireAnimation()
	local anim_empty = self:GetSilenced() and self.Anims.ShootEmptySilenced or self.Anims.ShootEmpty
	local anim_shoot = self:GetSilenced() and self.Anims.ShootSilenced or self.Anims.Shoot
	local anim = self:Clip1() == 1 and anim_empty or anim_shoot

	CS16_SendWeaponAnim( self, anim, 1 )
end

function SWEP:RecalculateAccuracy()
	self:Setm_flAccuracy( ( ( self:Getm_iShotsFired() * self:Getm_iShotsFired() * self:Getm_iShotsFired() ) / 220 ) + 0.3 )
end

function SWEP:M4A1Fire( flSpread, flCycleTime )
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

	local attachment = self:GetSilenced() and "0" or "2"
	local muzzle = self:GetSilenced() and "muzzleflash2" or "muzzleflash3"
	local muzzle_size = self:GetSilenced() and 10 or 18
	osmes.SpawnEffect( self.Owner, muzzle, self, { DrawViewModel = true, atID = attachment, CustomSizeVM = muzzle_size } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash3", self, { DrawWorldModel = true } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), flSpread, CS16_M4A1_DISTANCE, CS16_M4A1_PENETRATION, "CS16_556NATO", CS16_M4A1_DAMAGE, CS16_M4A1_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	local sound = self:GetSilenced() and self.FireSoundSilenced or self.FireSound
	self:EmitSound( sound )

	self:CreateShell( "rshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:SetNextSecondaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 1.5 )

	if SERVER then
		if !self.Owner:IsOnGround() then
			self:KickBack( 1.2, 0.5, 0.23, 0.15, 5.5, 3.5, 6 )
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:KickBack( 1.0, 0.45, 0.28, 0.045, 3.75, 3.0, 7 )
		elseif self.Owner:Crouching() then
			self:KickBack( 0.6, 0.3, 0.2, 0.0125, 3.25, 2.0, 7 )
		else
			self:KickBack( 0.65, 0.35, 0.25, 0.015, 3.5, 2.25, 7 )
		end
	end
end

function SWEP:WeaponIdle()
	if self:Getm_flTimeWeaponIdle() > CurTime() then
		return
	end

	if self:Clip1() != 0 then 
		local anim = self:GetSilenced() and self.Anims.IdleSilenced or self.Anims.Idle
		self:Setm_flTimeWeaponIdle( CurTime() + 20 )
		CS16_SendWeaponAnim( self, anim, 1 )
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end
