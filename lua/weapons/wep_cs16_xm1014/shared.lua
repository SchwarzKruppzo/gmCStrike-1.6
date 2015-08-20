if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Leone YG1265 Auto Shotgun"
    SWEP.Slot = 0
    SWEP.SlotPos = 12
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_xm1014.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_xm1014.mdl"
SWEP.HoldType			= "shotgun"

SWEP.Weight				= CS16_XM1014_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= CS16_XM1014_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_XM1014_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_BUCKSHOT"

SWEP.TimeWeaponIdle			= 0
SWEP.MaxSpeed 				= 250
SWEP.InSpecialReload		= 0
SWEP.PumpTime				= nil
SWEP.NextReload				= nil

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.3666666666666667, sound = Sound( "OldXM1014.Deploy" )},
}
SWEP.Sounds["insert"] = {
	[1] = {time = 0.0222222222222222, sound = Sound( "OldXM1014.Reload" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "insert"
SWEP.Anims.ReloadStart = "start_reload"
SWEP.Anims.ReloadEnd = "after_reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2" }

SWEP.FireSound = Sound("OldXM1014.Shot1")


local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end

	self.MaxSpeed = CS16_M3_MAX_SPEED

	if not self.FirstDeploy then
		if SERVER then CS16_SendWeaponAnim( self, self.Anims.Draw, 1 ) end
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
	if self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 or self:Clip1() == CS16_XM1014_MAX_CLIP then 
		return false
	end
	if self:GetNextPrimaryFire() > CurTime() then 
		return false
	end

	if self:Getm_iInSpecialReload() == 0 then
		self.Owner:SetAnimation( PLAYER_RELOAD )
		if SERVER then CS16_SendWeaponAnim( self, self.Anims.ReloadStart, 1 ) end
		self:Setm_iInSpecialReload( 1 )

		self:SetNextPrimaryFire( CurTime() + 0.55 )
		self:Setm_flTimeWeaponIdle( CurTime() + 0.55 )
	elseif self:Getm_iInSpecialReload() == 1 then
		if self:Getm_flTimeWeaponIdle() > CurTime() then
			return false
		end

		self:Setm_iInSpecialReload( 2 )
		if SERVER then CS16_SendWeaponAnim( self, self.Anims.Reload, 1 ) end

		self:Setm_flTimeWeaponIdle( CurTime() + 0.3 )
	else
		self:SetClip1( self:Clip1() + 1 )
		self.Owner:SetAmmo( self.Owner:GetAmmoCount( self.Primary.Ammo ) - 1, self.Primary.Ammo )

		self:Setm_iInSpecialReload( 1 )
		self:Set_nextFire( CurTime() + 0.1 ) // LIVE HACK FOR BRINGING UP BUG FROM CS 1.6
	end

	return true
end

function SWEP:FireAnimation()
	CS16_SendWeaponAnim( self, self.Anims.Shoot, 1 )
end

function SWEP:PrimaryAttack()
	if self.Owner:WaterLevel() == 3 then
		self:EmitSound( Sound( "OldRifle.DryFire" ) )
		self:SetNextPrimaryFire( CurTime() + 0.15 )

		return
	end
	if CurTime() < self:Get_nextFire()  then return end
	if self:Clip1() <= 0 then
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) == 0 or self:Clip1() == 0 or self.Primary.ClipSize == -1 then
			self:EmitSound( Sound( "OldRifle.DryFire" ) )
			self:SetNextPrimaryFire( CurTime() + 0.2 )
		end

		return
	end

	self:Setm_bDelayFire( true )
	self:Setm_iShotsFired( self:Getm_iShotsFired() + 6 )
	if SERVER then self:FireAnimation() end

	self:TakePrimaryAmmo( 1 )

	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, CustomSizeVM = 20 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash2", self, { DrawWorldModel = true } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	local bullet = {}
	bullet.Num = 6
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = (self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch()):Forward()
	bullet.Spread = CS16_VECTOR_CONE_XM1014
	bullet.Distance = 3000
	bullet.Tracer = 0
	bullet.Force = 2
	bullet.Damage = 5
	bullet.AmmoType = "CS16_BUCKSHOT"

	self.Owner:FireBullets( bullet )

	self:EmitSound( self.FireSound )

	self:CreateShell( "shotgunshell", "1" )

	if self:Clip1() > 0 then
		self:Setm_flPumpTime( CurTime() + 0.125 )
	end

	self:SetNextPrimaryFire( CurTime() + 0.25 )

	if self:Clip1() > 0 then
		self:Setm_flTimeWeaponIdle( CurTime() + 2.25 )
	else
		self:Setm_flTimeWeaponIdle( CurTime() + 0.75 )
	end

	self:Setm_iInSpecialReload( 0 )

	if SERVER then
		if self.Owner:IsOnGround() then
			self.Owner:CS16_SetViewPunch( self.Owner:CS16_GetViewPunch() + Angle( -math.random( 3, 5 ), 0, 0 ) )
		else
			self.Owner:CS16_SetViewPunch( self.Owner:CS16_GetViewPunch() + Angle( -math.random( 7, 10 ), 0, 0 ) )
		end
	end
end

function SWEP:WeaponIdle()
	if self:Getm_flTimeWeaponIdle() > CurTime() then
		return
	end

	if self:Getm_flPumpTime() != 0 and self:Getm_flPumpTime() < CurTime() then
		self:Setm_flPumpTime( 0 )
	end

	if self:Getm_flTimeWeaponIdle() < CurTime() then
		if self:Clip1() == 0 and self:Getm_iInSpecialReload() == 0 and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then
			self:Reload()
		elseif self:Getm_iInSpecialReload() != 0 then
			if self:Clip1() != CS16_XM1014_MAX_CLIP and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then
				self:Reload()
			else
				if SERVER then CS16_SendWeaponAnim( self, self.Anims.ReloadEnd, 1 ) end
				self:Setm_iInSpecialReload( 0 )
				self:Setm_flTimeWeaponIdle( CurTime() + 1.5 )
				self:Set_nextFire( 0 )
			end
		else
			CS16_SendWeaponAnim( self, self.Anims.Idle, 1 )
		end
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end