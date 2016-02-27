include( "shared.lua" )
include( "radio.lua" )
include( "gamelogic.lua" )
include( "cstrikevgui.lua" )
include( "binds.lua" )
include( "oldhud.lua" )
include( "cl_scoreboard.lua" )
include( "animation.lua" )
include( "damage.lua" )

oldBloom = GetConVar( "mat_bloomscale" ):GetInt()
RunConsoleCommand( "mat_bloomscale", 0 )

DEFINE_BASECLASS( "gamemode_base" )

CreateClientConVar( "cl_cs16_autobuy", "m4a1 ak47 famas galil p90 mp5 primammo secammo defusekit kevlarhelmet kevlar", true, true )

MAIN_SCHEMA = {}
MAIN_SCHEMA.ButtonBorder = Color( 255, 176, 0, 50 )
MAIN_SCHEMA.ButtonBorder2 = Color( 50, 50, 50, 100 )
MAIN_SCHEMA.ButtonBorderLight = Color( 255, 176, 0, 50 )
MAIN_SCHEMA.ButtonBG = Color( 0, 0, 0, 64 )
MAIN_SCHEMA.ButtonBGLight = Color( 255, 176, 0, 50 )
MAIN_SCHEMA.BG = Color( 0, 0, 0, 240 )
MAIN_SCHEMA.COLOR = Color( 255, 176, 0 )
MAIN_SCHEMA.COLOR_DARK = Color( 255, 176, 0, 100 )
MAIN_SCHEMA.COLOR_DARK2 = Color( 255, 176, 0, 50 )

local oldColor = {
	["$pp_colour_addr" ] = 0.02,
	["$pp_colour_addg" ] = 0.03,
	["$pp_colour_addb" ] = 0.004,
	["$pp_colour_brightness" ] = 0,
	["$pp_colour_contrast" ] = 0.91,
	["$pp_colour_colour" ] = 0.94,
	["$pp_colour_mulr" ] = 0,
	["$pp_colour_mulg" ] = 0.3,
	["$pp_colour_mulb" ] = 0
}

