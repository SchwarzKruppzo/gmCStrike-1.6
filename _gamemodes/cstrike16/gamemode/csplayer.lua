AddCSLuaFile()
DEFINE_BASECLASS( "player_default" )

local PLAYER = {}
PLAYER.DuckSpeed			= 0.3
PLAYER.UnDuckSpeed			= 0.3
PLAYER.WalkSpeed 			= 100
PLAYER.RunSpeed				= 100

function PLAYER:SetupDataTables()
	BaseClass.SetupDataTables( self )
	self.Player:NetworkVar( "Float", 0, "m_flStamina" )
	self.Player:NetworkVar( "Float", 1, "m_flStopModifier" )
	self.Player:NetworkVar( "Bool", 0, "m_bHasHelmet")
	self.Player:NetworkVar( "Int", 0, "m_iObserverLastMode")
	self.Player:NetworkVar( "Float", 2, "m_flDeathTime")
	self.Player:NetworkVar( "Entity", 0, "m_pIntroCamera")
	self.Player:NetworkVar( "Float", 3, "m_fIntroCamTime")
	self.Player:NetworkVar( "Int", 1, "m_iOldArmor")
	self.Player:NetworkVar( "Int", 2, "m_iArmorValue")
	self.Player:NetworkVar( "Bool", 1, "m_bHasC4")
	self.Player:NetworkVar( "Float", 4, "m_progressStart")
	self.Player:NetworkVar( "Float", 5, "m_progressEnd")
	self.Player:NetworkVar( "Bool", 2, "InBombSite")
	self.Player:NetworkVar( "Bool", 3, "m_bHasDefuser")
	self.Player:NetworkVar( "Bool", 4, "m_bInBuyZone")
	self.Player:SetNWBool( "m_bHasShield", false )
	self.Player:SetNWBool( "m_bShieldDrawn", false )
end
function PLAYER:Loadout()

end
function PLAYER:SetModel()
	BaseClass.SetModel( self )
end
function PLAYER:Spawn()
	BaseClass.Spawn( self )
	self.Player:SetModelFromClass()
	self.Player:SetCustomCollisionCheck( true )
	self.Player:AllowFlashlight( true )

	if self.Player:GetState() == STATE_ACTIVE then
		local addDefault = true
		if addDefault then
			self.Player:GiveDefaultItems()
		end
	end
	self.Player.deadflag = DEAD_NO
	self.Player.takedamage = DAMAGE_YES
	self.Player.m_bitsDamageType = 0
	self.Player.dmg_inflictor = nil
	self.Player.dmg_attacker = nil
	self.Player.dmg_take = 0
	self.Player.m_vBlastVector = Vector()
	self.Player.m_bKilledByBomb = false
	self.Player.m_bKilledByGrenade = false
	self.Player.m_iThrowDirection = THROW_NO

	self.Player:UnSpectate()
	self.Player:SetObserverMode( OBS_MODE_NONE )
	self.Player:SetMoveType( MOVETYPE_WALK )

	self.Player:Setm_flStamina( 0 )
	self.Player:Setm_flStopModifier( 0 )
	self.Player:SetInBombSite( false )
	self.Player:SetProgressBarTime( 0 )

	self.Player.m_bTeamChanged	= false
	self.Player.m_iOldTeam = TEAM_UNASSIGNED

	if !self.Player.m_iNumSpawns then self.Player.m_iNumSpawns = 0 end
	self.Player.m_iNumSpawns = self.Player.m_iNumSpawns + 1 
	self.Player.m_iRadioMessages = 60
	self.Player.m_flRadioTime = CurTime()

	local m_hWeapon = self.Player:GetActiveWeapon()
	if IsValid( m_hWeapon ) then
		m_hWeapon:Deploy()
		m_hWeapon:CallOnClient( "Deploy" )
	end
