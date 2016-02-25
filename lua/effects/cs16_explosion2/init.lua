function EFFECT:Init( data )
	self.m_vPos = data:GetOrigin()
	self.m_hEntity = data:GetEntity()
	self.m_flExplodeFx = CurTime() + 1
	self.m_flSmokeFx = CurTime() + 1.55
	self.m_vEExploOffset = Vector( math.Rand( -512, 512 ), math.Rand( -512, 512 ), math.Rand( -10, 10 ) )
	self.m_vFExploOffset = Vector( math.Rand( -512, 512 ), math.Rand( -512, 512 ), math.Rand( -10, 10 ) )
	self.m_vZExploOffset = Vector( math.Rand( -512, 512 ), math.Rand( -512, 512 ), math.Rand( -10, 10 ) )
	self.m_flSmokeZ = -5
	self.m_flSmokeNextChange = CurTime()
	self.m_flDieTime = CurTime() + 10

	self.m_flFExplo_SizeX = (500 - 275) * 0.6 * 10
	self.m_flFExplo_SizeY = 1500
	self.m_flEExplo_SizeX = math.floor( (500 - 275) * 0.6 ) * 10
	self.m_flEExplo_SizeY = 1500
	self.m_flZExplo_SizeX = math.floor( (500 - 275) * 0.6 ) * 10
	self.m_flZExplo_SizeY = 170

	sound.Play( Sound("OldC4.Explode"), self.m_vPos, 140, 100, 1 )
	sound.Play( "weapons/exp"..math.random(1,3)..".wav", self.m_vPos + self.m_vEExploOffset, 100, 100, 1 )
	sound.Play( "weapons/exp"..math.random(1,3)..".wav", self.m_vPos + self.m_vFExploOffset, 100, 100, 1 )

	for i = 1, 3 do
		local effect = EffectData()
		effect:SetOrigin( self.m_vPos + Vector( math.Rand( -128, 128 ) , math.Rand( -128, 128 ) ,math.Rand( 128, 512 )))
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
local mat4 = Material("cs16/zerogxplode")

function EFFECT:Render()
	mat:SetInt( "$frame", math.Clamp( math.floor( 30 - ( self.m_flExplodeFx - CurTime() ) * 30 ), 0, 29 ) )
	mat2:SetInt( "$frame", math.Clamp( math.floor( 30 - ( self.m_flExplodeFx - CurTime() ) * 30 ), 0, 24 ) )
	mat4:SetInt( "$frame", math.Clamp( math.floor( 30 - ( self.m_flExplodeFx - CurTime() ) * 30 ), 0, 15 ) )
	mat3:SetInt( "$frame", math.Clamp( math.floor( 8 - ( self.m_flSmokeFx - CurTime() ) * 8 ), 0, 15 ) )

	if mat3:GetInt( "$frame" ) != 15 then
		if CurTime() >= self.m_flSmokeNextChange then	
			if (self.m_flSmokeFx - CurTime()) < 1 then
				self.m_flSmokeZ = Lerp( 0.1, self.m_flSmokeZ, 256)
				self.m_flSmokeNextChange = CurTime() + 0.1
			end
		end
		render.SetMaterial( mat3 )
		render.DrawSprite( self.m_vPos + Vector( 0, 0, self.m_flSmokeZ ), 1500, 1500, Color(0,0,0,255) )
	end

	render.SetMaterial( mat )
	render.DrawSprite( self.m_vPos + Vector(0,0,20), self.m_flFExplo_SizeX, self.m_flFExplo_SizeY )
	render.SetMaterial( mat2 )
	render.DrawSprite( self.m_vPos + self.m_vEExploOffset, self.m_flEExplo_SizeX, self.m_flEExplo_SizeY )
	render.SetMaterial( mat )
	render.DrawSprite( self.m_vPos + self.m_vFExploOffset, self.m_flFExplo_SizeX, self.m_flFExplo_SizeY )
	if mat4:GetInt( "$frame" ) != 15 then
		render.SetMaterial( mat4 )
		render.DrawSprite( self.m_vPos + self.m_vZExploOffset, self.m_flZExplo_SizeX, self.m_flZExplo_SizeY )
	end
end