// Language
CStrike_Language = {}
CStrike_Language["en"] = {
	["csl_Target_Bombed"] = "Target successfully bombed!",
	["csl_Target_Saved"] = "Target successfully saved!",
	["csl_Terrorists_Win"] = "Terrorists win!",
	["csl_CTs_Win"] = "Counter-Terrorists win!",
	["csl_Bomb_Planted"] = "The bomb has been planted.",
	["csl_Bomb_Defused"] = "The bomb has been defused.",
	["csl_Game_Commencing"] = "Game commencing.",
	["csl_Round_Draw"] = "Round Draw!",
	["csl_Hostages_Not_Rescued"] = "Hostages have not been rescued!",
	["csl_All_Hostages_Rescued"] = "All hostages have been rescued!",
	["csl_Only_1_Team_Change"] = "Only 1 team change is allowed.",
	["csl_All_Teams_Full"] = "All teams is full.",
	["csl_Terrorists_Full"] = "Terrorists team is full.",
	["csl_CTs_Full"] = "Counter-Terrorists team is full.",
	["csl_Too_Many_Terrorists"] = "Too many terrorists.",
	["csl_Too_Many_CTs"] = "Too many counter-terrorists.",
	["csl_Affirmative"] = "Affirmative.",
	["csl_Roger_that"] = "Roger that.",
	["csl_Enemy_spotted"] = "Enemy spotted.",
	["csl_Need_backup"] = "Need backup.",
	["csl_Sector_clear"] = "Sector clear.",
	["csl_In_position"] = "I'm in position.",
	["csl_Reporting_in"] = "Reporting in.",
	["csl_In_position"] = "I'm in position.",
	["csl_Get_out_of_there"] = "Get out of there, it's gonna blow!",
	["csl_Negative"] = "Negative.",
	["csl_Enemy_down"] = "Enemy down.",
	["csl_Go_go_go"] = "Go go go!",
	["csl_Team_fall_back"] = "Team, fall back!",
	["csl_Stick_together_team"] = "Stick together, team.",
	["csl_Get_in_position_and_wait"] = "Get in position and wait for my go.",
	["csl_Storm_the_front"] = "Storm the Front!",
	["csl_Report_in_team"] = "Report in, team.",
	["csl_Cover_me"] = "Cover Me!",
	["csl_You_take_the_point"] = "You Take the Point.",
	["csl_Hold_this_position"] = "Hold This Position.",
	["csl_Regroup_Team"] = "Regroup Team.",
	["csl_Follow_me"] = "Follow me.",
	["csl_Taking_fire"] = "Taking Fire...Need Assistance!",
	["csl_Hvatit_orat"] = "Hvatit orat, ne umeesh orat' ne ori tvar' ebanaya.",
	["csl_Moscow"] = "V Moskvu nado ehat', v Moskve vsya sila. Ya tut razgrebu chut' chut' i v Moskvu.",
	["csl_Fire_in_the_Hole"] = "Fire in the Hole!",
	["csl_AwardForKilling"] = "Award for eliminating an enemy.",
	["csl_AwardForWin"] = "Award for winning the round.",
	["csl_AwardForPlant"] = "Award for planting a bomb.",
	["csl_AwardForBombed"] = "Award for bombing the target.",
	["csl_AwardForDefuse"] = "Award for defusing the bomb.",
	["csl_AwardForLose"] = "Money for losing.",
	["csl_Already_bought"] = "You already bought that!",
	["csl_Already_Have_Kevlar"] = "You already have Kevlar!",
	["csl_Already_Have_Kevlar_Helmet"] = "You already have Kevlar and a helmet!",
	["csl_Already_Have_Kevlar_Bought_Helmet"] = "You already have Kevlar, bought Helmet!",
	["csl_Already_Have_Helmet_Bought_Kevlar"] = "You already have Helmet, bought Kevlar!",
	["csl_Already_Have_One"] = "You already have one!",
	["csl_Not_Enough_Money"] = "You have insufficient funds.",
	["csl_Cannot_Carry_Anymore"] = "You cannot carry any more.",
	["csl_Player"] = "Player",
	["csl_HasBeenDisconnected"] = "has been disconnected",
	["csl_HasBeenConnected"] = "joining the game"
	
}
CStrike_Language["ru"] = {
	["csl_Target_Bombed"] = "Цель уничтожена!",
	["csl_Target_Saved"] = "Цель спасена!",
	["csl_Terrorists_Win"] = "Террористы одержали победу!",
	["csl_CTs_Win"] = "Спецназовцы одержали победу!",
	["csl_Bomb_Defused"] = "Бомба обезврежена.",
	["csl_Game_Commencing"] = "Игра начинается.",
	["csl_Round_Draw"] = "Ничья!",
	["csl_Hostages_Not_Rescued"] = "Спасательная операция провалена",
	["csl_All_Hostages_Rescued"] = "Все заложники спасены",
	["csl_Only_1_Team_Change"] = "Доступна только одна смены команды за раз.",
	["csl_All_Teams_Full"] = "Все команды переполнены.",
	["csl_Terrorists_Full"] = "Команда террористов переполнена.",
	["csl_CTs_Full"] = "Команда спецназа переполнена.",
	["csl_Too_Many_Terrorists"] = "Слишком много людей в команде террористов.",
	["csl_Too_Many_CTs"] = "Слишком много людей в команде спецназа.",
	["csl_AwardForKilling"] = "Награда за устранение противника.",
	["csl_AwardForWin"] = "Награда за победу в раунде.",
	["csl_AwardForPlant"] = "Награда за закладку бомбы.",
	["csl_AwardForBombed"] = "Награда за подрыв бомбы.",
	["csl_AwardForDefuse"] = "Награда за обезвреживание бомбы.",
	["csl_AwardForLose"] = "Денег за проигрыш.",
	["csl_Already_Have_Kevlar"] = "У вас уже есть бронежилет!",
	["csl_Already_Have_Kevlar_Helmet"] = "У вас уже есть бронежилет и шлем!",
	["csl_Already_Have_Kevlar_Bought_Helmet"] = "У вас уже есть бронежилет, покупаю шлем!",
	["csl_Already_Have_Helmet_Bought_Kevlar"] = "У вас уже есть шлем, покупаю бронежилет!",
	["csl_Already_Have_One"] = "У вас уже есть это!",
	["csl_Not_Enough_Money"] = "У вас нет денег.",
	["csl_Cannot_Carry_Anymore"] = "Вы не можете больше взять.",
	["csl_Player"] = "Игрок",
	["csl_HasBeenDisconnected"] = "покидает игру",
	["csl_HasBeenConnected"] = "вступает в игру"
}
function CSL( m_strText )
	local m_strLang = GetConVar("gmod_language"):GetString()
	local m_tLanguage = CStrike_Language["en"]
	if CStrike_Language[ m_strLang ] then
		m_tLanguage = CStrike_Language[ m_strLang ]
	end
	return m_tLanguage[m_strText] and m_tLanguage[m_strText] or ( CStrike_Language["en"][m_strText] and CStrike_Language["en"][m_strText] or m_strText ) 