end
function PLAYER:SpawnSpectator()
	BaseClass.Spawn( self )

	self.Player.m_bTeamChanged	= false
	self.Player.m_iOldTeam = TEAM_UNASSIGNED
	if !self.Player.m_iNumSpawns then self.Player.m_iNumSpawns = 0 end
	self.Player.m_iNumSpawns = self.Player.m_iNumSpawns + 1 
	self.Player.m_iRadioMessages = 60
	self.Player.m_flRadioTime = CurTime()

	self.Player:Spectate( OBS_MODE_ROAMING )
	self.Player:SetMoveType( MOVETYPE_NOCLIP )
end
function PLAYER:ShouldDrawLocal() 
end
function PLAYER:CreateMove( cmd )
end
function PLAYER:CalcView( view )
end
function PLAYER:GetHandsModel()
	return false
end
function PLAYER:StartMove( move )
	//BaseClass.StartMove( self, move )
end
function PLAYER:FinishMove( move )
	//BaseClass.FinishMove( self, move )
end

player_manager.RegisterClass( "csplayer", PLAYER, "player_default" )


local meta = FindMetaTable( "Player" )

function meta:IsObserver()
	return self:GetObserverMode() != OBS_MODE_NONE
end

function meta:SetProgressBarTime( time )
	if CLIENT then return end

	if time then
		self:Setm_progressStart( CurTime() )
		self:Setm_progressEnd( time )
	else
		self:Setm_progressStart( 0 )
		self:Setm_progressEnd( 0 )
	end
