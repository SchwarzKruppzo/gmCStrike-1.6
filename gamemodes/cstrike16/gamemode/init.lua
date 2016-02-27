include("shared.lua")
include("radio.lua")
include("gamelogic.lua")
include("buycommands.lua")
include("animation.lua")
include("damage.lua")

AddCSLuaFile("binds.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("radio.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("gamelogic.lua")
AddCSLuaFile("cstrikevgui.lua")
AddCSLuaFile("gamemovement.lua")
AddCSLuaFile("oldhud.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("animation.lua")
AddCSLuaFile("damage.lua")

DEFINE_BASECLASS( "gamemode_base" )

// Global variables
SetGlobalInt( "g_iGameState", 0 )
SetGlobalInt( "g_iCurrentRound", 0 )
SetGlobalFloat( "g_flRoundTimer", 0 )
SetGlobalFloat( "g_flFreezeTime", 0 )
SetGlobalBool( "m_bMapHasBombTarget", false )
SetGlobalBool( "m_bMapHasRescueZone", false )

// Functions
local m_mPlayer = FindMetaTable( "Player" )

function SetRound( int )
	SetGlobalInt( "g_iCurrentRound", int )
end

function m_mPlayer:SetMoney( int )
	self:SetNWInt( "m_iMoney", int )
	if self:GetMoney() > 16000 then
		self:SetNWInt( "m_iMoney", 16000 )
	end
end
function m_mPlayer:AddMoney( int )
	self:SetNWInt( "m_iMoney", self:GetMoney() + int )
	if self:GetMoney() > 16000 then
		self:SetNWInt( "m_iMoney", 16000 )
	end
	umsg.Start( "AddMoney", self )
		umsg.String( tostring( int ) )
	umsg.End()
end
function m_mPlayer:SetModelID( int )
	self:SetNWInt( "m_iModelID", int )
end

function m_mPlayer:OldPrintMessage( str )
	umsg.Start( "OldPrintMessage", self )
		umsg.String( str )
	umsg.End()
end
function OldPrintMessage( str )
	umsg.Start( "OldPrintMessage" )
		umsg.String( str )
	umsg.End()
end

function ClientChatPrint( ... )
	local m_tblArgs = { ... }
	local m_tblFilter = RecipientFilter()

	if type( m_tblArgs[1] ) == "Player" then
		m_tblFilter:AddPlayer( m_tblArgs[1] )
	elseif type( m_tblArgs[1] ) == "number" then
		for k, v in pairs( team.GetPlayers( m_tblArgs[1] ) ) do
			m_tblFilter:AddPlayer( v )
		end
	elseif m_tblArgs[1] == nil then
		m_tblFilter:AddAllPlayers()
	end

	umsg.Start( "ClientChatPrint", m_tblFilter )
		umsg.Short( #m_tblArgs )
		for k, v in pairs( m_tblArgs ) do
			if type( v ) == "string" then
				umsg.Bool( false )
				umsg.String( v )
			elseif type( v ) == "table" then
				umsg.Bool( true )
				umsg.Short( v.r )
				umsg.Short( v.g )
				umsg.Short( v.b )
			end
		end
	umsg.End()
end

// Hooks
function GM:Initialize()

end

function GM:PlayerInitialSpawn( m_hClient )
	BaseClass.PlayerInitialSpawn( self, m_hClient )
	if m_hClient:IsBot() then
		m_hClient:ChangeTeam( SelectDefaultTeam() )
		m_hClient:Spawn()
		m_hClient.m_iNumSpawns = 0
		m_hClient:SetModelID( math.random( 1, 4 ) )
		m_hClient:SetModelFromClass()
		m_hClient:GetIntoGame()
		return
	end
	m_hClient:SetTeam( TEAM_UNASSIGNED )
	m_hClient:SetState( STATE_WELCOME )
	m_hClient:ShowViewPortPanel( PANEL_MOTD )
end

function GM:PlayerSpawn( m_hClient )
	player_manager.SetPlayerClass( m_hClient, "csplayer" )
	if m_hClient:IsObserver() then
		player_manager.RunClass( m_hClient, "SpawnSpectator" )
	else
		player_manager.RunClass( m_hClient, "Spawn" )
	end
end

function GM:PlayerSelectSpawn( m_hClient )
	local classes
	local spawns
	if m_hClient:IsObserver() then
		spawns = ents.FindByClass( "info_player_start" )
	else
		classes = team.GetSpawnPoint( m_hClient:Team() ) and team.GetSpawnPoint( m_hClient:Team() ) or "info_player_start"
		spawns = ents.FindByClass( classes[1] )
	end
	
	local random_entry = math.random( #spawns )
	return spawns[ random_entry ]
end

function GM:PlayerSwitchFlashlight( m_hClient, m_bEnabled )
	if GetConVar("sv_cs16_flashlight"):GetInt() == 0 then
		return false
	end
	return true
end

local hackButtons = {
	IN_ALT1,
	IN_ALT2,
	IN_ATTACK,
	IN_ATTACK2,
	IN_BACK,
	IN_DUCK,
	IN_FORWARD,
	IN_JUMP,
	IN_LEFT,
	IN_MOVELEFT,
	IN_MOVERIGHT,
	IN_RELOAD,
	IN_SPEED,
	IN_USE,
	IN_WALK,
	IN_ZOOM,
	IN_GRENADE1,
	IN_GRENADE2,
	IN_WEAPON1,
	IN_WEAPON2,
	IN_BULLRUSH,
	IN_CANCEL,
	IN_RUN
}

function GM:PlayerTick( m_hClient )
	m_hClient:ResetMaxSpeed()
	if m_hClient:Team() == TEAM_T then
		if m_hClient:HasWeapon( CS16_WEAPON_C4 ) then
			if m_hClient:GetBodygroup( 1 ) != 1 then
				m_hClient:SetBodygroup( 1, 1 )
			end
		else
			if m_hClient:GetBodygroup( 1 ) != 0 then
				m_hClient:SetBodygroup( 1, 0 )
			end
		end
	elseif m_hClient:Team() == TEAM_CT then
		if m_hClient:HasDefuser() then
			if m_hClient:GetBodygroup( 1 ) != 1 then
				m_hClient:SetBodygroup( 1, 1 )
			end
		else
			if m_hClient:GetBodygroup( 1 ) != 0 then
				m_hClient:SetBodygroup( 1, 0 )
			end
		end
	end
	if m_hClient:GetState() == STATE_DEATH_ANIM then
		if m_hClient:OnGround() then
			local flForward = m_hClient:GetVelocity():Length() - 20
			if flForward <= 0 then
				m_hClient:SetVelocity( Vector() )
			else
				local vAbsVel = m_hClient:GetVelocity()
				vAbsVel:Normalize()
				vAbsVel = vAbsVel * flForward
				m_hClient:SetVelocity( vAbsVel )
			end
		end

		if CurTime() >= m_hClient:Getm_flDeathTime() + 3 then
			m_hClient:SetState( STATE_DEATH_WAIT_FOR_KEY )
		end
	elseif m_hClient:GetState() == STATE_DEATH_WAIT_FOR_KEY then
		local fAnyButtonDown = false
		for k,v in pairs( hackButtons ) do
			if m_hClient:KeyPressed( v ) then
				fAnyButtonDown = true
			end
		end
		if CurTime() >= m_hClient:Getm_flDeathTime() + 3 then
			fAnyButtonDown = true
		end
		if fAnyButtonDown then
			m_hClient:SetState( STATE_OBSERVER_MODE )
		end
	end
end

local FCAP_IMPULSE_USE = 0x00000010
local FCAP_CONTINUOUS_USE = 0x00000020
local FCAP_ONOFF_USE = 0x00000040

function GM:CS16_PlayerUse( player, moveData )
	if moveData:GetButtons() <= 0 then
		return
	end
	
	local pObject = nil
	local vecLOS = Vector()
	local flMaxDot = 0.7
	local flDot = 0
	local forward = player:EyeAngles():Forward()

	for k, v in pairs( ents.FindInSphere( player:GetPos(), 64 ) ) do
		if v:GetClass() != "cs16_planted_c4" then continue end
		if !v.ObjectCaps then continue end
		if bit.bor( v:ObjectCaps(), FCAP_IMPULSE_USE, FCAP_CONTINUOUS_USE, FCAP_ONOFF_USE ) > 0 then
			vecLOS = v:GetPos() - (player:GetPos() + player:GetCurrentViewOffset())

			if vecLOS:LengthSqr() < (96*96) then
				vecLOS:Normalize()
				flDot = forward:DotProduct( vecLOS )
				if flDot > 0.7 then
					pObject = v
				end
			end
		end 
	end
	if IsValid( pObject ) then
		local caps = pObject:ObjectCaps()
		if bit.band( moveData:GetButtons(), IN_USE ) > 0 and bit.band( caps, FCAP_CONTINUOUS_USE ) > 0 or moveData:KeyPressed( IN_USE ) and bit.band( caps, FCAP_IMPULSE_USE, FCAP_ONOFF_USE ) > 0 then
			pObject:CS16_Use( player )
			return
		end
	end
end

function GM:GetFallDamage( m_hClient, m_iSpeed )
	return 0
end
function GM:EntityTakeDamage( m_hClient, m_dmgInfo )
	local m_hAttacker = m_dmgInfo:GetAttacker()
	local m_hInflictor = m_dmgInfo:GetInflictor()
	local m_iDamageType = m_dmgInfo:GetDamageType()
	local m_flDamage = m_dmgInfo:GetDamage()

	if m_hClient:IsPlayer() then
		if m_hAttacker != m_hClient then
			if GetConVar("sv_cs16_friendlyfire"):GetInt() == 0 then
				if m_hAttacker:IsPlayer() then
					if m_hClient:Team() == m_hAttacker:Team() then
						return true
					end
				end
			end
		end

		local ffound = true
		local fmajor
		local fcritical
		local fTookDamage
		local ftrivial
		local flRatio = ARMOR_RATIO
		local flBonus = ARMOR_BONUS
		local flHealthPrev = m_hClient:Health()
		local armorhit = 0

		if m_iDamageType == DMG_BLAST then
			flBonus = flBonus * 2
		end

		if m_hInflictor:IsWeapon() then
			if m_hInflictor:GetClass() == CS16_WEAPON_AUG or m_hInflictor:GetClass() == CS16_WEAPON_M4A1 then
				flRatio = flRatio * 1.4
			elseif m_hInflictor:GetClass() == CS16_WEAPON_AWP then
				flRatio = flRatio * 1.95
			elseif m_hInflictor:GetClass() == CS16_WEAPON_G3SG1 then
				flRatio = flRatio * 1.65
			elseif m_hInflictor:GetClass() == CS16_WEAPON_SG550 then
				flRatio = flRatio * 1.45
			elseif m_hInflictor:GetClass() == CS16_WEAPON_M249 then
				flRatio = flRatio * 1.5
			elseif m_hInflictor:GetClass() == CS16_WEAPON_ELITE then
				flRatio = flRatio * 1.05
			elseif m_hInflictor:GetClass() == CS16_WEAPON_DEAGLE then
				flRatio = flRatio * 1.5
			elseif m_hInflictor:GetClass() == CS16_WEAPON_GLOCK18 then
				flRatio = flRatio * 1.05
			elseif m_hInflictor:GetClass() == CS16_WEAPON_FIVESEVEN or m_hInflictor:GetClass() == CS16_WEAPON_P90 then
				flRatio = flRatio * 1.5
			elseif m_hInflictor:GetClass() == CS16_WEAPON_MAC10 then
				flRatio = flRatio * 0.95
			elseif m_hInflictor:GetClass() == CS16_WEAPON_P228 then
				flRatio = flRatio * 1.25
			elseif m_hInflictor:GetClass() == CS16_WEAPON_SCOUT or m_hInflictor:GetClass() == CS16_WEAPON_KNIFE then
				flRatio = flRatio * 1.7
			elseif m_hInflictor:GetClass() == CS16_WEAPON_FAMAS or m_hInflictor:GetClass() == CS16_WEAPON_SG552 then
				flRatio = flRatio * 1.4
			elseif m_hInflictor:GetClass() == CS16_WEAPON_GALIL or m_hInflictor:GetClass() == CS16_WEAPON_AK47 then
				flRatio = flRatio * 1.55
			end
		end
		if m_dmgInfo:GetDamageType() != DMG_FALL or m_iDamageType != DMG_DROWN then
			if m_hClient:Getm_iArmorValue() > 0 and m_hClient:IsArmored( m_hClient:LastHitGroup() ) then
				local flNew = m_flDamage * flRatio
				local flArmor = (m_flDamage - flNew) * flBonus

				if flArmor <= m_hClient:Getm_iArmorValue() then
					armorhit = m_hClient:Getm_iArmorValue()

					if flArmor < 0 then
						flArmor = 1
					end

					m_hClient:Setm_iArmorValue( m_hClient:Getm_iArmorValue() - flArmor )
					m_hClient:Setm_iOldArmor( m_hClient:Getm_iArmorValue() - flArmor )
					armorhit = armorhit - m_hClient:Getm_iArmorValue()
				else
					armorhit = m_hClient:Getm_iArmorValue()
					flArmor = m_hClient:Getm_iArmorValue() * (1 / flBonus)
					m_hClient:Setm_iArmorValue( 0 )
					m_hClient:Setm_bHasHelmet( false )
					flNew = m_flDamage - flArmor
				end

				m_dmgInfo:SetDamage( flNew )
			end
		end

		if IsValid( m_hInflictor ) and !m_hInflictor:IsWeapon() then
			m_hClient.m_vBlastVector = m_hClient:GetPos() - m_hInflictor:GetPos()
		end
		if m_dmgInfo:GetDamageType() == DMG_BLAST then
			m_hClient.m_bKilledByBomb = true
		elseif m_dmgInfo:GetDamageType() == DMG_PLASMA then
			m_hClient.m_bKilledByGrenade = true
		end

		m_hClient:Pain( true )
		m_hClient:Setm_flStopModifier( 0.5 )

		umsg.Start( "msg_Damage", m_hClient )
			umsg.Vector( m_dmgInfo:GetAttacker():GetPos() )
		umsg.End()
	end
end

function GetAlivePlayers()
	local tbl = {}
	for k, v in pairs( player.GetAll() ) do
		if v:GetState() != STATE_ACTIVE then continue end
		if !v:Alive() then continue end

		table.insert( tbl, v )
	end
	return tbl
end
function GetNextPlayerForSpectating( m_hCurrent, m_hExclude )
	local alive = GetAlivePlayers()
	if #alive < 1 then return nil end
	local prev = nil
	local choice = nil
	if IsValid( m_hCurrent ) then
		for k, p in pairs( alive ) do
			if p == m_hExclude then continue end
			if prev == m_hCurrent then
				choice = p
			end
			prev = p
		end
	end
	if !IsValid( choice ) then
		choice = alive[1]
	end
	return choice
end
function GetPrevPlayerForSpectating( m_hCurrent, m_hExclude )
	local alive = GetAlivePlayers()
	if #alive < 1 then return nil end
	local prev = nil
	local choice = nil
	if IsValid( m_hCurrent ) then
		for k, p in pairs( alive ) do
			local id = #alive - k
			if id <= 0 then
				id = #alive
			end
			local p = alive[id]
			if p == m_hExclude then 
				continue
			end
			if prev == m_hCurrent then
				choice = p
			end
			prev = p
		end
	end
	if !IsValid( choice ) then
		choice = alive[1]
	end
	return choice
end
function GM:KeyPress( m_hClient, m_iKey )
	if !IsValid( m_hClient ) then return end
	if m_hClient:IsObserver() then
		if m_iKey == IN_JUMP then
			if m_hClient:GetObserverMode() == OBS_MODE_ROAMING then
				m_hClient:Setm_iObserverLastMode( OBS_MODE_CHASE )
				m_hClient:Spectate( OBS_MODE_CHASE )
				local target = nil
				if m_hClient:GetObserverTarget() == m_hClient then
					target = GetNextPlayerForSpectating( m_hClient )
				end
				m_hClient:SpectateEntity( target )
			elseif m_hClient:GetObserverMode() == OBS_MODE_CHASE then
				m_hClient:Setm_iObserverLastMode( OBS_MODE_IN_EYE )
				m_hClient:Spectate( OBS_MODE_IN_EYE )
				local target = nil
				if m_hClient:GetObserverTarget() == m_hClient then
					target = GetNextPlayerForSpectating( m_hClient )
				end
				m_hClient:SpectateEntity( target )
			elseif m_hClient:GetObserverMode() == OBS_MODE_IN_EYE then
				m_hClient:Setm_iObserverLastMode( OBS_MODE_ROAMING )
				m_hClient:Spectate( OBS_MODE_ROAMING )
				m_hClient:SpectateEntity( nil )
			end
		elseif m_iKey == IN_ATTACK then
			if m_hClient:GetObserverMode() == OBS_MODE_CHASE or m_hClient:GetObserverMode() == OBS_MODE_IN_EYE then
				local target = m_hClient:GetObserverTarget()
				target = GetNextPlayerForSpectating( target, m_hExclude )
				m_hClient:SpectateEntity( target )
			end
		elseif m_iKey == IN_ATTACK2 then
			if m_hClient:GetObserverMode() == OBS_MODE_CHASE or m_hClient:GetObserverMode() == OBS_MODE_IN_EYE then
				local target = m_hClient:GetObserverTarget()
				target = GetPrevPlayerForSpectating( target, m_hExclude )
				m_hClient:SpectateEntity( target )
			end
		end
	end
end


// Commands
concommand.Add( "jointeam", function( ply, cmd, args )
	local team = args[1]
	if !team then
		ply:ShowViewPortPanel( PANEL_TEAM )
		return
	end
	team = math.floor( args[1] )

	if ply.m_bTeamChanged and team != m_iOldTeam and team != TEAM_SPEC then
		ply:OldPrintMessage( "csl_Only_1_Team_Change" )
		return
	end

	if team == TEAM_UNASSIGNED then
		team = SelectDefaultTeam()

		if team == TEAM_UNASSIGNED then
			ply:OldPrintMessage( "csl_All_Teams_Full" )
			ply:ShowViewPortPanel( PANEL_TEAM )
			return
		end
	end

	if team == ply:Team() then
		if ply:Team() == TEAM_T then
			ply:ShowViewPortPanel( PANEL_CLASS_T )
		elseif ply:Team() == TEAM_CT then
			ply:ShowViewPortPanel( PANEL_CLASS_CT )
		end
		return
	end

	if TeamFull( team ) then
		if team == TEAM_T then
			ply:OldPrintMessage( "csl_Terrorists_Full" )
		elseif team == TEAM_CT then
			ply:OldPrintMessage( "csl_CTs_Full" )
		end
		ply:ShowViewPortPanel( PANEL_TEAM )
		return
	end

	if team == TEAM_SPEC then
		if GetConVar("sv_cs16_allowspectators"):GetInt() == 0 then
			ply:OldPrintMessage( "csl_Cannot_Be_Spectator" )
			return
		end
		if ply:Team() != TEAM_UNASSIGNED and ply:Alive() then
			ply:Kill()
			ply:AddFrags( 1 )
		end
		ply:SetTeam( TEAM_SPEC )
		ply:SetModelID( 0 )


		return
	end

	if TeamStacked( team, ply:Team() ) then
		ply:OldPrintMessage( team == TEAM_TERRORIST and	"csl_Too_Many_Terrorists" or "csl_Too_Many_CTs" )
		ply:ShowViewPortPanel( PANEL_TEAM )
		return
	end
	ply:ChangeTeam( team )
end )
concommand.Add( "joinclass", function( ply, cmd, args )
	local class = args[1]
	if class then
		class = math.floor( args[1] )
	end
	if class == CS_CLASS_NONE then
		class = math.random( 1, 4 )
	end
	ply:SetModelID( class )
	ply:SetModelFromClass()

	if ply:GetState() == STATE_ACTIVE then
		CheckWinConditions()
	end

	if !ply:Alive() then
		ply:GetIntoGame()
	else
		ply:Kill()
	end
end )
concommand.Add( "buy", function( ply, cmd, args )
	if !ply:IsInBuyZone() then return end

	ply:ShowViewPortPanel( PANEL_BUYMENU )
	return
end )

// Game events
gameevent.Listen( "player_disconnect" )
gameevent.Listen( "player_connect" )

hook.Add( "player_disconnect", "Notification", function( data )
	ClientChatPrint( nil, Color( 255, 255, 255 ), "csl_Player", " " .. data.name .. " ", "csl_HasBeenDisconnected", " ("..data.reason..")." )
end )
hook.Add( "player_connect", "Notification", function( data )
	ClientChatPrint( nil, Color( 255, 255, 255 ), "csl_Player", " " .. data.name .. " ", "csl_HasBeenConnected", "." )
end )

// Load gamemode content
resource.AddWorkshop( "509406601" )
resource.AddWorkshop( "214281320" )
//resource.AddWorkshop( "357662134" )