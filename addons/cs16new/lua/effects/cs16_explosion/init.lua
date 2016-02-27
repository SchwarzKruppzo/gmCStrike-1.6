function EFFECT:Init( data )
	self.m_vPos = data:GetOrigin()
	self.m_hEntity = data:GetEntity()
	self.m_flExplodeFx = CurTime() + 1
	self.m_flSmokeFx = CurTime() + 1.55
	self.m_vEExploOffset = Vector( math.Rand( -64, 64 ), math.Rand( -64, 64 ), math.Rand( -30, 35 ) )
	self.m_flSmokeZ = -5
	self.m_flSmokeNextChange = CurTime() + 1
	self.m_flDieTime = CurTime() + 10

	self.m_flFExplo_SizeX = 25 * 10
	self.m_flFExplo_SizeY = 30 * 10
	self.m_flEExplo_SizeX = 30 * 10
	self.m_flEExplo_SizeY = 30 * 10
	self.m_flSmoke_Size = ( 35 + math.Rand( 0, 10 ) )

	for i = 1, 3 do
		local effect = EffectData()
		effect:SetOrigin( self.m_vPos + Vector( math.Rand( -60, 60 ) , math.Rand( -60, 60 ) ,math.Rand( 40, 120 )))
		util.Effect("cball_explode",effect)
	end

	local light = DynamicLight( self.m_hEntity:EntIndex() )
	light.pos = self.m_vPos
	light.r = 255
	light.g = 100
	light.b = 10
	light.brightness = 3
	light.Decay = 2 ^ 9
	light.Size = 256
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
	mat3:SetInt( "$frame", math.Clamp( math.floor( 6 - ( self.m_flSmokeFx - CurTime() ) * 6 ), 0, 15 ) )

	if mat3:GetInt( "$frame" ) != 15 then
		if CurTime() >= self.m_flSmokeNextChange then	
			if (self.m_flSmokeFx - CurTime()) < 1 then
				self.m_flSmokeZ = Lerp( 0.1, self.m_flSmokeZ, 150)
				self.m_flSmokeNextChange = CurTime() + 0.1
			end
		end
		render.SetMaterial( mat3 )
		render.DrawSprite( self.m_vPos + Vector( 0, 0, self.m_flSmokeZ ), self.m_flSmoke_Size * 4, self.m_flSmoke_Size * 6, Color(0,0,0,255) )
	end

	render.SetMaterial( mat )
	render.DrawSprite( self.m_vPos + Vector(0,0,20), self.m_flFExplo_SizeX, self.m_flFExplo_SizeY )
	render.SetMaterial( mat2 )
	render.DrawSprite( self.m_vPos + Vector(0,0,0) + self.m_vEExploOffset, self.m_flEExplo_SizeX, self.m_flEExplo_SizeY )
end