end
if SERVER then
	function meta:SetState( int )
		self:SetNWBool( "m_bState", int )
		if int == STATE_PICKINGCLASS then
			self:OnEnterState_STATE_PICKINGCLASS()
		elseif int == STATE_OBSERVER_MODE then
			self:OnEnterState_STATE_OBSERVER_MODE()
		elseif int == STATE_DEATH_ANIM then
			self:OnEnterState_STATE_DEATH_ANIM()
		elseif int == STATE_WELCOME then
			self:OnEnterState_STATE_WELCOME()
		end
	end
	function meta:OnEnterState_STATE_WELCOME()
		self:SetMoveType( MOVETYPE_NONE )
		self:Spectate( OBS_MODE_ROAMING )
		self:SpectateEntity( nil )
	end
	function meta:OnEnterState_STATE_PICKINGCLASS()
		if self:GetObserverMode() == OBS_MODE_DEATHCAM then
			self:Spectate( OBS_MODE_DEATHCAM )
		else
			self:Spectate( OBS_MODE_FIXED )
		end

		self:SetModelID( 0 )

		if self:Team() == TEAM_T then
			self:ShowViewPortPanel( PANEL_CLASS_T )
		elseif self:Team() == TEAM_CT then
			self:ShowViewPortPanel( PANEL_CLASS_CT )
		end
	end
	function meta:OnEnterState_STATE_OBSERVER_MODE()
		local observerMode = self:Getm_iObserverLastMode()
		if observerMode == 0 then
			if GetConVar("sv_cs16_allow_chase"):GetInt() == 1 then
				self:Setm_iObserverLastMode( OBS_MODE_CHASE )
				self:Spectate( OBS_MODE_CHASE )
				local target = nil
				if self:GetObserverTarget() == self then
					target = GetNextPlayerForSpectating( self )
				end
				self:SpectateEntity( target )
				self:ResetMaxSpeed()
				return
			elseif GetConVar("sv_cs16_allow_ineye"):GetInt() == 1 then
				self:Setm_iObserverLastMode( OBS_MODE_IN_EYE )
				self:Spectate( OBS_MODE_IN_EYE )
				local target = nil
				if self:GetObserverTarget() == self then
					target = GetNextPlayerForSpectating( self )
				end
				self:SpectateEntity( target )
				self:ResetMaxSpeed()
				return
			elseif GetConVar("sv_cs16_allow_freecam"):GetInt() == 1 then
				self:Setm_iObserverLastMode( OBS_MODE_ROAMING )
				self:Spectate( OBS_MODE_ROAMING )
				self:SpectateEntity( nil )
				self:ResetMaxSpeed()
				return
			end
		else
			if observerMode == OBS_MODE_CHASE then
				self:Setm_iObserverLastMode( OBS_MODE_CHASE )
				self:Spectate( OBS_MODE_CHASE )
				local target = nil
				if self:GetObserverTarget() == self then
					target = GetNextPlayerForSpectating( self )
				end
				self:SpectateEntity( target )
				return
			elseif observerMode == OBS_MODE_IN_EYE then
				self:Setm_iObserverLastMode( OBS_MODE_IN_EYE )
				self:Spectate( OBS_MODE_IN_EYE )
				local target = nil
				if self:GetObserverTarget() == self then
					target = GetNextPlayerForSpectating( self )
				end
				self:SpectateEntity( target )
				return
			elseif observerMode == OBS_MODE_ROAMING then
				self:Setm_iObserverLastMode( OBS_MODE_ROAMING )
				self:Spectate( OBS_MODE_ROAMING )
				self:SpectateEntity( nil )
				return
			end
		end
	end
	function meta:OnEnterState_STATE_DEATH_ANIM()
		self:Setm_flDeathTime( CurTime() )
		self:Spectate( OBS_MODE_DEATHCAM )
		self:SpectateEntity( self )
	end
	function meta:MoveToNextIntroCamera()
		self:Setm_pIntroCamera( ents.FindByClass("point_viewcontrol")[1] )

		if !IsValid( self:Getm_pIntroCamera() ) then
			for k,v in pairs( ents.FindByClass("point_viewcontrol") ) do
				self:Setm_pIntroCamera( v )
				break
			end
		end
		local targetname = self:Getm_pIntroCamera():GetKeyValues()["target"]
		local target
		for k, v in pairs( ents.GetAll() ) do
			if v:GetName() == targetname then
				target = v
				break
			end
		end

		if !IsValid( self:Getm_pIntroCamera() ) then
			for k,v in pairs( ents.FindByClass("info_player_terrorist") ) do
				self:Setm_pIntroCamera( v )
				break
			end
		end

		if !IsValid( target ) then
			if IsValid( self:Getm_pIntroCamera() ) then
				self:SetPos( self:Getm_pIntroCamera():GetPos() )
			end
			self:SetAngles( Angle( 0, 0, 0 ) )
			self:Setm_pIntroCamera( nil )
			return
		end

		local vCamera = (target:GetPos() - self:Getm_pIntroCamera():GetPos()):Angle()
		local vIntroCamera = self:Getm_pIntroCamera():GetPos()
		vCamera:Normalize()
		local CamAngles = vCamera

		self:SetPos( self:Getm_pIntroCamera():GetPos() )
		self:SetEyeAngles( CamAngles )

		self:Setm_fIntroCamTime( CurTime() + 6 )
	end
	function meta:CS16_SelectBestWeapon( m_hCurrentWeapon )
		local pCheck = nil
		local pBest = nil
		local iBestWeight = -1

		//if !m_hCurrentWeapon.Holster() then
			//return false
		//end
		
		for k, v in pairs( self:GetWeapons() ) do
			pCheck = v
			if pCheck then
				if pCheck.Weight > -1 and pCheck.Weight == m_hCurrentWeapon.Weight and pCheck != m_hCurrentWeapon then
					self:SelectWeapon( pCheck:GetClass() )
					return true
				elseif pCheck.Weight > iBestWeight and pCheck != m_hCurrentWeapon then
					iBestWeight = pCheck.Weight
					pBest = pCheck
				end
			end
		end

		if !IsValid( pBest ) then
			return false
		end

		self:SelectWeapon( pBest:GetClass() )
		self:GetActiveWeapon():CallOnClient("Deploy")

		if self:GetSaveTable()["m_hLastWeapon"] == m_hCurrentWeapon then
			self:SetSaveValue( "m_hLastWeapon", self:GetWeapon( CS16_WEAPON_KNIFE ) )
		end

		return true
	end
	function meta:CS16_DropPlayerItem( m_hWeapon, m_vVelocity, m_vOffset )
		m_vOffset = m_vOffset and m_vOffset or Vector()
		if !IsValid( m_hWeapon ) then
			return
		end
		if m_hWeapon.CanDrop and !m_hWeapon:CanDrop() then
			self:OldPrintMessage("csl_Weapon_Cannot_Be_Dropped")
			return
		end

		self:CS16_SelectBestWeapon( m_hWeapon )

		if m_hWeapon:GetClass() == CS16_WEAPON_C4 then
			self:Setm_bHasC4( false )
			m_bBombDropped = true

			for k, v in pairs( player.GetAll() ) do
				if v:Team() == TEAM_T then
					v:OldPrintMessage("csl_Game_bomb_drop")
				end
			end
		end

		local ent = ents.Create("cs16_weapon")
		ent:SetPos( self:GetShootPos() + self:EyeAngles():Forward() * 10 + m_vOffset )
		ent:SetAngles( self:EyeAngles() )
		ent:Spawn()
		ent:SetOwner( self )

		local packAmmo1 = true
		local packAmmo2 = true

		for k, v in pairs( self:GetWeapons() ) do
			if v == m_hWeapon then continue end
			if v.Primary.Ammo == m_hWeapon.Primary.Ammo then
				packAmmo1 = false
			end
			if v.Secondary.Ammo == m_hWeapon.Secondary.Ammo then
				packAmmo2 = false
			end
		end

		if packAmmo1 then
			ent:PackAmmo( m_hWeapon.Primary.Ammo, self:GetAmmoCount( m_hWeapon.Primary.Ammo ) )
			self:SetAmmo( 0, m_hWeapon.Primary.Ammo )
		end
		if packAmmo2 then
			ent:PackAmmo2( m_hWeapon.Secondary.Ammo, self:GetAmmoCount( m_hWeapon.Secondary.Ammo ) )
			self:SetAmmo( 0, m_hWeapon.Secondary.Ammo )
		end

		ent:PackClip( m_hWeapon:Clip1(), m_hWeapon:Clip2() )
		ent:PackWeapon( m_hWeapon )

		ent:SetVelocity( m_vVelocity )
		ent:SetModel( m_hWeapon.PickupModel and m_hWeapon.PickupModel or m_hWeapon.WorldModel )
		return true
	end
	function meta:DropRifle()
		local bSuccess = false
		local pWeapon = self:Weapon_GetSlot( WEAPON_SLOT_RIFLE )
		if IsValid( pWeapon ) then
			bSuccess = self:CS16_DropPlayerItem( pWeapon, self:EyeAngles():Forward() * 300 )
		end

		return bSuccess;
	end
	function meta:DropPistol()
		local bSuccess = false
		local pWeapon = self:Weapon_GetSlot( WEAPON_SLOT_PISTOL )
		if IsValid( pWeapon ) then
			bSuccess = self:CS16_DropPlayerItem( pWeapon, self:EyeAngles():Forward() * 300 )
			self.m_bUsingDefaultPistol = false
		end

		return bSuccess;
	end
	function meta:DropShield()
		local vForward = self:GetAngles():Forward()
		local vRight = self:GetAngles():Right()

		self:RemoveShield()

		local ent = ents.Create("item_shield")
		ent:SetPos( self:GetShootPos() + self:EyeAngles():Forward() * 10 + Vector(0,0,0) )
		ent:SetAngles( self:GetAngles() )
		ent:Spawn()
		ent:SetOwner( self )
		ent:Setm_hOwner( self )
		ent:SetVelocity( vForward * 200 + vRight * math.Rand( -50, 50 ) )

		local pActive = self:GetActiveWeapon()

		if IsValid( pActive ) then
			pActive:CallOnClient( "Deploy" )
			pActive:Deploy()
		end
	end
	function meta:HasPrimaryWeapon()
		local bSuccess = false
		local pWeapon = self:Weapon_GetSlot( WEAPON_SLOT_RIFLE )
		if IsValid( pWeapon ) then
			bSuccess = true
		end

		return bSuccess;
	end
	function meta:HasSecondaryWeapon()
		local bSuccess = false
		local pWeapon = self:Weapon_GetSlot( WEAPON_SLOT_PISTOL )
		if IsValid( pWeapon ) then
			bSuccess = true
		end

		return bSuccess
	end

	function meta:CanPlayerBuy( display )
		if !self:IsInBuyZone() then
			return false
		end
		if !self:Alive() then
			return false
		end

		local buyTime = GetConVar("sv_cs16_buytime"):GetFloat() * 60
		if IsBuyTimeElapsed() then
			if display == true then
				//char strBuyTime[16]
				//Q_snprintf( strBuyTime, sizeof( strBuyTime ), "%d", buyTime );
				//ClientPrint( this, HUD_PRINTCENTER, "#Cant_buy", strBuyTime )
				self:OldPrintMessage( "#Cant_buy" )
			end

			return false
		end

		return true
	end

	concommand.Add("cs16_drop",function( m_pClient )
		if m_pClient:HasShield() then
			if m_pClient:GetActiveWeapon() != WEAPON_SLOT_RIFLE then
				m_pClient:DropShield()
				return
			end
		end
		m_pClient:CS16_DropPlayerItem( m_pClient:GetActiveWeapon(), m_pClient:EyeAngles():Forward() * 300 )
	end )
