function ReduceTimers( ply )
	local frame_msec = 1000.0 * FrameTime()

	if ply:Getm_flStamina() > 0 then
		ply:Setm_flStamina( ply:Getm_flStamina() - frame_msec )

		if ply:Getm_flStamina() < 0 then
			ply:Setm_flStamina( 0 )
		end
	end
end
function GM:OnPlayerHitGround( m_pClient, inWater, onFloater, speed )
	if inWater or speed < 250 or not IsValid( m_pClient ) then return end

	local velocity = speed - 500
	local dmg = velocity * (100 / (1100 - 500)) * 1.25
	if onFloater then dmg = dmg / 2 end
	local ground = m_pClient:GetGroundEntity()

	if SERVER then
		if math.floor( dmg ) > 0 then
			local dmgInfo = DamageInfo()
			dmgInfo:SetDamageType( DMG_FALL )
			dmgInfo:SetAttacker( game.GetWorld( ) )
			dmgInfo:SetInflictor( game.GetWorld( ) )
			dmgInfo:SetDamageForce( Vector( 0, 0, 1 ) )
			dmgInfo:SetDamage( dmg )
			m_pClient:TakeDamageInfo( dmgInfo )
			sound.Play( "physics/body/body_medium_break2.wav", m_pClient:GetShootPos(), 75, 100 )
		end
	end
	if math.floor( dmg ) > 0 then
		local angle = m_pClient:CS16_GetViewPunch( CLIENT )
		angle.r = speed * 0.013
		m_pClient:CS16_SetViewPunch( angle, true )
	end
	return true
end
function CheckJump( ply, mv )
	if ply:WaterLevel() >= 2 then 
		return 
	end
	local worldspawn = SERVER and game.GetWorld() or Entity(0)
	if !IsValid(ply:GetGroundEntity()) and ply:GetGroundEntity() != worldspawn then
		local buttons = bit.bor( mv:GetOldButtons(), IN_JUMP )
		mv:SetOldButtons( buttons )
		return
	end
	if bit.band( mv:GetOldButtons(), IN_JUMP ) != 0 then
		return
	end

	local velocity = mv:GetVelocity()
	velocity.z = math.sqrt(2 * 800 * 45)

	if ply:Getm_flStamina() > 0 then
		local velocity = mv:GetVelocity()
		velocity.z = velocity.z * (100.0 - ply:Getm_flStamina() * 0.001 * 19.0) * 0.01;
	end
	mv:SetVelocity( velocity )
	ply:Setm_flStamina( 1315.7894 )
	return true
end
local speed = 0
function GM:StartCommand( ply, ucmd )
	if IsFreezePeriod() then
		if ucmd:KeyDown( IN_ATTACK ) then
			ucmd:RemoveKey( IN_ATTACK )
		end
		if ucmd:KeyDown( IN_JUMP ) then
			ucmd:RemoveKey( IN_JUMP )
		end
	end
