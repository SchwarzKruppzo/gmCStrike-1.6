if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = ".40 Dual Elites"
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_elites.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_elite.mdl"
SWEP.HoldType			= "duel"

SWEP.Weight				= CS16_ELITE_WEIGHT

SWEP.Primary.ClipSize		= CS16_ELITE_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_ELITE_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_9MM"

SWEP.MaxSpeed 				= 250

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.0333333333333333, sound = Sound( "OldElites.Deploy" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.1714285714285714, sound = Sound( "OldElites.ReloadStart" )},
	[2] = {time = 1.257142857142857, sound = Sound( "OldElites.LeftClipIn" )},
	[3] = {time = 2.085714285714286, sound = Sound( "OldElites.ClipOut" )},
	[4] = {time = 2.342857142857143, sound = Sound( "OldElites.SlideRelease" )},
	[5] = {time = 3.2, sound = Sound( "OldElites.RightClipIn" )},
	[6] = {time = 3.571428571428571, sound = Sound( "OldElites.SlideRelease" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle"
SWEP.Anims.IdleEmptyLeft = "idle_leftempty"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.ShootLeft = { "shoot_left1", "shoot_left2", "shoot_left3", "shoot_left4", "shoot_left5" }
SWEP.Anims.ShootLeftLast = "shoot_leftlast"
SWEP.Anims.ShootRight = { "shoot_right1", "shoot_right2", "shoot_right3", "shoot_right4", "shoot_right5" }
SWEP.Anims.ShootRightLast = "shoot_rightlast"

SWEP.FireSound = Sound("OldElites.Shot1")

local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end

	self:Setm_flAccuracy( 0.88 )
	self.MaxSpeed = CS16_ELITE_MAX_SPEED

	if bit.band( self:Clip1(), 1) == 0 then
		self:SetLeftMode( true )
	end

	if not self.FirstDeploy then
		if SERVER then CS16_SendWeaponAnim( self, self.Anims.Draw, 1 ) end
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end
	
	self:Setm_flTimeWeaponIdle( CurTime() + 1 )

	return true
end

function SWEP:Reload()
	if self:Getm_bInReload() then 
		return 
	end
	if CLIENT and !IsFirstTimePredicted() then return end

	if self:CS16_DefaultReload( CS16_ELITE_MAX_CLIP, self.Anims.Reload, CS16_ELITE_RELOAD_TIME ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self:Setm_flAccuracy( 0.88 )
	end
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:ELITEFire( 1.3 * (1 - self:Getm_flAccuracy()), 0.2 )
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:ELITEFire( 0.175 * (1 - self:Getm_flAccuracy()), 0.2 )
	elseif self.Owner:Crouching() then
		self:ELITEFire( 0.08 * (1 - self:Getm_flAccuracy()), 0.2 )
	else
		self:ELITEFire( 0.1 * (1 - self:Getm_flAccuracy()), 0.2 )
	end
end

function SWEP:FireAnimation( left )
	local empty = self:GetLeftMode() and self.Anims.ShootLeftLast or self.Anims.ShootRightLast
	local shoot = self:GetLeftMode() and self.Anims.ShootLeft or self.Anims.ShootRight
	local anim = (self:Clip1() == 1 or self:Clip1() == 2) and empty or shoot

	CS16_SendWeaponAnim( self, anim, 1 )
end

function SWEP:ELITEFire( flSpread, flCycleTime )
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
		self:Setm_flAccuracy( self:Getm_flAccuracy() - (0.325 - (CurTime() - self:Getm_flLastFire())) * 0.275 )

		if self:Getm_flAccuracy() > 0.88 then
			self:Setm_flAccuracy( 0.88 )
		elseif self:Getm_flAccuracy() < 0.55 then
			self:Setm_flAccuracy( 0.55 )
		end
		self:Setm_flLastFire( CurTime() )
	end

	if SERVER then self:FireAnimation( self:GetLeftMode() ) end

	self:TakePrimaryAmmo( 1 )

	flCycleTime = flCycleTime - 0.125
	self:SetNextPrimaryFire( CurTime() + flCycleTime )

	if self:GetLeftMode() then
		osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, CustomSizeVM = 10, atID = "0" } )
		// worldmodel osmes.SpawnEffect( nil, "muzzleflash2", self, { DrawWorldModel = true } )

		self.Owner:MuzzleFlash()
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		self:SetLeftMode( false )

		self.Owner:FireBullets3( self.Owner:GetShootPos() + self.Owner:GetRight() * 5, self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_ELITE_DISTANCE, CS16_ELITE_PENETRATION, "CS16_9MM", CS16_ELITE_DAMAGE, CS16_ELITE_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )
		self:CreateShell( "pshell", "2" )
	else
		osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, CustomSizeVM = 10, atID = "1" } )
		// worldmodel osmes.SpawnEffect( nil, "muzzleflash2", self, { DrawWorldModel = true } )

		self.Owner:MuzzleFlash()
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		self:SetLeftMode( true )

		self.Owner:FireBullets3( self.Owner:GetShootPos() - self.Owner:GetRight() * 5, self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_ELITE_DISTANCE, CS16_ELITE_PENETRATION, "CS16_9MM", CS16_ELITE_DAMAGE, CS16_ELITE_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )
		self:CreateShell( "pshell", "3" )
	end
	
	self:EmitSound( self.FireSound )

	if SERVER then
		self.Owner:CS16_SetViewPunch( self.Owner:CS16_GetViewPunch() + Angle( -2, 0, 0 ) )
	end

	self:Setm_flTimeWeaponIdle( CurTime() + 2 )
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
		local anim = self:Clip1() == 1 and self.Anims.IdleEmptyLeft or self.Anims.Idle
		CS16_SendWeaponAnim( self, anim, 1 )
		self:Setm_flTimeWeaponIdle( CurTime() + 3.0625 )
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end

function SWEP:IsPistol()
	return true
end