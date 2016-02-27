local texOutlinedCorner = surface.GetTextureID( "gui/outline_corner" )

function draw.RoundedBoxOutlined( bordersize, x, y, w, h, color )
	local bord = 8
	x = math.Round( x )
	y = math.Round( y )
	w = math.Round( w )
	h = math.Round( h )
	
	surface.SetDrawColor( color )
	
	surface.SetTexture( texOutlinedCorner )
	surface.DrawTexturedRectRotated( x + bord/2 , y + bord/2, bord, bord, 0 ) 
	surface.DrawTexturedRectRotated( x + w - bord/2 , y + bord/2, bord, bord, 270 ) 
	surface.DrawTexturedRectRotated( x + w - bord/2 , y + h - bord/2, bord, bord, 180 ) 
	surface.DrawTexturedRectRotated( x + bord/2 , y + h -bord/2, bord, bord, 90 ) 
	
	surface.DrawLine( x+bordersize, y, x+w-bordersize, y )
	surface.DrawLine( x+bordersize, y+h-1, x+w-bordersize, y+h-1 )
	
	surface.DrawLine( x, y+bordersize, x, y+h-bordersize )
	surface.DrawLine( x+w-1, y+bordersize, x+w-1, y+h-bordersize )
end
local function GetSortedPlayers( t )
	local tbl = table.Copy( team.GetPlayers( t ) )
	local TblLen = #tbl
	if TblLen >= 1 then
		for i = TblLen, 1, -1 do
			for j = 1, i-1 do
				if tbl[j]:Frags() < tbl[j + 1]:Frags() then
					local temp = tbl[j]
					tbl[j] = tbl[j + 1]
					tbl[j + 1] = temp
				end
			end
		end
		return tbl
	end
	return {}
end

local PANEL = {}
function PANEL:Init()
	self.Name = self:Add("DLabel")
	self.Name:SetFont("CSDeathnotice")
	self.Ping = self:Add("DLabel")
	self.Ping:SetFont("CSDeathnotice")
	self.Deaths = self:Add("DLabel")
	self.Deaths:SetFont("CSDeathnotice")
	self.Score = self:Add("DLabel")
	self.Score:SetFont("CSDeathnotice")
	self.State = self:Add("DLabel")
	self.State:SetFont("CSDeathnotice")
end
function PANEL:Paint( w, h )
	if !IsValid( self.player ) then return end

	if self.player == LocalPlayer() then
		surface.SetDrawColor( Color( 255, 255, 255, 5 ) )
		surface.DrawRect( 0, 0, w - ScreenScaleZ( 9 ), h )
	end

	self.Name:SetText( self.player:Nick() )
	self.Ping:SetText( self.player:Ping() )
	self.Deaths:SetText( self.player:Deaths() )
	self.Score:SetText( self.player:Frags() )
	self.State:SetText( self.player:HasWeapon( CS16_WEAPON_C4 ) and "Bomb" or ( !self.player:Alive() and (self.player:Team() == TEAM_SPEC and "" or "Dead") or "" ) )
end
function PANEL:SetPlayer( player )
	self.player = player
	self.colorTeam = self.colorTeam
	if self.idTeam == TEAM_SPEC then
		self.colorTeam = Color( 200, 200, 200, 255 )
	end
	self.Name:SetTextColor( self.colorTeam )
	self.Ping:SetTextColor( self.colorTeam )
	self.Deaths:SetTextColor( self.colorTeam )
	self.Score:SetTextColor( self.colorTeam )
	self.State:SetTextColor( self.colorTeam )
end
function PANEL:PerformLayout( )
	self.Name:SizeToContents()
	self.Ping:SizeToContents()
	self.Deaths:SizeToContents()
	self.Score:SizeToContents()
	self.State:SizeToContents()

	local wide = self:GetParent():GetParent():GetWide()
	local w1 = (wide / 640) * 10
	local w2 = (wide / 640) * 64 + 10 + 16
	local w3 = (wide / 640) * 128 + 32
	local w4 = (wide / 640) * 320 - 16

	self.Name:Dock( LEFT )
	self.Name:DockMargin( 8, 0, 0, 0 )

	self.Ping:SetPos( wide - self.Ping:GetWide() - w1, 2 )
	self.Score:SetPos( wide - self.Score:GetWide() - w3, 2 )
	self.Deaths:SetPos( wide - self.Deaths:GetWide() - w2, 2 )
	self.State:SetPos( wide - self.State:GetWide() - w4, 2 )

	self:SetSize( self:GetParent():GetWide(), 18 )
end
vgui.Register( "CStrike_ScoreboardPlayer", PANEL, "EditablePanel" )

