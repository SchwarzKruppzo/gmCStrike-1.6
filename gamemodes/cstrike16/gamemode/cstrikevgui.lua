local motd_url = GetConVar("sv_cs16_motd_url"):GetString()
local motd_html = ""
http.Fetch( motd_url, function( body ) motd_html = body end)

function ScreenScaleZ( num )
	return (ScrH() / 480) * num
end

surface.CreateFont( "CSVGUI_Logo", {
	font = "Counter-Strike Logo",
	size = ScreenScaleZ( 32 ),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )
surface.CreateFont( "CSVGUI_1", {
	font = "Arial Narrow",
	size = ScreenScaleZ( 16 ),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = false,
} )
surface.CreateFont( "CSVGUI_2", {
	font = "Tahoma",
	size = ScreenScaleZ( 8 ),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )
surface.CreateFont( "CSVGUI_2_Bold", {
	font = "Verdana",
	size = 12,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = false,
} )
surface.CreateFont( "CSVGUI_2_Underline", {
	font = "Verdana",
	size = ScreenScaleZ( 8 ),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = true,
} )
surface.CreateFont( "CSVGUI_2_Small", {
	font = "Verdana",
	size = 12,
	weight = 0,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )
surface.CreateFont( "CSVGUI_2_VerySmall", {
	font = "Verdana",
	size = ScreenScaleZ( 6 ),
	weight = 0,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )
surface.CreateFont( "CSVGUI_3", {
	font = "Arial",
	size = 17,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )
surface.CreateFont( "OldPrintMessage_Font", {
	font = "Verdana",
	size = 13,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = false,
} )
surface.CreateFont( "CSVGUI_4", {
	font = "Verdana",
	size = 12,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )
surface.CreateFont( "CSDeathnotice", {
	font = "Verdana",
	size = 12,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = false,
} )
surface.CreateFont( "TestHUD", {
	font = "System",
	size = ScreenScaleZ( 20 ),
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )



local PANEL = {}
function PANEL:Init()
	self.entered = false

	self:SetTall( ScreenScaleZ( 20 ) )
	self:SetTextColor( MAIN_SCHEMA.COLOR )
	self:SetFont( "CSVGUI_2_Bold" )
	self:SetText("")
	self.text = ""
	self.mode = false
end
function PANEL:SetText2( text )
	self.text = text
end
function PANEL:OnCursorEntered()
	self.entered = true
end
function PANEL:OnCursorExited()
	self.entered = false
end
function PANEL:Paint( w, h )
	local bg_color = self.entered and MAIN_SCHEMA.ButtonBGLight or MAIN_SCHEMA.ButtonBG
	local border_color = self.entered and MAIN_SCHEMA.ButtonBorderLight or MAIN_SCHEMA.ButtonBorder
	local canAfford = true
	
	if self.class then
		if CS_BUY_INFO[self.class] then
			if CS_BUY_INFO[self.class].price then
				if LocalPlayer():GetMoney() < tonumber( CS_BUY_INFO[self.class].price ) then
					canAfford = false
				end
			end
		end
	end

	local affordColor = canAfford and self:GetTextColor() or MAIN_SCHEMA.COLOR_DARK2

	surface.SetDrawColor( bg_color )
	surface.DrawRect( 0, 0, w, h )

	surface.SetDrawColor( border_color )
	surface.DrawOutlinedRect( 0, 0, w, h )

	surface.SetDrawColor( MAIN_SCHEMA.ButtonBorder2 )
	surface.DrawOutlinedRect( 3, 3, w  - 6, h - 6 )
	
	surface.SetFont( self:GetFont() )
	local w_text, h_text = surface.GetTextSize( self.text )
	surface.SetTextColor( affordColor )
	if !self.mode then
		surface.SetTextPos( w / 2 - w_text / 2, h / 2 - h_text / 2 )
	else
		surface.SetTextPos( 5, h / 2 - h_text / 2 )
	end
	surface.DrawText( self.text )
end
vgui.Register( "CStrike_Button", PANEL, "DButton" )


local PANEL = {}
function PANEL:Init()
	cstrike_vgui_motd = self
	self:SetSize( ScreenScaleZ( 600 ), ScreenScaleZ( 440 ) )
	self:Center()

	self.cTitle = self:Add("DLabel")
	self.cTitle:SetText("")
	self.cTitle:SetTextColor( MAIN_SCHEMA.COLOR )
	self.cTitle:SetFont("CSVGUI_1")
	self.Frame = self:Add("Panel")
	self.cPanel = nil
end
function PANEL:SetTitle( text )
	self.cTitle:SetText( text )
end
function PANEL:Paint( w, h )
	draw.RoundedBoxEx( 16, 0, 0, w, ScreenScaleZ( 52 ), MAIN_SCHEMA.BG, true, true, false, false )
	draw.RoundedBoxEx( 16, 0, ScreenScaleZ( 52 ) + ScreenScaleZ( 1 ), w, h - ScreenScaleZ( 52 ) - ScreenScaleZ( 1 ), MAIN_SCHEMA.BG, false, false, true, true )

	surface.SetFont("CSVGUI_Logo")
	surface.SetTextPos( ScreenScaleZ( 16 ), ScreenScaleZ( 9 ) )
	surface.SetTextColor( MAIN_SCHEMA.COLOR )
	surface.DrawText("-")
end
function PANEL:OpenPanel( panelname )
	if IsValid( self.cPanel ) then self.cPanel:Remove() end
	self.cPanel = vgui.Create( panelname, self.Frame )
	self.cPanel:Dock( FILL )
	self.cPanel:PerformLayout()
end
function PANEL:PerformLayout()
	if IsValid( self.cTitle ) then
		self.cTitle:Dock( TOP )
		self.cTitle:DockMargin( ScreenScaleZ( 57 ), ScreenScaleZ( 13.5 ), 0, ScreenScaleZ( 21 ) )
		self.cTitle:SizeToContents()
	end
	if IsValid( self.Frame ) then
		self.Frame:Dock( FILL )
	end
end
function PANEL:OnKeyCodePressed( key )
	if IsValid( self.cPanel ) then
		if self.cPanel.OnKeyCodePressed then
			self.cPanel:OnKeyCodePressed( key )
		end
	end
end
vgui.Register( "CStrike_Main", PANEL, "EditablePanel" )


local PANEL = {}
function PANEL:Init()
	self:GetParent():GetParent():SetTitle("Counter-Strike 1.6: Source")

	self.HTML = self:Add("HTML")
	self.HTML:SetHTML( motd_html )
	self.HTML:Dock( FILL )

	self.pnl = self:Add("Panel")
	self.pnl:SetTall( ScreenScaleZ( 20 ) )
	self.pnl:Dock( BOTTOM )
	self.pnl:DockMargin( 0, ScreenScaleZ( 10 ), 0, 0 )

	self.OK = self.pnl:Add("CStrike_Button")
	self.OK:SetText2("OK")
	self.OK:SetWide( ScreenScaleZ( 125 ) )
	self.OK.DoClick = function()
		RunConsoleCommand("jointeam")
	end
end
function PANEL:Paint( w, h )
end
function PANEL:PerformLayout()
	self:DockMargin( ScreenScaleZ( 56 ), ScreenScaleZ( 45 ), ScreenScaleZ( 54 ), ScreenScaleZ( 64 + 8 ) )
end

vgui.Register( "CStrike_MOTD", PANEL, "EditablePanel" )

local PANEL = {}
function PANEL:Init()
	self:GetParent():GetParent():SetTitle("SELECT TEAM")

	self.TForces = self:Add("CStrike_Button")
	self.TForces:SetText2("1 TERRORIST FORCES")
	self.TForces:SetWide( ScreenScaleZ( 150 ) )
	self.TForces.mode = true
	self.TForces.DoClick = function()
		RunConsoleCommand("jointeam", 2 )
		cstrike_vgui_motd:Remove()
	end
	self.СTForces = self:Add("CStrike_Button")
	self.СTForces:SetText2("2 CT FORCES")
	self.СTForces:SetPos( 0, ScreenScaleZ( 20 ) + 20 )
	self.СTForces:SetWide( ScreenScaleZ( 150 ) )
	self.СTForces.mode = true
	self.СTForces.DoClick = function()
		RunConsoleCommand("jointeam", 3 )
		cstrike_vgui_motd:Remove()
	end
	self.Auto = self:Add("CStrike_Button")
	self.Auto:SetText2("3 AUTO ASSIGN")
	self.Auto:SetPos( 0, ScreenScaleZ( 20 ) * 4 + 20 )
	self.Auto:SetWide( ScreenScaleZ( 150 ) )
	self.Auto.mode = true
	self.Auto.DoClick = function()
		RunConsoleCommand("jointeam", TEAM_UNASSIGNED )
		cstrike_vgui_motd:Remove()
	end
	self.Spec = self:Add("CStrike_Button")
	self.Spec:SetText2("4 SPECTATE")
	self.Spec:SetPos( 0, ScreenScaleZ( 20 ) * 5 + 20 * 2 )
	self.Spec:SetWide( ScreenScaleZ( 150 ) )
	self.Spec.mode = true
	self.Spec.DoClick = function()
		RunConsoleCommand("jointeam", 1 )
		cstrike_vgui_motd:Remove()
	end

	if LocalPlayer():GetState() == STATE_ACTIVE then
		self.CloseB = self:Add("CStrike_Button")
		self.CloseB:SetText2("5 CANCEL")
		self.CloseB:SetPos( 0, ScreenScaleZ( 20 ) * 6 + 20 * 4 )
		self.CloseB:SetWide( ScreenScaleZ( 150 ) )
		self.CloseB.mode = true
		self.CloseB.DoClick = function()
			cstrike_vgui_motd:Remove()
		end
	end

	self.Slots = {
		[KEY_1] = self.TForces,
		[KEY_2] = self.СTForces,
		[KEY_3] = self.Auto,
		[KEY_4] = self.Spec,
	}
	if self.CloseB then
		self.Slots[KEY_5] = self.CloseB
	end
end
function PANEL:OnKeyCodePressed( keyCode )
	if self.Slots[ keyCode ] then
		self.Slots[ keyCode ].DoClick()
	else
		self.Slots[ KEY_1 ].DoClick()
	end
end
function PANEL:Paint( w, h )
end
function PANEL:PerformLayout()
	self:DockMargin( ScreenScaleZ( 56 ), ScreenScaleZ( 45 ), ScreenScaleZ( 54 ), ScreenScaleZ( 64 + 8 ) )
end

vgui.Register( "CStrike_Teampick", PANEL, "EditablePanel" )


local PANEL = {}
local function OnCursorEntered( self, imgPanel, descPanel )
	self.entered = true
	if self.class then
		if CS_CLASSES[3][self.class] then
			if imgPanel then
				imgPanel.Picture = Material( CS_CLASSES[2][self.class].img )
			end
			if descPanel then
				descPanel:SetText( CS_CLASSES[2][self.class].desc )
			end
		end
	end
end
function PANEL:Init()
	self:GetParent():GetParent():SetTitle("CHOOSE A CLASS")

	local ZPos = 0
	local ButtonWide = ScreenScaleZ( 150 )

	self.Class1 = self:Add("CStrike_Button")
	self.Class1:SetText2("1 PHOENIX CONNEXION")
	self.Class1:SetWide( ButtonWide )
	self.Class1.mode = true
	self.Class1.class = 1
	self.Class1.DoClick = function()
		RunConsoleCommand("joinclass", 1 )
		cstrike_vgui_motd:Remove()
	end

	ZPos = ZPos + ScreenScaleZ( 20 ) + 20

	self.Class2 = self:Add("CStrike_Button")
	self.Class2:SetText2("2 ELITE CREW")
	self.Class2:SetPos( 0, ZPos )
	self.Class2:SetWide( ButtonWide )
	self.Class2.mode = true
	self.Class2.class = 2
	self.Class2.DoClick = function()
		RunConsoleCommand("joinclass", 2 )
		cstrike_vgui_motd:Remove()
	end

	ZPos = ZPos + ScreenScaleZ( 20 ) + 20

	self.Class3 = self:Add("CStrike_Button")
	self.Class3:SetText2("3 ARCTIC AVENGERS")
	self.Class3:SetPos( 0, ZPos )
	self.Class3:SetWide( ButtonWide )
	self.Class3.mode = true
	self.Class3.class = 3
	self.Class3.DoClick = function()
		RunConsoleCommand("joinclass", 3 )
		cstrike_vgui_motd:Remove()
	end

	ZPos = ZPos + ScreenScaleZ( 20 ) + 20

	self.Class4 = self:Add("CStrike_Button")
	self.Class4:SetText2("4 GUERILLA WARFARE")
	self.Class4:SetPos( 0, ZPos )
	self.Class4:SetWide( ButtonWide )
	self.Class4.mode = true
	self.Class4.class = 4
	self.Class4.DoClick = function()
		RunConsoleCommand("joinclass", 4 )
		cstrike_vgui_motd:Remove()
	end

	ZPos = ZPos + ScreenScaleZ( 20 ) + 20
	ZPos = ZPos + ScreenScaleZ( 20 ) + 20

	self.Class5 = self:Add("CStrike_Button")
	self.Class5:SetText2("5 AUTO-SELECT")
	self.Class5:SetPos( 0, ZPos )
	self.Class5:SetWide( ButtonWide )
	self.Class5.mode = true
	self.Class5.class = 5
	self.Class5.DoClick = function()
		RunConsoleCommand("joinclass", 5 )
		cstrike_vgui_motd:Remove()
	end

	self.Slots = {
		[KEY_1] = self.Class1,
		[KEY_2] = self.Class2,
		[KEY_3] = self.Class3,
		[KEY_4] = self.Class4,
		[KEY_5] = self.Class5
	}

	local w = ScreenScaleZ( 256 + 32 + 10 ) 
	local h = ScreenScaleZ( 128 + 64 )

	self.ImagePanel = self:Add("Panel")
	self.ImagePanel:SetPos( ButtonWide + ScreenScaleZ( 20 ), 0 )
	self.ImagePanel:SetSize( w, h )
	self.ImagePanel.Picture = Material( CS_CLASSES[2][1].img )
	self.ImagePanel.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
		surface.DrawRect( 0, 0, w, h )

		if self.Picture then
			surface.SetMaterial( self.Picture )
			surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
			surface.DrawTexturedRect( 0, 0, ScreenScaleZ( 256 ), h )
		end

		surface.SetDrawColor( MAIN_SCHEMA.ButtonBorder )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	self.Desc = self:Add("DLabel")
	self.Desc:SetAutoStretchVertical( true )
	self.Desc:SetWrap( true )
	self.Desc:SetText( CS_CLASSES[2][1].desc )
	self.Desc:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Desc:SetFont("CSVGUI_2_Small")
	self.Desc:SetWide( 256 + 32 )
	self.Desc:SetPos( ButtonWide + ScreenScaleZ( 20 ), 0 )
	self.Desc:MoveBelow( self.ImagePanel, ScreenScaleZ( 32 ) )

	self.Class1.OnCursorEntered = function( button )
		OnCursorEntered( button, self.ImagePanel, self.Desc )
	end
	self.Class2.OnCursorEntered = function( button )
		OnCursorEntered( button, self.ImagePanel, self.Desc )
	end
	self.Class3.OnCursorEntered = function( button )
		OnCursorEntered( button, self.ImagePanel, self.Desc )
	end
	self.Class4.OnCursorEntered = function( button )
		OnCursorEntered( button, self.ImagePanel, self.Desc )
	end
	self.Class5.OnCursorEntered = function( button )
		OnCursorEntered( button, self.ImagePanel, self.Desc )
	end
end
function PANEL:OnKeyCodePressed( keyCode )
	if keyCode then
		if self.Slots[ keyCode ] then
			self.Slots[ keyCode ].DoClick()
			return
		end
		if keyCode == KEY_ENTER or keyCode == KEY_SPACE then
			self.Slots[KEY_1].DoClick()
			return
		end
	end
end
function PANEL:Paint( w, h ) end
function PANEL:PerformLayout()
	self:DockMargin( ScreenScaleZ( 56 ), ScreenScaleZ( 45 ), ScreenScaleZ( 54 ), ScreenScaleZ( 64 + 8 ) )
end

vgui.Register( "CStrike_ClassT", PANEL, "EditablePanel" )

local PANEL = {}
local function OnCursorEntered( self, imgPanel, descPanel )
	self.entered = true
	if self.class then
		if CS_CLASSES[3][self.class] then
			if imgPanel then
				imgPanel.Picture = Material( CS_CLASSES[3][self.class].img )
			end
			if descPanel then
				descPanel:SetText( CS_CLASSES[3][self.class].desc )
			end
		end
	end
end
function PANEL:Init()
	self:GetParent():GetParent():SetTitle("CHOOSE A CLASS")

	local ZPos = 0
	local ButtonWide = ScreenScaleZ( 150 )

	self.Class1 = self:Add("CStrike_Button")
	self.Class1:SetText2("1 SEAL TEAM 6")
	self.Class1:SetWide( ButtonWide )
	self.Class1.mode = true
	self.Class1.class = 1
	self.Class1.DoClick = function()
		RunConsoleCommand("joinclass", 1 )
		cstrike_vgui_motd:Remove()
	end

	ZPos = ZPos + ScreenScaleZ( 20 ) + 20

	self.Class2 = self:Add("CStrike_Button")
	self.Class2:SetText2("2 GSG-9")
	self.Class2:SetPos( 0, ZPos )
	self.Class2:SetWide( ButtonWide )
	self.Class2.mode = true
	self.Class2.class = 2
	self.Class2.DoClick = function()
		RunConsoleCommand("joinclass", 2 )
		cstrike_vgui_motd:Remove()
	end

	ZPos = ZPos + ScreenScaleZ( 20 ) + 20

	self.Class3 = self:Add("CStrike_Button")
	self.Class3:SetText2("3 SAS")
	self.Class3:SetPos( 0, ZPos )
	self.Class3:SetWide( ButtonWide )
	self.Class3.mode = true
	self.Class3.class = 3
	self.Class3.DoClick = function()
		RunConsoleCommand("joinclass", 3 )
		cstrike_vgui_motd:Remove()
	end

	ZPos = ZPos + ScreenScaleZ( 20 ) + 20

	self.Class4 = self:Add("CStrike_Button")
	self.Class4:SetText2("4 GIGN")
	self.Class4:SetPos( 0, ZPos )
	self.Class4:SetWide( ButtonWide )
	self.Class4.mode = true
	self.Class4.class = 4
	self.Class4.DoClick = function()
		RunConsoleCommand("joinclass", 4 )
		cstrike_vgui_motd:Remove()
	end

	ZPos = ZPos + ScreenScaleZ( 20 ) + 20
	ZPos = ZPos + ScreenScaleZ( 20 ) + 20

	self.Class5 = self:Add("CStrike_Button")
	self.Class5:SetText2("5 AUTO-SELECT")
	self.Class5:SetPos( 0, ZPos )
	self.Class5:SetWide( ButtonWide )
	self.Class5.mode = true
	self.Class5.class = 5
	self.Class5.DoClick = function()
		RunConsoleCommand("joinclass", 5 )
		cstrike_vgui_motd:Remove()
	end

	self.Slots = {
		[KEY_1] = self.Class1,
		[KEY_2] = self.Class2,
		[KEY_3] = self.Class3,
		[KEY_4] = self.Class4,
		[KEY_5] = self.Class5
	}

	local w = ScreenScaleZ( 256 + 32 + 10 ) 
	local h = ScreenScaleZ( 128 + 64 )

	self.ImagePanel = self:Add("Panel")
	self.ImagePanel:SetPos( ButtonWide + ScreenScaleZ( 20 ), 0 )
	self.ImagePanel:SetSize( w, h )
	self.ImagePanel.Picture = Material( CS_CLASSES[3][1].img )
	self.ImagePanel.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
		surface.DrawRect( 0, 0, w, h )

		if self.Picture then
			surface.SetMaterial( self.Picture )
			surface.SetDrawColor( Color( 255, 255, 255 ) )
			surface.DrawTexturedRect( 0, 0, ScreenScaleZ( 256 ), h )
		end

		surface.SetDrawColor( MAIN_SCHEMA.ButtonBorder )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	self.Desc = self:Add("DLabel")
	self.Desc:SetAutoStretchVertical( true )
	self.Desc:SetWrap( true )
	self.Desc:SetText( CS_CLASSES[3][1].desc )
	self.Desc:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Desc:SetFont("CSVGUI_2_Small")
	self.Desc:SetWide( 256 + 32 )
	self.Desc:SetPos( ButtonWide + ScreenScaleZ( 20 ), 0 )
	self.Desc:MoveBelow( self.ImagePanel, ScreenScaleZ( 32 ) )

	self.Class1.OnCursorEntered = function( button )
		OnCursorEntered( button, self.ImagePanel, self.Desc )
	end
	self.Class2.OnCursorEntered = function( button )
		OnCursorEntered( button, self.ImagePanel, self.Desc )
	end
	self.Class3.OnCursorEntered = function( button )
		OnCursorEntered( button, self.ImagePanel, self.Desc )
	end
	self.Class4.OnCursorEntered = function( button )
		OnCursorEntered( button, self.ImagePanel, self.Desc )
	end
	self.Class5.OnCursorEntered = function( button )
		OnCursorEntered( button, self.ImagePanel, self.Desc )
	end
end
function PANEL:OnKeyCodePressed( keyCode )
	if keyCode then
		if self.Slots[ keyCode ] then
			self.Slots[ keyCode ].DoClick()
			return
		end
		if keyCode == KEY_ENTER or keyCode == KEY_SPACE then
			self.Slots[KEY_1].DoClick()
			return
		end
	end
end
function PANEL:Paint( w, h ) end
function PANEL:PerformLayout()
	self:DockMargin( ScreenScaleZ( 56 ), ScreenScaleZ( 45 ), ScreenScaleZ( 54 ), ScreenScaleZ( 64 + 8 ) )
end

vgui.Register( "CStrike_ClassCT", PANEL, "EditablePanel" )

local PANEL = {}
function PANEL:Init()
	self:GetParent():GetParent():SetTitle("Buy Menu")

	self.pnl = self:Add("Panel")
	self.pnl:SetWide( ScreenScaleZ( 160 ) )
	self.pnl:Dock( LEFT )
	self.pnl:DockMargin( 0, ScreenScaleZ( 25 ), 0, 0 )
	self.pnl.Paint = function( self, w, h )
		surface.SetDrawColor( MAIN_SCHEMA.ButtonBGLight )
		surface.DrawLine( w - 1, 0, w - 1, h )
	end

	self.pnl2 = self:Add("Panel")
	self.pnl2:SetWide( ScreenScaleZ( 160 ) )
	self.pnl2:Dock( LEFT )
	self.pnl2:DockMargin( ScreenScaleZ( 15 ), ScreenScaleZ( 25 ), 0, 0 )

	self.Pistol = self.pnl:Add("CStrike_Button")
	self.Pistol:SetText2("1 PISTOLS")
	self.Pistol.mode = true
	self.Pistol:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.Pistol:Dock( TOP )
	self.Pistol:DockMargin( 0, 0, ScreenScaleZ( 15 ), ScreenScaleZ( 13 ) )
	self.Pistol.DoClick = function()
		BuyMenuPistol()
	end
	self.Shotgun = self.pnl:Add("CStrike_Button")
	self.Shotgun:SetText2("2 SHOTGUNS")
	self.Shotgun.mode = true
	self.Shotgun:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.Shotgun:Dock( TOP )
	self.Shotgun:DockMargin( 0, 0, ScreenScaleZ( 15 ), ScreenScaleZ( 13 ) )
	self.Shotgun.DoClick = function()
		BuyMenuShotguns()
	end
	self.SMG = self.pnl:Add("CStrike_Button")
	self.SMG:SetText2("3 SMG")
	self.SMG.mode = true
	self.SMG:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.SMG:Dock( TOP )
	self.SMG:DockMargin( 0, 0, ScreenScaleZ( 15 ), ScreenScaleZ( 13 ) )
	self.SMG.DoClick = function()
		BuyMenuSMG()
	end
	self.Rifles = self.pnl:Add("CStrike_Button")
	self.Rifles:SetText2("4 RIFLES")
	self.Rifles.mode = true
	self.Rifles:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.Rifles:Dock( TOP )
	self.Rifles:DockMargin( 0, 0, ScreenScaleZ( 15 ), ScreenScaleZ( 13 ) )
	self.Rifles.DoClick = function()
		BuyMenuRifles()
	end
	self.Mguns = self.pnl:Add("CStrike_Button")
	self.Mguns:SetText2("5 MACHINE GUNS")
	self.Mguns.mode = true
	self.Mguns:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.Mguns:Dock( TOP )
	self.Mguns:DockMargin( 0, 0, ScreenScaleZ( 15 ), ScreenScaleZ( 13 ) )
	self.Mguns.DoClick = function()
		BuyMenuMachineGuns()
	end
	self.PrimaryAmmo = self.pnl:Add("CStrike_Button")
	self.PrimaryAmmo:SetText2("6 PRIMARY AMMO")
	self.PrimaryAmmo.mode = true
	self.PrimaryAmmo:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.PrimaryAmmo:Dock( TOP )
	self.PrimaryAmmo:DockMargin( 0, 0, ScreenScaleZ( 15 ), ScreenScaleZ( 13 ) )
	self.PrimaryAmmo.DoClick = function()
		RunConsoleCommand("primammo")
		cstrike_vgui_motd:Remove()
		cstrike_vgui_motd = nil
	end
	self.SecondaryAmmo = self.pnl:Add("CStrike_Button")
	self.SecondaryAmmo:SetText2("7 SECONDARY AMMO")
	self.SecondaryAmmo.mode = true
	self.SecondaryAmmo:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.SecondaryAmmo:Dock( TOP )
	self.SecondaryAmmo:DockMargin( 0, 0, ScreenScaleZ( 15 ), ScreenScaleZ( 13 ) )
	self.SecondaryAmmo.DoClick = function()
		RunConsoleCommand("secammo")
		cstrike_vgui_motd:Remove()
		cstrike_vgui_motd = nil
	end
	self.Equip = self.pnl:Add("CStrike_Button")
	self.Equip:SetText2("8 EQUIPMENT")
	self.Equip.mode = true
	self.Equip:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.Equip:Dock( TOP )
	self.Equip:DockMargin( 0, 0, ScreenScaleZ( 15 ), ScreenScaleZ( 21 ) )
	self.Equip.DoClick = function()
		BuyMenuEquipment()
	end
	self.Cancel = self.pnl:Add("CStrike_Button")
	self.Cancel:SetText2("0 CANCEL")
	self.Cancel.mode = true
	self.Cancel:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.Cancel:Dock( BOTTOM )
	self.Cancel:DockMargin( 0, 0, ScreenScaleZ( 15 ), 0 )
	self.Cancel.DoClick = function()
		cstrike_vgui_motd:Remove()
		cstrike_vgui_motd = nil
	end

	self.AutoBuy = self.pnl2:Add("CStrike_Button")
	self.AutoBuy:SetText2("A AUTO-BUY")
	self.AutoBuy.mode = true
	self.AutoBuy:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.AutoBuy:Dock( TOP )
	self.AutoBuy:DockMargin( 0, 0, 0, ScreenScaleZ( 13 ) )
	self.AutoBuy.DoClick = function()
		RunConsoleCommand("autobuy")
	end
	self.ReBuy = self.pnl2:Add("CStrike_Button")
	self.ReBuy:SetText2("R RE-BUY PREVIOUS")
	self.ReBuy.mode = true
	self.ReBuy:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.ReBuy:Dock( TOP )
	self.ReBuy:DockMargin( 0, 0, 0, ScreenScaleZ( 13 ) )
	self.ReBuy.DoClick = function()
		RunConsoleCommand("rebuy")
	end

	self.Slots = {
		[KEY_1] = self.Pistol,
		[KEY_2] = self.Shotgun,
		[KEY_3] = self.SMG,
		[KEY_4] = self.Rifles,
		[KEY_5] = self.Mguns,
		[KEY_6] = self.PrimaryAmmo,
		[KEY_7] = self.SecondaryAmmo,
		[KEY_8] = self.Equip,
		[KEY_0] = self.Cancel,
		[KEY_A] = self.AutoBuy,
		[KEY_R] = self.ReBuy
	}
end
function PANEL:OnKeyCodePressed( keyCode )
	if keyCode then
		if self.Slots[ keyCode ] then
			self.Slots[ keyCode ].DoClick()
			return
		end
		if keyCode == KEY_ENTER then
			self.Slots[KEY_0].DoClick()
			return
		end
	end
end
function PANEL:Paint( w, h )
	surface.SetFont( "CSVGUI_2_Bold" )
	surface.SetTextColor( MAIN_SCHEMA.COLOR )
	surface.SetTextPos( 12.5, 5 )
	surface.DrawText( "SHOP BY CATEGORY" )
end
function PANEL:PerformLayout()
	self:DockMargin( ScreenScaleZ( 56 ), ScreenScaleZ( 20 ), ScreenScaleZ( 54 ), ScreenScaleZ( 60 ) )
end

vgui.Register( "CStrike_Buymenu", PANEL, "EditablePanel" )


local PANEL = {}
local function OnCursorEntered( self, parent )
	local canAfford = true
	
	if self.class then
		if CS_BUY_INFO[self.class] then
			if CS_BUY_INFO[self.class].price then
				if LocalPlayer():GetMoney() < tonumber( CS_BUY_INFO[self.class].price ) then
					canAfford = false
				end
			end
		end
	end

	self.entered = canAfford
	if self.class then
		if CS_BUY_INFO[self.class] then
			local price = CS_BUY_INFO[self.class].price
			local country = CS_BUY_INFO[self.class].country
			local caliber = CS_BUY_INFO[self.class].caliber
			local clip = CS_BUY_INFO[self.class].clip
			local rof = CS_BUY_INFO[self.class].rof
			local weight = CS_BUY_INFO[self.class].weight
			local pweight = CS_BUY_INFO[self.class].pweight
			local muzzlevel = CS_BUY_INFO[self.class].muzzlevel
			local muzzleenergy = CS_BUY_INFO[self.class].muzzleenergy

			parent.ImagePanel:SetVisible( true )
			parent.ImagePanel.Picture = Material( CS_BUY_INFO[self.class].img )
			parent.Info1:SetText( "PRICE" )
			parent.Info2:SetText( "COUNTRY OF ORIGIN" )
			parent.Info3:SetText( "CALIBER" )
			parent.Info4:SetText( "CLIP CAPACITY" )
			parent.Info5:SetText( "RATE OF FIRE" )
			if CS_BUY_INFO[self.class].weightloaded then
				parent.Info6:SetText( "WEIGHT (LOADED)" )
			else
				parent.Info6:SetText( "WEIGHT (EMPTY)" )
			end
			parent.Info7:SetText( "PROJECTILE WEIGHT" )
			parent.Info8:SetText( "MUZZLE VELOCITY" )
			parent.Info9:SetText( "MUZZLE ENERGY" )

			parent.Price:SetText( ": $" .. price )
			parent.Origin:SetText( ": " .. country )
			parent.Caliber:SetText( ": " .. caliber )
			parent.ClipCap:SetText( ": " .. clip .. " ROUNDS")
			parent.ROF:SetText( ": " .. rof )
			parent.Weight:SetText( ": " .. weight .. "KG")
			parent.PWeight:SetText( ": " .. pweight .. " GRAMS")
			parent.MuzzleVel:SetText( ": " .. muzzlevel .. " FEET/SECOND")
			parent.MuzzleEnergy:SetText( ": " .. muzzleenergy .. " JOULES")

			parent.Info1:SizeToContents()
			parent.Info2:SizeToContents()
			parent.Info3:SizeToContents()
			parent.Info4:SizeToContents()
			parent.Info5:SizeToContents()
			parent.Info6:SizeToContents()
			parent.Info7:SizeToContents()
			parent.Info8:SizeToContents()
			parent.Info9:SizeToContents()
			parent.Price:SizeToContents()
			parent.Origin:SizeToContents()
			parent.Caliber:SizeToContents()
			parent.ClipCap:SizeToContents()
			parent.ROF:SizeToContents()
			parent.Weight:SizeToContents()
			parent.PWeight:SizeToContents()
			parent.MuzzleVel:SizeToContents()
			parent.MuzzleEnergy:SizeToContents()
		end
	else
		parent.ImagePanel:SetVisible( false )
		parent.Info1:SetText( "" )
		parent.Info2:SetText( "" )
		parent.Info3:SetText( "" )
		parent.Info4:SetText( "" )
		parent.Info5:SetText( "" )
		parent.Info6:SetText( "" )
		parent.Info7:SetText( "" )
		parent.Info8:SetText( "" )
		parent.Info9:SetText( "" )
		
		parent.Price:SetText( "" )
		parent.Origin:SetText( "" )
		parent.Caliber:SetText( "" )
		parent.ClipCap:SetText( "" )
		parent.ROF:SetText( "" )
		parent.Weight:SetText( "" )
		parent.PWeight:SetText( "" )
		parent.MuzzleVel:SetText( "" )
		parent.MuzzleEnergy:SetText( "" )
	end
end
function PANEL:Init()
	self.pnl = self:Add("Panel")
	self.pnl:SetWide( ScreenScaleZ( 160 ) )
	self.pnl:Dock( LEFT )
	self.pnl:DockMargin( 0, ScreenScaleZ( 25 ), 0, 0 )

	self.pnl2 = self:Add("Panel")
	self.pnl2:SetWide( ScreenScaleZ( 299.73 ) )
	self.pnl2:Dock( LEFT )
	self.pnl2:DockMargin( ScreenScaleZ( 8 ), ScreenScaleZ( 25 ), 0, 0 )

	self.Buttons = {}

	self.Cancel = self.pnl:Add("CStrike_Button")
	self.Cancel:SetText2("0 CANCEL")
	self.Cancel.mode = true
	self.Cancel:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.Cancel:Dock( BOTTOM )
	self.Cancel:DockMargin( 0, 0, ScreenScaleZ( 15 ), 0 )
	self.Cancel.DoClick = function()
		cstrike_vgui_motd:Remove()
		cstrike_vgui_motd = nil
	end
	self.Cancel.OnCursorEntered = function( par )
		OnCursorEntered( par, self )
	end

	self.ImagePanel = self.pnl2:Add("Panel")
	self.ImagePanel:Dock( TOP )
	self.ImagePanel:SetTall( ScreenScaleZ( 128 ) )
	self.ImagePanel.Picture = nil
	self.ImagePanel:SetVisible( false )
	self.ImagePanel.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
		surface.DrawRect( 0, 0, w, h )

		local imgH = h
		if self:GetParent():GetParent().Type == 1 then
			imgH = ScreenScaleZ( 64 )
		end
		if self.Picture then
			surface.SetMaterial( self.Picture )
			surface.SetDrawColor( Color( 255, 255, 255 ) )
			surface.DrawTexturedRect( 0, ScreenScaleZ( 8 ), ScreenScaleZ( 256 ), imgH )
		end

		surface.SetDrawColor( MAIN_SCHEMA.ButtonBorder )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end


	self.labelPanel = self.pnl2:Add("Panel")
	self.labelPanel:SetWide( ScreenScaleZ( 138.6 ) )
	self.labelPanel:Dock( LEFT )
	self.labelPanel:DockMargin( 0, 0, 0, 0 )

	local offset = 2
	self.Info1 = self.labelPanel:Add("DLabel")
	self.Info1:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Info1:SetFont( "CSVGUI_2_Bold" )
	self.Info1:SizeToContents()
	self.Info1:Dock( TOP )
	self.Info1:DockMargin( 0, offset, 0, 0 )
	self.Info2 = self.labelPanel:Add("DLabel")
	self.Info2:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Info2:SetFont( "CSVGUI_2_Bold" )
	self.Info2:SizeToContents()
	self.Info2:Dock( TOP )
	self.Info2:DockMargin( 0, offset, 0, 0 )
	self.Info3 = self.labelPanel:Add("DLabel")
	self.Info3:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Info3:SetFont( "CSVGUI_2_Bold" )
	self.Info3:SizeToContents()
	self.Info3:Dock( TOP )
	self.Info3:DockMargin( 0, offset, 0, 0 )
	self.Info4 = self.labelPanel:Add("DLabel")
	self.Info4:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Info4:SetFont( "CSVGUI_2_Bold" )
	self.Info4:SizeToContents()
	self.Info4:Dock( TOP )
	self.Info4:DockMargin( 0, offset, 0, 0 )
	self.Info5 = self.labelPanel:Add("DLabel")
	self.Info5:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Info5:SetFont( "CSVGUI_2_Bold" )
	self.Info5:SizeToContents()
	self.Info5:Dock( TOP )
	self.Info5:DockMargin( 0, offset, 0, 0 )
	self.Info6 = self.labelPanel:Add("DLabel")
	self.Info6:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Info6:SetFont( "CSVGUI_2_Bold" )
	self.Info6:SizeToContents()
	self.Info6:Dock( TOP )
	self.Info6:DockMargin( 0, offset, 0, 0 )
	self.Info7 = self.labelPanel:Add("DLabel")
	self.Info7:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Info7:SetFont( "CSVGUI_2_Bold" )
	self.Info7:SizeToContents()
	self.Info7:Dock( TOP )
	self.Info7:DockMargin( 0, offset, 0, 0 )
	self.Info8 = self.labelPanel:Add("DLabel")
	self.Info8:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Info8:SetFont( "CSVGUI_2_Bold" )
	self.Info8:SizeToContents()
	self.Info8:Dock( TOP )
	self.Info8:DockMargin( 0, offset, 0, 0 )
	self.Info9 = self.labelPanel:Add("DLabel")
	self.Info9:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Info9:SetFont( "CSVGUI_2_Bold" )
	self.Info9:SizeToContents()
	self.Info9:Dock( TOP )
	self.Info9:DockMargin( 0, offset, 0, 0 )

	self.valuePanel = self.pnl2:Add("Panel")
	self.valuePanel:SetWide( ScreenScaleZ( 138.6 ) )
	self.valuePanel:Dock( LEFT )
	self.valuePanel:DockMargin( 0, 0, 0, 0 )
	self.Price = self.valuePanel:Add("DLabel")
	self.Price:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Price:SetFont( "CSVGUI_2_Bold" )
	self.Price:SizeToContents()
	self.Price:Dock( TOP )
	self.Price:DockMargin( 0, offset, 0, 0 )
	self.Origin = self.valuePanel:Add("DLabel")
	self.Origin:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Origin:SetFont( "CSVGUI_2_Bold" )
	self.Origin:SizeToContents()
	self.Origin:Dock( TOP )
	self.Origin:DockMargin( 0, offset, 0, 0 )
	self.Caliber = self.valuePanel:Add("DLabel")
	self.Caliber:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Caliber:SetFont( "CSVGUI_2_Bold" )
	self.Caliber:SizeToContents()
	self.Caliber:Dock( TOP )
	self.Caliber:DockMargin( 0, offset, 0, 0 )
	self.ClipCap = self.valuePanel:Add("DLabel")
	self.ClipCap:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.ClipCap:SetFont( "CSVGUI_2_Bold" )
	self.ClipCap:SizeToContents()
	self.ClipCap:Dock( TOP )
	self.ClipCap:DockMargin( 0, offset, 0, 0 )
	self.ROF = self.valuePanel:Add("DLabel")
	self.ROF:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.ROF:SetFont( "CSVGUI_2_Bold" )
	self.ROF:SizeToContents()
	self.ROF:Dock( TOP )
	self.ROF:DockMargin( 0, offset, 0, 0 )
	self.Weight = self.valuePanel:Add("DLabel")
	self.Weight:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Weight:SetFont( "CSVGUI_2_Bold" )
	self.Weight:SizeToContents()
	self.Weight:Dock( TOP )
	self.Weight:DockMargin( 0, offset, 0, 0 )
	self.PWeight = self.valuePanel:Add("DLabel")
	self.PWeight:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.PWeight:SetFont( "CSVGUI_2_Bold" )
	self.PWeight:SizeToContents()
	self.PWeight:Dock( TOP )
	self.PWeight:DockMargin( 0, offset, 0, 0 )
	self.MuzzleVel = self.valuePanel:Add("DLabel")
	self.MuzzleVel:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.MuzzleVel:SetFont( "CSVGUI_2_Bold" )
	self.MuzzleVel:SizeToContents()
	self.MuzzleVel:Dock( TOP )
	self.MuzzleVel:DockMargin( 0, offset, 0, 0 )
	self.MuzzleEnergy = self.valuePanel:Add("DLabel")
	self.MuzzleEnergy:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.MuzzleEnergy:SetFont( "CSVGUI_2_Bold" )
	self.MuzzleEnergy:SizeToContents()
	self.MuzzleEnergy:Dock( TOP )
	self.MuzzleEnergy:DockMargin( 0, offset, 0, 0 )

	self.Info1:SetText( "" )
	self.Info2:SetText( "" )
	self.Info3:SetText( "" )
	self.Info4:SetText( "" )
	self.Info5:SetText( "" )
	self.Info6:SetText( "" )
	self.Info7:SetText( "" )
	self.Info8:SetText( "" )
	self.Info9:SetText( "" )
	
	self.Price:SetText( "" )
	self.Origin:SetText( "" )
	self.Caliber:SetText( "" )
	self.ClipCap:SetText( "" )
	self.ROF:SetText( "" )
	self.Weight:SetText( "" )
	self.PWeight:SetText( "" )
	self.MuzzleVel:SetText( "" )
	self.MuzzleEnergy:SetText( "" )

	self.Slots = {
		[KEY_0] = self.Cancel,
	}
end
function PANEL:AddBuyButton( key, title, class, doClick )
	local buy = self.pnl:Add("CStrike_Button")
	buy:SetText2( title )
	buy.mode = true
	buy.class = class
	buy:SetWide( ScreenScaleZ( 164 - 18 ) )
	buy:Dock( TOP )
	buy:DockMargin( 0, 0, ScreenScaleZ( 15 ), ScreenScaleZ( 13 ) )
	buy.DoClick = function( _ ) 
		doClick( _ )
		cstrike_vgui_motd:Remove() 
		cstrike_vgui_motd = nil 
	end
	buy.OnCursorEntered = function( par )
		OnCursorEntered( par, self )
	end
	self.Slots[key] = buy
	self.Buttons[#self.Buttons + 1] = buy
end
function PANEL:OnKeyCodePressed( keyCode )
	if keyCode then
		if self.Slots[ keyCode ] then
			self.Slots[ keyCode ].DoClick()
			return
		end
		if keyCode == KEY_ENTER then
			self.Slots[KEY_0].DoClick()
			return
		end
	end
end
function PANEL:Paint( w, h ) end
function PANEL:PerformLayout()
	self:DockMargin( ScreenScaleZ( 56 ), ScreenScaleZ( 20 ), ScreenScaleZ( 54 ), ScreenScaleZ( 60 ) )

	if self.Type == 1 then
		if self.ImagePanel:GetTall() != ScreenScaleZ( 80 ) then
			self.ImagePanel:SetTall( ScreenScaleZ( 80 ) )
		end
	end
end

vgui.Register( "CStrike_Buycategory", PANEL, "EditablePanel" )


local PANEL = {}
local function OnCursorEntered( self, parent )
	local canAfford = true
	
	if self.class then
		if CS_BUY_INFO[self.class] then
			if CS_BUY_INFO[self.class].price then
				if LocalPlayer():GetMoney() < tonumber( CS_BUY_INFO[self.class].price ) then
					canAfford = false
				end
			end
		end
	end
	
	self.entered = canAfford
	if self.class then
		if CS_BUY_INFO[self.class] then
			local price = CS_BUY_INFO[self.class].price
			local desc = CS_BUY_INFO[self.class].desc

			parent.ImagePanel:SetVisible( true )
			parent.ImagePanel.Picture = Material( CS_BUY_INFO[self.class].img )
			parent.Info1:SetText( "PRICE" )
			parent.Info2:SetText( "DESCRIPTION" )

			parent.Price:SetText( ": $" .. price )
			parent.Desc:SetText( ": " .. desc )

			parent.Info1:SizeToContents()
			parent.Info2:SizeToContents()
			parent.Price:SizeToContents()
		end
	else
		parent.ImagePanel:SetVisible( false )
		parent.Info1:SetText( "" )
		parent.Info2:SetText( "" )
		
		parent.Price:SetText( "" )
		parent.Desc:SetText( "" )
	end
end
function PANEL:Init()
	self.pnl = self:Add("Panel")
	self.pnl:SetWide( ScreenScaleZ( 160 ) )
	self.pnl:Dock( LEFT )
	self.pnl:DockMargin( 0, ScreenScaleZ( 25 ), 0, 0 )

	self.pnl2 = self:Add("Panel")
	self.pnl2:SetWide( ScreenScaleZ( 299.73 ) )
	self.pnl2:Dock( LEFT )
	self.pnl2:DockMargin( ScreenScaleZ( 8 ), ScreenScaleZ( 25 ), 0, 0 )

	self.Buttons = {}

	self.Cancel = self.pnl:Add("CStrike_Button")
	self.Cancel:SetText2("0 CANCEL")
	self.Cancel.mode = true
	self.Cancel:SetWide( ScreenScaleZ( 164 - 18 ) )
	self.Cancel:Dock( BOTTOM )
	self.Cancel:DockMargin( 0, 0, ScreenScaleZ( 15 ), 0 )
	self.Cancel.DoClick = function()
		cstrike_vgui_motd:Remove()
		cstrike_vgui_motd = nil
	end
	self.Cancel.OnCursorEntered = function( par )
		OnCursorEntered( par, self )
	end

	self.ImagePanel = self.pnl2:Add("Panel")
	self.ImagePanel:Dock( TOP )
	self.ImagePanel:SetTall( ScreenScaleZ( 128 ) )
	self.ImagePanel.Picture = nil
	self.ImagePanel:SetVisible( false )
	self.ImagePanel.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
		surface.DrawRect( 0, 0, w, h )

		if self.Picture then
			surface.SetMaterial( self.Picture )
			surface.SetDrawColor( Color( 255, 255, 255 ) )
			surface.DrawTexturedRect( 0, 0, ScreenScaleZ( 256 ), h )
		end

		surface.SetDrawColor( MAIN_SCHEMA.ButtonBorder )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end


	self.labelPanel = self.pnl2:Add("Panel")
	self.labelPanel:SetWide( ScreenScaleZ( 138.6 ) )
	self.labelPanel:Dock( LEFT )
	self.labelPanel:DockMargin( 0, 0, 0, 0 )

	local offset = ScreenScaleZ( 6 )
	self.Info1 = self.labelPanel:Add("DLabel")
	self.Info1:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Info1:SetFont( "CSVGUI_2_Bold" )
	self.Info1:SizeToContents()
	self.Info1:Dock( TOP )
	self.Info1:DockMargin( 0, offset, 0, 0 )
	self.Info2 = self.labelPanel:Add("DLabel")
	self.Info2:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Info2:SetFont( "CSVGUI_2_Bold" )
	self.Info2:SizeToContents()
	self.Info2:Dock( TOP )
	self.Info2:DockMargin( 0, offset, 0, 0 )

	self.valuePanel = self.pnl2:Add("Panel")
	self.valuePanel:SetWide( ScreenScaleZ( 138.6 ) )
	self.valuePanel:Dock( LEFT )
	self.valuePanel:DockMargin( 0, 0, 0, 0 )
	self.Price = self.valuePanel:Add("DLabel")
	self.Price:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Price:SetFont( "CSVGUI_2_Bold" )
	self.Price:SizeToContents()
	self.Price:Dock( TOP )
	self.Price:DockMargin( 0, offset, 0, 0 )
	self.Desc = self.valuePanel:Add("DLabel")
	self.Desc:SetAutoStretchVertical( true )
	self.Desc:SetWrap( true )
	self.Desc:SetTextColor( MAIN_SCHEMA.COLOR_DARK )
	self.Desc:SetFont( "CSVGUI_2_Bold" )
	self.Desc:Dock( TOP )
	self.Desc:DockMargin( 0, offset, 0, 0 )

	self.Info1:SetText( "" )
	self.Info2:SetText( "" )

	self.Price:SetText( "" )
	self.Desc:SetText( "" )

	self.Slots = {
		[KEY_0] = self.Cancel,
	}
end
function PANEL:AddBuyButton( key, title, class, doClick )
	local buy = self.pnl:Add("CStrike_Button")
	buy:SetText2( title )
	buy.mode = true
	buy.class = class
	buy:SetWide( ScreenScaleZ( 164 - 18 ) )
	buy:Dock( TOP )
	buy:DockMargin( 0, 0, ScreenScaleZ( 15 ), ScreenScaleZ( 13 ) )
	buy.DoClick = function( _ ) 
		doClick( _ )
		cstrike_vgui_motd:Remove() 
		cstrike_vgui_motd = nil 
	end
	buy.OnCursorEntered = function( par )
		OnCursorEntered( par, self )
	end
	self.Slots[key] = buy
	self.Buttons[#self.Buttons + 1] = buy
end
function PANEL:OnKeyCodePressed( keyCode )
	if keyCode then
		if self.Slots[ keyCode ] then
			self.Slots[ keyCode ].DoClick()
			return
		end
		if keyCode == KEY_ENTER then
			self.Slots[KEY_0].DoClick()
			return
		end
	end
end
function PANEL:Paint( w, h ) end
function PANEL:PerformLayout()
	self:DockMargin( ScreenScaleZ( 56 ), ScreenScaleZ( 20 ), ScreenScaleZ( 54 ), ScreenScaleZ( 60 ) )

	if self.Type == 1 then
		if self.ImagePanel:GetTall() != ScreenScaleZ( 80 ) then
			self.ImagePanel:SetTall( ScreenScaleZ( 80 ) )
		end
	end
end

vgui.Register( "CStrike_BuycategoryEquipment", PANEL, "EditablePanel" )

local rendertarget_radiomenu = GetRenderTarget( "RadioMenu", ScreenScaleZ( 256 ), ScreenScaleZ( 256 ) )
local radiomenu_mat = CreateMaterial( "_RadioMenuMat", "UnlitGeneric", {
    ["$vertexcolor"] = 1,
    ["$vertexalpha"] = 1,
    ["$additive"] = 1,
} )

local PANEL = {}
function PANEL:Init()
	cstrike_vgui_radiomenu = self
	self:SetPos( 20, 0 )
	self:SetSize( ScreenScaleZ( 512 ), ScreenScaleZ( 256 ) )

	self.Height = 0
	self.Buttons = {}
end
function PANEL:AddButton( text, bind, onclick, color )
	local tbl = {
		text = text,
		onclick = onclick,
		color = color,
		bind = bind,
	}
	table.insert( self.Buttons, tbl )
end
function PANEL:Paint( w, h )
	render.PushRenderTarget( rendertarget_radiomenu )
		render.Clear( 0, 0, 0, 255 )
		cam.Start2D()
		    surface.SetFont("CSVGUI_3")
			local w_text, h_text = surface.GetTextSize("B")
			self.Height = 0
			for k, v in pairs( self.Buttons ) do
				if v.color then
					surface.SetTextColor( v.color )
				else
					surface.SetTextColor( Color( 255, 255, 255 ) )
				end
				surface.SetTextPos( h_text, h_text / 2 + self.Height )
				surface.DrawText( v.text )
				self.Height = self.Height + h_text + 5
			end
		cam.End2D()
	render.PopRenderTarget()

	radiomenu_mat:SetTexture( "$basetexture", rendertarget_radiomenu )
    surface.SetMaterial( radiomenu_mat )
	surface.SetDrawColor( Color( 255, 255, 255 ) )
	surface.DrawTexturedRect( 20, 0, ScreenScaleZ( 256 ), ScreenScaleZ( 256 ) )
end
function PANEL:PerformLayout()
	surface.SetFont("CSVGUI_3")
	local w_text, h_text = surface.GetTextSize("B") 
	self:SetPos( 0, ScrH() / 2 - ((h_text + 5) * #self.Buttons) / 2 )
end
function PANEL:CallMenu( slot )
	if slot then
		for k, v in pairs( self.Buttons ) do
			if v.bind and v.bind == slot then
				if v.onclick then
					v.onclick()
					return
				end
			end
		end

		self:Close()
		return
	end
end
function PANEL:Close()
	self:Remove()
	cstrike_vgui_radiomenu = nil
end
vgui.Register( "CStrike_Radiomenu", PANEL, "EditablePanel" )

function OpenRadiomenu1()
	if !LocalPlayer():Alive() then return end
	if cstrike_vgui_radiomenu then 
		cstrike_vgui_radiomenu:Remove()
		cstrike_vgui_radiomenu = nil
	end
	vgui.Create("CStrike_Radiomenu")
	cstrike_vgui_radiomenu:AddButton( "Radio Commands", nil, function() end, Color( 255, 255, 0 ) )
	cstrike_vgui_radiomenu:AddButton( "" )
	cstrike_vgui_radiomenu:AddButton( "1. \"Cover Me\"", 1, function() RunConsoleCommand("coverme") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "2. \"You Take the Point\"", 2, function() RunConsoleCommand("takepoint") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "3. \"Hold This Position\"", 3, function() RunConsoleCommand("holdpos") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "4. \"Regroup Team\"", 4, function() RunConsoleCommand("regroup") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "5. \"Follow Me\"", 5, function() RunConsoleCommand("followme") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "6. \"Taking Fire, Need Assistance\"", 6, function() RunConsoleCommand("takingfire") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "7. \"V moskvu nado ehat\"", 7, function() RunConsoleCommand("moscow") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "" )
	cstrike_vgui_radiomenu:AddButton( "0. \"Exit\"", 0, function() cstrike_vgui_radiomenu:Remove() end )
end
function OpenRadiomenu2()
	if !LocalPlayer():Alive() then return end
	if cstrike_vgui_radiomenu then 
		cstrike_vgui_radiomenu:Remove()
		cstrike_vgui_radiomenu = nil
	end
	vgui.Create("CStrike_Radiomenu")
	cstrike_vgui_radiomenu:AddButton( "Group Radio Commands", nil, function() end, Color( 255, 255, 0 ) )
	cstrike_vgui_radiomenu:AddButton( "" )
	cstrike_vgui_radiomenu:AddButton( "1. \"Go\"", 1, function() RunConsoleCommand("go") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "2. \"Fall Back\"", 2, function() RunConsoleCommand("fallback") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "3. \"Stick Together Team\"", 3, function() RunConsoleCommand("sticktog") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "4. \"Get in Position\"", 4, function() RunConsoleCommand("getinpos") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "5. \"Storm the Front\"", 5, function() RunConsoleCommand("stormfront") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "6. \"Report In\"", 6, function() RunConsoleCommand("report") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "7. \"Hvatit Orat\"", 7, function() RunConsoleCommand("orat") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "" )
	cstrike_vgui_radiomenu:AddButton( "0. \"Exit\"", 0, function() cstrike_vgui_radiomenu:Remove() end )
end
function OpenRadiomenu3()
	if !LocalPlayer():Alive() then return end
	if cstrike_vgui_radiomenu then 
		cstrike_vgui_radiomenu:Remove()
		cstrike_vgui_radiomenu = nil
	end
	vgui.Create("CStrike_Radiomenu")
	cstrike_vgui_radiomenu:AddButton( "Radio Responses/Reports", nil, function() end, Color( 255, 255, 0 ) )
	cstrike_vgui_radiomenu:AddButton( "" )
	cstrike_vgui_radiomenu:AddButton( "1. \"Affirmative/Roger\"", 1, function() RunConsoleCommand("roger") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "2. \"Enemy Spotted\"", 2, function() RunConsoleCommand("enemyspot") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "3. \"Need Backup\"", 3, function() RunConsoleCommand("needbackup") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "4. \"Sector Clear\"", 4, function() RunConsoleCommand("sectorclear") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "5. \"I'm in Position\"", 5, function() RunConsoleCommand("inposition") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "6. \"Reporting In\"", 6, function() RunConsoleCommand("reportingin") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "7. \"She's gonna Blow!\"", 7, function() RunConsoleCommand("getout") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "8. \"Negative\"", 8, function() RunConsoleCommand("negative") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "9. \"Enemy Down\"", 9, function() RunConsoleCommand("enemydown") cstrike_vgui_radiomenu:Close() end )
	cstrike_vgui_radiomenu:AddButton( "" )
	cstrike_vgui_radiomenu:AddButton( "0. \"Exit\"", 0, function() cstrike_vgui_radiomenu:Remove() end )
end

concommand.Add( "radio1", function() OpenRadiomenu1() end )
concommand.Add( "radio2", function() OpenRadiomenu2() end )
concommand.Add( "radio3", function() OpenRadiomenu3() end )

function BuyMenuPistol()
	if cstrike_vgui_motd then 
		cstrike_vgui_motd:Remove() 
		cstrike_vgui_motd = nil 
	end
	cstrike_vgui_motd = vgui.Create("CStrike_Main")
	cstrike_vgui_motd:OpenPanel("CStrike_Buycategory")
	cstrike_vgui_motd:SetTitle("BUY PISTOLS (SECONDARY WEAPON)")
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_1, "1 9X19MM SIDEARM", "glock18", function() RunConsoleCommand("glock18") end )
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_2, "2 KM .45 TACTICAL", "usp", function() RunConsoleCommand("usp") end )
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_3, "3 228 COMPACT", "p228", function() RunConsoleCommand("p228") end )
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_4, "4 NIGHT HAWK .50C", "deagle", function() RunConsoleCommand("deagle") end )
	if LocalPlayer():Team() == TEAM_T then
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_5, "5 .40 DUAL ELITES", "elites", function() RunConsoleCommand("elites") end )
	else
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_5, "5 ES FIVE-SEVEN", "fiveseven", function() RunConsoleCommand("fiveseven") end )
	end
	cstrike_vgui_motd:MakePopup()
end

function BuyMenuShotguns()
	if cstrike_vgui_motd then 
		cstrike_vgui_motd:Remove() 
		cstrike_vgui_motd = nil 
	end
	cstrike_vgui_motd = vgui.Create("CStrike_Main")
	cstrike_vgui_motd:OpenPanel("CStrike_Buycategory")
	cstrike_vgui_motd.cPanel.Type = 1
	cstrike_vgui_motd:SetTitle("BUY SHOTGUNS (PRIMARY WEAPON)")
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_1, "1 LEONE 12 GAUGE SUPER", "m3", function() RunConsoleCommand("m3") end )
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_2, "2 LEONE YG1265 AUTO SHOTGUN", "xm1014", function() RunConsoleCommand("xm1014") end )
	cstrike_vgui_motd:MakePopup()
end

function BuyMenuSMG()
	if cstrike_vgui_motd then 
		cstrike_vgui_motd:Remove() 
		cstrike_vgui_motd = nil 
	end
	cstrike_vgui_motd = vgui.Create("CStrike_Main")
	cstrike_vgui_motd:OpenPanel("CStrike_Buycategory")
	cstrike_vgui_motd:SetTitle("BUY SUBMACHINE GUNS (PRIMARY WEAPON)")
	if LocalPlayer():Team() == TEAM_T then
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_1, "1 INGRAM MAC-10", "mac10", function() RunConsoleCommand("mac10") end )
	else
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_1, "1 SCHMIDT MACHINE PISTOL", "tmp", function() RunConsoleCommand("tmp") end )
	end
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_2, "2 KM SUB-MACHINE GUN", "mp5", function() RunConsoleCommand("mp5") end )
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_3, "3 KM UMP45", "ump45", function() RunConsoleCommand("ump45") end )
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_4, "4 ES C90", "p90", function() RunConsoleCommand("p90") end )
	cstrike_vgui_motd:MakePopup()
