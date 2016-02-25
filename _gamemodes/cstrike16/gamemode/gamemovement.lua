STAMINA_MAX = 100.0
STAMINA_COST_JUMP = 25.0
STAMINA_COST_FALL = 20.0
STAMINA_RECOVER_RATE = 19.0
CS_WALK_SPEED = 100.0

function ReduceTimers( ply )
	if !ply:Getm_flStamina() then ply:Setm_flStamina( 0 ) end

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
function CheckJump( ply, mv, velocity )
	if !ply:Alive() then
		local buttons = bit.bor( mv:GetOldButtons(), IN_JUMP )
		mv:SetOldButtons( buttons )
		return
	end
	if ply:WaterLevel() >= 2 then 
		return 
	end
	if ply:GetGroundEntity() == nil then
		local buttons = bit.bor( mv:GetOldButtons(), IN_JUMP )
		mv:SetOldButtons( buttons )
		return
	end
	if bit.band( mv:GetOldButtons(), IN_JUMP ) != 0 then
		return
	end

	if ply:Getm_flStamina() > 0 then
		local flRatio = ( STAMINA_MAX - ( ( ply:Getm_flStamina()  / 1000.0 ) * STAMINA_RECOVER_RATE ) ) / STAMINA_MAX
		velocity.z = velocity.z * flRatio
	end

	ply:Setm_flStamina( ( STAMINA_COST_JUMP / STAMINA_RECOVER_RATE ) * 1000.0 )

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
	
	hook.Run( "CS16_PlayerUse", ply, mv )
end