end
function meta:GetState()
	return self:GetNWBool( "m_bState" )
end
function meta:ResetMaxSpeed()
	local speed
	local pWeapon = self:GetActiveWeapon()

	if self:IsObserver() then
		speed = 900
	elseif IsFreezePeriod() then
		speed = 1
	elseif IsValid( pWeapon ) then
		if self:HasShield() and self:IsShieldDrawn() then
			speed = 160
		else
			speed = pWeapon.GetMaxSpeed and pWeapon:GetMaxSpeed() or 240
		end
	else
		speed = 240
	end

	self:SetJumpPower( 240 )
	self:SetRunSpeed( speed )
	self:SetWalkSpeed( speed )
	self:SetMaxSpeed( speed )
end
function meta:ObserverRoundRespawn()
end
function meta:Reset()
	self:SetFrags( 0 )
	self:SetDeaths( 0 )

	self:CS16_RemoveAllItems( true )

	self:SetMoney( GetConVar("sv_cs16_startingmoney"):GetInt() )
end
function meta:RoundRespawn()
	if self:GetState() == STATE_PICKINGCLASS then
		return 
	end
	if self:GetWeapon( CS16_WEAPON_C4 ) then
		self:StripWeapon( CS16_WEAPON_C4 )
	end
	self:SetObserverMode( 0 )
	self:SetState( STATE_ACTIVE )

	self:Spawn()
	self.deadflag = DEAD_NO
	self.takedamage = DAMAGE_YES
	self.m_bitsDamageType = 0
	self.dmg_inflictor = nil
	self.dmg_attacker = nil
	self.dmg_take = 0
	self.m_vBlastVector = Vector()
	self.m_bKilledByBomb = false
	self.m_bKilledByGrenade = false
	self.m_iThrowDirection = THROW_NO

	self:SetInBombSite( false )
	self:SetProgressBarTime( 0 )

	self:Setm_iArmorValue( self:Getm_iOldArmor( ) )
	self:ShowViewPortPanel( "nil" )

	self.m_receivesMoneyNextRound = true