end

// Functions
local m_strLastPrintMessage = ""
local m_flLastPrintMessageDieTime = 0
local m_mTimerIcon = Material( "cs16timer.png", "smooth" )
local function DrawOldPrintMessages()
	if m_flLastPrintMessageDieTime != 0 and m_flLastPrintMessageDieTime >= CurTime() and m_strLastPrintMessage != "" then
		surface.SetFont("OldPrintMessage_Font")
		local m_iW, m_iH = surface.GetTextSize( m_strLastPrintMessage )
		
		surface.SetTextColor( Color( 0, 0, 0, 255 ) )
		surface.SetTextPos( ScrW() / 2 - m_iW / 2 + 1, ScrH() / 2.88 + 1)
		surface.DrawText( m_strLastPrintMessage )
		surface.SetTextColor( MAIN_SCHEMA.COLOR )
		surface.SetTextPos( ScrW() / 2 - m_iW / 2, ScrH() / 2.88 )
		surface.DrawText( m_strLastPrintMessage )
	end
end
local function DrawSpectatorHUD()
	if !LocalPlayer():IsObserver() then return end
	if IsValid( cstrike_vgui_motd ) then return end

	local height = math.floor( ScreenScaleZ( 64 ) )
	local timerIconSize = ScreenScaleZ( 14 )
	surface.SetDrawColor( Color( 0, 0, 0, 225 ) )
	surface.DrawRect( 0, 0, ScrW(), height )
	surface.DrawRect( 0, ScrH() - height, ScrW(), height )

	surface.SetFont("CSVGUI_4")
	surface.SetTextColor( MAIN_SCHEMA.COLOR )

	local roundtime = os.date( "%M:%S" , GetRoundRemainingTime() )
	roundtime = roundtime and roundtime or "0:00"
	local w_round, h_round = surface.GetTextSize( roundtime )
	surface.SetTextPos( ScrW() - w_round - 10, height / 2 + timerIconSize / 2 - h_round / 2)
	surface.DrawText( roundtime )

	local cterrorist = team.GetName( 3 ).." : "..team.GetScore( 3 )
	local w, h = surface.GetTextSize( cterrorist )
	surface.SetTextPos( ScrW() - w - w_round - timerIconSize - 10 - 16, height / 2 - h / 2 - 10 )
	surface.DrawText( cterrorist )

	local terrorist = team.GetName( 2 ).." : "..team.GetScore( 2 )
	local w, h = surface.GetTextSize( terrorist )
	surface.SetTextPos( ScrW() - w - w_round - timerIconSize - 10 - 16, height / 2 + timerIconSize / 2 - h_round / 2 )
	surface.DrawText( terrorist )

	local xy = (w_round - timerIconSize - 10 - 16)
	surface.SetDrawColor( MAIN_SCHEMA.ButtonBorder )
	surface.DrawLine( ScrW() - w_round - timerIconSize - 10 - 8, height / 1.4, ScrW() - w_round - timerIconSize - 10 - 8, height / 4 )

	local money = LocalPlayer():GetMoney()
	local w, h = surface.GetTextSize( money )
	surface.SetTextPos( ScrW() - w_round - 10 - timerIconSize, height / 2 - h / 2 - 10)
	surface.DrawText( "$"..money )

	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.SetMaterial( m_mTimerIcon )
	surface.DrawTexturedRect( ScrW() - w_round - 10 - timerIconSize - 1, height / 2, timerIconSize, timerIconSize )

	local nick = LocalPlayer():Nick()
	local health = LocalPlayer():Health()
	local team_color = team.GetColor( LocalPlayer():Team() )
	local target = LocalPlayer():GetObserverTarget()
	if IsValid( target ) and target:IsPlayer() then
		nick = target:Nick()
		health = target:Health()
		team_color = team.GetColor( target:Team() )
	end
	local w, h = surface.GetTextSize( nick )
	surface.SetTextColor( team_color )
	surface.SetTextPos( ScrW() / 2 - w / 2, ScrH() - height / 2 - h / 2 )
	surface.DrawText( nick .. " ("..health..")" )
