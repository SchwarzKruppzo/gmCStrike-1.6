if SERVER then
	util.AddNetworkString("CS16_SetViewPunch")
end

local function VectorScale( inc, scale, out )
	out[1] = inc[1] * scale
	out[2] = inc[2] * scale
	out[3] = inc[3] * scale
end

local function VectorNormalize( v )
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

local meta = FindMetaTable("Player")
function meta:CS16_SetViewPunch( angle )
	if SERVER then
		net.Start( "CS16_SetViewPunch" )
			net.WriteAngle( angle )
			net.WriteEntity( self )
		net.Broadcast()
	end
	self.cs16_vp = angle
end

function meta:CS16_GetViewPunch()
	return self.cs16_vp and self.cs16_vp or Angle()
end

if CLIENT then
	net.Receive( "CS16_SetViewPunch", function() 
		local angle = net.ReadAngle()
		local entity = net.ReadEntity()
		if !IsValid( entity ) then return end

		entity.cs16_vp = angle
	end )
end

function meta:CS16_DropPunchAngle( )
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
if SERVER then
	hook.Add( "Move", "gmCStrike", function( ply )
		ply:CS16_DropPunchAngle()
	end)
end