end
function meta:DoesPlayerGetRoundStartMoney()
	return self.m_receivesMoneyNextRound
end

function meta:Weapon_GetSlot( slot )
	local targetSlot = slot
	for k, v in pairs( self:GetWeapons() ) do
		if v.Slot and v.Slot == targetSlot then
			return v
		end
	end
end

function meta:IsInBuyZone()
	return self:Getm_bInBuyZone()
end

function meta:HasDefuser() 
	return (self.Getm_bHasDefuser and self:Getm_bHasDefuser() == true or false)
end

function meta:HasShield() 
	return self:GetNWBool( "m_bHasShield" )
end

function meta:IsShieldDrawn() 
	return self:GetNWBool( "m_bShieldDrawn" )
end

function meta:RemoveDefuser() 
	self:Setm_bHasDefuser( false )
end

function meta:GiveShield()
	self:SetNWBool( "m_bHasShield", true )
	self:SetNWBool( "m_bShieldDrawn", false )
end

function meta:RemoveShield()
	self:SetNWBool( "m_bHasShield", false )
	self:SetNWBool( "m_bShieldDrawn", false )
end

function meta:SetShieldDrawnState( bState )
	if CLIENT then return end
	self:SetNWBool( "m_bShieldDrawn", bState )
end

function meta:HasPrimaryWeapon()
	local bSuccess = false
	local pWeapon = self:Weapon_GetSlot( WEAPON_SLOT_RIFLE )
	if pWeapon then
		bSuccess = true
	end

	return bSuccess