end

function BuyMenuRifles()
	if cstrike_vgui_motd then 
		cstrike_vgui_motd:Remove() 
		cstrike_vgui_motd = nil 
	end
	cstrike_vgui_motd = vgui.Create("CStrike_Main")
	cstrike_vgui_motd:OpenPanel("CStrike_Buycategory")
	cstrike_vgui_motd.cPanel.Type = 1
	cstrike_vgui_motd:SetTitle("BUY RIFLES (PRIMARY WEAPON)")
	if LocalPlayer():Team() == TEAM_T then
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_1, "1 IDF DEFENDER", "galil", function() RunConsoleCommand("galil") end )
	else
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_1, "1 CLARION 5.56", "famas", function() RunConsoleCommand("famas") end )
	end
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_2, "2 SCHMIDT SCOUT", "scout", function() RunConsoleCommand("scout") end )
	if LocalPlayer():Team() == TEAM_T then
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_3, "3 CV-47", "ak47", function() RunConsoleCommand("ak47") end )
	else
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_3, "3 MAVERICK M4A1 CARBINE", "m4a1", function() RunConsoleCommand("m4a1") end )
	end
	if LocalPlayer():Team() == TEAM_T then
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_4, "4 KRIEG 552", "sg552", function() RunConsoleCommand("sg552") end )
	else
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_4, "4 BULLPUP", "aug", function() RunConsoleCommand("aug") end )
	end
	if LocalPlayer():Team() == TEAM_T then
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_5, "5 MAGNUM SNIPER RIFLE", "awp", function() RunConsoleCommand("awp") end )
	else
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_5, "5 KRIEG 550 COMMANDO", "sg550", function() RunConsoleCommand("sg550") end )
	end
	if LocalPlayer():Team() == TEAM_T then
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_6, "6 D3/AU-1", "g3sg1", function() RunConsoleCommand("g3sg1") end )
	else
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_6, "6 MAGNUM SNIPER RIFLE", "awp", function() RunConsoleCommand("awp") end )
	end
	cstrike_vgui_motd:MakePopup()
