if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Clarion 5.56"
	SWEP.DrawAmmo = false
end
SWEP.AnimPrefix = "carbine"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.Price = 2250
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_famas.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/p_famas.mdl"
SWEP.PickupModel   		= "models/cs16/w_famas.mdl"
SWEP.HoldType			= "ar2"

SWEP.Weight				= CS16_FAMAS_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_FAMAS_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_FAMAS_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_556NATO"

SWEP.MaxSpeed 				= 250

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.2857142857142857, sound = Sound( "OldFAMAS.Forearm" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.5, sound = Sound( "OldFAMAS.Clipout" )},
	[2] = {time = 1.566666666666667, sound = Sound( "OldFAMAS.Clipin" )},
	[3] = {time = 2.166666666666667, sound = Sound( "OldFAMAS.Forearm" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2", "shoot3" }

SWEP.FireSound = Sound("OldFAMAS.Shot1")


local SP = game.SinglePlayer()
function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end
	
	self:Setm_flAccuracy( 0.2 )
	self.MaxSpeed = CS16_FAMAS_MAX_SPEED

	if not self.FirstDeploy then
		CS16_SendWeaponAnim( self, self.Anims.Draw, 1 )
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end

	self.Owner:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
	
	self:Setm_flTimeWeaponIdle( CurTime() + 1.5 )
	self:SetNextPrimaryFire( CurTime() + 0.5 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then 
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_FAMAS_MAX_CLIP, self.Anims.Reload, CS16_FAMAS_RELOAD_TIME, 4 ) then
		self:Setm_flAccuracy( 0.2 )
		self:Setm_iShotsFired( 0 )
		self:Setm_bDelayFire( false )
	end
end

function SWEP:FireRemaining()
	if self:Getm_flFamasShoot() >= CurTime() then
		return
	end
	self:TakePrimaryAmmo( 1 )

	if self:Clip1() <= 0 then
		self:SetClip1( 0 )
		self:Setm_iFamasShotsFired( 3 )
		self:Setm_flFamasShoot( 0 )
		return
	end

	self:FireAnimation()
	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), self:Getm_flBurstSpread(), 8192, 2, "CS16_556NATO", 30, 0.96, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	osmes.SpawnEffect( self.Owner, "muzzleflash3", self, { DrawViewModel = true, CustomSizeVM = 20 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash2", self, { DrawWorldModel = true, CustomSizeWM = 18 } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self:CreateShell( "pshell", "1" )

	self:Setm_iFamasShotsFired( self:Getm_iFamasShotsFired() + 1 )

	if self:Getm_iFamasShotsFired() == 3 then
		self:Setm_flFamasShoot( 0 )
	else
		self:Setm_flFamasShoot( CurTime() + 0.1 )
	end
end

function SWEP:PrimaryAttack()
	if self.Owner:WaterLevel() == 3 then
		self:EmitSound( Sound( "OldRifle.DryFire" ) )
		self:SetNextPrimaryFire( CurTime() + 0.15 )

		return
	end

	if !self.Owner:IsOnGround() then
		self:FamasFire( 0.030 + 0.3 * self:Getm_flAccuracy(), 0.0825 )
	elseif self.Owner:GetVelocity():Length2D() > 140 then
		self:FamasFire( 0.030 + 0.07 * self:Getm_flAccuracy(), 0.0825 )
	else
		self:FamasFire( 0.02 * self:Getm_flAccuracy(), 0.0825 )
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire()  then 
		return
	end

	if self:GetBurstMode() then
		if self.Owner.OldPrintMessage then
			self.Owner:OldPrintMessage( "Switched to semi-automatic" )
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to semi-automatic" )
		end
		self:SetBurstMode( false )
	else
		if self.Owner.OldPrintMessage then
			self.Owner:OldPrintMessage( "Switched to Burst-Fire mode" )
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to Burst-Fire mode" )
		end
		self:SetBurstMode( true )
	end

	self:SetNextSecondaryFire( CurTime() + 0.3)
end

function SWEP:FireAnimation()
	CS16_SendWeaponAnim( self, self.Anims.Shoot, 1 )
end

function SWEP:RecalculateAccuracy()
	self:Setm_flAccuracy( 0.35 + ( ( self:Getm_iShotsFired() * self:Getm_iShotsFired() * self:Getm_iShotsFired() ) / 215 ) + 0.3 )
end

function SWEP:FamasFire( flSpread, flCycleTime, burst )
	if self:Clip1() <= 0 then
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) == 0 or self:Clip1() == 0 or self.Primary.ClipSize == -1 then
			self:EmitSound( Sound( "OldRifle.DryFire" ) )
			self:SetNextPrimaryFire( CurTime() + 0.2 )
		end

		return
	end

	if self:GetBurstMode() then
		self:Setm_iFamasShotsFired( 0 )
		flCycleTime = 0.55
	else
		flSpread = flSpread + 0.01
	end

	self:Setm_bDelayFire( true )
	self:Setm_iShotsFired( self:Getm_iShotsFired() + 1 )
	self:RecalculateAccuracy()
	if self:Getm_flAccuracy() > 1 then
		self:Setm_flAccuracy( 1 )
	end

	self:FireAnimation()
	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash3", self, { DrawViewModel = true, CustomSizeVM = 20 } )
	osmes.SpawnEffect( nil, "muzzleflash1", self, { DrawWorldModel = true, CustomSizeWM = 35 } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), flSpread, CS16_FAMAS_DISTANCE, CS16_FAMAS_PENETRATION, "CS16_556NATO", CS16_FAMAS_DAMAGE, CS16_FAMAS_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	local sound = self:GetBurstMode() and Sound( "OldFAMAS.Burst" ) or self.FireSound
	self:EmitSound( self.FireSound )

	self:CreateShell( "rshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:SetNextSecondaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 1.1 )

	if !self.Owner:IsOnGround() then
		self:KickBack( 1.25, 0.45, 0.22, 0.18, 5.5, 4, 5 )
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack( 1, 0.45, 0.275, 0.05, 4, 2.5, 7 )
	elseif self.Owner:Crouching() then
		self:KickBack( 0.575, 0.325, 0.2, 0.011, 3.25, 2, 8 )
	else
		self:KickBack( 0.625, 0.375, 0.25, 0.0125, 3.5, 2.25, 8 )
	end

	if self:GetBurstMode() then
		self:Setm_iFamasShotsFired( self:Getm_iFamasShotsFired() + 1 )
		self:Setm_flFamasShoot( CurTime() + 0.1 )
		self:Setm_flBurstSpread( flSpread )
	end
end

function SWEP:WeaponIdle()
	if self:Getm_flTimeWeaponIdle() > CurTime() then
		return
	end

	if self:Clip1() != 0 then 
		self:Setm_flTimeWeaponIdle( CurTime() + 20 )
		CS16_SendWeaponAnim( self, self.Anims.Idle, 1 )
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end