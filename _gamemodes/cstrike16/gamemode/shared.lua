GM.Name = "Counter-Strike 1.6: Source"
GM.Author = "Schwarz Kruppzo"
GM.Email = ""
GM.Website = ""
GM.IsCStrike = true

DeriveGamemode("base")
include( "csplayer.lua" )
include( "gamemovement.lua" )

DEFINE_BASECLASS( "gamemode_base" )

CreateConVar( "sv_cs16_roundtimer", "1", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "Time per round (minutes)" )
CreateConVar( "sv_cs16_freezetime", "6", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "Freeze time (seconds)" )
CreateConVar( "sv_cs16_startingmoney", "16000", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "Starting money" )
CreateConVar( "sv_cs16_maxrounds", "0", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_fraglimit", "0", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_winlimit", "0", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_restartgame", "0", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_limitteams", "2", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_friendlyfire", "0", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_motd_url", "http://puu.sh/jSCSP.txt", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_friendlycollide", "0", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_flashlight", "1", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_buytime", "1", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )

CreateConVar( "sv_cs16_allowspectators", "1", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_allow_chase", "1", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_allow_ineye", "1", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_allow_freecam", "1", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )
CreateConVar( "sv_cs16_allow_spectate_all", "1", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "" )

if CLIENT then
	CreateClientConVar( "cl_cs16_autoselectdrop", "1", true, true )
end
TEAM_SPEC = 1
TEAM_T = 2
TEAM_CT = 3
GAMESTATE_INVALID = 0
GAMESTATE_ROUND_START = 1
GAMESTATE_ROUND_PLAYING = 2
GAMESTATE_ROUND_END = 3
GAMESTATE_GAME_OVER = 4
WINNER_NONE = 0
WINNER_DRAW = 1
WINNER_TER = 2
WINNER_CT = 3
STATE_ACTIVE = 0
STATE_WELCOME = 1
STATE_PICKINGTEAM = 2
STATE_PICKINGCLASS = 3
STATE_DEATH_ANIM = 4
STATE_DEATH_WAIT_FOR_KEY = 5
STATE_OBSERVER_MODE = 6
NUM_PLAYER_STATES = 7
Target_Bombed = 1
Bomb_Defused = 2
CTs_Win = 3
Terrorists_Win = 4
Round_Draw = 5
All_Hostages_Rescued = 6
Target_Saved = 7
Hostages_Not_Rescued = 8
Game_Commencing = 9
PANEL_TEAM = "CStrike_Teampick"
PANEL_CLASS_T = "CStrike_ClassT"
PANEL_CLASS_CT = "CStrike_ClassCT"
PANEL_MOTD = "CStrike_MOTD"
PANEL_BUYMENU = "CStrike_Buymenu"
WEAPON_SLOT_RIFLE = 0
WEAPON_SLOT_PISTOL = 1
WEAPON_SLOT_KNIFE = 2
WEAPON_SLOT_GRENADES = 3
WEAPON_SLOT_C4 = 4
WEAPON_SLOT_FIRST = 0
WEAPON_SLOT_LAST = 4
ARMOR_RATIO = 0.5
ARMOR_BONUS = 0.5 
CHATPRINT_GREEN = Color( 185, 255, 130 )
THROW_NONE = 0
THROW_FORWARD = 1
THROW_BACKWARD = 2
THROW_HITVEL = 3
THROW_BOMB = 4
THROW_GRENADE = 5
THROW_HITVEL_MINUS_AIRVEL = 6
HITGROUP_SHIELD = 8

// Team Set-Up
team.SetUp( TEAM_SPEC, "Spectators", Color( 255, 255, 255 ) )
team.SetUp( TEAM_T, "Terrorists", Color( 255, 63, 63 ) )
team.SetUp( TEAM_CT, "Counter-Terrorists", Color( 153, 204, 255 ) )
team.SetSpawnPoint( TEAM_T, { "info_player_terrorist" } )
team.SetSpawnPoint( TEAM_CT, { "info_player_counterterrorist" } )

// Hooks
function GM:PlayerFootstep( m_hClient, m_vPos, m_iFoot, m_strSound, m_flVolume, m_rFilter )
	if m_hClient:IsObserver() then return end

	local m_flVolume = 1.0
	if  m_hClient:KeyDown( IN_SPEED ) then 
		return true 
	end
	if m_hClient:KeyDown( IN_DUCK ) then
		m_flVolume = m_flVolume * 0.35
	end
	local isMetal = false
	local isDirt = false
	local isLadder = false
	local isGrate = false
	local isSnow = false
	local isTile = false
	local isDuct = false

	if string.find( m_strSound, "ladder" ) then
		isLadder = true
	end
	if string.find( m_strSound, "metal" ) then
		isMetal = true
	end

	if SERVER then
		if m_hClient:GetVelocity():Length() > 150 or m_hClient:GetMoveType() == MOVETYPE_LADDER then
			if m_iFoot == 0 then
				if isLadder then
					m_hClient:EmitSound( "cs16player/pl_ladder" .. math.random( 1, 2 ) .. ".wav", 75, 100, m_flVolume )
				elseif isMetal then
					m_hClient:EmitSound( "cs16player/pl_metal" .. math.random( 1, 2 ) .. ".wav", 75, 100, m_flVolume )
				else
					m_hClient:EmitSound( "cs16player/pl_step" .. math.random( 1, 2 ) .. ".wav", 75, 100, m_flVolume )
				end
			else
				if isLadder then
					m_hClient:EmitSound( "cs16player/pl_ladder" .. math.random( 3, 4 ) .. ".wav", 75, 100, m_flVolume )
				elseif isMetal then
					m_hClient:EmitSound( "cs16player/pl_metal" .. math.random( 3, 4 ) .. ".wav", 75, 100, m_flVolume )
				else
					m_hClient:EmitSound( "cs16player/pl_step" .. math.random( 3, 4 ) .. ".wav", 75, 100, m_flVolume )
				end
			end
		end
	end
	return true
end
function GM:PlayerStepSoundTime( m_hClient, m_iType, m_bWalking )
	return 300
end
function GM:ScalePlayerDamage( m_hClient, m_iHitgroup, m_dmgInfo )
	if m_iHitgroup == HITGROUP_HEAD then
		m_dmgInfo:ScaleDamage( 4 )
		local p = m_dmgInfo:GetDamage() * -0.5
		local z = m_dmgInfo:GetDamage() * math.Rand( -1, 1 )

		local punchAngle = m_hClient:CS16_GetViewPunch( CLIENT )
		punchAngle.p =  p
		if punchAngle.p < -12 then
			punchAngle.p = -12
		end
		punchAngle.z =  z
		if punchAngle.z < -9 then
			punchAngle.z = -9
		elseif punchAngle.z > 9 then
			punchAngle.z = 9
		end

		m_hClient:CS16_SetViewPunch( punchAngle, true )
	elseif m_iHitgroup == HITGROUP_CHEST then
		m_dmgInfo:ScaleDamage( 1 )

		if m_hClient:Getm_iArmorValue() <= 0 then
			local punchAngle = m_hClient:CS16_GetViewPunch( CLIENT )
			punchAngle.p = m_dmgInfo:GetDamage() * -0.1
			if punchAngle. p < -4 then
				punchAngle.p = -4
			end
			m_hClient:CS16_SetViewPunch( punchAngle, true )
		end
	elseif m_iHitgroup == HITGROUP_STOMACH then
		m_dmgInfo:ScaleDamage( 1.25 )

		if m_hClient:Getm_iArmorValue() <= 0 then
			local punchAngle = m_hClient:CS16_GetViewPunch( CLIENT )
			punchAngle.p = m_dmgInfo:GetDamage() * -0.1
			if punchAngle. p < -4 then
				punchAngle.p = -4
			end
			m_hClient:CS16_SetViewPunch( punchAngle, true )
		end
	elseif m_iHitgroup == HITGROUP_LEFTARM or m_iHitgroup == HITGROUP_RIGHTARM then
		m_dmgInfo:ScaleDamage( 1 )
	elseif m_iHitgroup == HITGROUP_LEFTLEG or m_iHitgroup == HITGROUP_RIGHTLEG then
		m_dmgInfo:ScaleDamage( 0.75 )
	elseif m_iHitgroup == HITGROUP_SHIELD then
		local punchAngle = m_hClient:CS16_GetViewPunch( CLIENT )
		punchAngle.p = m_dmgInfo:GetDamage() * math.Rand( -0.15, 0.15 )
		punchAngle.r = m_dmgInfo:GetDamage() * math.Rand( -0.15, 0.15 )

		if punchAngle.p < 4 then
			punchAngle.p = 4
		end
		if punchAngle.r < -5 then
			punchAngle.r = -5
		elseif punchAngle.r > 5 then
			punchAngle.r = 5
		end
		m_hClient:CS16_SetViewPunch( punchAngle, true )
		m_dmgInfo:ScaleDamage( 0 )
	end
end
function GM:PlayerTraceAttack( m_hClient, m_dmgInfo, m_vDir, m_tblTrace )
	local dtrace = {}
	dtrace.start = m_tblTrace.HitPos
	dtrace.endpos = dtrace.start + m_vDir * 250
	dtrace.filter = m_hClient
	dtrace.mask = MASK_NPCWORLDSTATIC
	
	local tr = util.TraceLine( dtrace )
	if m_tblTrace.HitGroup != HITGROUP_SHIELD then
		local ed = EffectData()
		ed:SetOrigin( m_tblTrace.HitPos + m_tblTrace.HitNormal * 5 )
		util.Effect( "BloodImpact", ed )
		if tr.Hit then
			util.Decal( "Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
		end	
	end	
	if m_dmgInfo:GetInflictor() == m_dmgInfo:GetAttacker() then
		m_dmgInfo:SetInflictor( m_dmgInfo:GetAttacker():GetActiveWeapon() )
	end
	if SERVER then
		m_hClient.deathact = GetDeathActivity( m_hClient, m_dmgInfo )
 		GAMEMODE:ScalePlayerDamage( m_hClient, m_tblTrace.HitGroup, m_dmgInfo ) 
 		if m_dmgInfo:GetDamage() != 0 then
			m_hClient:TakeDamageInfo( m_dmgInfo )
		end
 	end

	return true
end
function GM:AllowPlayerPickup( ply, ent )
	return false
end
function GM:ShouldCollide( m_hEntity, m_hEntity2 )
	if GetConVar("sv_cs16_friendlycollide"):GetInt() == 0 then
		if m_hEntity:IsPlayer() and m_hEntity2:IsPlayer() then
			if m_hEntity:Team() == m_hEntity2:Team() then
				return false
			end
		end
	end

	local collisionGroup0 = m_hEntity:GetCollisionGroup()
	local collisionGroup1 = m_hEntity2:GetCollisionGroup()
	local phys = m_hEntity2:GetPhysicsObject()
	if collisionGroup0 > collisionGroup1 then
		local old = collisionGroup0
		collisionGroup0 = collisionGroup1
		collisionGroup1 = old
	end

	if m_hEntity.m_bIsC4 then
		if m_hEntity2.IsWeaponBox or m_hEntity2:IsPlayer() then
			return false
		end
	end
	if m_hEntity.IsWeaponBox then
		if m_hEntity2.IsWeaponBox or m_hEntity2:IsPlayer() then
			return false
		end
	end
	if m_hEntity:IsPlayer() then
		if m_hEntity2.IsWeaponBox or m_hEntity2.m_bIsC4 then
			return false
		end
	end

	if collisionGroup0 == COLLISION_GROUP_PLAYER_MOVEMENT and 
		collisionGroup1 == COLLISION_GROUP_WEAPON then
		return false
	end

	if (collisionGroup0 == COLLISION_GROUP_PLAYER or collisionGroup0 == COLLISION_GROUP_PLAYER_MOVEMENT) and
		collisionGroup1 == COLLISION_GROUP_PUSHAWAY then
		if m_hEntity2:GetModel() != "models/props_c17/oildrum001.mdl" then
			return false
		end
		return true
	end

	if collisionGroup0 == COLLISION_GROUP_PUSHAWAY and collisionGroup1 == COLLISION_GROUP_PUSHAWAY then
		return true
	end


	return true
end
function GM:OnEntityCreated( m_hEntity )
	if m_hEntity:GetClass() == "prop_physics_multiplayer" then
		m_hEntity:SetCollisionGroup( COLLISION_GROUP_PUSHAWAY )
		if SERVER then 
			timer.Simple( 1, function() 
				m_hEntity:GetPhysicsObject():EnableMotion( false )
			end)
		end
	end
end

// Functions
local m_mPlayer = FindMetaTable( "Player" )

function GetRound()
	return GetGlobalInt( "g_iCurrentRound" )
end
function GetRoundRemainingTime()
	return (GetGlobalFloat("m_fRoundStartTime") + GetGlobalFloat("m_iRoundTime")) - CurTime()
end
function GetMapRemainingTime()
end

function m_mPlayer:GetMoney()
	return self:GetNWInt( "m_iMoney" ) or 0
end
function m_mPlayer:GetModelID()
	return self:GetNWInt( "m_iModelID" ) or 0
end

function IsBombDefuse()
	local m_sMap = game.GetMap()
	local m_sType = string.Explode( "_", m_sMap )

	if m_sType[1] == "de" then
		return true
	end
	return false
end

function ResetAllPlayers( m_bRespawn, m_bFreeze, m_bResetMoney )
	for k,v in pairs( player.GetAll() ) do
		if m_bRespawn then 
			v:Spawn() 
		end
		if m_bFreeze then
			v:SetMoveType( MOVETYPE_NONE )
		else
			v:SetMoveType( MOVETYPE_WALK )
		end
		if m_bResetMoney then
			v:SetMoney( GetConVar("sv_cs16_startmoney"):GetInt() )
			v:ChatPrint( "Money: " .. v:GetMoney() )
		end
	end
end

// Precache
util.PrecacheModel( "models/cs16/pshell.mdl" )
util.PrecacheModel( "models/cs16/rshell.mdl" )
util.PrecacheModel( "models/cs16/rshell_big.mdl" )
util.PrecacheModel( "models/cs16/shotgunshell.mdl" )
util.PrecacheModel( "models/cs16/w_ak47.mdl" )
util.PrecacheModel( "models/cs16/w_aug.mdl" )
util.PrecacheModel( "models/cs16/w_awp.mdl" )
util.PrecacheModel( "models/cs16/w_deagle.mdl" )
util.PrecacheModel( "models/cs16/w_elite.mdl" )
util.PrecacheModel( "models/cs16/w_famas.mdl" )
util.PrecacheModel( "models/cs16/w_fiveseven.mdl" )
util.PrecacheModel( "models/cs16/w_g3sg1.mdl" )
util.PrecacheModel( "models/cs16/w_galil.mdl" )
util.PrecacheModel( "models/cs16/w_glock18.mdl" )
util.PrecacheModel( "models/cs16/w_hegrenade.mdl" )
util.PrecacheModel( "models/cs16/w_knife.mdl" )
util.PrecacheModel( "models/cs16/w_m3.mdl" )
util.PrecacheModel( "models/cs16/w_m4a1.mdl" )
util.PrecacheModel( "models/cs16/w_m429.mdl" )
util.PrecacheModel( "models/cs16/w_mac10.mdl" )
util.PrecacheModel( "models/cs16/w_mp3.mdl" )
util.PrecacheModel( "models/cs16/w_p90.mdl" )
util.PrecacheModel( "models/cs16/w_p228.mdl" )
util.PrecacheModel( "models/cs16/w_scout.mdl" )
util.PrecacheModel( "models/cs16/w_sg550.mdl" )
util.PrecacheModel( "models/cs16/w_sg552.mdl" )
util.PrecacheModel( "models/cs16/w_shield.mdl" )
util.PrecacheModel( "models/cs16/w_tmp.mdl" )
util.PrecacheModel( "models/cs16/w_ump45.mdl" )
util.PrecacheModel( "models/cs16/w_usp.mdl" )
util.PrecacheModel( "models/cs16/w_xm1014.mdl" )

util.PrecacheModel( "models/weapons/cs16/w_ak47.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_aug.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_awp.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_deagle.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_elite.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_famas.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_fiveseven.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_g3sg1.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_galil.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_glock18.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_hegrenade.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_knife.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_m3.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_m4a1.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_m429.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_mac10.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_mp3.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_p90.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_p228.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_scout.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_sg550.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_sg552.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_shield.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_tmp.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_ump45.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_usp.mdl" )
util.PrecacheModel( "models/weapons/cs16/w_xm1014.mdl" )

util.PrecacheModel( "models/weapons/cs16/v_ak47.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_aug.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_awp.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_deagle.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_elite.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_famas.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_fiveseven.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_g3sg1.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_galil.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_glock18.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_hegrenade.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_knife.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_m3.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_m4a1.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_m429.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_mac10.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_mp3.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_p90.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_p228.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_scout.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_sg550.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_sg552.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_tmp.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_ump45.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_usp.mdl" )
util.PrecacheModel( "models/weapons/cs16/v_xm1014.mdl" )

util.PrecacheModel( "models/urban.mdl" )
util.PrecacheModel( "models/gsg09.mdl" )
util.PrecacheModel( "models/sas.mdl" )
util.PrecacheModel( "models/gign.mdl" )
util.PrecacheModel( "models/terror.mdl" )
util.PrecacheModel( "models/leet.mdl" )
util.PrecacheModel( "models/arctic.mdl" )
util.PrecacheModel( "models/guerilla.mdl" )

// Classes
CS_CLASS_FIRST = 1
CS_CLASS_SECOND = 2
CS_CLASS_THIRD = 3
CS_CLASS_FOURTH = 4
CS_CLASS_NONE = 5

CS_CLASSES = {}
CS_CLASSES[3] = {
	[CS_CLASS_FIRST] = { model = "models/urban.mdl", img = "urban.png", desc = "ST-6 (to be known later as DEVGRU) was founded in 1980 under the command of Lieutenant-Commander Richard Marcincko. ST-6 was placed on permament alert to respond to terrorist attacks against American targets worldwide." },
	[CS_CLASS_SECOND] = { model = "models/gsg9.mdl", img = "gsg9.png",desc = "GSG-9 was born out of the tragic events that led to the death of several Israeli athletes during the 1972 Olympic games in Munich, Germany." },
	[CS_CLASS_THIRD] = { model = "models/sas.mdl", img = "sas.png",desc = "The world-renowned British SAS was founded in the Second World War by man named David Stirling. Their role during WW2 involved gathering intelligence behind enemy lines and executing sabotage strikes and assassinations against key targets." },
	[CS_CLASS_FOURTH] = { model = "models/gign.mdl", img = "gign.png",desc = "France's elite Counter-Terrorist unit, the GIGN was designed to be a fast response force that could decisively react to any large-scale terrorist incident. Consisting of no more than 100 men, the GIGN has earned its reputation through a history of successful ops." },
	[CS_CLASS_NONE] = { img = "ct_random.png", desc = "Auto-Select randomly selects a character model." }
}
CS_CLASSES[2] = {
	[CS_CLASS_FIRST] = { model = "models/terror.mdl", img = "terror.png", desc = "Having established a reputation for killing anyone that gets in their way, the Phoenix Faction is one of the most feared terrorst groups in Eastern Europe. Formed shortly after the breakup of the USSR." },
	[CS_CLASS_SECOND] = { model = "models/leet.mdl", img = "leet.png", desc = "Middle Eastern fundamentalist group bent on world domination and various other evil deeds." },
	[CS_CLASS_THIRD] = { model = "models/artic.mdl", img = "arctic.png", desc = "Swedish terrorist faction founded in 1977. Famous for their bombing of the Canadian embassy in 1990." },
	[CS_CLASS_FOURTH] = { model = "models/guerilla.mdl", img = "guerilla.png", desc = "A terrorist faction founded in the Middle East, this group has a reputation for ruthlessness. Their disgust for the American lifestyle was demonstrated in their 1982 bombing of a school bus full of Rock and Roll musicians." },
	[CS_CLASS_NONE] = { img = "t_random.png", desc = "Auto-Select randomly selects a character model." }
}

CS_BUY_INFO = {}
CS_BUY_INFO["glock18"] = {
	img = "glock18.png",
	price = "400",
	country = "AUSTRIA",
	caliber = "9MM PARABELLUM",
	clip = "20",
	rof = "N/A",
	weight = "0.9",
	weightloaded = true,
	pweight = "8",
	muzzlevel = "1132",
	muzzleenergy = "475",
}
CS_BUY_INFO["usp"] = {
	img = "usp45.png",
	price = "500",
	country = "GERMANY",
	caliber = ".45 ACP",
	clip = "12",
	rof = "N/A",
	weight = "1",
	weightloaded = false,
	pweight = "15.2",
	muzzlevel = "886",
	muzzleenergy = "553",
}
CS_BUY_INFO["p228"] = {
	img = "p228.png",
	price = "600",
	country = "SWITZERLAND/GERMANY",
	caliber = ".357 SIG",
	clip = "13",
	rof = "N/A",
	weight = "1.03",
	weightloaded = true,
	pweight = "8.1",
	muzzlevel = "1400",
	muzzleenergy = "600",
}
CS_BUY_INFO["deagle"] = {
	img = "deserteagle.png",
	price = "650",
	country = "ISRAEL",
	caliber = ".50 ACTION EXPRESS",
	clip = "7",
	rof = "N/A",
	weight = "1.8",
	weightloaded = true,
	pweight = "19.4",
	muzzlevel = "1380",
	muzzleenergy = "1650",
}
CS_BUY_INFO["elites"] = {
	img = "elites.png",
	price = "800",
	country = "ITALY",
	caliber = ".40 SW",
	clip = "15",
	rof = "N/A",
	weight = "1.15",
	weightloaded = true,
	pweight = "8",
	muzzlevel = "1280",
	muzzleenergy = "606",
}
CS_BUY_INFO["fiveseven"] = {
	img = "fiveseven.png",
	price = "750",
	country = "BELGIUM",
	caliber = "5.7 X 28MM",
	clip = "20",
	rof = "N/A",
	weight = "0.618",
	weightloaded = true,
	pweight = "2",
	muzzlevel = "2345",
	muzzleenergy = "465",
}
CS_BUY_INFO["m3"] = {
	img = "m3.png",
	price = "1700",
	country = "ITALY",
	caliber = "12 GAUGE",
	clip = "8",
	rof = "N/A",
	weight = "3.5",
	weightloaded = false,
	pweight = "3.8",
	muzzlevel = "1250",
	muzzleenergy = "2429",
}
CS_BUY_INFO["xm1014"] = {
	img = "xm1014.png",
	price = "3000",
	country = "ITALY",
	caliber = "12 GAUGE",
	clip = "7",
	rof = "400 RPM",
	weight = "4",
	weightloaded = false,
	pweight = "3.8",
	muzzlevel = "1250",
	muzzleenergy = "2429",
}
CS_BUY_INFO["mac10"] = {
	img = "mac10.png",
	price = "1400",
	country = "UNITED STATES OF AMERICA",
	caliber = ".45 ACP",
	clip = "30",
	rof = "857 RPM",
	weight = "3.82",
	weightloaded = true,
	pweight = "15.2",
	muzzlevel = "919",
	muzzleenergy = "584",
}
CS_BUY_INFO["tmp"] = {
	img = "tmp.png",
	price = "1250",
	country = "AUSTRIA",
	caliber = "9MM PARABELLUM",
	clip = "30",
	rof = "857 RPM",
	weight = "1.3",
	weightloaded = false,
	pweight = "8",
	muzzlevel = "1280",
	muzzleenergy = "606",
}
CS_BUY_INFO["mp5"] = {
	img = "mp5.png",
	price = "1500",
	country = "GERMANY",
	caliber = "9MM PARABELLUM",
	clip = "30",
	rof = "800 RPM",
	weight = "3.42",
	weightloaded = false,
	pweight = "8",
	muzzlevel = "1132",
	muzzleenergy = "637",
}
CS_BUY_INFO["ump45"] = {
	img = "ump45.png",
	price = "1700",
	country = "GERMANY",
	caliber = ".45 ACP",
	clip = "25",
	rof = "600 RPM",
	weight = "2.27",
	weightloaded = true,
	pweight = "15.2",
	muzzlevel = "1005",
	muzzleenergy = "625",
}
CS_BUY_INFO["p90"] = {
	img = "p90.png",
	price = "2350",
	country = "BELGIUM",
	caliber = "5.7 x 28MM",
	clip = "50",
	rof = "900 RPM",
	weight = "3",
	weightloaded = true,
	pweight = "2",
	muzzlevel = "2345",
	muzzleenergy = "465",
}
CS_BUY_INFO["famas"] = {
	img = "famas.png",
	price = "2250",
	country = "FRANCE",
	caliber = "5.56 NATO",
	clip = "25",
	rof = "1100 RPM",
	weight = "3.40",
	weightloaded = true,
	pweight = "4",
	muzzlevel = "2212",
	muzzleenergy = "1712",
}
CS_BUY_INFO["galil"] = {
	img = "galil.png",
	price = "2000",
	country = "ISRAEL",
	caliber = ".308",
	clip = "35",
	rof = "675 RPM",
	weight = "4.35",
	weightloaded = true,
	pweight = "4",
	muzzlevel = "2013",
	muzzleenergy = "1712",
}
CS_BUY_INFO["scout"] = {
	img = "scout.png",
	price = "2750",
	country = "AUSTRIA",
	caliber = "7.62 NATO",
	clip = "10",
	rof = "N/A",
	weight = "3.3",
	weightloaded = false,
	pweight = "8",
	muzzlevel = "2800",
	muzzleenergy = "2200",
}
CS_BUY_INFO["ak47"] = {
	img = "ak47.png",
	price = "2500",
	country = "RUSSIA",
	caliber = "7.62 NATO",
	clip = "30",
	rof = "600 RPM",
	weight = "4.79",
	weightloaded = true,
	pweight = "7.9",
	muzzlevel = "2329",
	muzzleenergy = "1992",
}
CS_BUY_INFO["m4a1"] = {
	img = "m4a1.png",
	price = "3100",
	country = "UNITED STATES OF AMERICA",
	caliber = "5.56 NATO",
	clip = "30",
	rof = "685 RPM",
	weight = "3.22",
	weightloaded = false,
	pweight = "4",
	muzzlevel = "2900",
	muzzleenergy = "1570",
}
CS_BUY_INFO["sg552"] = {
	img = "sg552.png",
	price = "3500",
	country = "SWITZERLAND",
	caliber = "5.56 NATO",
	clip = "30",
	rof = "727 RPM",
	weight = "3.1",
	weightloaded = false,
	pweight = "4",
	muzzlevel = "2900",
	muzzleenergy = "1570",
}
CS_BUY_INFO["aug"] = {
	img = "aug.png",
	price = "3500",
	country = "AUSTRIA",
	caliber = "5.56 NATO",
	clip = "30",
	rof = "727 RPM",
	weight = "4.09",
	weightloaded = true,
	pweight = "4",
	muzzlevel = "2900",
	muzzleenergy = "1570",
}
CS_BUY_INFO["g3sg1"] = {
	img = "g3sg1.png",
	price = "5000",
	country = "GERMANY",
	caliber = "7.62 NATO",
	clip = "20",
	rof = "N/A",
	weight = "4.41",
	weightloaded = true,
	pweight = "8",
	muzzlevel = "2800",
	muzzleenergy = "2200",
}
CS_BUY_INFO["sg550"] = {
	img = "sg550.png",
	price = "4200",
	country = "SWITZERLAND",
	caliber = "5.56 NATO",
	clip = "30",
	rof = "N/A",
	weight = "7.02",
	weightloaded = false,
	pweight = "4",
	muzzlevel = "3100",
	muzzleenergy = "1650",
}
CS_BUY_INFO["awp"] = {
	img = "awp.png",
	price = "4750",
	country = "UNITED KINGDOM",
	caliber = ".338 LAPUA MAGNUM",
	clip = "10",
	rof = "N/A",
	weight = "6",
	weightloaded = true,
	pweight = "16.2",
	muzzlevel = "3000",
	muzzleenergy = "7000",
}
CS_BUY_INFO["m249"] = {
	img = "m249.png",
	price = "5750",
	country = "BELGIUM",
	caliber = "5.56 PARABELLUM",
	clip = "100",
	rof = "600 RPM",
	weight = "6",
	weightloaded = true,
	pweight = "4",
	muzzlevel = "3000",
	muzzleenergy = "1600",
}
CS_BUY_INFO["kevlar"] = {
	img = "kevlar.png",
	price = "650",
	desc = "A Kevlar vest that protects against projectiles."
}
CS_BUY_INFO["kevlarhelmet"] = {
	img = "kevlar_helmet.png",
	price = "1000",
	desc = "A Kevlar vest and ballistic helmet which both protect against projectiles."
}
CS_BUY_INFO["hegrenade"] = {
	img = "hegrenade.png",
	price = "300",
	desc = "A high-explosive device. Pull the pin, release the spoon and throw."
}
CS_BUY_INFO["defusekit"] = {
	img = "defusekit.png",
	price = "200",
	desc = "A bomb defusal kit used speed up the bomb defus process."
}
CS_BUY_INFO["shield"] = {
	img = "tacticalshield.png",
	price = "2200",
	desc = "Barrier-type shield for street tactics and intervention."
}

CS16_AmmoBuyTable = {}
CS16_AmmoBuyTable["CS16_9MM"] = {
	give = 30,
	price = 20
}
CS16_AmmoBuyTable["CS16_57MM"] = {
	give = 50,
	price = 50
}
CS16_AmmoBuyTable["CS16_50AE"] = {
	give = 7,
	price = 40
}
CS16_AmmoBuyTable["CS16_45ACP"] = {
	give = 12,
	price = 25
}
CS16_AmmoBuyTable["CS16_357SIG"] = {
	give = 13,
	price = 50
}
CS16_AmmoBuyTable["CS16_338MAGNUM"] = {
	give = 10,
	price = 125
}
CS16_AmmoBuyTable["CS16_556NATO"] = {
	give = 30,
	price = 60
}
CS16_AmmoBuyTable["CS16_556NATOBOX"] = {
	give = 30,
	price = 60
}
CS16_AmmoBuyTable["CS16_762NATO"] = {
	give = 30,
	price = 80
}
CS16_AmmoBuyTable["CS16_BUCKSHOT"] = {
	give = 8,
	price = 65
}


sound.Add(
{
    name = "BaseCombatCharacter.AmmoPickup",
    channel = CHAN_ITEM,
    volume = 1.0,
    level = 75,
    sound = "",
})