end

function BuyMenuMachineGuns()
	if cstrike_vgui_motd then 
		cstrike_vgui_motd:Remove() 
		cstrike_vgui_motd = nil 
	end
	cstrike_vgui_motd = vgui.Create("CStrike_Main")
	cstrike_vgui_motd:OpenPanel("CStrike_Buycategory")
	cstrike_vgui_motd:SetTitle("BUY MACHINE GUNS (PRIMARY WEAPON)")
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_1, "1 M249", "m249", function() RunConsoleCommand("m249") end )
	cstrike_vgui_motd:MakePopup()
end

function BuyMenuEquipment()
	if cstrike_vgui_motd then 
		cstrike_vgui_motd:Remove() 
		cstrike_vgui_motd = nil 
	end
	cstrike_vgui_motd = vgui.Create("CStrike_Main")
	cstrike_vgui_motd:OpenPanel("CStrike_BuycategoryEquipment")
	cstrike_vgui_motd:SetTitle("BUY EQUIPMENT")
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_1, "1 KEVLAR", "kevlar", function() RunConsoleCommand("kevlar") end )
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_2, "2 KEVLAR+HELMET", "kevlarhelmet", function() RunConsoleCommand("kevlarhelmet") end )
	cstrike_vgui_motd.cPanel:AddBuyButton( KEY_4, "4 HE GRENADE", "hegrenade", function() RunConsoleCommand("hegrenade") end )
	if LocalPlayer():Team() == TEAM_CT and GetGlobalBool( "m_bMapHasBombTarget") then
		cstrike_vgui_motd.cPanel:AddBuyButton( KEY_5, "5 DEFUSAL KIT", "defusekit", function() RunConsoleCommand("defusekit") end )
	end
	if LocalPlayer():Team() == TEAM_CT then
		if GetGlobalBool( "m_bMapHasBombTarget") then
			cstrike_vgui_motd.cPanel:AddBuyButton( KEY_6, "6 TACTICAL SHIELD", "shield", function() RunConsoleCommand("shield") end )
		else
			cstrike_vgui_motd.cPanel:AddBuyButton( KEY_5, "5 TACTICAL SHIELD", "shield", function() RunConsoleCommand("shield") end )
		end
	end
	cstrike_vgui_motd:MakePopup()
end
