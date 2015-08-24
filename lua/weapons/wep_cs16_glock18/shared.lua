if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "9x19mm Sidearm"
    SWEP.Slot = 1
    SWEP.SlotPos = 3
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_glock18.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_glock18.mdl"
SWEP.HoldType			= "pistol"

SWEP.Weight				= CS16_GLOCK18_WEIGHT

SWEP.Primary.ClipSize		= CS16_GLOCK18_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_GLOCK18_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_9MM"

SWEP.InReload				= false
SWEP.TimeWeaponIdle			= 0
SWEP.Accuracy				= 0.9
SWEP.MaxSpeed 				= 250
SWEP.LastFire				= 0
SWEP.Glock18ShotsFired		= 0
SWEP.Glock18Shoot			= 0
SWEP.ShotsFired 			= 0

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.3777777777777778, sound = Sound( "OldGlock.SlideBack" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.3666666666666667, sound = Sound( "OldGlock.Clipout" )},
	[2] = {time = 1.066666666666667, sound = Sound( "OldGlock.Clipin" )},
	[3] = {time = 1.433333333333333, sound = Sound( "OldGlock.Sliderelease" )},
}

SWEP.Anims = {}
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = "shoot3"
SWEP.Anims.ShootBurst = { "shoot", "shoot2" }
SWEP.Anims.ShootEmpty = "shoot_empty"
SWEP.Anims.ShieldUp = "shield_up"
SWEP.Anims.ShieldDown = "shield_down"
SWEP.Anims.ShieldIdle = "shield_idle"

SWEP.FireSound = Sound("OldGlock.Shot1")

