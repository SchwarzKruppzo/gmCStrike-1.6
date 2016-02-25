if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "С4"
	SWEP.DrawAmmo = false
end
SWEP.AnimPrefix = "c4"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.Price = 0
SWEP.IsC4 = true
SWEP.iTeam = 2

SWEP.Category = "Counter-Strike 1.6"
SWEP.Base = "cs16_base"
SWEP.Author            = "Schwarz Kruppzo"
SWEP.Contact        = ""
SWEP.Purpose        = ""

SWEP.ViewModelFOV    = 73
SWEP.ViewModelFlip    = true

SWEP.Spawnable            = true
SWEP.AdminSpawnable        = true

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_c4.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/p_c4.mdl"
SWEP.PickupModel   		= "models/cs16/w_backpack.mdl"
SWEP.HoldType			= "slam"

SWEP.Weight				= CS16_C4_WEIGHT

SWEP.Primary.ClipSize		= CS16_C4_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_C4_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_C4"

SWEP.MaxSpeed 				= 250
SWEP.ServersideSounds 		= true 

SWEP.Sounds = {}
SWEP.Sounds["pressbutton"] = {
	[1] = {time = 1.181, sound = Sound( "OldC4.Click" )},
	[2] = {time = 1.424, sound = Sound( "OldC4.Click" )},
	[3] = {time = 1.636, sound = Sound( "OldC4.Click" )},
	[4] = {time = 1.878, sound = Sound( "OldC4.Click" )},
	[5] = {time = 2.121, sound = Sound( "OldC4.Click" )},
	[6] = {time = 2.363, sound = Sound( "OldC4.Click" )},
	[7] = {time = 2.545, sound = Sound( "OldC4.Click" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle1"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Press = "pressbutton"
SWEP.Anims.Drop = "drop"

local SP = game.SinglePlayer()
function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end

	self:Setm_bStartedArming( false )
	self:Setm_fArmedTime( 0 )
	self.plant = false
	self.MaxSpeed = CS16_C4_MAX_SPEED

	if not self.FirstDeploy then
		CS16_SendWeaponAnim( self, self.Anims.Draw, 1 )
	else
		if SP and SERVER then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1, 0, self.Owner:Ping() / 1000 )
		end
		self.FirstDeploy = false
	end

	self.Owner:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
	
	self:Setm_flTimeWeaponIdle( CurTime() + 4 )
	self:SetNextPrimaryFire( CurTime() + 0.5 )

	return true
end

function SWEP:Holster()
	self.plant = false
	self:Setm_bStartedArming( false )
	self:Setm_fArmedTime( 0 )

	self:SetNextPrimaryFire( CurTime() + 0.5 )

	return true
end

function SWEP:Reload()
	return
end
function SWEP:PrimaryAttack()
	return
end

function SWEP:PlantBomb( player, pos )
	local grenade = ents.Create("cs16_planted_c4")
	grenade:SetPos( pos )
	grenade:Spawn()
	grenade:SetOwner( player )
	grenade:Setm_hOwner( player )
end

function SWEP:PrimaryFire()
	if self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 then
		return
	end
	if CurTime() <= self:GetNextPrimaryFire() then
		return
	end
	if GetGlobalBool("m_bBombPlanted") then
		self.Owner:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
		return
	end
	
	local onBombZone = self.Owner:GetInBombSite()
	local onGround   = bit.band( self.Owner:GetFlags(), FL_ONGROUND ) > 0

	if !self:Getm_bStartedArming() then
		if !onBombZone then
			if SERVER then
				self.Owner:OldPrintMessage( "csl_C4_Plant_At_Bomb_Spot" )
			end
			self:SetNextPrimaryFire( CurTime() + 1 )
			return
		end
		if !onGround then
			if SERVER then
				self.Owner:OldPrintMessage( "csl_C4_Plant_Must_Be_On_Ground" )
			end
			self:SetNextPrimaryFire( CurTime() + 1 )
			return
		end

		self:Setm_bStartedArming( true )
		self:Setm_bBombPlacedAnimation( false )
		self:Setm_fArmedTime( CurTime() + 3 )

		CS16_SendWeaponAnim( self, self.Anims.Press, 1 )
		if !GetGlobalBool("m_bBombPlanted") then 
			self.Owner:SetAnimation( PLAYER_ATTACK1 ) 
		end
		self.Owner:SetProgressBarTime( 3 )

		self:SetNextPrimaryFire( CurTime() + 0.3 )
		self:Setm_flTimeWeaponIdle( CurTime() + math.Rand( 10, 15 ) )
	else
		if !onGround or !onBombZone then
			if SERVER then
				if onBombZone then
					self.Owner:OldPrintMessage( "csl_C4_Plant_Must_Be_On_Ground" )
				else
					self.Owner:OldPrintMessage( "csl_C4_Arming_Cancelled" )
				end
			end
			self.Owner:ResetMaxSpeed()
			self.Owner:SetProgressBarTime( 0 )
			self.Owner:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
			CS16_SendWeaponAnim( self, self:Getm_bBombPlacedAnimation() and self.Anims.Draw or self.Anims.Idle, 1 )
			
			self:Setm_bStartedArming( false )
			self:SetNextPrimaryFire( CurTime() + 1.5 )
			return
		end

		self.Owner:SetRunSpeed( 1 )
		self.Owner:SetWalkSpeed( 1 )
		self.Owner:SetMaxSpeed( 1 )

		if CurTime() >= self:Getm_fArmedTime() then
			if self:Getm_bStartedArming() then
				self.Owner:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
				self.plant = true 
				self:Setm_bStartedArming( false )
				self:Setm_fArmedTime( 0 )
				self.Owner:SetProgressBarTime( 0 )
				self.Owner:Setm_bHasC4( false )
				self.Owner:ResetMaxSpeed()
				
				if SERVER then
					self:PlantBomb( self.Owner, self.Owner:GetPos() )
					OldPrintMessage( "csl_Bomb_Planted" )

					m_bBombDropped = false 
					SetGlobalBool( "m_bBombPlanted", true )
					
					umsg.Start( "SendAudio" )
						umsg.String( "cs16radio/bombpl.wav" )
					umsg.End()
				end

				self:EmitSound("OldC4.Plant")
				
				self:TakePrimaryAmmo( 1 )
				if SERVER then 	
					if self.Owner.CS16_SelectBestWeapon then
						self.Owner:CS16_SelectBestWeapon( self )
					end
					SafeRemoveEntity( self )
				end
			end
		else
			if CurTime() >= self:Getm_fArmedTime() - 0.75 and !self:Getm_bBombPlacedAnimation() then
				self.Owner:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
				self:Setm_bBombPlacedAnimation( true )
				CS16_SendWeaponAnim( self, self.Anims.Drop, 1 )
			end
		end
	end

	//self:SetNextPrimaryFire( CurTime() + 0.3 )
	self:Setm_flTimeWeaponIdle( CurTime() + math.Rand( 10, 15 ) )
end
function SWEP:WeaponIdle()
	if self.Owner:KeyDown( IN_ATTACK ) and !GetGlobalBool("m_bBombPlanted") then
		self:PrimaryFire()
	else
		if self:Getm_bStartedArming() then
			self:Setm_bStartedArming( false )
			self.Owner:ResetMaxSpeed()
			self.Owner:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
			self:SetNextPrimaryFire( CurTime() + 1 )
			self.Owner:SetProgressBarTime( 0 )

			CS16_SendWeaponAnim( self, self:Getm_bBombPlacedAnimation() and self.Anims.Draw or self.Anims.Idle, 1 )
		end

		if self:Getm_flTimeWeaponIdle() <= CurTime() then
			if self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 then
				if SERVER then 
					if self.Owner.CS16_SelectBestWeapon then
						self.Owner:CS16_SelectBestWeapon( self )
					end
					SafeRemoveEntity( self )
				end
				return
			end

			CS16_SendWeaponAnim( self, self.Anims.Draw, 1 )
			CS16_SendWeaponAnim( self, self.Anims.Idle, 1 )
		end
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end

function SWEP:IsPistol()
	return true
end