end
function meta:HasSecondaryWeapon()
	local bSuccess = false
	local pWeapon = self:Weapon_GetSlot( WEAPON_SLOT_PISTOL )
	if pWeapon then
		bSuccess = true
	end

	return bSuccess
end
function meta:IsArmored( nHitGroup )
	local bApplyArmor = false

	if self:Getm_iArmorValue() > 0 then
		if nHitGroup == HITGROUP_GENERIC then
			bApplyArmor = true
		elseif nHitGroup == HITGROUP_CHEST then
			bApplyArmor = true
		elseif nHitGroup == HITGROUP_STOMACH then
			bApplyArmor = true
		elseif nHitGroup == HITGROUP_LEFTARM then
			bApplyArmor = true
		elseif nHitGroup == HITGROUP_RIGHTARM then
			bApplyArmor = true
		elseif nHitGroup == HITGROUP_HEAD then
			if self:Getm_bHasHelmet() then
				bApplyArmor = true
			end
		end
	end

	return bApplyArmor
end

function meta:Pain( bHasArmour )
	if self:LastHitGroup() == HITGROUP_HEAD then
		if self:Getm_bHasHelmet() then
			self:EmitSound( Sound( "OldPlayer.DamageHelmet" ) )
		else
			self:EmitSound( Sound( "OldPlayer.DamageHeadshot" ) )
		end
	elseif self:LastHitGroup() == HITGROUP_LEFTLEG or self:LastHitGroup() == HITGROUP_RIGHTLEG then
		if bHasArmour then
			self:EmitSound( Sound( "OldPlayer.DamageKevlar" ) )
		else
			self:EmitSound( Sound( "OldPlayer.Damage" ) )
		end
	else
		self:EmitSound( Sound( "OldPlayer.Damage" ) )
	end
end