end


// Hooks
function GM:SetupFonts()
	oldScrW = ScrW()
	oldScrH = ScrH()
end
hook.Run( "SetupFonts" )

function GM:OnPlayerChat( m_hClient, strText, bTeamOnly, bPlayerIsDead)
	local tab = {}

	if IsValid( m_hClient ) then
		table.insert( tab, team.GetColor( m_hClient:Team() ) )
	end
	if bPlayerIsDead then
		table.insert( tab, "*DEAD*")
	end
	if bTeamOnly then
		table.insert( tab, "(" .. team.GetName( m_hClient:Team() ) .. ")" )
	end
	if IsValid( m_hClient ) then
		table.insert( tab, " " .. m_hClient:Nick() )
	else
		table.insert( tab, Color( 230, 126, 34 ) )
		table.insert( tab, " Console" )
	end

	table.insert(tab, Color( 255, 255, 255 ) )
	table.insert(tab, " : " .. strText )

	chat.AddText( unpack( tab ) )
	return true
end
function GM:HUDPaint()
	if oldScrW != ScrW() or oldScrH != ScrH() then
		hook.Run( "SetupFonts" )
	end
	DrawOldPrintMessages()
	DrawSpectatorHUD()

	if !LocalPlayer():IsObserver() then
		local time = GetRoundRemainingTime()
		if IsFreezePeriod() then
			time = GetRoundRemainingTime() - GetGlobalFloat("m_iRoundTime")
		end
		local roundtime = os.date( "%M:%S" , time )
		roundtime = roundtime and roundtime or "00:00"

		surface.SetFont("TestHUD")

		surface.SetTextColor( Color( 255, 255, 255 ) )
		surface.SetTextPos( 0, 0 )
		surface.DrawText( "ALPHA version" )
	end

	DrawHealthAndArmor()
	DrawRoundTimer()
	DrawMoney()
	DrawAmmo()
	DrawDeathnotice()
	DrawDamageIndicator()
	DrawProgressBar()
	DrawStatusIndicator()
end
function GM:Think()
	CheckCustomBinds()
end
function GM:ShutDown()
	RunConsoleCommand( "mat_bloomscale", oldBloom )
