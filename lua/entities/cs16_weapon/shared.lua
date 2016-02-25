AddCSLuaFile()
DEFINE_BASECLASS( "base_entity" )

function ENT:Initialize()
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionBounds( Vector( 0, 0, 0 ) , Vector( 0, 0, 0 ) )
	self:SetMoveType( MOVETYPE_FLYGRAVITY )
	self:SetGravity( 1 )
	self:SetFriction( 0.5 )
	self:SetElasticity( 0.5 )
	self:SetCustomCollisionCheck( true )
	self.IsWeaponBox = true
	self.m_flDieTime = CurTime() + 300
end
function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "m_hOwner" )
	self:NetworkVar( "String", 1, "m_strWeapon" )
	self:NetworkVar( "String", 2, "m_strAmmoType1" )
	self:NetworkVar( "String", 3, "m_strAmmoType2" )
	self:NetworkVar( "Int", 4, "m_iAmmo1" )
	self:NetworkVar( "Int", 5, "m_iAmmo2" )
	self:NetworkVar( "Int", 6, "m_iClip1" )
	self:NetworkVar( "Int", 7, "m_iClip2" )
end

function ENT:PackWeapon( m_hWeapon )
	if IsValid( m_hWeapon.Owner ) then
		m_hWeapon.Owner:StripWeapon( m_hWeapon:GetClass() )
	end
	self:Setm_strWeapon( m_hWeapon:GetClass() )

	SafeRemoveEntity( m_hWeapon )
end
function ENT:PackAmmo( m_strAmmoType, m_iAmmo )
	self:Setm_strAmmoType1( m_strAmmoType )
	self:Setm_iAmmo1( m_iAmmo )
end
function ENT:PackAmmo2( m_strAmmoType, m_iAmmo )
	self:Setm_strAmmoType2( m_strAmmoType )
	self:Setm_iAmmo2( m_iAmmo )
end
function ENT:PackClip( clip1, clip2 )
	self:Setm_iClip1( clip1 )
	self:Setm_iClip2( clip2 )
end

function ENT:DoPickup( m_hClient )
	if m_hClient:HasWeapon( self:Getm_strWeapon() ) then
		return false
	end
	if self.cantPickup then return false end

	local slot_id = weapons.GetStored( self:Getm_strWeapon() ).Slot
	if m_hClient:HasShield() then
		if slot_id == WEAPON_SLOT_RIFLE or self:Getm_strWeapon() == CS16_WEAPON_ELITE then
			return false
		end
	end

	local weapon_hack = ents.Create( self:Getm_strWeapon() )
	if !IsValid( weapon_hack ) then return false end
	local can_pickup = hook.Run( "PlayerCanPickupWeapon", m_hClient, weapon_hack )
	if !can_pickup then weapon_hack:Remove() return false end

	weapon_hack:Remove()
	
	self.cantPickup = true
	local weapon = m_hClient:Give( self:Getm_strWeapon() )
	weapon:SetClip1( self:Getm_iClip1() or 0 )
	weapon:SetClip2( self:Getm_iClip2() or 0 )
	m_hClient:GiveAmmo( self:Getm_iAmmo1(), self:Getm_strAmmoType1(), true )
	m_hClient:GiveAmmo( self:Getm_iAmmo2(), self:Getm_strAmmoType2(), true )

	if m_hClient:GetInfoNum( "cl_cs16_autoselectdrop", 0 ) == 1 then
		if self:Getm_strWeapon() != CS16_WEAPON_C4 then
			m_hClient:SelectWeapon( self:Getm_strWeapon() )
		end
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

		self:SetLocalVelocity( Vector( vecAbsVelocity.x, vecAbsVelocity.y, 0 ) )
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
		elseif trace.HitNormal.z > 0 then
			self:SetLocalVelocity( Vector( 0, 0, 0 ) )
			self:SetLocalAngularVelocity( Angle() )
			if IsStandable( trace.Entity ) then
				self:SetGroundEntity( trace.Entity )
			end
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