end
function GM:SetupMove( ply, mv, cmd )
	--[[
	ReduceTimers( ply )

	if mv:KeyDown( IN_SPEED ) then
		mv:SetMaxClientSpeed( 100 )
	end
	if bit.band( ply:GetFlags(), FL_DUCKING ) > 0 then
		mv:SetMaxClientSpeed( 70 )
	end

	if ply:OnGround() then
		if ply:Getm_flStopModifier() < 1.0 then
			ply:Setm_flStopModifier( ply:Getm_flStopModifier() + FrameTime() / 3.0 )
		end
		if ply:Getm_flStopModifier() > 1.0 then
			ply:Setm_flStopModifier( 1.0 )
		end
	end

	local forwardMove = mv:GetForwardSpeed()
	local sideMove = mv:GetSideSpeed()
	local upMove = mv:GetUpSpeed()

	local spd = ( forwardMove * forwardMove ) + ( sideMove * sideMove ) + ( upMove * upMove )
	local maxspeed = mv:GetMaxClientSpeed()
	local speedFactor = 1.0

	speedFactor = speedFactor * ply:Getm_flStopModifier()
	
	mv:SetMaxClientSpeed( mv:GetMaxClientSpeed() * speedFactor )

	if spd != 0 and spd > ( mv:GetMaxClientSpeed() * mv:GetMaxClientSpeed() ) then
		local flRatio = mv:GetMaxClientSpeed() / math.sqrt( spd )
		mv:SetForwardSpeed( mv:GetForwardSpeed() * flRatio )
		mv:SetSideSpeed( mv:GetSideSpeed() * flRatio )
		mv:SetUpSpeed( mv:GetUpSpeed() * flRatio )
	end

	if bit.band( ply:GetFlags(), FL_FROZEN ) > 0 then
		mv:SetForwardSpeed( 0 )
		mv:SetSideSpeed( 0 )
		mv:SetUpSpeed( 0 )
	end
	
	local velocity = mv:GetVelocity()

	if bit.band( mv:GetButtons(), IN_JUMP ) != 0 then
		CheckJump( ply, mv, velocity )
	else
		local buttons = bit.band( mv:GetOldButtons(), bit.bnot( IN_JUMP ) )
		mv:SetOldButtons( buttons )
	end

	if ply:Getm_flStamina() > 0 and ply:IsOnGround() then
		local flRatio = ( STAMINA_MAX - ( ( ply:Getm_flStamina() / 1000.0 ) * STAMINA_RECOVER_RATE ) ) / STAMINA_MAX

		local flReferenceFrametime = 1.0 / 70.0
		local flFrametimeRatio = FrameTime() / flReferenceFrametime

		flRatio = math.pow( flRatio, flFrametimeRatio )

		velocity.x = velocity.x * flRatio
		velocity.y = velocity.y * flRatio
	end
	if mv:GetForwardSpeed() > 250 then
		mv:SetForwardSpeed( 250 )
	end
	if mv:GetSideSpeed() > 250 then
		mv:SetSideSpeed( 250 )
	end
		
	
	mv:SetVelocity( velocity )
	]]
	hook.Run( "CS16_PlayerUse", ply, mv )
end

function GM:Move( m_pClient, m_mvData )
	if m_pClient:Alive() then
		ReduceTimers( m_pClient )

		if bit.band( m_pClient:GetFlags(), FL_FROZEN ) > 0 then
			m_mvData:SetForwardSpeed( 0 )
			m_mvData:SetSideSpeed( 0 )
			m_mvData:SetUpSpeed( 0 )
		end
	
		if m_mvData:KeyDown( IN_SPEED ) then
			m_mvData:SetMaxClientSpeed( 100 )
		end
		if bit.band( m_pClient:GetFlags(), FL_DUCKING ) > 0 then
			m_mvData:SetMaxClientSpeed( m_mvData:GetMaxClientSpeed() * 0.333 )
		end

		if bit.band( m_mvData:GetButtons(), IN_JUMP ) != 0 then
			CheckJump( m_pClient, m_mvData )
		else
			local buttons = bit.band( m_mvData:GetOldButtons(), bit.bnot( IN_JUMP ) )
			m_mvData:SetOldButtons( buttons )
		end


		local ground = m_pClient:GetGroundEntity()
		local worldspawn = SERVER and game.GetWorld() or Entity(0) -- game.GetWorld doesn't work properly on client

		if m_pClient:OnGround() then
			if IsValid( ground ) or ground == worldspawn then
				if m_pClient:Getm_flStopModifier() < 1.0 then
					m_pClient:Setm_flStopModifier( m_pClient:Getm_flStopModifier() + FrameTime() / 3.0 )
				elseif m_pClient:Getm_flStopModifier() > 1.0 then
					m_pClient:Setm_flStopModifier( 1.0 )
				end

				if m_pClient:Getm_flStamina() > 0 then
					local factor = (100.0 - m_pClient:Getm_flStamina() * 0.001 * 19.0) * 0.01
					local velocity = m_mvData:GetVelocity()
					velocity.x = velocity.x * factor
					velocity.y = velocity.y * factor
					m_mvData:SetVelocity( velocity )
				end
			end
		end

		m_mvData:SetMaxClientSpeed( m_mvData:GetMaxClientSpeed() * m_pClient:Getm_flStopModifier() )
	end
end