if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_viewmodel.lua")
	AddCSLuaFile("sh_events.lua")
	AddCSLuaFile("sh_muzzleflashes.lua")
	AddCSLuaFile("sh_player.lua")
end

include("sh_events.lua")
include("sh_muzzleflashes.lua")
include("sh_player.lua")

if CLIENT then
	include("cl_viewmodel.lua")

	SWEP.PrintName = ""
    SWEP.Slot = 3
    SWEP.SlotPos = 3
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
else
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false 
end

SWEP.Author            = "Schwarz Kruppzo"
SWEP.Contact        = ""
SWEP.Purpose        = ""
SWEP.HoldType = "ar2"

SWEP.ViewModelFOV    = 55
SWEP.ViewModelFlip    = false
SWEP.UseHands			= false

SWEP.Spawnable            = false
SWEP.AdminSpawnable        = false

SWEP.ViewModel      = "models/Items/AR2_Grenade.mdl"
SWEP.WorldModel   = ""

SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic       = false    
SWEP.Primary.Ammo             = "none"
 
SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Automatic       = false
SWEP.Secondary.Ammo         = "none"

SWEP.IsCS16 = true
SWEP.Sounds = {}
SWEP.SoundsShield = {}
SWEP.SoundSpeed = 0
SWEP.SoundTime = 0
SWEP.CurrentSoundTable = nil
SWEP.CurrentSoundEntry = 0
SWEP.CurrentAnim = nil
SWEP.FirstDeploy = true
SWEP.Glock18ShotsFired = 0
SWEP.Glock18Shoot = 0
SWEP.EnableIdle = true

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "m_iShotsFired" )
	self:NetworkVar( "Float", 1, "m_flDecreaseShotsFired" )
	self:NetworkVar( "Bool", 2, "m_bDelayFire" )
	self:NetworkVar( "Float", 3, "m_flAccuracy" )
	self:NetworkVar( "Float", 4, "m_flTimeWeaponIdle")
	self:NetworkVar( "Bool", 5, "m_bInReload")
	self:NetworkVar( "Float", 6, "m_flEjectBrass")
	self:NetworkVar( "Int", 7, "m_iInSpecialReload")
	self:NetworkVar( "Bool", 8, "m_bDirection")
	self:NetworkVar( "Float", 9, "m_flLastFire" )
	self:NetworkVar( "Bool", 10, "LeftMode" )
	self:NetworkVar( "Bool", 11, "Silenced" )
	self:NetworkVar( "Bool", 12, "BurstMode" )
	self:NetworkVar( "Int", 13, "m_iGlock18ShotsFired" )
	self:NetworkVar( "Float", 14, "m_flGlock18Shoot" )
	self:NetworkVar( "Int", 15, "m_iSwing" )
	self:NetworkVar( "Float", 16, "m_flPumpTime" )
	self:NetworkVar( "Float", 17, "_nextFire" )
	self:NetworkVar( "Int", 18, "m_iFamasShotsFired" )
	self:NetworkVar( "Float", 19, "m_flFamasShoot" )
	self:NetworkVar( "Float", 20, "m_flBurstSpread" )
	self:NetworkVar( "Bool", 21, "IsInScope" )
	self:NetworkVar( "Int", 22, "ScopeZoom" )
	self:NetworkVar( "Int", 23, "LastScopeZoom" )
	self:NetworkVar( "Bool", 24, "ResumeZoom" )
	self:NetworkVar( "Float", 25, "m_flThrowTime" )
	self:NetworkVar( "Bool", 26, "m_bPinPulled" )
	self:NetworkVar( "Bool", 27, "m_bRedraw" )
	self:NetworkVar( "Bool", 28, "m_bStartedArming")
	self:NetworkVar( "Float", 29, "m_fArmedTime")
	self:NetworkVar( "Bool", 30, "m_bBombPlacedAnimation")
end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )

	if CLIENT then
		if not self.viewmodel then
			self.viewmodel = ClientsideModel( self.ViewModelMDL, RENDERGROUP_BOTH )
			self.viewmodel:SetNoDraw( true )
		end
	end
end

if CLIENT then 
	function SWEP:DrawWorldModel()
		if IsValid( self.Owner ) and self.Owner:HasShield() and self.WorldModelShield then
			if self:GetModel() != self.WorldModelShield then
				self:SetModel( Model( self.WorldModelShield ) )
			end
		elseif IsValid( self.Owner ) and !self.Owner:HasShield() and self.WorldModel then
			if self:GetModel() != self.WorldModel then
				self:SetModel( self.WorldModel )
			end
		end
		self:DrawModel()
	end
