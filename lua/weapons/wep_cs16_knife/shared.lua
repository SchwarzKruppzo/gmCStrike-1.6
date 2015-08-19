if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Knife"
    SWEP.Slot = 2
    SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
end

SWEP.Category = "Counter-Strike 1.6"
SWEP.Base = "cs16_base"
SWEP.Author            = "Schwarz Kruppzo"
SWEP.Contact        = ""
SWEP.Purpose        = ""

SWEP.ViewModelFOV    = 73
SWEP.ViewModelFlip    = false

SWEP.Spawnable            = true
SWEP.AdminSpawnable        = true

SWEP.ViewModelMDL 		= "models/weapons/cs16/v_knife.mdl"
SWEP.WorldModel   		= "models/weapons/cs16/w_knife.mdl"
SWEP.HoldType			= "knife"

SWEP.Weight				= CS16_KNIFE_WEIGHT

SWEP.Primary.Automatic		= true
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"

SWEP.Sounds = {}
SWEP.Sounds["draw"] = {
	[1] = {time = 0.0333333333333333, sound = Sound( "OldKnife.Deploy" )},
}
SWEP.Sounds["reload"] = {
	[1] = {time = 0.7058823529411765, sound = Sound( "OldP228.ClipOut" )},
	[2] = {time = 1.441176470588235, sound = Sound( "OldP228.ClipIn" )},
	[3] = {time = 2.382352941176471, sound = Sound( "OldP228.SlideRelease" )},
}

SWEP.Anims = {}
SWEP.Anims.Idle = "idle"
SWEP.Anims.Draw = "draw"
SWEP.Anims.Reload = "reload"
SWEP.Anims.Shoot = { "shoot1", "shoot2", "shoot3" }
SWEP.Anims.ShootEmpty = "shoot_empty"
SWEP.Anims.ShieldUp = "shield_up"
SWEP.Anims.ShieldDown = "shield_down"
SWEP.Anims.ShieldIdle = "shield_idle"

SWEP.FireSound = Sound("OldP228.Shot1")

local SP = game.SinglePlayer()

local function _Length2D( vec )
	return math.sqrt( vec.x * vec.x + vec.y * vec.y )
end
local function DotProduct2D( vec, vec2 )
	return vec.x * vec2.x + vec.y * vec2.y
end
local function Normalize2D( vec )
	return Vector( vec.x / _Length2D( vec ), vec.y / _Length2D( vec ), 0 )
end

function SWEP:Deploy()
	if not IsValid( self.Owner ) then
		return false
	end

	self:Setm_iSwing( 0 )
	self.MaxSpeed = CS16_KNIFE_MAX_SPEED

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

function FindHullIntersection( vecSrc, tr, pflMins, pfkMaxs, pEntity)
	local	i, j, k
	local trTemp
	local flDistance = 1000000
	local pflMinMaxs = { pflMins, pfkMaxs }
	local vecHullEnd    = tr.HitPos

	vecHullEnd = vecSrc + ((vecHullEnd - vecSrc) * 2)
	trTemp = util.TraceLine( { start = vecSrc, endpos = vecHullEnd, mask = MASK_SOLID, filter = pEntity } )

	if trTemp.Fraction < 1 then
		tr = trTemp
		return
	end

	for i = 1 , 2 do
		for j = 1 , 2 do
			for k = 1 , 2 do
				local vecEnd = Vector()
				vecEnd.x = vecHullEnd.x + pflMinMaxs[i].x
				vecEnd.y = vecHullEnd.y + pflMinMaxs[j].y
				vecEnd.z = vecHullEnd.z + pflMinMaxs[k].z

				trTemp = util.TraceLine( { start = vecSrc, endpos = vecEnd, mask = MASK_SOLID, filter = pEntity } )

				if trTemp.Fraction < 1 then
					local flThisDistance = (trTemp.HitPos - vecSrc):Length()

					if flThisDistance < flDistance then
						tr = trTemp
						flDistance = flThisDistance
					end
				end
			end
		end
	end
end

function SWEP:Reload()
	return false
end