end
function GM:RenderScreenspaceEffects()
	render.ResetToneMappingScale( 1 )
	DrawColorModify( oldColor )
end

// Usermessages
function umsg_GameEvent_round_end( data )
	local winner = data:ReadShort()
	local text = data:ReadString()
	local defuse = data:ReadBool()

	if winner == WINNER_DRAW then
		surface.PlaySound( "cs16radio/rounddraw.wav" )
	elseif winner == WINNER_CT then
		if !defuse then
			surface.PlaySound( "cs16radio/ctwin.wav" )
		else
			surface.PlaySound( "cs16radio/bombdef.wav" )
		end
	elseif winner == WINNER_TER then
		surface.PlaySound( "cs16radio/terwin.wav" )
	end
end
function umsg_GameEvent_round_start( data )

end
function umsg_PrintMessage( data )
	local m_strText = data:ReadString()

	m_strLastPrintMessage = CSL( m_strText )
	m_flLastPrintMessageDieTime = CurTime() + 8
end
function umsg_ShowViewPortPanel( data )
	local panel = data:ReadString()
	if IsValid( cstrike_vgui_motd ) then cstrike_vgui_motd:Remove() end

	if panel != "nil" then
		local vguii = vgui.Create("CStrike_Main")
		vguii:OpenPanel( panel )
		vguii:MakePopup()
	end
	if panel == PANEL_MOTD then
		sound.PlayURL( "http://schwarzkruppzo.hol.es/mdk_online.mp3", "", function( snd ) if snd then snd:Play() end end )
	end
end
function umsg_Pickup( data )
	local client = data:ReadEntity()
	if !IsValid( client ) then return end
	client:EmitSound( "items/gunpickup2.wav", 70 )
end
function umsg_AmmoPickup( data )
	local client = data:ReadEntity()
	if !IsValid( client ) then return end
	client:EmitSound( "items/9mmclip1.wav", 70 )
end
function umsg_Kevlar( data )
	local client = data:ReadEntity()
	if !IsValid( client ) then return end
	client:EmitSound( "items/ammopickup2.wav", 70 )
end
function umsg_ClientChatPrint( data )
	local m_iArgCount = data:ReadShort()
	local m_tblArgs = {}
	for i = 1, m_iArgCount do
		if data:ReadBool() == true then
			table.insert( m_tblArgs, Color( data:ReadShort(), data:ReadShort(), data:ReadShort() ) )
		else
			table.insert( m_tblArgs, CSL( data:ReadString() ) )
		end
	end
	chat.AddText( unpack( m_tblArgs ) )
end
function umsg_AddMoney( data )
	local value = tonumber( data:ReadString() )
	hook.Run( "player_money_changed", value )
end
function umsg_Hurt( data )
	local health = tonumber( data:ReadShort() )
	local ent1 = Entity( tonumber( data:ReadShort() ) )
	local ent2 = Entity( tonumber( data:ReadShort() ) )
	local userid = ent1.UserID and ent1:UserID() or -1
	local userid2 = ent2.UserID and ent2:UserID() or -1
	hook.Run( "player_hurt", { health = health, userid = userid, attacker = userid2 } )
end

usermessage.Hook( "GameEvent_round_start", umsg_GameEvent_round_start )
usermessage.Hook( "GameEvent_round_end", umsg_GameEvent_round_end )
usermessage.Hook( "OldPrintMessage", umsg_PrintMessage )
usermessage.Hook( "ShowViewPortPanel", umsg_ShowViewPortPanel )
usermessage.Hook( "Pickup", umsg_Pickup )
usermessage.Hook( "AmmoPickup", umsg_AmmoPickup )
usermessage.Hook( "Kevlar", umsg_Kevlar )
usermessage.Hook( "ClientChatPrint", umsg_ClientChatPrint )
usermessage.Hook( "AddMoney", umsg_AddMoney )
usermessage.Hook( "PlayerHurt", umsg_Hurt )