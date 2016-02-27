if CLIENT then
	function MsgFunc_SendAudio( data )
		local str = data:ReadString()

		surface.PlaySound( str )
	end
	function MsgFunc_RadioText( data )
		local dest = data:ReadShort()
		local client = data:ReadShort()
		local msgname = data:ReadString()
		local param1 = CSL( data:ReadString() )
		local param2 = CSL( data:ReadString() )
		local param3 = CSL( data:ReadString() )
		local param4 = CSL( data:ReadString() )

		local ent = Entity( client )
		if !IsValid( ent ) then return end

		local str = {}
		table.insert( str, team.GetColor( ent:Team() ) )
		table.insert( str, param1 .. " " )
		table.insert( str, msgname .. ": " )
		table.insert( str, param2 .. " " )
		table.insert( str, param3 .. " " )
		table.insert( str, param4 .. " " )

		chat.AddText( unpack( str ) )
		chat.PlaySound()
	end

	usermessage.Hook( "SendAudio", MsgFunc_SendAudio )
	usermessage.Hook( "RadioText", MsgFunc_RadioText )
end

if SERVER then
	local meta = FindMetaTable( "Player" )

	function UTIL_CSRadioMessage( filter, m_iClient, msg_dest, msg_name, param1, param2, param3, param4 )
		umsg.Start( "RadioText", filter )
			umsg.Short( msg_dest )
			umsg.Short( m_iClient )
			umsg.String( msg_name )
			umsg.String( param1 and param1 or "" )
			umsg.String( param2 and param2 or "" )
			umsg.String( param3 and param3 or "" )
			umsg.String( param4 and param4 or "" )
		umsg.End()
	end
	
	function meta:HandleMenu_Radio1( slot )
		if self.m_iRadioMessages < 0 then return end
		if self.m_flRadioTime > CurTime() then return end

		self.m_iRadioMessages = self.m_iRadioMessages - 1
		self.m_flRadioTime = CurTime() + 1.5

		if slot == 1 then
			self:Radio( "cs16radio/ct_coverme.wav", "csl_Cover_me" )
			return
		elseif slot == 2 then
			self:Radio( "cs16radio/takepoint.wav", "csl_You_take_the_point" )
			return
		elseif slot == 3 then
			self:Radio( "cs16radio/position.wav", "csl_Hold_this_position" )
			return
		elseif slot == 4 then
			self:Radio( "cs16radio/regroup.wav", "csl_Regroup_Team" )
			return
		elseif slot == 5 then
			self:Radio( "cs16radio/followme.wav", "csl_Follow_me" )
			return
		elseif slot == 6 then
			self:Radio( "cs16radio/fireassis.wav", "csl_Taking_fire" )
			return
		elseif slot == 7 then
			self:Radio( "cs16radio/moscow.wav", "csl_Moscow" )
			return
		end
	end
	function meta:HandleMenu_Radio2( slot )
		if self.m_iRadioMessages < 0 then return end
		if self.m_flRadioTime > CurTime() then return end

		self.m_iRadioMessages = self.m_iRadioMessages - 1
		self.m_flRadioTime = CurTime() + 1.5

		if slot == 1 then
			self:Radio( "cs16radio/com_go.wav", "csl_Go_go_go" )
			return
		elseif slot == 2 then
			self:Radio( "cs16radio/fallback.wav", "csl_Team_fall_back" )
			return
		elseif slot == 3 then
			self:Radio( "cs16radio/sticktog.wav", "csl_Stick_together_team" )
			return
		elseif slot == 4 then
			self:Radio( "cs16radio/com_getinpos.wav", "csl_Get_in_position_and_wait" )
			return
		elseif slot == 5 then
			self:Radio( "cs16radio/stormfront.wav", "csl_Storm_the_front" )
			return
		elseif slot == 6 then
			self:Radio( "cs16radio/com_reportin.wav", "csl_Report_in_team" )
			return
		elseif slot == 7 then
			self:Radio( "cs16radio/orat.mp3", "csl_Hvatit_orat" )
			return
		end
	end
	function meta:HandleMenu_Radio3( slot )
		if self.m_iRadioMessages < 0 then return end
		if self.m_flRadioTime > CurTime() then return end

		self.m_iRadioMessages = self.m_iRadioMessages - 1
		self.m_flRadioTime = CurTime() + 1.5

		if slot == 1 then
			if math.random( 0, 1 ) != 0 then
				self:Radio( "cs16radio/ct_affirm.wav", "csl_Affirmative" )
			else
				self:Radio( "cs16radio/roger.wav", "csl_Roger_that" )
			end
			return
		elseif slot == 2 then
			self:Radio( "cs16radio/ct_enemys.wav", "csl_Enemy_spotted" )
			return
		elseif slot == 3 then
			self:Radio( "cs16radio/ct_backup.wav", "csl_Need_backup" )
			return
		elseif slot == 4 then
			self:Radio( "cs16radio/clear.wav", "csl_Sector_clear" )
			return
		elseif slot == 5 then
			self:Radio( "cs16radio/ct_inpos.wav", "csl_In_position" )
			return
		elseif slot == 6 then
			self:Radio( "cs16radio/ct_reportingin.wav", "csl_Reporting_in" )
			return
		elseif slot == 7 then
			self:Radio( "cs16radio/blow.wav", "csl_Get_out_of_there" )
			return
		elseif slot == 8 then
			self:Radio( "cs16radio/negative.wav", "csl_Negative" )
			return
		elseif slot == 9 then
			self:Radio( "cs16radio/enemydown.wav", "csl_Enemy_down" )
			return
		end
	end

	function meta:ConstructRadioFilter( filter )
		local team = self:Team()

		for k,v in pairs( player.GetAll() ) do
			if !IsValid( v ) then continue end
			if v.m_bIgnoreRadio then continue end

			if v:Team() == TEAM_SPECTATOR then
				if v:GetObserverMode() == OBS_MODE_IN_EYE or v:GetObserverMode() == OBS_MODE_CHASE then
					filter:AddPlayer( v )
				end
			elseif v:Team() == team then
				filter:AddPlayer( v )
			end
		end
	end

	function meta:Radio( radioSound, radioText )
		if !self:Alive() then
			return
		end
		if self:IsObserver() then
			return
		end

		local filter = RecipientFilter()
		self:ConstructRadioFilter( filter )

		if radioText then
			UTIL_CSRadioMessage( filter, self:EntIndex(), HUD_PRINTTALK, "(RADIO)", self:GetName(), radioText )
		end

		umsg.Start( "SendAudio", filter )
			umsg.String( radioSound )
		umsg.End()
	end

	concommand.Add( "coverme", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio1( 1 ) end )
	concommand.Add( "takepoint", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio1( 2 ) end )
	concommand.Add( "holdpos", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio1( 3 ) end )
	concommand.Add( "regroup", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio1( 4 ) end )
	concommand.Add( "followme", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio1( 5 ) end )
	concommand.Add( "takingfire", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio1( 6 ) end )
	concommand.Add( "moscow", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio1( 7 ) end )
	concommand.Add( "go", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio2( 1 ) end )
	concommand.Add( "fallback", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio2( 2 ) end )
	concommand.Add( "sticktog", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio2( 3 ) end )
	concommand.Add( "getinpos", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio2( 4 ) end )
	concommand.Add( "stormfront", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio2( 5 ) end )
	concommand.Add( "report", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio2( 6 ) end )
	concommand.Add( "orat", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio2( 7 ) end )
	concommand.Add( "roger", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio3( 1 ) end )
	concommand.Add( "enemyspot", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio3( 2 ) end )
	concommand.Add( "needbackup", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio3( 3 ) end )
	concommand.Add( "sectorclear", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio3( 4 ) end )
	concommand.Add( "inposition", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio3( 5 ) end )
	concommand.Add( "reportingin", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio3( 6 ) end )
	concommand.Add( "getout", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio3( 7 ) end )
	concommand.Add( "negative", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio3( 8 ) end )
	concommand.Add( "enemydown", function( ply ) if !ply:Alive() or ply:IsObserver() then return end ply:HandleMenu_Radio3( 9 ) end )

end