end

function SWEP:ShieldSecondaryAttack()
	if self.Owner:HasShield() then
		if SERVER then  
			self.Owner:SetShieldDrawnState( !self.Owner:IsShieldDrawn() )

			if self.Owner:IsShieldDrawn() then
				CS16_SendWeaponAnim( self, self.Anims.ShieldUp, 1, 0, 0, true )
			else
				CS16_SendWeaponAnim( self, self.Anims.ShieldDown, 1, 0, 0, true )
			end
		end

		self.Owner:ResetMaxSpeed()
		
		self:SetNextPrimaryFire( CurTime() + 0.4 )
		self:SetNextSecondaryFire( CurTime() + 0.4 )
		return true
	end

	return false
end

function SWEP:SecondaryAttack()
	if self:ShieldSecondaryAttack() then
		return
	end
end

function SWEP:CS16_DefaultReload( clipsize, anim, delay, idleDelay, customSoundID )
	if self.Owner:IsShieldDrawn() then return false end
	if CurTime() <= self:GetNextSecondaryFire() then return false end
	if CurTime() <= self:GetNextPrimaryFire() then return false end
	if self.Owner:KeyDown( IN_ATTACK ) or self.Owner:KeyDown( IN_ATTACK2 ) then return false end
	if self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 then 
		return false
	end
	local j = math.min( clipsize - self:Clip1(), self.Owner:GetAmmoCount( self.Primary.Ammo ) )
	if j == 0 then return false end

	self:SetNextPrimaryFire( CurTime() + delay )
	self:SetNextSecondaryFire( CurTime() + delay )
	if SERVER then CS16_SendWeaponAnim( self, anim, 1, 0, 0, true, customSoundID ) end
	self.Owner:SetAnimation( PLAYER_RELOAD )
	print("SetAnimation")

	self:Setm_flTimeWeaponIdle( CurTime() + (idleDelay and idleDelay or 0.5) )
	self:Setm_bInReload( true )

	return true
end

function SWEP:KickBack( up_base, lateral_base, up_modifier, lateral_modifier, up_max, lateral_max, direction_change )
	if !IsFirstTimePredicted() then return end
	local front, side

	if self:Getm_iShotsFired() == 1 then
		front = up_base
		side = lateral_base
	else
		front = self:Getm_iShotsFired() * up_modifier + up_base
		side  = self:Getm_iShotsFired() * lateral_modifier + lateral_base
	end

	local angles = self.Owner:CS16_GetViewPunch()
	if CLIENT then
		angles = self.Owner:CS16_GetViewPunch( true )
	end

	angles.p = angles.p + -front
	if angles.p <= -up_max then
		angles.p = -up_max
	end

	if self:Getm_bDirection() then
		angles.y = angles.y + side

		if angles.y >= lateral_max then
			angles.y = lateral_max
		end
	else
		angles.y = angles.y + -side

		if angles.y <= -lateral_max then
			angles.y = -lateral_max
		end
	end

	if math.random( 0, direction_change ) == 0 then
		self:Setm_bDirection( !self:Getm_bDirection() )
	end

	self.Owner:CS16_SetViewPunch( angles, true )
end

function SWEP:Holster( weapon )
	if self:Getm_bInReload() then 
		self:Setm_bInReload( false )
	end
	return true
end

function SWEP:RecalculateAccuracy()
end

