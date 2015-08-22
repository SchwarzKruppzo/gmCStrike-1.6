function EFFECT:Init( data )
	self.m_vPos = data:GetOrigin()
	self.m_hEntity = data:GetEntity()
	self.m_flExplodeFx = CurTime() + 1
	self.m_flSmokeFx = CurTime() + 1.55
	self.m_vEExploOffset = Vector( math.Rand(-1,1 ), math.Rand(-1,1 ), 0 )
	self.m_flSmokeZ = 30
	self.m_flSmokeNextChange = CurTime() + 0.1
	self.m_flDieTime = CurTime() + 10

	for i = 1, 4 do
		local effect = EffectData()
		effect:SetOrigin( self.m_vPos + Vector( math.Rand( -60, 60 ) , math.Rand( -60, 60 ) ,math.Rand( 40, 120 )))
		util.Effect("cball_explode",effect)
	end

	local light = DynamicLight( self.m_hEntity:EntIndex() )
	light.pos = self.m_vPos
	light.r = 255
	light.g = 150
	light.b = 50
	light.brightness = 5
	light.Decay = 2 ^ 9
	light.Size = 1024
	light.DieTime = CurTime() + 0.4
end


function EFFECT:Think()
	if CurTime() > self.m_flDieTime then
		return false
	end
	return true
end

local mat = Material("cs16/fexplo")
local mat2 = Material("cs16/eexplo")
local mat3 = Material("cs16/steam1")
function EFFECT:Render()
	mat:SetInt( "$frame", math.Clamp( math.floor( 30 - ( self.m_flExplodeFx - CurTime() ) * 30 ), 0, 29 ) )
	mat2:SetInt( "$frame", math.Clamp( math.floor( 30 - ( self.m_flExplodeFx - CurTime() ) * 30 ), 0, 24 ) )
	mat3:SetInt( "$frame", math.Clamp( math.floor( 8 - ( self.m_flSmokeFx - CurTime() ) * 8), 0, 15 ) )

	if mat3:GetInt( "$frame" ) != 15 then
		if CurTime() >= self.m_flSmokeNextChange then	
			if (self.m_flSmokeFx - CurTime()) < 1 then
				self.m_flSmokeZ = Lerp( 0.05, self.m_flSmokeZ, 150)
				self.m_flSmokeNextChange = CurTime() + 0.1
			end
		end
		render.SetMaterial( mat3 )
		render.DrawSprite( self.m_vPos + Vector( 0, 0, self.m_flSmokeZ ), 128, 256 - 64, Color(0,0,0,255) )
	end

	cam.Start3D( EyePos() - Vector(0,0,90), EyeAngles() )
		render.SetMaterial( mat )
		render.DrawSprite( self.m_vPos + Vector(0,0,0), 256 - 32, 256 )
		render.SetMaterial( mat2 )
		render.DrawSprite( self.m_vPos + Vector(0,0,0) + self.m_vEExploOffset * 30, 256 - 4, 256 - 4 )
	cam.End3D()
end

//if SERVER then
concommand.Add("_test",function( ply )
	local data = EffectData()
	data:SetOrigin( ply:GetEyeTrace().HitPos )
	util.Effect( "cs16_explosion", data )
end)
//end