local PANEL = {}
function PANEL:Init()
	self.Players = {}

	self.Header = self:Add("Panel")
	self.Header:Dock( TOP )
	self.List = self:Add("DPanelList")
	self.List:Dock( TOP )
	self.List:DockMargin( 8, 0, 0, 0 )

	self.TeamName = self.Header:Add("DLabel")
	self.TeamName:SetFont("CSDeathnotice")
	self.Score = self.Header:Add("DLabel")
	self.Score:SetFont("CSDeathnotice")
end
function PANEL:Paint( w, h ) 
	if #self.Players <= 0 then 
		self.TeamName:SetText("")
		self.Score:SetText("")
		return 
	end

	local count = #team.GetPlayers( self.idTeam )
	self.TeamName:SetText( self.nameTeam .. "      -      " .. count .. " player" .. ((count == 1) and "" or "s") )
	self.Score:SetText( team.GetScore( self.idTeam ) )
end
function PANEL:SetupTeam( t )
	self.idTeam = t
	self.nameTeam = team.GetName( t )
	if t != TEAM_SPEC then
		self.colorTeam = team.GetColor( t )
	else
		self.colorTeam = MAIN_SCHEMA.COLOR
	end

	self.TeamName:SetTextColor( self.colorTeam )
	self.Score:SetTextColor( self.colorTeam )

	self.Header.Paint = function( p, w, h )
		if #self.Players <= 0 then return end
		if t != TEAM_SPEC then
			surface.SetDrawColor( self.colorTeam )
		else
			surface.SetDrawColor( MAIN_SCHEMA.COLOR_DARK2 )
		end
		surface.DrawLine( 7, h - 1, w - ScreenScaleZ( 10 ) + 1, h - 1)
	end

	for k, v in pairs( GetSortedPlayers( t ) ) do
		self:AddPlayer( v )
	end
end
function PANEL:ForceRebuild()
	self.Players = {}
	for k, v in pairs( GetSortedPlayers( self.idTeam ) ) do
		self:AddPlayer( v )
	end
