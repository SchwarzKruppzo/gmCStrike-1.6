ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:StartTouch( m_pEntity )
	if m_pEntity:IsPlayer() then
		if m_pEntity:Alive() and m_pEntity.SetInBombSite then
			m_pEntity:SetInBombSite( true )
		end
	end
end

function ENT:EndTouch( m_pEntity )
	if m_pEntity:IsPlayer() then
		if m_pEntity:Alive() and m_pEntity.SetInBombSite then
			m_pEntity:SetInBombSite( false )
		end
	end
end

function ENT:TriggerOutput( output, activator, data )
end
function ENT:KeyValue( key, value )
	if key == "BombExplode" then
		self:StoreOutput( key, value )
	end
end