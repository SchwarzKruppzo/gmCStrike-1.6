AddCSLuaFile()
DEFINE_BASECLASS( "base_entity" )

function ENT:Initialize()
	self:SetModel("models/cs16/w_c4.mdl")
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionBounds( Vector( -3, -6, 0 ), Vector( 3, 6, 8 ) )
	self:UseTriggerBounds( true, 64 )
	self:SetMoveType( MOVETYPE_FLYGRAVITY )
	self:SetGravity( 1 )
	self:SetFriction( 0.9 )
	self:SetElasticity( 0.4 )
	self:SetCustomCollisionCheck( true )

	self:NextThink( CurTime() + 0.1 )

	self.m_flC4Blow			= CurTime() + 45
	self.m_flNextFreqInterval	= 45 / 4
	self.m_flNextFreq			= CurTime()
	self.m_flNextBeep			= CurTime() + 0.5
	self.m_flNextBlink			= CurTime() + 2.0

	self.m_iCurWave	= 0
	self.m_fAttenu		= 0
	self.m_sBeepName	= nil

	self.m_fNextDefuse = 0;

	self.m_bIsC4		= true
	self.m_bStartDefuse= false
	self.m_bJustBlew	= false
end

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "m_hOwner" )
end

function ENT:Detonate()
	m_bTargetBombed = true
	self.m_bJustBlew = true

	util.ScreenShake( self:GetPos(), 25, 150, 1, 3000 )

	if SERVER then
		local tracedata = {}
		local data = EffectData()
		local m_pTrace
		local dmg = DamageInfo()
		local pos = self:GetPos()

		for k,v in pairs( ents.FindByClass("func_bomb_target") ) do
			v:Fire( "BombExplode" )
		end

		self:EmitSound( Sound("OldC4.Explode") )

		CheckWinConditions() 

		tracedata.start = pos + Vector( 0, 0, 8 )
		tracedata.endpos = ( pos + Vector( 0, 0, 8 ) ) + Vector( 0, 0, -40 )
		tracedata.filter = self
		tracedata.mask = MASK_SOLID
		m_pTrace = util.TraceLine( tracedata )

		if m_pTrace.Fraction != 1 then
			pos = m_pTrace.HitPos + ( m_pTrace.HitNormal * ( 500 - 24 ) * 0.6 )
		end

		data:SetOrigin( pos )
		data:SetEntity( self )

		util.Effect( "cs16_explosion2", data )
		util.Decal( "Scorch", m_pTrace.HitPos - m_pTrace.HitNormal, m_pTrace.HitPos + m_pTrace.HitNormal )

		RadiusDamage( self:GetPos(), self, self, 500, 500 * 3.5, DMG_BLAST, true )

		SafeRemoveEntity( self )
	end
end

function ENT:Think()
	if SERVER then
		if not self:IsInWorld() then
			self:Remove()
			return
		end
	end

	self:NextThink( CurTime() + 0.12 )
	if CurTime() >= self.m_flNextFreq then
		self.m_flNextFreq = CurTime() + self.m_flNextFreqInterval
		self.m_flNextFreqInterval = self.m_flNextFreqInterval * 0.9

		if self.m_iCurWave == 0 then
			self.m_sBeepName = "weapons/c4_beep1.wav"
			self.m_fAttenu = 75
		elseif self.m_iCurWave == 1 then
			self.m_sBeepName = "weapons/c4_beep2.wav"
			self.m_fAttenu = 80
		elseif self.m_iCurWave == 2 then
			self.m_sBeepName = "weapons/c4_beep3.wav"
			self.m_fAttenu = 85
		elseif self.m_iCurWave == 3 then
			self.m_sBeepName = "weapons/c4_beep4.wav"
			self.m_fAttenu = 140
		elseif self.m_iCurWave == 4 then
			self.m_sBeepName = "weapons/c4_beep5.wav"
			self.m_fAttenu = 150
		end

		self.m_iCurWave = self.m_iCurWave + 1
	end
	if self.m_flNextBeep < CurTime() then
		self.m_flNextBeep = CurTime() + 1.4
		if SERVER then self:EmitSound( self.m_sBeepName, self.m_fAttenu, 100 ) end
	end
	if SERVER then
		if self.m_flNextBlink < CurTime() then
			self.m_flNextBlink = CurTime() + 2

			local data = EffectData()
			data:SetEntity( self )
			data:SetOrigin( self:GetPos() + Vector( 0, 0, 5 ) )
			util.Effect( "cs16_beep", data )
		end
	end

	if self.m_flC4Blow <= CurTime() then
		self:Detonate()
		
		m_bBombDropped = false
	end

	if self.m_bStartDefuse then
		local pDefuser = self.m_pBombDefuser
		if IsValid( pDefuser ) and self.m_flDefuseCountDown > CurTime() then
			local isOnGround = pDefuser:OnGround()
			if !isOnGround or self.m_fNextDefuse < CurTime() then
				if !isOnGround then
					pDefuser:OldPrintMessage( "csl_C4_Defuse_Must_Be_On_Ground" )
				end
				pDefuser:ResetMaxSpeed()
				pDefuser:SetProgressBarTime( 0 )

				pDefuser.m_bIsDefusing = false

				self.m_bStartDefuse = false
				self.m_flDefuseCountDown = 0.0
			end
		else
			self:EmitSound( "common/null.wav" )
			pDefuser:EmitSound( Sound( "OldC4.Disarmed" ) )
			SafeRemoveEntity( self )
			m_bJustBlew = true

			pDefuser:ResetMaxSpeed()
			pDefuser:SetProgressBarTime( 0 )
			pDefuser.m_bIsDefusing = false

			m_bBombDefused = true
			CheckWinConditions()

			m_bBombDropped = false
			self.m_bStartDefuse = false
		end
	end

	return true
end

function ENT:IsBombActive()
	return true
end

function ENT:CS16_Use( activator )
	local barTime = 0

	if activator:Team() == TEAM_CT then
		if m_bBombDefused then
			return
		end
		if self.m_bStartDefuse then
			self.m_fNextDefuse = CurTime() + 0.5
			return
		end

		activator:SetRunSpeed( 1 )
		activator:SetWalkSpeed( 1 )
		activator:SetMaxSpeed( 1 )

		if activator:HasDefuser() then
			activator:OldPrintMessage( "csl_Defusing_Bomb_With_Defuse_Kit" )
			activator:EmitSound( Sound( "OldC4.Disarm" ) )
			activator.m_bIsDefusing = true;

			self.m_pBombDefuser	= activator
			self.m_bStartDefuse	= true
			self.m_flDefuseCountDown = CurTime() + 5.0
			self.m_fNextDefuse = CurTime() + 0.5

			barTime = 5
		else
			activator:OldPrintMessage( "csl_Defusing_Bomb_Without_Defuse_Kit" )
			activator:EmitSound( Sound( "OldC4.Disarm" ) )
			activator.m_bIsDefusing = true;

			self.m_pBombDefuser	= activator
			self.m_bStartDefuse	= true
			self.m_flDefuseCountDown = CurTime() + 10.0
			self.m_fNextDefuse = CurTime() + 0.5

			barTime = 10
		end
		activator:SetProgressBarTime( barTime )
	end
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

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end