function SWEP:Swing( first )
	local DidHit = false

	local vecSrc = self.Owner:GetShootPos()
	local vecEnd = vecSrc + self.Owner:EyeAngles():Forward() * 48

	local tracedata = {}
	tracedata.start = vecSrc
	tracedata.endpos = vecEnd
	tracedata.filter = self.Owner
	tracedata.mask = MASK_SOLID
	local tr = util.TraceLine( tracedata )

	if tr.Fraction >= 1 then
		local tracedata = {}
		tracedata.start = vecSrc
		tracedata.endpos = vecEnd
		tracedata.mins = Vector( -16, -16, -18 )
		tracedata.maxs = Vector( 16, 16, 18 )
		tracedata.filter = self.Owner
		tracedata.mask = MASK_SOLID
		tr = util.TraceHull( tracedata )

		if tr.Fraction < 1 then
			if !tr.Entity or tr.Entity:GetSolid() == SOLID_BSP then
				FindHullIntersection( vecSrc, tr, self.Owner:OBBMins(), self.Owner:OBBMaxs(), self.Owner )
			end

			vecEnd = tr.HitPos
		end
	end

	if tr.Fraction >= 1 then
		if first then
			self:Setm_iSwing( self:Getm_iSwing() + 1 )
			local anim = (self:Getm_iSwing() % 2) == 1 and "midslash2" or "midslash1"
			if SERVER then CS16_SendWeaponAnim( self, anim, 1 ) end

			self.Owner:SetAnimation( PLAYER_ATTACK1 )

			self:SetNextPrimaryFire( CurTime() + 0.35 )
			self:SetNextSecondaryFire( CurTime() + 0.5 )

			self:Setm_flTimeWeaponIdle( CurTime() + 2 )

			self:EmitSound( Sound("OldKnife.Slash") )
		end
	else
		DidHit = true

		self:Setm_iSwing( self:Getm_iSwing() + 1 )
		local anim = (self:Getm_iSwing() % 2) == 1 and "midslash2" or "midslash1"
		if SERVER then CS16_SendWeaponAnim( self, anim, 1 ) end

		self:SetNextPrimaryFire( CurTime() + 0.4 )
		self:SetNextSecondaryFire( CurTime() + 0.5 )
		self:Setm_flTimeWeaponIdle( CurTime() + 2 )

		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		local info = DamageInfo()
		info:SetAttacker( self.Owner )
		info:SetInflictor( self )
		info:SetDamage( 15 )
		info:SetDamageType( bit.bor( DMG_BULLET , DMG_NEVERGIB ) )
		tr.Entity:DispatchTraceAttack( info, tr, vForward )

		local flVol = 1

		if !tr.HitWorld and tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			self:EmitSound( Sound("OldKnife.Hit") )

			if tr.Entity:IsPlayer() and !tr.Entity:Alive() then
				return true
			end
		else
			self:EmitSound( Sound("OldKnife.HitWall") )
		end
	end

	return DidHit
end

function SWEP:Stab( first )
	local DidHit = false

	local vecSrc = self.Owner:GetShootPos()
	local vecEnd = vecSrc + self.Owner:EyeAngles():Forward() * 32

	local tracedata = {}
	tracedata.start = vecSrc
	tracedata.endpos = vecEnd
	tracedata.filter = self.Owner
	tracedata.mask = MASK_SOLID
	local tr = util.TraceLine( tracedata )

	if tr.Fraction >= 1 then
		local tracedata = {}
		tracedata.start = vecSrc
		tracedata.endpos = vecEnd
		tracedata.mins = Vector( -16, -16, -18 )
		tracedata.maxs = Vector( 16, 16, 18 )
		tracedata.filter = self.Owner
		tracedata.mask = MASK_SOLID
		tr = util.TraceHull( tracedata )

		if tr.Fraction < 1 then
			if !tr.Entity or tr.Entity:GetSolid() == SOLID_BSP then
				FindHullIntersection( vecSrc, tr, self.Owner:OBBMins(), self.Owner:OBBMaxs(), self.Owner )
			end

			vecEnd = tr.HitPos
		end
	end

	if tr.Fraction >= 1 then
		if first then
			if SERVER then CS16_SendWeaponAnim( self, "stab_miss", 1 ) end

			self:SetNextPrimaryFire( CurTime() + 1 )
			self:SetNextSecondaryFire( CurTime() + 1 )
			self:Setm_flTimeWeaponIdle( CurTime() + 2 )

			self:EmitSound( Sound("OldKnife.Slash") )
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
		end
	else
		DidHit = true

		if SERVER then CS16_SendWeaponAnim( self, "stab", 1 ) end

		self:SetNextPrimaryFire( CurTime() + 1.1 )
		self:SetNextSecondaryFire( CurTime() + 1.1 )
		self:Setm_flTimeWeaponIdle( CurTime() + 2 )

		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		local info = DamageInfo()
		info:SetAttacker( self.Owner )
		info:SetInflictor( self )
		info:SetDamage( 65 )
		if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			local vec2LOS = Vector()
			local vecForward = self.Owner:EyeAngles():Forward()

			vec2LOS = Vector( vecForward.x, vecForward.y, 0 )
			vec2LOS = Normalize2D( vec2LOS )
			if DotProduct2D( vec2LOS, Vector( vecForward.x, vecForward.y, 0 ) ) > 0.8 then
				info:ScaleDamage(3)
			end
		end
		info:SetDamageType( bit.bor( DMG_BULLET , DMG_NEVERGIB ) )
		tr.Entity:DispatchTraceAttack( info, tr, vForward )

		local flVol = 1

		if !tr.HitWorld and tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			self:EmitSound( Sound("OldKnife.Stab") )

			if tr.Entity:IsPlayer() and !tr.Entity:Alive() then
				return true
			end
		else
			self:EmitSound( Sound("OldKnife.HitWall") )
		end
	end

	return DidHit
end

function SWEP:PrimaryAttack()
	self.Owner:LagCompensation( true )
		self:Swing( true )
	self.Owner:LagCompensation( false )
end

function SWEP:SecondaryAttack()
	self.Owner:LagCompensation( true )
		self:Stab( true )
	self.Owner:LagCompensation( false )
end

function SWEP:Holster()
	self:SetNextPrimaryFire( CurTime() + 1 )
	self:SetNextSecondaryFire( CurTime() + 1 )
	return true
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
		self:Setm_flTimeWeaponIdle( CurTime() + 3.0625 )
		CS16_SendWeaponAnim( self, self.Anims.Idle, 1 )
	end
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed
end

function SWEP:IsPistol()
	return true
end