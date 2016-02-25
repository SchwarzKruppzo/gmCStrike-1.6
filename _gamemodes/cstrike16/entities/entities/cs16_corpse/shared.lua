AddCSLuaFile()
DEFINE_BASECLASS( "base_entity" )

function ENT:Initialize()
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionBounds( Vector( 0, 0, 0 ) , Vector( 0, 0, 0 ) )
	self:SetMoveType( MOVETYPE_FLYGRAVITY )
	self:DrawShadow( false )
	self:SetGravity( 1 )
	self:SetFriction( 1 )
	self:SetElasticity( 0.5 )
end

function ENT:SetupDataTables()
end

function ENT:Think()
	self:SetAngles( Angle( 0, self:GetAngles().y, 0 ) )
	
	if SERVER then
		if not self:IsInWorld() then
			SafeRemoveEntity( self )
			return
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