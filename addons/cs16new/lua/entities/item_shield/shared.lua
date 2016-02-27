AddCSLuaFile()
DEFINE_BASECLASS( "base_entity" )

function ENT:Initialize()
	self:SetModel("models/cs16/w_shield.mdl")
	self:SetCustomCollisionCheck( true )
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionBounds( Vector( 0, 0, 0 ) , Vector( 0, 0, 0 ) )
	self:SetMoveType( MOVETYPE_FLYGRAVITY )
	self:SetGravity( 1 )
	self:SetFriction( 0.5 )
	self:SetElasticity( 0.5 )
	self.IsWeaponBox = true
	self.m_flDieTime = CurTime() + 300
end
function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "m_hOwner" )
end
function ENT:DoPickup( m_hClient )
	if m_hClient:HasShield() then return false end
	if m_hClient:HasPrimaryWeapon() then return false end
	if m_hClient:Weapon_GetSlot( WEAPON_SLOT_PISTOL ) then
		if m_hClient:Weapon_GetSlot( WEAPON_SLOT_PISTOL ):GetClass() == CS16_WEAPON_ELITE then return false end
	end
	if self.cantPickup then return false end

	self.cantPickup = true
	m_hClient:GiveShield()

	umsg.Start( "Pickup" )
		umsg.Entity( m_hClient )
	umsg.End()

	local m_hWeapon = m_hClient:GetActiveWeapon()
	if IsValid( m_hWeapon ) then
		m_hWeapon:Deploy()
		m_hWeapon:CallOnClient( "Deploy" )
	end

	SafeRemoveEntity( self )
	return true
end

function ENT:Think()
	local angles = self:GetAngles()
	self:SetAngles( Angle( 0, angles.y, angles.r ) )

	if SERVER then
		if not self:IsInWorld() or CurTime() >= self.m_flDieTime then
			SafeRemoveEntity( self )
			return
		end

		if self:IsOnGround() then
			for k,v in pairs( ents.FindInBox( self:GetPos() + Vector( -16, -16, 0 ), self:GetPos() + Vector( 16, 16, 16 ) ) ) do
				if !v:IsPlayer() then continue end
				if !v:Alive() then continue end
				self:DoPickup( v )
			end
		end
	end

	self:NextThink( CurTime() )
	return true
end

function ENT:OnRemove() end

function ENT:StartTouch( otherent )
	self:ResolveFlyCollisionCustom( self:GetTouchTrace() , self:GetVelocity() )
end

function ENT:Touch( m_hEntity )
	if m_hEntity:IsPlayer() then
		return
	end
end

local function PhysicsClipVelocity( in_, normal, out, overbounce )
	local backoff
	local change = 0
	local angle
	local i
	local STOP_EPSILON = 0.2
	
	angle = normal.z
	
	backoff = in_:DotProduct( normal ) * overbounce
	for i = 1 , 3 do
		change = normal[i] * backoff
		out[i] = in_[i] - change
		if out[i] > -STOP_EPSILON and out[i] < STOP_EPSILON then
			out[i] = 0
		end
	end
end

local function IsStandable( ent )
	return ent:GetSolid() == SOLID_BSP or ent:GetSolid() == SOLID_VPHYSICS or ent:GetSolid() == SOLID_BBOX
end

function ENT:ResolveFlyCollisionCustom( trace , vecVelocity )
	local flSurfaceElasticity = 1
	if IsValid( trace.Entity ) and trace.Entity:IsPlayer() or trace.Entity:IsNPC() then
		flSurfaceElasticity = 0.3
	end
	
	local flTotalElasticity = self:GetElasticity() * flSurfaceElasticity
	flTotalElasticity = math.Clamp( flTotalElasticity, 0.3, 0.9 )

	local vecAbsVelocity = Vector()
	PhysicsClipVelocity( self:GetVelocity(), trace.Normal, vecAbsVelocity, 2 )
	vecAbsVelocity = vecAbsVelocity * flTotalElasticity

	local flSpeedSqr = vecVelocity:DotProduct( vecVelocity )
	if trace.Normal.z > 0.7 then
		local pEntity = trace.Entity

		self:SetVelocity( Vector( vecAbsVelocity.x, vecAbsVelocity.y, 1 ) )
		if flSpeedSqr < ( 30 * 30 ) then
			if IsStandable( pEntity ) then
				self:SetGroundEntity( pEntity )
			end

			self:SetVelocity( Vector() )
			self:SetLocalAngularVelocity( Angle() )

			local angle = trace.Normal:Angle()
			angle.p = math.Rand( 0, 360 )
			self:SetAngles( angle )
		end
	else
		if flSpeedSqr < ( 30 * 30 ) then
			self:SetLocalVelocity( Vector( 0, 0, 0 ) )
			self:SetLocalAngularVelocity( Angle() )
		else
			self:SetLocalVelocity( Vector( 0, 0, 0 ) )
		end
	end
end


if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end