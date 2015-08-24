if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "KM .45 Tactical"
    SWEP.Slot = 1
    SWEP.SlotPos = 4
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

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_usp.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_usp.mdl"
SWEP.HoldType			= "pistol"

SWEP.Weight				= CS16_USP_WEIGHT

SWEP.Primary.ClipSize		= CS16_USP_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_USP_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_45ACP"

SWEP.MaxSpeed 				= 250

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.0208333333333333, sound = Sound( "OldUSP.Deploy" )},
	[2] = {time = 0.5416666666666667, sound = Sound( "OldUSP.SlideBack" )},
}
SWEP.Sounds["draw_unsil"] = {
	[1] = {time = 0.0208333333333333, sound = Sound( "OldUSP.Deploy" )},
	[2] = {time = 0.5416666666666667, sound = Sound( "OldUSP.SlideBack" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.4594594594594595, sound = Sound( "OldUSP.ClipOut" )},
	[2] = {time = 1.081081081081081, sound = Sound( "OldUSP.ClipIn" )},
	[3] = {time = 2.216216216216216, sound = Sound( "OldUSP.SlideRelease" )},
}
SWEP.Sounds["reload_unsil"] = {
	[1] = {time = 0.4594594594594595, sound = Sound( "OldUSP.ClipOut" )},
	[2] = {time = 1.081081081081081, sound = Sound( "OldUSP.ClipIn" )},
	[3] = {time = 2.216216216216216, sound = Sound( "OldUSP.SlideRelease" )},
}
SWEP.Sounds["add_silencer"] = {
	[1] = {time = 1.027027027027027, sound = Sound( "OldUSP.AddSilencer" )},
}
SWEP.Sounds["detach_silencer"] = {
	[1] = {time = 0.7837837837837838, sound = Sound( "OldUSP.DetachSilencer" )},
}

SWEP.Anims = {}
SWEP.Anims.IdleSilenced = "idle"
SWEP.Anims.DrawSilenced = "draw"
SWEP.Anims.ReloadSilenced = "reload"
SWEP.Anims.ShootSilenced = { "shoot1", "shoot2", "shoot3" }
SWEP.Anims.ShootEmptySilenced = "shootlast"
SWEP.Anims.Idle = "idle_unsil"
SWEP.Anims.Draw = "draw_unsil"
SWEP.Anims.Reload = "reload_unsil"
SWEP.Anims.Shoot = { "shoot1_unsil", "shoot2_unsil", "shoot3_unsil" }
SWEP.Anims.ShootEmpty = "shootlast_unsil"
SWEP.Anims.AttachSilencer = "add_silencer"
SWEP.Anims.DetachSilencer = "detach_silencer"

SWEP.FireSound = Sound("OldUSP.Shot1")
SWEP.FireSoundSilenced = Sound("OldUSP.Shot1_Silenced")


local SP = game.SinglePlayer()

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end

	self:Setm_flAccuracy( 0.92 )
	self.MaxSpeed = CS16_USP_MAX_SPEED

	local anim = self:GetSilenced() and self.Anims.DrawSilenced or self.Anims.Draw

	if not self.FirstDeploy then
		CS16_SendWeaponAnim( self, anim, 1 )
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, anim, 1, 0, self.Owner:Ping() / 1000 )
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

	local anim = self:GetSilenced() and self.Anims.ReloadSilenced or self.Anims.Reload
	if self:CS16_DefaultReload( CS16_USP_MAX_CLIP, anim, CS16_USP_RELOAD_TIME ) then
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self:Setm_flAccuracy( 0.92 )
	end
end

function SWEP:PrimaryAttack()
	if self:GetSilenced() then
		if !self.Owner:IsOnGround() then
			self:USPFire( 1.3 * (1 - self:Getm_flAccuracy()), 0.225 )
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:USPFire( 0.25 * (1 - self:Getm_flAccuracy()), 0.225 )
		elseif self.Owner:Crouching() then
			self:USPFire( 0.125 * (1 - self:Getm_flAccuracy()), 0.225 )
		else
			self:USPFire( 0.15 * (1 - self:Getm_flAccuracy()), 0.225 )
		end
	else
		if !self.Owner:IsOnGround() then
			self:USPFire( 1.2 * (1 - self:Getm_flAccuracy()), 0.225 )
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:USPFire( 0.225 * (1 - self:Getm_flAccuracy()), 0.225 )
		elseif self.Owner:Crouching() then
			self:USPFire( 0.08 * (1 - self:Getm_flAccuracy()), 0.225 )
		else
			self:USPFire( 0.1 * (1 - self:Getm_flAccuracy()), 0.225 )
		end
	end
end
function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire()  then 
		return
	end

	if self:GetSilenced() then
		self:SetSilenced( false )
		CS16_SendWeaponAnim( self, self.Anims.DetachSilencer, 1 )
	else
		self:SetSilenced( true )
		CS16_SendWeaponAnim( self, self.Anims.AttachSilencer, 1 )
	end

	self:Setm_flTimeWeaponIdle( CurTime() + 3.0 )
	self:SetNextSecondaryFire( CurTime() + 3.0 )
	self:SetNextPrimaryFire( CurTime() + 3.0 )
end

function SWEP:FireAnimation()
	local anim_empty = self:GetSilenced() and self.Anims.ShootEmptySilenced or self.Anims.ShootEmpty
	local anim_shoot = self:GetSilenced() and self.Anims.ShootSilenced or self.Anims.Shoot
	local anim = self:Clip1() == 1 and anim_empty or anim_shoot

	CS16_SendWeaponAnim( self, anim, 1 )
end

function SWEP:USPFire( flSpread, flCycleTime )
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
		self:Setm_flAccuracy( self:Getm_flAccuracy() - (0.3 - (CurTime() - self:Getm_flLastFire())) * 0.275 )

		if self:Getm_flAccuracy() > 0.92 then
			self:Setm_flAccuracy( 0.92 )
		elseif self:Getm_flAccuracy() < 0.6 then
			self:Setm_flAccuracy( 0.6 )
		end
		self:Setm_flLastFire( CurTime() )
	end

	self:FireAnimation()
	self:TakePrimaryAmmo( 1 )

	flCycleTime = flCycleTime - 0.075
	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:SetNextSecondaryFire( CurTime() + flCycleTime )

	local attachment = self:GetSilenced() and "0" or "2"
	osmes.SpawnEffect( self.Owner, "muzzleflash2", self, { DrawViewModel = true, atID = attachment, CustomSizeVM = 8 } )
	// worldmodel osmes.SpawnEffect( nil, "muzzleflash2", self, { DrawWorldModel = true } )

	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.Owner:FireBullets3( self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_USP_DISTANCE, CS16_USP_PENETRATION, "CS16_45ACP", CS16_USP_DAMAGE, CS16_USP_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex() )

	local sound = self:GetSilenced() and self.FireSoundSilenced or self.FireSound
	self:EmitSound( sound )

	self:CreateShell( "pshell", "1" )

	self.Owner:CS16_SetViewPunch( self.Owner:CS16_GetViewPunch( CLIENT ) + Angle( -2, 0, 0 ) )

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
		local anim = self:GetSilenced() and self.Anims.IdleSilenced or self.Anims.Idle
		self:Setm_flTimeWeaponIdle( CurTime() + 3.0625 )
		CS16_SendWeaponAnim( self, anim, 1 )
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end

function SWEP:IsPistol()
	return true
end