CUSTOM_KEYS = {}
CUSTOM_KEYS[KEY_F1] = { command = "autobuy" }
CUSTOM_KEYS[KEY_Z] = { command = "radio1" }
CUSTOM_KEYS[KEY_X] = { command = "radio2" }
CUSTOM_KEYS[KEY_C] = { command = "radio3" }
CUSTOM_KEYS[KEY_G] = { command = "cs16_drop" }
CUSTOM_KEYS[KEY_M] = { command = "jointeam" }
CUSTOM_KEYS[KEY_B] = { command = "buy" }

local last = {}
local chatboxOpened = false

function CheckCustomBinds()
	for k,v in pairs( CUSTOM_KEYS  ) do
		if !last[k] and input.IsKeyDown( k ) and !chatboxOpened and !gui.IsGameUIVisible() then
			RunConsoleCommand( v.command )
			last[k] = true
		end
		if !input.IsKeyDown( k ) and last[k] then
			last[k] = false
		end
	end
end

local function StartChat()
	chatboxOpened = true
end
local function FinishChat()
	chatboxOpened = false
end

hook.Add( "StartChat", "CustomBinds", StartChat )
hook.Add( "FinishChat", "CustomBinds", FinishChat )