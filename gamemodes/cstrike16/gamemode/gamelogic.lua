if SERVER then
	SetGlobalFloat( "m_iRoundTime", 0 )
	m_iRoundWinStatus = WINNER_NONE
	m_iFreezeTime = 0

	SetGlobalFloat( "m_fRoundStartTime", 0 )
	m_bAllowWeaponSwitch = true
	SetGlobalBool( "m_bFreezePeriod", true )

	m_flRestartRoundTime = 0.1
	m_iNumTerrorist = 0
	m_iNumCT = 0
	m_iNumSpawnableTerrorist = 0
	m_iNumSpawnableCT = 0
	m_bFirstConnected = false
	m_bCompleteReset = true
	m_iAccountTerrorist = 0
	m_iAccountCT = 0

	m_iNumConsecutiveCTLoses = 0;
	m_iNumConsecutiveTerroristLoses = 0;
	m_bTargetBombed = false;
	m_bBombDefused = false;
	m_iTotalRoundsPlayed = -1
	m_iUnBalancedRounds = 0
	m_flGameStartTime = 0
	m_iHostagesRemaining = 0
	m_bLevelInitialized = false
	m_tmNextPeriodicThink = 0

	m_bMapHasBombTarget = false
	m_bMapHasRescueZone = false

	m_iSpawnPointCount_Terrorist = 0
	m_iSpawnPointCount_CT = 0

	m_bTCantBuy = false
	m_bCTCantBuy = false
	m_bMapHasBuyZone = false

	m_iLoserBonus = 0

	m_iHostagesRescued = 0
	m_iHostagesTouched = 0
	m_flNextHostageAnnouncement = 0

	m_bMapHasBombZone = false
	m_bBombDropped = false
	SetGlobalBool("m_bBombPlanted",false)
	m_pLastBombGuy = nil

	function ReadMultiplayCvars()
		SetGlobalFloat( "m_iRoundTime", GetConVar("sv_cs16_roundtimer"):GetInt() * 60 )
		m_iFreezeTime = GetConVar("sv_cs16_freezetime"):GetInt()
	end

	function EndRound()
		TerminateRound( 0, Round_Draw )
	end
	function TerminateRound( delay, reason )
		local winner = WINNER_NONE
		local text = "UNKNOWN"

		local Reasons = {}
		Reasons[Target_Bombed] = { text = "csl_Target_Bombed", win = WINNER_TER }
		Reasons[Hostages_Not_Rescued] = { text = "csl_Hostages_Not_Rescued", win = WINNER_TER }
		Reasons[Terrorists_Win] = { text = "csl_Terrorists_Win", win = WINNER_TER }
		Reasons[Bomb_Defused] = { text = "csl_Bomb_Defused", win = WINNER_CT }
		Reasons[CTs_Win] = { text = "csl_CTs_Win", win = WINNER_CT }
		Reasons[All_Hostages_Rescued] = { text = "csl_All_Hostages_Rescued", win = WINNER_CT }
		Reasons[Target_Saved] = { text = "csl_Target_Saved", win = WINNER_CT }
		Reasons[Game_Commencing] = { text = "csl_Game_Commencing", win = WINNER_DRAW }
		Reasons[Round_Draw] = { text = "csl_Round_Draw", win = WINNER_DRAW }
		
		if Reasons[reason] then
			text = Reasons[reason].text
			winner = Reasons[reason].win
		end

		m_iRoundWinStatus = winner
		m_flRestartRoundTime = CurTime() + delay

		for k, v in pairs( player.GetAll() ) do
			v:Setm_iOldArmor( v:Getm_iArmorValue() )
		end

		umsg.Start( "GameEvent_round_end" )
			umsg.Short( winner )
			umsg.String( text )
			umsg.Bool( m_bBombDefused )
		umsg.End()
		OldPrintMessage( text )

		//if GetMapRemainingTime() == 0 then
		//	GoToIntermission()
		//end
	end
	function RestartRound()
		SetRound( GetRound() + 1 )

		m_bBombDropped = false
		SetGlobalBool("m_bBombPlanted",false)

		if m_bCompleteReset then
			m_flGameStartTime = CurTime()

			m_iTotalRoundsPlayed = 0
			team.SetScore( 2, 0 )
			team.SetScore( 3, 0 )
			m_iNumConsecutiveTerroristLoses = 0
			m_iNumConsecutiveCTLoses = 0

			for k,v in pairs( player.GetAll() ) do
				v:Reset()
			end
		end

		SetGlobalBool( "m_bFreezePeriod", true )
		ReadMultiplayCvars()

		m_bCTCantBuy = false
		m_bTCantBuy = false

		CheckMapConditions()

		if m_iRoundWinStatus == WINNER_TER then
			if m_iNumConsecutiveTerroristLoses > 1 then
				m_iLoserBonus = 1400
			end
			m_iNumConsecutiveTerroristLoses = 0
			m_iNumConsecutiveCTLoses = m_iNumConsecutiveCTLoses + 1
		elseif m_iRoundWinStatus == WINNER_CT then
			if m_iNumConsecutiveCTLoses > 1 then
				m_iLoserBonus = 1400
			end
			m_iNumConsecutiveCTLoses = 0
			m_iNumConsecutiveTerroristLoses = m_iNumConsecutiveTerroristLoses + 1
		end
		if m_iNumConsecutiveCTLoses > 1 and m_iLoserBonus < 3400 then
			m_iLoserBonus = m_iLoserBonus + 500
		elseif m_iNumConsecutiveTerroristLoses > 1 and m_iLoserBonus < 3400 then
			m_iLoserBonus = m_iLoserBonus + 500
		end

		if m_iRoundWinStatus == WINNER_TER then
			m_iAccountCT = m_iAccountCT + m_iLoserBonus
			ClientChatPrint( 3, CHATPRINT_GREEN, "+$" .. m_iLoserBonus, Color( 255, 255, 255 ), ": ", Color( 255, 255, 255 ), "csl_AwardForLose")
		elseif m_iRoundWinStatus == WINNER_CT then
			m_iAccountTerrorist = m_iAccountTerrorist + m_iLoserBonus
			ClientChatPrint( 2, CHATPRINT_GREEN, "+$" .. m_iLoserBonus, Color( 255, 255, 255 ), ": ", Color( 255, 255, 255 ), "csl_AwardForLose")
		end
			
		SetGlobalFloat( "m_fRoundStartTime", CurTime() + m_iFreezeTime )

		if m_bCompleteReset then
			m_iAccountTerrorist = 0
			m_iAccountCT = 0

			team.SetScore( 2, 0 )
			team.SetScore( 3, 0 )
			m_iNumConsecutiveTerroristLoses = 0
			m_iNumConsecutiveCTLoses = 0
			m_iLoserBonus = 1400
		end			
		for k,v in pairs( player.GetAll() ) do
			v.m_iNumSpawns = 0
			v.m_bTeamChanged = false

			if v:Team() == TEAM_CT then
				if v:DoesPlayerGetRoundStartMoney() then
					v:AddMoney( m_iAccountCT )
				end
			elseif v:Team() == TEAM_T then
				if v:DoesPlayerGetRoundStartMoney() then
					v:AddMoney( m_iAccountTerrorist )
				end
			end
			if v:Team() != TEAM_SPECTATOR then
				v:ResetMaxSpeed()
			end
		end

		for k,v in pairs( player.GetAll() ) do
			if v:Team() == TEAM_CT then
				v:RoundRespawn()
			elseif v:Team() == TEAM_T then
				v:RoundRespawn()
			else
				v:ObserverRoundRespawn()
			end	
		end

		game.CleanUpMap()

		if GetGlobalBool("m_bMapHasBombTarget") then
			GiveC4()
		end

		m_flIntermissionEndTime = 0
		m_flRestartRoundTime = 0.0
		m_iAccountTerrorist = 0
		m_iAccountCT = 0
		m_iHostagesRescued = 0
		m_iHostagesTouched = 0
		m_iHostagesRemaining = 0
		m_iRoundWinStatus = WINNER_NONE
		m_bTargetBombed = false
		m_bBombDefused = false
		m_bCompleteReset = false
		m_flNextHostageAnnouncement = CurTime()
		m_iHostagesRemaining = 0

		umsg.Start( "GameEvent_round_start" )
		umsg.End()

		print("A new round has been started.")
	end

	function GiveC4()
		local iTerrorists = { 
			[0] = {}
		}
		local numAliveTs = 0
		local lastBombGuyIndex = -1

		for k,v in pairs( team.GetPlayers( TEAM_T ) ) do
			if v and v:Alive() and numAliveTs < 256 then
				if m_pLastBombGuy == v then
					lastBombGuyIndex = numAliveTs
				end
				iTerrorists[0][numAliveTs] = k
				numAliveTs = numAliveTs + 1
			end
		end

		if numAliveTs > 0 then
			local index = math.random( 0, numAliveTs - 1)
			if lastBombGuyIndex >= 0 then
				index = (lastBombGuyIndex + 1) % numAliveTs
			end
			local ply = team.GetPlayers( TEAM_T )[iTerrorists[0][index]]

			if !IsValid( ply ) or !ply:Alive() then
				return
			end

			ply:Give( "wep_cs16_c4" )
			ply:GiveAmmo( 1, "CS16_C4" )

			m_pLastBombGuy = ply
		end
		m_bBombDropped = false
	end

	function CheckMaxRounds()
		if GetConVar("sv_cs16_maxrounds"):GetInt() != 0 then
			if m_iTotalRoundsPlayed >= GetConVar("sv_cs16_maxrounds"):GetInt() then
				GoToIntermission()
				return true
			end
		end
		return false
	end
	function CheckFragLimit()
		if GetConVar("sv_cs16_fraglimit"):GetInt() <= 0 then
			return
		end

		for k,v in pairs( player.GetAll() ) do
			if v and v:Frags() >= GetConVar("sv_cs16_fraglimit"):GetInt() then
				GoToIntermission()
				return true
			end
		end

		return false
	end
	function CheckWinLimit()
		if GetConVar("sv_cs16_winlimit"):GetInt() != 0 then
			if timer.GetScore( TEAM_CT ) >= GetConVar("sv_cs16_winlimit"):GetInt() then
				GoToIntermission()
				return true
			end
			if timer.GetScore( TEAM_T ) >= GetConVar("sv_cs16_winlimit"):GetInt() then
				GoToIntermission()
				return true
			end
		end

		return false
	end
	function CheckRoundTimeExpired()
		if GetRoundRemainingTime() > 0 or m_iRoundWinStatus != WINNER_NONE then
			return
		end
		if !m_bFirstConnected then
			return
		end

		if GetGlobalBool("m_bMapHasBombTarget") then
			if !GetGlobalBool("m_bBombPlanted") then
				m_iAccountCT = m_iAccountCT + 3500
				ClientChatPrint( TEAM_CT, CHATPRINT_GREEN, "+$3500", Color( 255, 255, 255 ), ": ", Color( 255, 255, 255 ), "csl_AwardForWin")
				TerminateRound( 5, Target_Saved )
				team.AddScore( TEAM_CT, 1 )
			end
		elseif m_bMapHasRescueZone then
			m_iAccountT = m_iAccountT + 3500
			ClientChatPrint( TEAM_T, CHATPRINT_GREEN, "+$3500", Color( 255, 255, 255 ), ": ", Color( 255, 255, 255 ), "csl_AwardForWin")
			TerminateRound( 5, Hostages_Not_Rescued )
			team.AddScore( TEAM_T, 1 )
		end
	end
	function CheckFreezePeriodExpired()
		local startTime = GetGlobalFloat( "m_fRoundStartTime" )

		if CurTime() < startTime then
			return
		end

		local CTsentence
		local Tsentence
		local sentences = {}
		sentences[0] = "cs16radio/moveout.wav"
		sentences[1] = "cs16radio/letsgo.wav"
		sentences[2] = "cs16radio/locknload.wav"
		sentences[3] = "cs16radio/go.wav"
		CTsentence = table.Random( sentences )
		Tsentence = table.Random( sentences )

		SetGlobalBool( "m_bFreezePeriod", false )

		local bCTPlayed = false
		local bTPlayed = false

		for k,v in pairs( player.GetAll() ) do
			if IsValid( v ) then
				if v:GetState() == STATE_ACTIVE then
					if v:Team() == TEAM_CT and !bCTPlayed then
						v:Radio( CTsentence )
						bCTPlayed = true
					elseif v:Team() == TEAM_T and !bTPlayed then
						v:Radio( Tsentence )
						bTPlayed = true
					end
					if v:Team() != TEAM_SPECTATOR then
						v:ResetMaxSpeed()
					end
				end
			end
		end
	end
	function CheckLevelInitialized()
		if !m_bLevelInitialized then
			m_iSpawnPointCount_Terrorist = 0
			m_iSpawnPointCount_CT = 0

			for k,v in pairs( ents.FindByClass( "info_player_terrorist" ) ) do
				m_iSpawnPointCount_Terrorist = m_iSpawnPointCount_Terrorist + 1
			end
			for k,v in pairs( ents.FindByClass( "info_player_counterterrorist" ) ) do
				m_iSpawnPointCount_CT = m_iSpawnPointCount_CT + 1
			end

			m_bLevelInitialized = true
		end
	end
	function CheckMapConditions()
		if #ents.FindByClass( "func_bomb_target" ) != 0 then
			SetGlobalBool( "m_bMapHasBombTarget", true )
		else
			SetGlobalBool( "m_bMapHasBombTarget", false )
		end

		if #ents.FindByClass( "func_hostage_rescue" ) != 0 then
			m_bMapHasRescueZone = true
		else
			m_bMapHasRescueZone = false
		end

		if #ents.FindByClass( "func_buyzone" ) != 0 then
			m_bMapHasBuyZone = true
		else
			m_bMapHasBuyZone = false
		end
	end
	function CheckRestartRound()
		local iRestartDelay = GetConVar("sv_cs16_restartgame"):GetInt()

		if iRestartDelay > 0 then
			if iRestartDelay > 60 then
				iRestartDelay = 60
			end

			m_flRestartRoundTime = CurTime() + iRestartDelay
			m_bCompleteReset = true
			RunConsoleCommand( "sv_cs16_restartgame", 0 )
		end
	end
	function BombRoundEndCheck()
		if m_bTargetBombed == true and GetGlobalBool( "m_bMapHasBombTarget") then
			m_iAccountTerrorist = m_iAccountTerrorist + 3500

			if !bNeededPlayers then
				team.AddScore( TEAM_T, 1 )
			end
			ClientChatPrint( TEAM_T, CHATPRINT_GREEN, "+$3500", Color( 255, 255, 255 ), ": ", Color( 255, 255, 255 ), "csl_AwardForBombed")
			
			TerminateRound( 5, Target_Bombed )
			return true
		elseif m_bBombDefused == true and GetGlobalBool( "m_bMapHasBombTarget") then
			m_iAccountCT = m_iAccountCT + 3250
			m_iAccountTerrorist = m_iAccountTerrorist + 800

			if !bNeededPlayers then
				team.AddScore( TEAM_CT, 1 )
			end
			ClientChatPrint( TEAM_CT, CHATPRINT_GREEN, "+$3250", Color( 255, 255, 255 ), ": ", Color( 255, 255, 255 ), "csl_AwardForDefuse")
			ClientChatPrint( TEAM_T, CHATPRINT_GREEN, "+$800", Color( 255, 255, 255 ), ": ", Color( 255, 255, 255 ), "csl_AwardForPlant")
			
			TerminateRound( 5, Bomb_Defused )
			return true
		end

		return false
	end
	function TeamExterminationCheck( NumAliveTerrorist, NumAliveCT, NumDeadTerrorist, NumDeadCT, bNeededPlayers )
		if ( m_iNumCT > 0 and m_iNumSpawnableCT > 0 ) and ( m_iNumTerrorist > 0 and m_iNumSpawnableTerrorist > 0 ) then
			if NumAliveTerrorist == 0 && NumDeadTerrorist != 0 && m_iNumSpawnableCT > 0 then
				local nowin = false
				for k, v in pairs( ents.FindByClass("cs16_planted_c4") ) do
					if v:IsBombActive() then
						nowin = true
					end
				end

				if !nowin then
					if GetGlobalBool( "m_bMapHasBombTarget") then
						m_iAccountCT = m_iAccountCT + 3500
					else
						m_iAccountCT = m_iAccountCT + 3000
					end
					ClientChatPrint( TEAM_CT, CHATPRINT_GREEN, "+$" .. m_iAccountCT, Color( 255, 255, 255 ), ": ", Color( 255, 255, 255 ), "csl_AwardForWin")
					if !bNeededPlayers then
						team.AddScore( TEAM_CT, 1 )
					end

					TerminateRound( 5, CTs_Win )
					return true
				end
			end

			if NumAliveCT == 0 && NumDeadCT != 0 && m_iNumSpawnableTerrorist > 0 then
				if GetGlobalBool( "m_bMapHasBombTarget") then
					m_iAccountTerrorist = m_iAccountTerrorist + 3500
				else
					m_iAccountTerrorist = m_iAccountTerrorist + 3000
				end
				ClientChatPrint( TEAM_T, CHATPRINT_GREEN, "+$" .. m_iAccountTerrorist, Color( 255, 255, 255 ), ": ", Color( 255, 255, 255 ), "csl_AwardForWin")
	
				if !bNeededPlayers then
					team.AddScore( TEAM_T, 1 )
				end

				TerminateRound( 5, Terrorists_Win )
				return true
			end
		elseif NumAliveCT == 0 and NumAliveTerrorist == 0 then
			TerminateRound( 5, Round_Draw )
			return true
		end
		return false
	end
	function HostageRescueRoundEndCheck()
	end

	function CheckWinConditions()
		if m_iRoundWinStatus != WINNER_NONE then
			local NumDeadCT, NumDeadTerrorist, NumAliveTerrorist, NumAliveCT
			NumDeadCT, NumDeadTerrorist, NumAliveTerrorist, NumAliveCT = InitializePlayerCounts()

			local bNeededPlayers = false
			NeededPlayersCheck( bNeededPlayers )

			return true
		end
		local NumDeadCT, NumDeadTerrorist, NumAliveTerrorist, NumAliveCT
		NumDeadCT, NumDeadTerrorist, NumAliveTerrorist, NumAliveCT = InitializePlayerCounts()
		local bNeededPlayers = false
		if NeededPlayersCheck( bNeededPlayers ) then
			return false
		end
		if BombRoundEndCheck( bNeededPlayers ) then
			return true
		end
		if TeamExterminationCheck( NumAliveTerrorist, NumAliveCT, NumDeadTerrorist, NumDeadCT, bNeededPlayers )  then
			return true
		end
		if HostageRescueRoundEndCheck( bNeededPlayers ) then
			return true
		end
		return false
	end

	function InitializePlayerCounts()
		local NumDeadCT, NumDeadTerrorist, NumAliveTerrorist, NumAliveCT = 0, 0, 0, 0
		m_iNumCT = 0
		m_iNumTerrorist = 0
		m_iNumSpawnableTerrorist = 0
		m_iNumSpawnableCT = 0

		for k, v in pairs( team.GetAllTeams() ) do
			for z, x in pairs( team.GetPlayers( k ) ) do
				if k == TEAM_CT then
					m_iNumCT = m_iNumCT + 1
					if x:GetState() != STATE_PICKINGCLASS then
						m_iNumSpawnableCT = m_iNumSpawnableCT + 1
					end
					if x:Alive() then
						NumAliveCT = NumAliveCT + 1
					else
						NumDeadCT = NumDeadCT + 1
					end
				elseif k == TEAM_T then
					m_iNumTerrorist = m_iNumTerrorist + 1
					if x:GetState() != STATE_PICKINGCLASS then
						m_iNumSpawnableTerrorist = m_iNumSpawnableTerrorist + 1
					end
					if x:Alive() then
						NumAliveTerrorist = NumAliveTerrorist + 1
					else
						NumDeadTerrorist = NumDeadTerrorist + 1
					end
				end
			end
		end
		return NumDeadCT, NumDeadTerrorist, NumAliveTerrorist, NumAliveCT
	end

	function NeededPlayersCheck( bNeededPlayers )
		if m_iNumSpawnableTerrorist == 0 or m_iNumSpawnableCT == 0 then
			MsgAll( "Game will not start until both teams have players.\n" )
			bNeededPlayers = true

			m_bFirstConnected = false
		end
		if !m_bFirstConnected and m_iNumSpawnableTerrorist != 0 and m_iNumSpawnableCT != 0 then
			SetGlobalBool( "m_bFreezePeriod", false )
			m_bCompleteReset = true

			TerminateRound( 3, Game_Commencing )
			m_bFirstConnected = true
			return true
		end
		return false
	end

	function GoToIntermission()
		for k,v in pairs( player.GetAll() ) do
			if IsValid( v ) then
				v:Freeze( true )
			end
		end

		SetGlobalBool( "m_bFreezePeriod", true )
	end
	function TeamStacked( newTeam_id, curTeam_id  )
		if newTeam_id == curTeam_id then
			return false
		end

		if GetConVar("sv_cs16_limitteams"):GetInt() == 0 then
			return false
		end

		if newTeam_id == TEAM_T then
			if curTeam_id != TEAM_UNASSIGNED && curTeam_id != TEAM_SPECTATOR then
				if (m_iNumTerrorist + 1) > (m_iNumCT + GetConVar("sv_cs16_limitteams"):GetInt() - 1) then
					return true
				else
					return false
				end
			else
				if (m_iNumTerrorist + 1) > (m_iNumCT + GetConVar("sv_cs16_limitteams"):GetInt()) then
					return true
				else
					return false
				end
			end
		elseif newTeam_id == TEAM_CT then
			if curTeam_id != TEAM_UNASSIGNED && curTeam_id != TEAM_SPECTATOR then
				if (m_iNumCT + 1) > (m_iNumTerrorist + GetConVar("sv_cs16_limitteams"):GetInt() - 1) then
					return true
				else
					return false
				end
			else
				if (m_iNumCT + 1) > (m_iNumTerrorist + GetConVar("sv_cs16_limitteams"):GetInt()) then
					return true
				else
					return false
				end
			end
		end

		return false
	end
	function TeamFull( team_id )
		CheckLevelInitialized()

		if team_id == TEAM_T then
			return m_iNumTerrorist >= m_iSpawnPointCount_Terrorist
		elseif team_id == TEAM_CT then
			return m_iNumCT >= m_iSpawnPointCount_CT
		end

		return false
	end
	function SelectDefaultTeam()
		local team_num = TEAM_UNASSIGNED
		local numTerrorists = m_iNumTerrorist
		local numCTs = m_iNumCT
		if numTerrorists < numCTs then
			team_num = TEAM_T
		elseif numTerrorists > numCTs then
			team_num = TEAM_CT
		elseif team.GetScore( TEAM_T ) < team.GetScore( TEAM_CT ) then
			team_num = TEAM_T
		elseif team.GetScore( TEAM_CT ) < team.GetScore( TEAM_T ) then
			team_num = TEAM_CT
		else
			if math.random( 0, 1 ) == 0 then
				team_num = TEAM_CT
			else
				team_num = TEAM_T
			end
		end

		if TeamFull( team_num ) then
			if team_num == TEAM_T then
				team_num = TEAM_CT;
			else
				team_num = TEAM_T
			end

			if TeamFull( team_num ) then
				return TEAM_UNASSIGNED
			end
		end

		return team_num
	end

	function GM:PlayerDisconnected( m_hClient )
		CheckWinConditions()
	end
	function GM:PlayerDeathThink( m_hClient )
		if m_hClient.m_iNumSpawns > 0 and m_bFirstConnected then
			return false
		end
		if CurTime() < m_flRestartRoundTime then
			return false
		end
		if m_hClient:Team() != TEAM_CT and m_hClient:Team() != TEAM_T then
			return false
		end
		if m_hClient:GetModelID() == CS_CLASS_NONE then
			return false
		end
		if m_hClient:GetState() == STATE_PICKINGCLASS then
			return false
		end

		m_iNumCT = team.NumPlayers( TEAM_CT )
		m_iNumTerrorist = team.NumPlayers( TEAM_T )

		if m_iNumTerrorist > 0 and m_iNumCT > 0 then
			if CurTime() > GetGlobalFloat( "m_fRoundStartTime" ) + 20 then
				return false
			end
		end

		return true
	end

	function GetDeathActivity( pVictim, dmgInfo )
		local deathActivity
		local flDot
		local tr
		local vecSrc

		vecSrc = pVictim:WorldSpaceCenter()
		deathActivity = ACT_DIESIMPLE

		flDot = pVictim:EyeAngles():Forward():DotProduct( ( dmgInfo:GetDamagePosition() - pVictim:GetPos() ):GetNormalized() * -1)

		pVictim.m_iThrowDirection = THROW_NONE

		if pVictim:LastHitGroup() == HITGROUP_HEAD then
			deathActivity = ACT_DIE_HEADSHOT
			pVictim.m_iThrowDirection = THROW_BACKWARD
		elseif pVictim:LastHitGroup() == HITGROUP_STOMACH then
			deathActivity = ACT_DIE_GUTSHOT
		elseif pVictim:LastHitGroup() == HITGROUP_GENERIC then
			if flDot > 0.3 then
				deathActivity = ACT_DIEFORWARD
				pVictim.m_iThrowDirection = THROW_FORWARD
			elseif flDot <= -0.3 then
				deathActivity = ACT_DIEBACKWARD
				pVictim.m_iThrowDirection = THROW_HITVEL
			end
		else 
			if flDot > 0.3 then
				deathActivity = ACT_DIEFORWARD
				pVictim.m_iThrowDirection = THROW_FORWARD
			elseif flDot <= -0.3 then
				deathActivity = ACT_DIEBACKWARD
				pVictim.m_iThrowDirection = THROW_BACKWARD
			end
		end

		if bit.band( pVictim:GetFlags(), FL_DUCKING ) > 0 then
			deathActivity = ACT_DIEVIOLENT
			pVictim.m_iThrowDirection = THROW_BACKWARD
		end

		if deathActivity == ACT_DIEFORWARD then
			local tracedata = {}
			tracedata.start = vecSrc
			tracedata.endpos = vecSrc + pVictim:EyeAngles():Forward() * 64
			tracedata.mins = Vector( -16, -16, -18 )
			tracedata.maxs = Vector( 16, 16, 18 )
			tracedata.filter = pVictim
			tracedata.mask = MASK_SOLID
			tr = util.TraceHull( tracedata )

			if tr.Fraction != 1.0 then
				deathActivity = ACT_DIESIMPLE
			end
		end

		if deathActivity == ACT_DIEBACKWARD then
			local tracedata = {}
			tracedata.start = vecSrc
			tracedata.endpos = vecSrc + pVictim:EyeAngles():Forward() * 64
			tracedata.mins = Vector( -16, -16, -18 )
			tracedata.maxs = Vector( 16, 16, 18 )
			tracedata.filter = pVictim
			tracedata.mask = MASK_SOLID
			tr = util.TraceHull( tracedata )

			if tr.Fraction != 1.0 then
				deathActivity = ACT_DIESIMPLE
			end
		end

		return deathActivity
	end

	function GM:PlayerDeath( pVictim, pInflictor, pAttacker )
		if IsValid( pVictim.dmg_attacker ) then
			pAttacker = pVictim.dmg_attacker
		end
		if IsValid( pVictim.dmg_inflictor ) and !pInflictor.m_bIsC4 then
			pInflictor = pVictim.dmg_inflictor
		end

		if pVictim == pAttacker or pInflictor.m_bIsC4 then
			MsgAll( pVictim:Name() .. " suicided.\n" )
		else
			MsgAll( pVictim:Name() .. " killed by " .. (pAttacker:IsPlayer() and pAttacker:Name() or pAttacker:GetClass() ).. " using " .. pInflictor:GetClass() .. "\n" )
		end
	end
	function GM:DoPlayerDeath( pVictim, pAttacker, dmgInfo )
		if IsValid( pVictim.dmg_attacker ) then
			pAttacker = pVictim.dmg_attacker
		end
		if IsValid( pVictim.dmg_inflictor ) then
			dmgInfo:SetInflictor( pVictim.dmg_inflictor )
		end

		if pVictim:IsObserver() then return end
		
		local ent = ents.Create("cs16_corpse")
		ent:SetModel( pVictim:GetModel() )
		ent:SetPos( pVictim:GetPos() )
		ent:SetAngles( pVictim:GetAngles() )
		ent:Spawn()
		ent:ResetSequence( ent:SelectWeightedSequence( pVictim.deathact and pVictim.deathact or ACT_DIESIMPLE ) )
		if pVictim.m_bKilledByBomb then
			pVictim.m_iThrowDirection = THROW_BOMB
		elseif pVictim.m_bKilledByGrenade then
			pVictim.m_iThrowDirection = THROW_GRENADE
		end

		local angles = pVictim:EyeAngles()
		if pVictim.m_iThrowDirection == THROW_FORWARD then
			local velocity = angles:Forward() * math.Rand( 100, 200 )
			velocity.z = math.Rand( 50, 100 )
			ent:SetVelocity( velocity )
		elseif pVictim.m_iThrowDirection == THROW_BACKWARD then
			local velocity = angles:Forward() * math.Rand( -100, -200 )
			velocity.z = math.Rand( 50, 100 )
			ent:SetVelocity( velocity )
		elseif pVictim.m_iThrowDirection == THROW_HITVEL then
			local velocity = angles:Forward() * math.Rand( 200, 300 )
			velocity.z = math.Rand( 200, 300 )
			ent:SetVelocity( velocity )
		elseif pVictim.m_iThrowDirection == THROW_BOMB then
			local velocity = pVictim.m_vBlastVector * ( 1 / pVictim.m_vBlastVector:Length() ) * ( 2300 - pVictim.m_vBlastVector:Length() )
			velocity.z = ( 2300 - pVictim.m_vBlastVector:Length() ) / 2.75
			ent:SetVelocity( velocity )
		elseif pVictim.m_iThrowDirection == THROW_GRENADE then
			local velocity = pVictim.m_vBlastVector * ( 1 / pVictim.m_vBlastVector:Length() ) * ( 500 - pVictim.m_vBlastVector:Length() )
			velocity.z = ( 350 - pVictim.m_vBlastVector:Length() ) / 1.5
			ent:SetVelocity( velocity )
		elseif pVictim.m_iThrowDirection == THROW_HITVEL_MINUS_AIRVEL then
			local velocity = angles:Forward() * math.Rand( 200, 300 )
			ent:SetVelocity( velocity )
		end
		
		//pVictim:CreateRagdoll()
		if pAttacker:GetClass() != "cs16_planted_c4" then
			pVictim:AddDeaths( 1 )
		end
	
		if IsValid( pAttacker ) and pAttacker:IsPlayer() then
			if pAttacker != pVictim then
				if pVictim:Team() == pAttacker:Team() then
					pAttacker:AddFrags( -1 )
					pAttacker:AddMoney( -3300 )
				else
					pAttacker:AddFrags( 1 )
					pAttacker:AddMoney( 300 )
					ClientChatPrint( pAttacker, CHATPRINT_GREEN, "+$300", Color( 255, 255, 255 ), ": ", Color( 255, 255, 255 ), "csl_AwardForKilling")
				end
			end
		end

		pVictim:EmitSound( Sound( "OldPlayer.Death" ) )

		if pVictim:KeyDown( IN_ATTACK ) then
			if pVictim:GetActiveWeapon():GetClass() == CS16_WEAPON_HEGRENADE then
				if pVictim:GetAmmoCount( pVictim:GetActiveWeapon().Primary.Ammo ) > 0 then
					pVictim:GetActiveWeapon():ShootTimed2( pVictim:GetShootPos(), pVictim:EyeAngles():Forward(), 1.5 )
				end
			end
		end

		pVictim:DropWeapons()
		pVictim:CS16_RemoveAllItems( true )

		umsg.Start( "PlayerKilled" )
			umsg.String( (pAttacker:IsPlayer() and pAttacker:Nick() or "") )
			umsg.String( pVictim:Nick() )
			umsg.String( dmgInfo:GetInflictor():GetClass() )
			umsg.Short( (pAttacker:IsPlayer() and pAttacker:Team() or -1) )
			umsg.Short( pVictim:Team() )
			umsg.Bool( pVictim:LastHitGroup() == HITGROUP_HEAD )
		umsg.End()
	end
	function GM:PostPlayerDeath( pVictim )
		pVictim:SetState( STATE_DEATH_ANIM )
		CheckWinConditions()
	end
	function GM:PlayerDeathSound( pVictim )
		return true
	end
	function GM:PlayerCanPickupWeapon( m_pClient, m_pWeapon )
		local slot_id = weapons.GetStored( m_pWeapon:GetClass() ).Slot
		if slot_id then
			local slot = m_pClient:Weapon_GetSlot( slot_id )
			if IsValid( slot ) then
				return false
			end
		end
		if m_pWeapon:GetClass() == CS16_WEAPON_C4 then
			if m_pClient:Team() == TEAM_CT then
				return false
			end
		end
		if m_pClient:HasWeapon( m_pWeapon:GetClass() ) then 
			return false 
		end
	
		umsg.Start( "Pickup" )
			umsg.Entity( m_pClient )
		umsg.End()
		return true
	end
	function GM:WeaponEquip( m_pWeapon )

	end
	function GM:Think()
		if #player.GetAll() <= 0 then return end

		for k,v in pairs(player.GetAll()) do
			if v:GetState() == STATE_WELCOME then
				if v:Getm_pIntroCamera() and CurTime() >= v:Getm_fIntroCamTime() then
					v:MoveToNextIntroCamera()
				end
			end
		end

		//if CheckGameOver() then
		//	return
		//end
		if CheckMaxRounds() then
			return
		end
		if CheckFragLimit() then
			return
		end
		if CheckWinLimit() then
			return
		end
		if !GetGlobalBool("m_bBombPlanted") then
			if IsFreezePeriod() then
				CheckFreezePeriodExpired()
			else
				CheckRoundTimeExpired()
			end
		end

		CheckLevelInitialized()

		if m_flRestartRoundTime > 0 and m_flRestartRoundTime <= CurTime() then
			RestartRound()
		end

		if CurTime() > m_tmNextPeriodicThink then
			CheckRestartRound()
			m_tmNextPeriodicThink = CurTime() + 1
		end
	end
end
function IsFreezePeriod()
	return GetGlobalBool( "m_bFreezePeriod" )
end
function IsBombDefuseMap()
	return GetGlobalBool("m_bMapHasBombTarget")
end
function IsThereABomber()
	for k,v in pairs( player.GetAll() ) do
		if !v:Alive() then continue end
		if v:IsObserver() then continue end
		if v:Team() == TEAM_CT then continue end
		if v:Getm_bHasC4() then
			return true 
		end
	end
	return false
end
function IsThereABomb()
	local bBombFound = false
	if #ents.FindByClass( "wep_cs16_c4" ) != 0 then
		bBombFound = true
	elseif #ents.FindByClass( "wep_planted_c4" ) != 0 then
		bBombFound = true
	else
		for k,v in pairs( ents.FindByClass( "cs16_weapon" ) ) do
			if v:Getm_strWeapon() == "wep_cs16_c4" then
				bBombFound = true
			end
		end
	end

	return bBombFound
end
function GetBuyTimeLength()
	return GetConVar("sv_cs16_buytime"):GetFloat() * 60
end
function IsBuyTimeElapsed()
	return ((CurTime() - GetGlobalFloat( "m_fRoundStartTime" )) > GetBuyTimeLength())
end