end
function PANEL:Think2( )
	if #self.Players > 0 then
		if !self:IsVisible() then
			self:SetVisible( true )
		end
	else
		if self:IsVisible() then
			self:SetVisible( false )
		end
	end

	local sorted = GetSortedPlayers( self.idTeam )

	for i, v in pairs( self.Players ) do
		if self.Players[i] and !IsValid( self.Players[i].ply ) then
			self.Players[i].panel:Remove()
			table.remove( self.Players, i )
			self:PerformLayout()
			cstrike_vgui_scoreboard:PerformLayout()
		elseif self.Players[i] and self.Players[i].ply:Team() != self.idTeam then
			self.Players[i].panel:Remove()
			table.remove( self.Players, i )
			self:PerformLayout()
			cstrike_vgui_scoreboard:PerformLayout()
		elseif self.Players[i] and IsValid( self.Players[i].ply ) and self.Players[i].ply != sorted[i] then
			self.Players[i].panel:SetPlayer( sorted[i] )
			self.Players[i].ply = sorted[i]
			self:PerformLayout()
			cstrike_vgui_scoreboard:PerformLayout()
		end
	end
	if #sorted != #self.Players then
		self:AddPlayer( sorted[#sorted] )
	end
end
function PANEL:AddPlayer( player )
	local p = vgui.Create("CStrike_ScoreboardPlayer")
	p.idTeam = self.idTeam
	p.colorTeam = self.colorTeam
	p.wPing = 5
	p.wDeath = 5
	p.wKills = 5
	p:SetPlayer( player )

	self.List:AddItem( p )

	local id = 1
	for i = 1, 256 do
		if self.Players[i] == nil then
			id = i
			break
		end
	end
	table.insert( self.Players, { ply = player, panel = p } )
	self:PerformLayout()
	cstrike_vgui_scoreboard:PerformLayout()
end
function PANEL:PerformLayout( )
	local y = 0
	for i = 1, #self.Players do
		y = (i * 18)
	end
	self.List:GetCanvas():SetSize( self:GetWide(), y )
	self.List:SetSize( self.List:GetCanvas():GetWide(), self.List:GetCanvas():GetTall() )
	self:SetTall( 24 + self.List:GetCanvas():GetTall() )

	self.TeamName:SizeToContents()
	self.TeamName:Dock( LEFT )
	self.TeamName:DockMargin( 8, 4, 0, 0 )
	local w3 = (self:GetWide() / 640) * 128 + 32
	self.Score:SizeToContents()
	self.Score:SetPos( self:GetParent():GetWide() - self.Score:GetWide() - w3, 8 )
end
vgui.Register( "CStrike_ScoreboardTeam", PANEL, "EditablePanel" )

local PANEL = {}
function PANEL:Init()
	if IsValid( cstrike_vgui_scoreboard ) then
		cstrike_vgui_scoreboard:Remove()
	end
	cstrike_vgui_scoreboard = self
	
	self:SetSize( ScreenScaleZ( 520 ), ScreenScaleZ( 380 ) )
	self:Center()

	self.Header = self:Add("Panel")
	self.Header:Dock( TOP )
	self.Header.Paint = function( p, w, h )
		surface.SetDrawColor( MAIN_SCHEMA.COLOR_DARK2 )
		surface.DrawLine( 7, h - 1, w - ScreenScaleZ( 10 ) + 1, h - 1)
	end
		self.ServerName = self.Header:Add("DLabel")
		self.ServerName:SetTextColor( MAIN_SCHEMA.COLOR )
		self.ServerName:SetFont("CSDeathnotice")
		self.ServerName:SetText("Counter-Strike")
		self.PingLabel = self.Header:Add("DLabel")
		self.PingLabel:SetTextColor( MAIN_SCHEMA.COLOR )
		self.PingLabel:SetFont("CSDeathnotice")
		self.PingLabel:SetText("Latency")
		self.DeathLabel = self.Header:Add("DLabel")
		self.DeathLabel:SetTextColor( MAIN_SCHEMA.COLOR )
		self.DeathLabel:SetFont("CSDeathnotice")
		self.DeathLabel:SetText("Deaths")
		self.KillsLabel = self.Header:Add("DLabel")
		self.KillsLabel:SetTextColor( MAIN_SCHEMA.COLOR )
		self.KillsLabel:SetFont("CSDeathnotice")
		self.KillsLabel:SetText("Score")
		
		self:PerformLayout()

	self.Terrorists = self:Add("CStrike_ScoreboardTeam")
	self.Terrorists:Dock( TOP )
	self.Terrorists:SetupTeam( 2 )	

	self.CounterTerrorists = self:Add("CStrike_ScoreboardTeam")
	self.CounterTerrorists:Dock( TOP )
	self.CounterTerrorists:SetupTeam( 3 )	

	self.Spectators = self:Add("CStrike_ScoreboardTeam")
	self.Spectators:Dock( TOP )
	self.Spectators:SetupTeam( TEAM_SPEC )	
end
function PANEL:Paint( w, h )
	draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 0, 0, 204 ) )
	draw.RoundedBoxOutlined( 8, 0, 0, w, h, MAIN_SCHEMA.COLOR_DARK2 )

	self.ServerName:SetText( GetHostName() )

	self.Terrorists:Think2()
	self.CounterTerrorists:Think2()
	self.Spectators:Think2()
end
function PANEL:PerformLayout()
	self.ServerName:SizeToContents()
	self.DeathLabel:SizeToContents()
	self.KillsLabel:SizeToContents()
	self.PingLabel:SizeToContents()

	local w1 = (self:GetWide() / 640) * 10
	local w2 = (self:GetWide() / 640) * 64 + 10 + 16
	local w3 = (self:GetWide() / 640) * 128 + 32
	self.ServerName:Dock( LEFT )
	self.ServerName:DockMargin( 8, 0, 0, 4 )

	self.DeathLabel:SetPos( self:GetWide() - self.DeathLabel:GetWide() - w2, 4 )
	self.KillsLabel:SetPos( self:GetWide() - self.KillsLabel:GetWide() - w3, 4 )
	self.PingLabel:SetPos( self:GetWide() - self.PingLabel:GetWide() - w1, 4 )

	local y = 24
	if self.Terrorists and #self.Terrorists.Players > 0 then
		y = y + self.Terrorists:GetTall()
	end
	if self.CounterTerrorists and #self.CounterTerrorists.Players > 0 then
		y = y + self.CounterTerrorists:GetTall()
	end
	if self.Spectators and #self.Spectators.Players > 0 then
		y = y + self.Spectators:GetTall()
	end
	y = y + 5

	self:SetTall( y )
	self:Center()
end
vgui.Register( "CStrike_Scoreboard", PANEL, "EditablePanel" )
if cstrike_vgui_scoreboard then
cstrike_vgui_scoreboard:Remove()
cstrike_vgui_scoreboard = nil
end
function GM:ScoreboardShow()
	if !cstrike_vgui_scoreboard then
		vgui.Create( "CStrike_Scoreboard" )
	end
	cstrike_vgui_scoreboard:SetVisible( true )
	return false 
end

function GM:ScoreboardHide()
	if cstrike_vgui_scoreboard then
		cstrike_vgui_scoreboard:SetVisible(false)
	end
	return false 
end