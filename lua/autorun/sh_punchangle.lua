function VectorScale( inc, scale, out )
	out[1] = inc[1] * scale
	out[2] = inc[2] * scale
	out[3] = inc[3] * scale
end

function VectorNormalize( v )
    local length, ilength
 
    length = v[1]*v[1] + v[2]*v[2] + v[3]*v[3]
    length = math.sqrt( length )
    if length != 0 then
		ilength = 1 / length
		v[1] = v[1] * ilength
		v[2] = v[2] * ilength
		v[3] = v[3] * ilength
    end
               
    return length
end

function VectorMA( veca, scale, vecb, vecc)
	vecc[1] = veca[1] + scale * vecb[1]
	vecc[2] = veca[2] + scale * vecb[2]
	vecc[3] = veca[3] + scale * vecb[3]
end

local meta = FindMetaTable("Player")
function meta:CS16_SetViewPunch( angle, client )
	if !game.SinglePlayer() and !IsFirstTimePredicted() then return end
	local check = game.SinglePlayer() and true or CLIENT
	if SERVER then
		self.cs16_vp = angle
		umsg.Start( "CS16_SetViewPunch", self )
			umsg.Angle( angle )
			umsg.Entity( self )
		umsg.End()
	end
	if client and check then
		self:CS16_SetViewPunch_Client( angle, check )
	end
end
function meta:CS16_SetViewPunch_Client( angle, check )
	if SERVER and check then
		umsg.Start( "CS16_SetViewPunch_Client", self )
			umsg.Angle( angle )
			umsg.Entity( self )
		umsg.End()
	end
	self.cs16_vp_client = angle
end

function meta:CS16_GetViewPunch( isLocal )
	if isLocal and CLIENT then
		return self.cs16_vp_client and self.cs16_vp_client or Angle()
	else
		return self.cs16_vp and self.cs16_vp or Angle()
	end
end

if CLIENT then
	local function _CS16_SetViewPunch( data )
		local angle = data:ReadAngle()
		local entity = data:ReadEntity()

		if !IsValid( entity ) then return end

		entity.cs16_vp = angle
	end
	local function _CS16_SetViewPunch_Client( data )
		local angle = data:ReadAngle()
		local entity = data:ReadEntity()

		if !IsValid( entity ) then return end

		entity.cs16_vp_client = angle
	end
	
	usermessage.Hook( "CS16_SetViewPunch", _CS16_SetViewPunch )
	usermessage.Hook( "CS16_SetViewPunch_Client", _CS16_SetViewPunch_Client )
end

if SERVER then
	function meta:CS16_DropPunchAngle( )
		if self:CS16_GetViewPunch():IsZero() then return end

		self._cs16_vp = Vector()
		self._cs16_vp.x = self:CS16_GetViewPunch().p
		self._cs16_vp.y = self:CS16_GetViewPunch().y
		self._cs16_vp.z = self:CS16_GetViewPunch().r

		self.cs16punchlen = 0
		self.cs16punchlen = VectorNormalize( self._cs16_vp )
		self.cs16punchlen = self.cs16punchlen - (10.0 + self.cs16punchlen * 0.5) * FrameTime()
		self.cs16punchlen = math.max( self.cs16punchlen, 0.0 )
		VectorScale( self._cs16_vp, self.cs16punchlen, self._cs16_vp )

		self:CS16_SetViewPunch( Angle( self._cs16_vp.x, self._cs16_vp.y, self._cs16_vp.z ) )
	end
else
	function CS16_DropPunchAngle( )
		local self = LocalPlayer()
		if self:CS16_GetViewPunch( true ):IsZero() then return end
		
		self._cs16_vp_client = Vector()
		self._cs16_vp_client.x = self:CS16_GetViewPunch( true ).p
		self._cs16_vp_client.y = self:CS16_GetViewPunch( true ).y
		self._cs16_vp_client.z = self:CS16_GetViewPunch( true ).r

		self.cs16punchlen = 0
		self.cs16punchlen = VectorNormalize( self._cs16_vp_client )
		self.cs16punchlen = self.cs16punchlen - (10.0 + self.cs16punchlen * 0.5) * FrameTime()
		self.cs16punchlen = math.max( self.cs16punchlen, 0.0 )
		VectorScale( self._cs16_vp_client, self.cs16punchlen, self._cs16_vp_client )

		self:CS16_SetViewPunch_Client( Angle( self._cs16_vp_client.x, self._cs16_vp_client.y, self._cs16_vp_client.z ) )
	end
end

if SERVER then
	local CS16_DropPunchAngle = debug.getregistry().Player.CS16_DropPunchAngle

	hook.Add( "Move", "gmCStrike", CS16_DropPunchAngle )
else
	hook.Add( "Think", "_gmCStrike", function() CS16_DropPunchAngle() end )
end