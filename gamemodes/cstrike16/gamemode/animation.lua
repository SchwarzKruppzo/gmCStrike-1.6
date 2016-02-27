local CS16_TranslateAnimPrefix = {}
CS16_TranslateAnimPrefix["ak47"] = {
	["Idle"] = ACT_IDLE,
	["Run"] = ACT_RUN,
	["Walk"] = ACT_WALK,
	["Jump"] = ACT_JUMP,
	["Reload"] = ACT_RELOAD,
	["Shoot"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
	["Idle_Crouch"] = ACT_CROUCHIDLE,
	["Walk_Crouch"] = ACT_WALK_CROUCH,
	["Reload_Crouch"] = ACT_RELOAD_FINISH,
	["Shoot_Crouch"] = ACT_PLAYER_CROUCH_FIRE,
}
CS16_TranslateAnimPrefix["knife"] = {
	["Idle"] = ACT_HL2MP_IDLE_KNIFE,
	["Run"] = ACT_HL2MP_RUN_KNIFE,
	["Walk"] = ACT_HL2MP_WALK_KNIFE,
	["Jump"] = ACT_HL2MP_JUMP_KNIFE,
	["Shoot"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE,
	["Idle_Crouch"] = ACT_HL2MP_IDLE_CROUCH_KNIFE,
	["Walk_Crouch"] = ACT_HL2MP_WALK_CROUCH_KNIFE,
	["Shoot_Crouch"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
}
CS16_TranslateAnimPrefix["mp5"] = {
	["Idle"] = ACT_HL2MP_IDLE_SMG1,
	["Run"] = ACT_HL2MP_RUN_SMG1,
	["Walk"] = ACT_HL2MP_WALK_SMG1,
	["Jump"] = ACT_HL2MP_JUMP_SMG1,
	["Reload"] = ACT_HL2MP_GESTURE_RELOAD_SMG1,
	["Shoot"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1,
	["Idle_Crouch"] = ACT_HL2MP_IDLE_CROUCH_SMG1,
	["Walk_Crouch"] = ACT_HL2MP_WALK_CROUCH_SMG1,
	["Reload_Crouch"] = ACT_MP_RELOAD_CROUCH,
	["Shoot_Crouch"] = ACT_MP_ATTACK_CROUCH_PRIMARY,
}
CS16_TranslateAnimPrefix["pistol"] = {
	["Idle"] = ACT_HL2MP_IDLE_PISTOL,
	["Run"] = ACT_HL2MP_RUN_PISTOL,
	["Walk"] = ACT_HL2MP_WALK_PISTOL,
	["Jump"] = ACT_HL2MP_JUMP_PISTOL,
	["Reload"] = ACT_HL2MP_GESTURE_RELOAD_PISTOL,
	["Shoot"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL,
	["Idle_Crouch"] = ACT_HL2MP_IDLE_CROUCH_PISTOL,
	["Walk_Crouch"] = ACT_HL2MP_WALK_CROUCH_PISTOL,
	["Reload_Crouch"] = ACT_MP_RELOAD_CROUCH_SECONDARY,
	["Shoot_Crouch"] = ACT_MP_ATTACK_CROUCH_SECONDARY,
}
CS16_TranslateAnimPrefix["grenade"] = {
	["Idle"] = ACT_HL2MP_IDLE_GRENADE,
	["Run"] = ACT_HL2MP_RUN_GRENADE,
	["Walk"] = ACT_HL2MP_WALK_GRENADE,
	["Jump"] = ACT_HL2MP_JUMP_GRENADE,
	["Shoot"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE,
	["Idle_Crouch"] = ACT_HL2MP_IDLE_CROUCH_GRENADE,
	["Walk_Crouch"] = ACT_HL2MP_WALK_CROUCH_GRENADE,
	["Shoot_Crouch"] = ACT_MP_ATTACK_CROUCH_GRENADE,
}
CS16_TranslateAnimPrefix["shotgun"] = {
	["Idle"] = ACT_HL2MP_IDLE_SHOTGUN,
	["Run"] = ACT_HL2MP_RUN_SHOTGUN,
	["Walk"] = ACT_HL2MP_WALK_SHOTGUN,
	["Jump"] = ACT_HL2MP_JUMP_SHOTGUN,
	["Reload"] = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
	["Shoot"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN,
	["Idle_Crouch"] = ACT_HL2MP_IDLE_CROUCH_SHOTGUN,
	["Walk_Crouch"] = ACT_HL2MP_WALK_CROUCH_SHOTGUN,
	["Reload_Crouch"] = ACT_MP_RELOAD_CROUCH_SECONDARY,
	["Shoot_Crouch"] = ACT_MP_RELOAD_CROUCH_END,
}
CS16_TranslateAnimPrefix["c4"] = {
	["Idle"] = ACT_HL2MP_IDLE_CAMERA,
	["Run"] = ACT_HL2MP_RUN_CAMERA,
	["Walk"] = ACT_HL2MP_WALK_CAMERA,
	["Jump"] = ACT_HL2MP_JUMP_CAMERA,
	["Shoot"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_CAMERA,
	["Idle_Crouch"] = ACT_HL2MP_IDLE_CROUCH_CAMERA,
	["Walk_Crouch"] = ACT_HL2MP_WALK_CROUCH_CAMERA,
	["Shoot_Crouch"] = ACT_HL2MP_GESTURE_RELOAD_CAMERA,
}
CS16_TranslateAnimPrefix["carbine"] = {
	["Idle"] = ACT_HL2MP_IDLE_RPG,
	["Run"] = ACT_HL2MP_RUN_RPG,
	["Walk"] = ACT_HL2MP_WALK_RPG,
	["Jump"] = ACT_HL2MP_JUMP_RPG,
	["Reload"] = ACT_HL2MP_GESTURE_RELOAD_RPG,
	["Shoot"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG,
	["Idle_Crouch"] = ACT_HL2MP_IDLE_CROUCH_RPG,
	["Walk_Crouch"] = ACT_HL2MP_WALK_CROUCH_RPG,
	["Reload_Crouch"] = ACT_GESTURE_RANGE_ATTACK2_LOW,
	["Shoot_Crouch"] = ACT_GESTURE_RANGE_ATTACK2,
}
CS16_TranslateAnimPrefix["rifle"] = {
	["Idle"] = ACT_HL2MP_IDLE_REVOLVER,
	["Run"] = ACT_HL2MP_RUN_REVOLVER,
	["Walk"] = ACT_HL2MP_WALK_REVOLVER,
	["Jump"] = ACT_HL2MP_JUMP_REVOLVER,
	["Reload"] = ACT_HL2MP_GESTURE_RELOAD_REVOLVER,
	["Shoot"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER,
	["Idle_Crouch"] = ACT_HL2MP_IDLE_CROUCH_REVOLVER,
	["Walk_Crouch"] = ACT_HL2MP_WALK_CROUCH_REVOLVER,
	["Reload_Crouch"] = ACT_HL2MP_SWIM_IDLE_REVOLVER,
	["Shoot_Crouch"] = ACT_HL2MP_SWIM_REVOLVER,
}
CS16_TranslateAnimPrefix["m249"] = {
	["Idle"] = ACT_HL2MP_IDLE_SCARED,
	["Run"] = ACT_HL2MP_RUN_SCARED,
	["Walk"] = ACT_HL2MP_WALK_SCARED,
	["Jump"] = ACT_HL2MP_JUMP_SCARED,
	["Reload"] = ACT_HL2MP_GESTURE_RELOAD_SCARED,
	["Shoot"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_SCARED,
	["Idle_Crouch"] = ACT_HL2MP_IDLE_CROUCH_SCARED,
	["Walk_Crouch"] = ACT_HL2MP_WALK_CROUCH_SCARED,
	["Reload_Crouch"] = ACT_HL2MP_SWIM_IDLE_SCARED,
	["Shoot_Crouch"] = ACT_HL2MP_SWIM_SCARED,
}
CS16_TranslateAnimPrefix["dual"] = {
	["Idle"] = ACT_HL2MP_IDLE_DUEL,
	["Run"] = ACT_HL2MP_RUN_DUEL,
	["Walk"] = ACT_HL2MP_WALK_DUEL,
	["Jump"] = ACT_HL2MP_JUMP_DUEL,
	["Reload"] = ACT_HL2MP_GESTURE_RELOAD_DUEL,
	["Shoot"] = ACT_HL2MP_GESTURE_RANGE_ATTACK_DUEL,
	["Shoot2"] = ACT_MP_RELOAD_SWIM_SECONDARY,
	["Idle_Crouch"] = ACT_HL2MP_IDLE_CROUCH_DUEL,
	["Walk_Crouch"] = ACT_HL2MP_WALK_CROUCH_DUEL,
	["Reload_Crouch"] = ACT_MP_RELOAD_SWIM_PRIMARY,
	["Shoot_Crouch"] = ACT_MP_RELOAD_SWIM_PRIMARY_END,
	["Shoot2_Crouch"] = ACT_MP_RELOAD_SWIM_SECONDARY_END,
}
CS16_TranslateAnimPrefix["shielded"] = {
	["Idle"] = ACT_SHIELD_UP_IDLE,
	["Run"] = ACT_SHIELD_UP,
	["Walk"] = ACT_SHIELD_KNOCKBACK,
	["Jump"] = ACT_SHIELD_DOWN,
	["Idle_Crouch"] = ACT_CROUCHING_SHIELD_UP_IDLE,
	["Walk_Crouch"] = ACT_SHIELD_ATTACK,
}
CS16_TranslateAnimPrefix["shieldgun"] = {
	["Idle"] = ACT_IDLE_AGITATED,
	["Run"] = ACT_RUN_AGITATED,
	["Walk"] = ACT_WALK_AGITATED,
	["Jump"] = ACT_OVERLAY_SHIELD_KNOCKBACK,
	["Reload"] = ACT_OVERLAY_SHIELD_DOWN,
	["Shoot"] = ACT_OVERLAY_SHIELD_ATTACK,
	["Idle_Crouch"] = ACT_CROUCHIDLE_AGITATED,
	["Walk_Crouch"] = ACT_CROUCHING_SHIELD_UP,
	["Shoot_Crouch"] = ACT_CROUCHING_SHIELD_ATTACK,
	["Reload_Crouch"] = ACT_CROUCHING_GRENADEREADY,
}
CS16_TranslateAnimPrefix["shieldgren"] = {
	["Idle"] = ACT_MP_STAND_BUILDING,
	["Run"] = ACT_MP_RUN_BUILDING,
	["Walk"] = ACT_MP_WALK_BUILDING,
	["Jump"] = ACT_MP_JUMP_BUILDING,
	["Shoot"] = ACT_MP_ATTACK_STAND_GRENADE_BUILDING,
	["Idle_Crouch"] = ACT_MP_CROUCH_BUILDING,
	["Walk_Crouch"] = ACT_MP_CROUCHWALK_BUILDING,
	["Shoot_Crouch"] = ACT_MP_ATTACK_CROUCH_GRENADE_BUILDING,
}
CS16_TranslateAnimPrefix["shieldknife"] = {
	["Idle"] = ACT_MP_STAND_MELEE,
	["Run"] = ACT_MP_RUN_MELEE,
	["Walk"] = ACT_MP_WALK_MELEE,
	["Jump"] = ACT_MP_JUMP_MELEE,
	["Shoot"] = ACT_MP_ATTACK_STAND_MELEE,
	["Idle_Crouch"] = ACT_MP_CROUCH_MELEE,
	["Walk_Crouch"] = ACT_MP_CROUCHWALK_MELEE,
	["Shoot_Crouch"] = ACT_MP_ATTACK_CROUCH_MELEE,
}
function GM:TranslateActivity( ply, act )
    return
end
function GM:DoAnimationEvent( ply, event, data )
	local weapon = ply:GetActiveWeapon()
	if ply:Team() == TEAM_CT and weapon.AnimPrefix == "ak47" then
		weapon.AnimPrefix = "rifle"
	end
    local anim = CS16_TranslateAnimPrefix[weapon.AnimPrefix and weapon.AnimPrefix or "none"]
    local prefixShield = "shielded"
    if ply:HasShield() then
		if !ply:IsShieldDrawn() then
			if weapon.AnimPrefix == "knife" then
				prefixShield = "shieldknife"
			elseif weapon.AnimPrefix == "grenade" then
				prefixShield = "shieldgren"
			else
				prefixShield = "shieldgun"
			end
		end
		anim = CS16_TranslateAnimPrefix[prefixShield]
	end
	
    if data == 23211 then
    	ply:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
    	ply:ResetSequence( ply:SelectWeightedSequence( anim.Idle ) )
    	ply:AnimRestartMainSequence()
    	return ACT_IDLE
    end

	if event == PLAYERANIMEVENT_JUMP then
		ply.m_bJumping = true
		ply.m_bFirstJumpFrame = true
		ply.m_flJumpStartTime = CurTime()
		
		ply:AnimRestartMainSequence()
		return ACT_JUMP
	end

	if event == PLAYERANIMEVENT_CUSTOM_GESTURE and anim and data == 551 then
		if ply:Crouching() then
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, anim.Shoot2_Crouch, true )
		else
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, anim.Shoot2, true )
		end
		return ACT_VM_PRIMARYATTACK
	end
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY and anim then
		if ply:Crouching() then
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, anim.Shoot_Crouch, true )
		else
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, anim.Shoot, true )
		end
		return ACT_VM_PRIMARYATTACK
	end
	if event == PLAYERANIMEVENT_RELOAD and anim then
		if ply:Crouching() then
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, anim.Reload_Crouch, true )
		else
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, anim.Reload, true )
		end

		return ACT_VM_RELOAD
	end
	return ACT_INVALID
end
function HandlePlayerJumping( ply, velocity )
	if ply:GetMoveType() == MOVETYPE_NOCLIP then
		ply.m_bJumping = false
		return
	end

	local weapon = ply:GetActiveWeapon()
	if ply:Team() == TEAM_CT and weapon.AnimPrefix == "ak47" then
		weapon.AnimPrefix = "rifle"
	end
	local anim = CS16_TranslateAnimPrefix[weapon.AnimPrefix and weapon.AnimPrefix or "none"]
	local prefixShield = "shielded"
    if ply:HasShield() then
		if !ply:IsShieldDrawn() then
			if weapon.AnimPrefix == "knife" then
				prefixShield = "shieldknife"
			elseif weapon.AnimPrefix == "grenade" then
				prefixShield = "shieldgren"
			else
				prefixShield = "shieldgun"
			end
		end
		anim = CS16_TranslateAnimPrefix[prefixShield]
	end

	if !ply.m_bJumping and !ply:OnGround() and ply:WaterLevel() <= 0 then
	
		if !ply.m_fGroundTime then
			ply.m_fGroundTime = CurTime()
		elseif (CurTime() - ply.m_fGroundTime) > 0 and velocity:Length2D() < 0.5 then
			ply.m_bJumping = true
			ply.m_bFirstJumpFrame = false
			ply.m_flJumpStartTime = 0
		end
	end
	
	if ply.m_bJumping then
		if ply.m_bFirstJumpFrame then
			ply.m_bFirstJumpFrame = false
		end
		
		if  ply:WaterLevel() >= 2 or ((CurTime() - ply.m_flJumpStartTime) > 0.2 and ply:OnGround()) then
			ply.m_bJumping = false
			ply.m_fGroundTime = nil
		end
		
		if ply.m_bJumping then
			if IsValid( weapon ) and weapon.AnimPrefix then
				if anim then
					ply.CalcIdeal = anim.Jump and anim.Jump or ACT_JUMP
					return true
				end
			end
		end
	end
	
	return false
end
function GM:CalcMainActivity( ply, velocity )
    ply.CalcIdeal = ACT_IDLE
    ply.CalcSeqOverride = -1
    ply.m_flPoseYawOffset = 0

    local weapon = ply:GetActiveWeapon()
    local speed = velocity:Length2D()
    if ply:Team() == TEAM_CT and weapon.AnimPrefix == "ak47" then
		weapon.AnimPrefix = "rifle"
	end
    local anim = CS16_TranslateAnimPrefix[weapon.AnimPrefix and weapon.AnimPrefix or "none"]

    local prefixShield = "shielded"
    if ply:HasShield() then
		if !ply:IsShieldDrawn() then
			if weapon.AnimPrefix == "knife" then
				prefixShield = "shieldknife"
			elseif weapon.AnimPrefix == "grenade" then
				prefixShield = "shieldgren"
			else
				prefixShield = "shieldgun"
			end
		end
		anim = CS16_TranslateAnimPrefix[prefixShield]
	end


    if IsValid( weapon ) and weapon.AnimPrefix and anim then
    	ply.CalcIdeal = anim.Idle and anim.Idle or ACT_IDLE
    
	 	if !HandlePlayerJumping( ply, velocity ) then
		 	if ply:Crouching() then
			    if speed == 0 then
			 		ply.CalcIdeal = anim.Idle_Crouch and anim.Idle_Crouch or ACT_CROUCHIDLE
				else
					ply.CalcIdeal = anim.Walk_Crouch and anim.Walk_Crouch or ACT_WALK_CROUCH
				end
		 	elseif speed > 150 then
		 		ply.m_flPoseYawOffset = 0
		 		ply.CalcIdeal = anim.Run and anim.Run or ACT_RUN
			elseif speed > 0 then
				ply.m_flPoseYawOffset = 24
				ply.CalcIdeal = anim.Walk and anim.Walk or ACT_WALK
			end
		end
	end
    return ply.CalcIdeal, ply.CalcSeqOverride
end
function CalculateYawBlend( ply )
	StudioEstimateGait( ply )

	local yaw = ply:EyeAngles()[2] - ply.m_flGaityaw

	if yaw < -180 then
		yaw = yaw + 360
	elseif yaw > 180 then
		yaw = yaw - 360
	end

	if ply.m_flGaitMovement != 0 then
		if yaw > 120 then
			ply.m_flGaityaw = ply.m_flGaityaw - 180
			ply.m_flGaitMovement = -ply.m_flGaitMovement
			yaw = yaw - 180;
		elseif yaw < -120 then
			ply.m_flGaityaw = ply.m_flGaityaw + 180
			ply.m_flGaitMovement = -ply.m_flGaitMovement
			yaw = yaw + 180
		end
	end

	local blend_yaw = (yaw / 90) * 128 + 127

	if blend_yaw > 255 then
		blend_yaw = 255
	end

	if blend_yaw < 0 then
		blend_yaw = 0
	end

	blend_yaw = 255.0 - blend_yaw
	//pev->blending[0] = (int)blend_yaw;
	return yaw
end
function StudioEstimateGait( ply )
	local dt = FrameTime()

	if dt < 0 then
		dt = 0
	elseif dt > 1 then
		dt = 1
	end

	if dt == 0 then
		ply.m_flGaitMovement = 0
		return
	end

	if !ply.m_prevgaitorigin then ply.m_prevgaitorigin = ply:GetPos() end
	if !ply.m_flGaityaw then ply.m_flGaityaw = 0 end
	if !ply.m_flYawModifier then ply.m_flYawModifier = 0 end

	local velocity = ply:GetPos() - ply.m_prevgaitorigin

	ply.m_prevgaitorigin = ply:GetPos()
	ply.m_flGaitMovement = velocity:Length2D()
		
	if dt <= 0 or ply.m_flGaitMovement / dt < 5 then
		ply.m_flGaitMovement = 0
		velocity.x = 0
		velocity.y = 0
	end


	if velocity.x == 0 and velocity.y == 0 then
		local flYawDiff = ply:EyeAngles()[2] - ply.m_flGaityaw
		local flYaw = flYawDiff

		//flYawDiff = flYawDiff - (flYawDiff / 360) * 360

		if flYawDiff > 180 then
			flYawDiff = flYawDiff - 360
		end

		if flYawDiff < -180 then
			flYawDiff = flYawDiff + 360
		end

		if flYaw < -180 then
			flYaw = flYaw + 360
		elseif flYaw > 180 then
			flYaw = flYaw - 360
		end

		if flYaw > -5 and flYaw < 5 then
			ply.m_flYawModifier = 0.05
		end
		if flYaw < -45 or flYaw > 90 then
			ply.m_flYawModifier = 3.5
		end

		if dt < 0.25 then
			flYawDiff = flYawDiff * dt * ply.m_flYawModifier;
		else
			flYawDiff = flYawDiff * dt
		end

		if math.abs(flYawDiff) < 0.1 then
			flYawDiff = 0
		end

		ply.m_flGaityaw = ply.m_flGaityaw + flYawDiff;
		//ply.m_flGaityaw = ply.m_flGaityaw -  (ply.m_flGaityaw / 360) * 360
		ply.m_flGaitMovement = 0
	else
		ply.m_flGaityaw = (math.atan2(velocity.y, velocity.x) * 180 / math.pi)

		if ply.m_flGaityaw > 180 then
			ply.m_flGaityaw = 180
		end

		if ply.m_flGaityaw < -180 then
			ply.m_flGaityaw = -180
		end
	end
	
end
function GM:UpdateAnimation( ply, velocity, maxSeqGroundSpeed )
	//if CLIENT then
		if ply.m_flGaitMovement and ply.m_flGaitMovement > 0 then
			ply:SetPlaybackRate( math.min(velocity:Length2D() / maxSeqGroundSpeed * 1, 2) )
		elseif ply.m_flGaitMovement and ply.m_flGaitMovement < 0 then
			ply:SetPlaybackRate( -math.min(velocity:Length2D() / maxSeqGroundSpeed * 1, 2) )
		end
		if !ply:OnGround() and !ply:Crouching() then
			ply:SetPlaybackRate( 1 )
		end
	
		local yaw = CalculateYawBlend( ply )

		local ang = Angle( 0, ply.m_flGaityaw, 0 )
		if ang.y < 0 then
			ang.y = ang.y + 360
		end
		ply:SetRenderAngles( ang )

		local yaw = (ply:EyeAngles().y - ply.m_flGaityaw)
		yaw = yaw + ply.m_flPoseYawOffset
		if yaw < -180 then
			yaw = yaw + 360
		end
		if yaw > 180 then
			yaw = yaw - 360
		end
		ply:SetPoseParameter( "aim_yaw", yaw )
	//end
end