function SWEP:Think()
	if self:GetNextPrimaryFire() <= CurTime() and self:GetResumeZoom() == true then
		self:SetScopeZoom( self:GetLastScopeZoom() )
		if self:GetScopeZoom() == self:GetLastScopeZoom() then
			self:SetResumeZoom( false )
		end
	end
	if self:GetClass() == CS16_WEAPON_GLOCK18 then
		if self:Getm_flGlock18Shoot() != 0 then
			self:FireRemaining( self:Getm_iGlock18ShotsFired(), self:Getm_flGlock18Shoot(), true )
		end
	elseif self:GetClass() == CS16_WEAPON_FAMAS then
		if self:Getm_flFamasShoot() != 0 then
			self:FireRemaining( self:Getm_iFamasShotsFired(), self:Getm_flFamasShoot(), true )
		end
	end
	if self:Getm_bInReload() and self:GetNextPrimaryFire() <= CurTime() then
		local j = math.min( self.Primary.ClipSize - self:Clip1(), self.Owner:GetAmmoCount( self.Primary.Ammo ) )

		if SERVER then 
			self:SetClip1( self:Clip1() + j )
			self.Owner:SetAmmo( self.Owner:GetAmmoCount( self.Primary.Ammo ) - j, self.Primary.Ammo )
		end

		self:Setm_bInReload( false )
	end
	if self.EnableIdle and CurTime() > self:Getm_flTimeWeaponIdle() and !self:Getm_bInReload() and !self.IsC4 then
		self:WeaponIdle()
	end
	if self.IsC4 then
		self:WeaponIdle()
	end
	if !self.Owner:KeyDown( IN_ATTACK ) and !self.Owner:KeyDown( IN_ATTACK2 ) then

		if self:Getm_bDelayFire() then
			self:Setm_bDelayFire( false )

			if self:Getm_iShotsFired() > 15 then
				self:Setm_iShotsFired( 15 )
			end

			self:Setm_flDecreaseShotsFired( CurTime() + 0.4 )
		end

		if self:GetClass() != CS16_WEAPON_USP and self:GetClass() != CS16_WEAPON_GLOCK18 and self:GetClass() != CS16_WEAPON_P228 and self:GetClass() != CS16_WEAPON_DEAGLE and self:GetClass() != CS16_WEAPON_ELITE and self:GetClass() != CS16_WEAPON_FIVESEVEN then
			if self:Getm_iShotsFired() > 0 then
				if CurTime() > self:Getm_flDecreaseShotsFired() then
					self:Setm_iShotsFired( self:Getm_iShotsFired() - 1 )
					self:RecalculateAccuracy()
					self:Setm_flDecreaseShotsFired( CurTime() + 0.0225 )
				end
			end
		else
			self:Setm_iShotsFired( 0 )
		end

		if self:Clip1() == 0 and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 and !self:Getm_bInReload() and CurTime() > self:GetNextPrimaryFire() and CurTime() > self:Getm_flFamasShoot() then 
			self:Reload()
		end
	end
	if self:Getm_flEjectBrass() != 0 and CurTime() >= self:Getm_flEjectBrass() then
		if self.IsSniperRifle and self:IsSniperRifle() then
			self:CreateShell( "rshell", "1" )
		else
			self:CreateShell( "shotgunshell", "1" )
		end
		self:Setm_flEjectBrass( 0 )
	end
	if IsFirstTimePredicted() then
		if CLIENT and !self.ServersideSounds then
			if self.CurrentSoundTable then
				local tbl = self.CurrentSoundTable[self.CurrentSoundEntry]

				if self.viewmodel:SequenceDuration() * self.viewmodel:GetCycle() >= tbl.time / self.SoundSpeed then
					self:EmitSound( tbl.sound, 70, 100 )
					
					if self.CurrentSoundTable[self.CurrentSoundEntry + 1] then
						self.CurrentSoundEntry = self.CurrentSoundEntry + 1
					else
						self.CurrentSoundTable = nil
						self.CurrentSoundEntry = nil
						self.SoundTime = nil
					end
				end
			end
		end
	end
	if SERVER and self.ServersideSounds then

		if self.CurrentSoundTable then
			local tbl = self.CurrentSoundTable[self.CurrentSoundEntry]

			if CurTime() >= self.SoundTime + tbl.time / self.SoundSpeed then
				self.Owner:EmitSound( tbl.sound, 70, 100 ) 
					
				if self.CurrentSoundTable[self.CurrentSoundEntry + 1] then
					self.CurrentSoundEntry = self.CurrentSoundEntry + 1
				else
					self.CurrentSoundTable = nil
					self.CurrentSoundEntry = nil
					self.SoundTime = nil
				end
			end
		end
	end
	if self:Getm_bPinPulled() and !self.Owner:KeyDown( IN_ATTACK ) and CurTime() > self:Getm_flTimeWeaponIdle() then
		self:Setm_flThrowTime( CurTime() + 0.1 )
		self:Setm_bPinPulled( false )
		CS16_SendWeaponAnim( self, self.Anims.Throw, 1 )

		self:SetNextPrimaryFire( CurTime() + 0.5 )
		self:Setm_flTimeWeaponIdle( CurTime() + 0.5 )
	elseif self:Getm_flThrowTime() > 0 and self:Getm_flThrowTime() < CurTime() then
		if self.Throw then self:Throw() end
	end
end

function SWEP:Holster()
	self.Owner:SetShieldDrawnState( false )
	return true
end