local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end

	self:Setm_flAccuracy( 0.9 )
	self.MaxSpeed = CS16_GLOCK18_MAX_SPEED

	if not self.FirstDeploy then
		CS16_SendWeaponAnim( self, self.Anims.Draw, 1 )
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end
	
	self:Setm_flTimeWeaponIdle( CurTime() + 4 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_GLOCK18_MAX_CLIP, self.Anims.Reload, CS16_GLOCK18_RELOAD_TIME ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self:Setm_flAccuracy( 0.9 )
	end
end

function SWEP:FireRemaining( )
	self:TakePrimaryAmmo( 1 )

	if self:Clip1() < 0 then
		self:SetClip1( 0 )
		self:Setm_iGlock18ShotsFired( 3 )
		self:Setm_flGlock18Shoot( 0 )
		return
	end

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + 2.0 * self.Owner:CS16_GetViewPunch(), 0.05, 8192, 1, "CS16_9MM", 18, 0.9, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, CustomSizeVM = 16 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash2", self, { DrawWorldModel = true, CustomSizeWM = 18 } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self:CreateShell( "pshell", "1" )

	self:Setm_iGlock18ShotsFired( self:Getm_iGlock18ShotsFired() + 1 )

	if self:Getm_iGlock18ShotsFired() == 3 then
		self:Setm_flGlock18Shoot( 0 )
	else
		self:Setm_flGlock18Shoot( CurTime() + 0.1 )
	end
end

function SWEP:PrimaryAttack()
	if self:GetBurstMode() then
		if !self.Owner:IsOnGround() then
			self:GLOCK18Fire( 1.2 * (1 - self:Getm_flAccuracy()), 0.5 )
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:GLOCK18Fire( 0.185 * (1 - self:Getm_flAccuracy()), 0.5 )
		elseif self.Owner:Crouching() then
			self:GLOCK18Fire( 0.095 * (1 - self:Getm_flAccuracy()), 0.5 )
		else
			self:GLOCK18Fire( 0.3 * (1 - self:Getm_flAccuracy()), 0.5 )
		end
	else
		if !self.Owner:IsOnGround() then
			self:GLOCK18Fire( 1.0 * (1 - self:Getm_flAccuracy()), 0.2 )
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:GLOCK18Fire( 0.165 * (1 - self:Getm_flAccuracy()), 0.2 )
		elseif self.Owner:Crouching() then
			self:GLOCK18Fire( 0.075 * (1 - self:Getm_flAccuracy()), 0.2 )
		else
			self:GLOCK18Fire( 0.1 * (1 - self:Getm_flAccuracy()), 0.2 )
		end
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire()  then 
		return
	end

	if self:GetBurstMode() then
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to semi-automatic" )
		self:SetBurstMode( false )
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to Burst-Fire mode" )
		self:SetBurstMode( true )
	end

	self:SetNextSecondaryFire( CurTime() + 0.3)
end


function SWEP:FireAnimation( empty )
	local anim
	if empty then
		anim = self.Anims.ShootEmpty
	else
		anim = self:Clip1() == 1 and self.Anims.ShootEmpty or self.Anims.Shoot
	end

	CS16_SendWeaponAnim( self, anim, 1 )
end

function SWEP:GLOCK18Fire( flSpread, flCycleTime )
	if self:Clip1() <= 0 then
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) == 0 or self:Clip1() == 0 or self.Primary.ClipSize == -1 then
			self:EmitSound( Sound( "OldPistol.DryFire" ) )
			self:SetNextPrimaryFire( CurTime() + 0.2 )
		end

		return
	end

	if self:GetBurstMode() then
		self:Setm_iGlock18ShotsFired( 0 )
	else
		self:Setm_iShotsFired( self:Getm_iShotsFired() + 1 )

		if self:Getm_iShotsFired() > 1 then
			return
		end

		flCycleTime = flCycleTime - 0.05
	end

	if self:Getm_flLastFire() == 0 then
		self:Setm_flLastFire( CurTime() )
	else
		self:Setm_flAccuracy( self:Getm_flAccuracy() - (0.325 - (CurTime() - self.LastFire)) * 0.275 )

		if self:Getm_flAccuracy() > 0.9 then
			self:Setm_flAccuracy( 0.9 )
		elseif self:Getm_flAccuracy() < 0.6 then
			self:Setm_flAccuracy( 0.6 )
		end
		self:Setm_flLastFire( CurTime() )
	end

	local empty = false
	if self:GetBurstMode() then 
		empty = ( self:Clip1() - 3 ) <= 0 and true or false
	end

	self:FireAnimation( empty )

	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, CustomSizeVM = 16 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash2", self, { DrawWorldModel = true, CustomSizeWM = 18 } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_GLOCK18_DISTANCE, CS16_GLOCK18_PENETRATION, "CS16_9MM", CS16_GLOCK18_DAMAGE, CS16_GLOCK18_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	self:EmitSound( self.FireSound )

	self:CreateShell( "pshell", "1" )

	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:Setm_flTimeWeaponIdle( CurTime() + 2 )

	if self:GetBurstMode() then
		self:Setm_iGlock18ShotsFired( self:Getm_iGlock18ShotsFired() + 1 )
		self:Setm_flGlock18Shoot( CurTime() + 0.1 )
	end
end

function SWEP:WeaponIdle()
	if self:Getm_flTimeWeaponIdle() > CurTime() then
		return
	end

	if self.Owner.HasCS16Shield and self.Owner:HasCS16Shield() then
		self:Setm_flTimeWeaponIdle( CurTime() + 20 )

		//if (FBitSet(m_iWeaponState, WPNSTATE_SHIELD_DRAWN))
		//{
		//	SendWeaponAnim(P228_SHIELD_IDLE_UP, UseDecrement() != FALSE);
		//}
	elseif self:Clip1() != 0 then 
		local random = math.Rand( 0, 1 )
		
		if random <= 0.3 then 
			self:Setm_flTimeWeaponIdle( CurTime() + 3.0625 )
			CS16_SendWeaponAnim( self, "idle3", 1 )
		elseif random <= 0.6 then 
			self:Setm_flTimeWeaponIdle( CurTime() + 3.75 )
			CS16_SendWeaponAnim( self, "idle1", 1 )
		else
			self:Setm_flTimeWeaponIdle( CurTime() + 2.5 )
			CS16_SendWeaponAnim( self, "idle2", 1 )
		end
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end

function SWEP:IsPistol()
	return true
end