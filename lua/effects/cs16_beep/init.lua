function EFFECT:Init( data )
	self.m_hEntity = data:GetEntity()
	self.m_vPos = data:GetOrigin()
	self.m_flDieTime = CurTime() + 1
	self.m_fFade = 255
	self.m_hPixelVis = util.GetPixelVisibleHandle()
end


function EFFECT:Think()
	if !IsValid( self.m_hEntity ) then
		return false
	end
	if CurTime() > self.m_flDieTime then
		return false
	end
	return true
end

local mat = Material("ledglow")
function EFFECT:Render()
	if self.m_fFade != 0 then
		self.m_fFade = math.max( self.m_fFade - FrameTime() * 256, 0 )
	end
	if util.PixelVisible( self.m_vPos, 4, self.m_hPixelVis ) > 0.5 then
		cam.IgnoreZ( true )
			render.SetMaterial( mat )
			render.DrawSprite( self.m_vPos, 30, 30, Color( 255, 255, 255, self.m_fFade ) )
		cam.IgnoreZ( false )
	end
end