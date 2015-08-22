AddCSLuaFile()
DEFINE_BASECLASS( "base_entity" )

function ENT:Initialize()
	if CLIENT then return end
	self:SetModel("models/cs16/w_hegrenade.mdl")
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionBounds( Vector( 0, 0, 0 ) , Vector( 0, 0, 0 ) )
	self:SetMoveType( MOVETYPE_FLYGRAVITY )
	self:SetGravity( 0.55 )
	self:SetFriction( 0.7 )
	self:SetElasticity( 0.4 )

	self:ResetSequence( math.random(1,3) )
	self:SetPlaybackRate( 1 )
end

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "m_hOwner" )
	self:NetworkVar( "Float", 1, "m_flTime" )
	self:NetworkVar( "Float", 2, "m_flTimer" )
end

function ENT:Explode()
	if SERVER then
		local tracedata = {}
		local data = EffectData()
		local tr

		tracedata.start = self:GetPos()
		tracedata.endpos = self:GetPos() - Vector( 0, 0, 60 )
		tracedata.mask = MASK_SOLID
		tracedata.filter = self
		tr = util.TraceLine( tracedata )
		data:SetOrigin( self:GetPos() )
		data:SetEntity( self )
		util.Effect( "cs16_explosion", data )
		util.Decal( "Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

		util.BlastDamage( self, self:Getm_hOwner(), self:GetPos(),  100 * 2.8, 118 )
		self:EmitSound("weapons/exp"..math.random(1,3)..".wav", 140, 100, 1, CHAN_STATIC )
		SafeRemoveEntity( self )
	end
end

function ENT:Think()
	if SERVER then
		if not self:IsInWorld() then
			self:Remove()
			return
		end

		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = self:GetPos() - Vector( 0, 0, 10 )
		tracedata.mask = MASK_SOLID_BRUSHONLY
		tracedata.filter = self
		local tr = util.TraceLine( tracedata )
		if tr.Fraction < 1.0 then
			self:ResetSequence( 0 )
			local angles = self:GetAngles()
			self:SetAngles( Angle( 0, angles.y, angles.r ) ) // HACK
		end
	end
	if self:Getm_flTimer() == 0 then
		self:Setm_flTimer( CurTime() + self:Getm_flTime() )
	elseif CurTime() > self:Getm_flTimer() then
		self:Explode()
	end

	self:NextThink( CurTime() )
	return true
end

function ENT:OnRemove() end

function ENT:StartTouch( otherent )
	self:ResolveFlyCollisionCustom( self:GetTouchTrace() , self:GetVelocity() )
end

function ENT:Touch( m_hEntity )
	if m_hEntity == self:Getm_hOwner() then
		return
	end
	self:DoBounce()
end

local function PhysicsClipVelocity( in_, normal, out, overbounce )
	local backoff
	local change = 0
	local angle
	local i
	local STOP_EPSILON = 0.1
	
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

	local breakthrough = false

	if IsValid( trace.Entity ) and trace.Entity:GetClass() == "func_breakable" then
		breakthrough = true
	end
	if IsValid( trace.Entity ) and trace.Entity:GetClass() == "func_breakable_surf" then
		breakthrough = true
	end
	if IsValid( trace.Entity ) and trace.Entity:GetClass() == "prop_physics" and trace.Entity:Health() != 0 then
		breakthrough = true
	end
	if breakthrough then
		local info = DamageInfo()
		info:SetAttacker( self )
		info:SetInflictor( self )
		info:SetDamageForce( vecVelocity )
		info:SetDamagePosition( self:GetPos() )
		info:SetDamageType( DMG_CLUB )
		info:SetDamage( 10 )
		trace.Entity:DispatchTraceAttack( info , trace , vecVelocity )
		
		if trace.Entity:Health() <= 0 then
			self:SetVelocity( vecVelocity )
			return
		end
	end
	
	local flTotalElasticity = self:GetElasticity() * flSurfaceElasticity
	flTotalElasticity = math.Clamp( flTotalElasticity, 0.3, 0.9 )

	local vecAbsVelocity = Vector()
	PhysicsClipVelocity( self:GetVelocity(), trace.Normal, vecAbsVelocity, 2.0 )
	vecAbsVelocity = vecAbsVelocity * flTotalElasticity

	local flSpeedSqr = vecVelocity:DotProduct( vecVelocity )
	if trace.Normal.z > 0.7 then
		local pEntity = trace.Entity

		self:SetVelocity( vecAbsVelocity )
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
			self:SetVelocity( Vector() )
			self:SetLocalAngularVelocity( Angle() )
		else
			self:SetVelocity( vecAbsVelocity )
		end
	end
end

function ENT:DoBounce()
	self:EmitSound( Sound( "OldDefault.HEBounce" ) )
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end