if SERVER then
	function meta:CS16_RemoveAllItems( bool )
		if self:HasDefuser() then
			self:RemoveDefuser()
		end

		if self:HasShield() then
			self:RemoveShield()
		end

		self.m_bHasNightVision = false
		self.m_bNightVisionOn = false

		if bool then
			self:Setm_bHasHelmet( false )
			self:Setm_iArmorValue( 0 )
			self:Setm_iOldArmor( 0 )
		end

		self:RemoveAllItems( bool )
	end
	function meta:GiveDefaultItems()
		local pistol = self:Weapon_GetSlot( WEAPON_SLOT_PISTOL )

		if pistol then
			return
		end
		m_bUsingDefaultPistol = true

		if self:Team() == TEAM_CT then
			self:Give( "wep_cs16_knife" )
			self:Give( "wep_cs16_usp" )
			self:GiveAmmo( 24, "CS16_45ACP" )
		elseif self:Team() == TEAM_T then
			self:Give( "wep_cs16_knife" )
			self:Give( "wep_cs16_glock18" )
			self:GiveAmmo( 40, "CS16_9MM" )
		end

		self:CS16_SelectBestWeapon( self:GetActiveWeapon() )
	end

	function meta:DropWeapons()
		local c4 = self:GetWeapon( CS16_WEAPON_C4 )
		if c4 then
			self:CS16_DropPlayerItem( c4, (self:EyeAngles():Forward() * 32 ), Vector(0,0,-5) )
		end
		if self:HasDefuser() then
			local ent = ents.Create("item_defusekit")
			ent:SetPos( self:GetShootPos() + self:EyeAngles():Forward() * 10 + Vector(0,0,-6) )
			ent:SetAngles( self:EyeAngles() )
			ent:Spawn()
			ent:SetOwner( self )
			ent:Setm_hOwner( self )
			ent:SetVelocity( (self:EyeAngles():Forward() * 32 ) )
			self:Setm_bHasDefuser( false )
		end
		if self:HasShield() then
			self:DropShield()
		else
			if !self:DropRifle() then
				self:DropPistol()
			end
		end
	end

	function meta:ShowViewPortPanel( panel )
		umsg.Start( "ShowViewPortPanel", self )
			umsg.String( panel )
		umsg.End()
	end
	function meta:ChangeTeam( team )
		if team == self:Team() then return end

		local iOldTeam = self:Team()

		self:DropWeapons()

		if team != TEAM_SPEC then
			self.m_bTeamChanged = true
		else
			self.m_iOldTeam = iOldTeam
		end

		self:SetTeam( team )

		self:SetModelID( 0 )

		if team == TEAM_UNASSIGNED then
			self:SetState( STATE_OBSERVER_MODE )
			player_manager.RunClass( self, "SpawnSpectator" )
		elseif team == TEAM_SPEC then
			self:SetMoney( 0 )
			self:RemoveAllItems()
			self:SetState( STATE_OBSERVER_MODE )
			player_manager.RunClass( self, "SpawnSpectator" )
		else
			if iOldTeam == TEAM_SPEC then
				self:SetMoney( GetConVar("sv_cs16_startingmoney"):GetInt() )
			elseif iOldTeam != TEAM_UNASSIGNED and self:Alive() then
				self:Kill()
			end

			self:SetState( STATE_PICKINGCLASS )
		end

		InitializePlayerCounts()
	end
	function meta:GetIntoGame()
		self:ResetMaxSpeed()

		if !hook.Run("PlayerDeathThink", self ) then
			self:SetState( STATE_OBSERVER_MODE )
			CheckWinConditions()
		else
			self:SetState( STATE_ACTIVE )
			self:Spawn()
			player_manager.RunClass( self, "Spawn" )
			self:Spawn()

			CheckWinConditions()

			if m_flRestartRoundTime == 0 then
				if IsBombDefuseMap() and !IsThereABomber() and !IsThereABomb() then
					GiveC4()
				end
			end
		end
	end
	function meta:SetModelFromClass()
		local class = tonumber(self:GetModelID())
		local team = self:Team()

		if class == CS_CLASS_NONE then class = math.random( CS_CLASS_FIRST, CS_CLASS_FOURTH ) end

		if CS_CLASSES[team] then
			if CS_CLASSES[team][class] then

				self:SetModel( CS_CLASSES[team][class].model )
			end
		end
	end
else
	function GM:PlayerBindPress( ply, bind, pressed )
		if string.find( bind, "slot" ) and pressed then
			local slot = tonumber( string.match( bind, "slot(%d)" ) ) or 1
			if IsValid( cstrike_vgui_radiomenu ) then
				cstrike_vgui_radiomenu:CallMenu( slot )
				return true
			end
		elseif bind == "+menu" and pressed then
			RunConsoleCommand( "lastinv" )
			return true
		end
	end
end