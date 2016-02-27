ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:StartTouch( m_pEntity )
	if m_pEntity:IsPlayer() then
		if m_pEntity:Alive() then
			if m_pEntity:Team() == self.m_LegacyTeamNum and m_pEntity.Setm_bInBuyZone then
				m_pEntity:Setm_bInBuyZone( true )
			end
		end
	end
end

function ENT:EndTouch( m_pEntity )
	if m_pEntity:IsPlayer() then
		if m_pEntity:Alive() and m_pEntity.Setm_bInBuyZone then
			m_pEntity:Setm_bInBuyZone( false )
		end
	end
end

function ENT:KeyValue( key, value )
	if key == "TeamNum" then
		self.m_LegacyTeamNum = tonumber( value )
	end
end