BUY_BOUGHT = 1
BUY_ALREADY_HAVE = 2
BUY_CANT_AFFORD = 3
BUY_PLAYER_CANT_BUY = 4
BUY_NOT_ALLOWED = 5
BUY_INVALID_ITEM = 6

AUTOBUYCLASS_PRIMARY = 1
AUTOBUYCLASS_SECONDARY = 2
AUTOBUYCLASS_AMMO = 4
AUTOBUYCLASS_ARMOR = 8
AUTOBUYCLASS_DEFUSER = 16
AUTOBUYCLASS_PISTOL = 32
AUTOBUYCLASS_SMG = 64
AUTOBUYCLASS_RIFLE = 128
AUTOBUYCLASS_SNIPERRIFLE = 256
AUTOBUYCLASS_SHOTGUN = 512
AUTOBUYCLASS_MACHINEGUN = 1024
AUTOBUYCLASS_GRENADE = 2048
AUTOBUYCLASS_NIGHTVISION = 4096
AUTOBUYCLASS_SHIELD = 8192

g_autoBuyInfo = {
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_RIFLE ),
		m_command = "galil",
		m_classname = CS16_WEAPON_GALIL
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_RIFLE ),
		m_command = "ak47",
		m_classname = CS16_WEAPON_AK47
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_SNIPERRIFLE ),
		m_command = "scout",
		m_classname = CS16_WEAPON_SCOUT
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_RIFLE ),
		m_command = "sg552",
		m_classname = CS16_WEAPON_SG552
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_SNIPERRIFLE ),
		m_command = "awp",
		m_classname = CS16_WEAPON_AWP
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_SNIPERRIFLE ),
		m_command = "g3sg1",
		m_classname = CS16_WEAPON_G3SG1
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_RIFLE ),
		m_command = "famas",
		m_classname = CS16_WEAPON_FAMAS
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_RIFLE ),
		m_command = "m4a1",
		m_classname = CS16_WEAPON_M4A1
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_RIFLE ),
		m_command = "aug",
		m_classname = CS16_WEAPON_AUG
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_SNIPERRIFLE ),
		m_command = "sg550",
		m_classname = CS16_WEAPON_SG550
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_SECONDARY, AUTOBUYCLASS_PISTOL ),
		m_command = "glock18",
		m_classname = CS16_WEAPON_GLOCK18
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_SECONDARY, AUTOBUYCLASS_PISTOL ),
		m_command = "usp",
		m_classname = CS16_WEAPON_USP
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_SECONDARY, AUTOBUYCLASS_PISTOL ),
		m_command = "p228",
		m_classname = CS16_WEAPON_P228
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_SECONDARY, AUTOBUYCLASS_PISTOL ),
		m_command = "deagle",
		m_classname = CS16_WEAPON_DEAGLE
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_SECONDARY, AUTOBUYCLASS_PISTOL ),
		m_command = "elites",
		m_classname = CS16_WEAPON_ELITE
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_SECONDARY, AUTOBUYCLASS_PISTOL ),
		m_command = "fiveseven",
		m_classname = CS16_WEAPON_FIVESEVEN
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_SHOTGUN ),
		m_command = "m3",
		m_classname = CS16_WEAPON_M3
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_SHOTGUN ),
		m_command = "xm1014",
		m_classname = CS16_WEAPON_XM1014
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_SMG ),
		m_command = "mac10",
		m_classname = CS16_WEAPON_MAC10
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_SMG ),
		m_command = "tmp",
		m_classname = CS16_WEAPON_TMP
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_SMG ),
		m_command = "mp5",
		m_classname = CS16_WEAPON_MP5NAVY
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_SMG ),
		m_command = "ump45",
		m_classname = CS16_WEAPON_UMP45
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_SMG ),
		m_command = "p90",
		m_classname = CS16_WEAPON_P90
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_MACHINEGUN ),
		m_command = "m249",
		m_classname = CS16_WEAPON_M249
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_AMMO ),
		m_command = "primammo",
		m_classname = "primammo"
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_SECONDARY, AUTOBUYCLASS_AMMO ),
		m_command = "secammo",
		m_classname = "secammo"
	},
	{
		m_class = AUTOBUYCLASS_ARMOR,
		m_command = "kevlar",
		m_classname = "kevlar"
	},
	{
		m_class = AUTOBUYCLASS_ARMOR,
		m_command = "kevlarhelmet",
		m_classname = "kevlarhelmet"
	},
	{
		m_class = AUTOBUYCLASS_GRENADE,
		m_command = "hegrenade",
		m_classname = CS16_WEAPON_HEGRENADE
	},
	{
		m_class = AUTOBUYCLASS_DEFUSER,
		m_command = "defusekit",
		m_classname = "defusekit"
	},
	{
		m_class = bit.bor( AUTOBUYCLASS_PRIMARY, AUTOBUYCLASS_SHIELD ),
		m_command = "shield",
		m_classname = "shield"
	},
	{
		m_class = 0,
		m_command = "",
		m_classname = ""
	}
}
function GetAutoBuyCommandInfo( command )
	local i = 1
	local ret = nil
	local temp = g_autoBuyInfo[i]

	while (!ret and temp.m_class != 0) do
		temp = g_autoBuyInfo[i]
		i = i + 1

		if temp.m_command == command then
			ret = temp
		end
	end

	return ret
end

local meta = FindMetaTable( "Player" )
function meta:ShouldExecuteAutoBuyCommand( commandInfo, boughtPrimary, boughtSecondary)
	if !commandInfo then
		return false
	end

	if boughtPrimary and bit.band( commandInfo.m_class, AUTOBUYCLASS_PRIMARY ) != 0 and bit.band( commandInfo.m_class, AUTOBUYCLASS_AMMO ) == 0 then
		return false
	end

	if boughtSecondary and bit.band( commandInfo.m_class, AUTOBUYCLASS_SECONDARY ) != 0 and bit.band( commandInfo.m_class, AUTOBUYCLASS_AMMO ) == 0 then
		return false
	end

	if bit.band( commandInfo.m_class, AUTOBUYCLASS_ARMOR ) and self:Getm_iArmorValue() >= 100 then
		return false
	end

	return true
end

function meta:CombineBuyResults( prevResult, newResult )
	if newResult == BUY_BOUGHT then
		prevResult = BUY_BOUGHT
	elseif prevResult != BUY_BOUGHT and
		(newResult == BUY_CANT_AFFORD or newResult == BUY_INVALID_ITEM or newResult == BUY_PLAYER_CANT_BUY ) then
		prevResult = BUY_CANT_AFFORD
	end

	return prevResult
end

function meta:PostAutoBuyCommandProcessing( commandInfo, boughtPrimary, boughtSecondary)
	if !commandInfo then
		return
	end

	local pPrimary = self:Weapon_GetSlot( WEAPON_SLOT_RIFLE )
	local pSecondary = self:Weapon_GetSlot( WEAPON_SLOT_PISTOL )

	if pPrimary and pPrimary:GetClass() == commandInfo.m_classname then
		boughtPrimary = true
	elseif !pPrimary and bit.band( commandInfo.m_class, AUTOBUYCLASS_SHIELD ) == AUTOBUYCLASS_SHIELD and self:HasShield() then
		boughtPrimary = true
	elseif pSecondary and pSecondary:GetClass() == commandInfo.m_classname then
		boughtSecondary = true
	end

	return boughtPrimary, boughtSecondary
end

function meta:ParseAutoBuyString( string, boughtPrimary, boughtSecondary )
	local overallResult = BUY_ALREADY_HAVE;
	local tbl = string.Explode( " ", string )

	for k, command in pairs( tbl ) do
		local commandInfo = GetAutoBuyCommandInfo( command )
		if self:ShouldExecuteAutoBuyCommand( commandInfo, boughtPrimary, boughtSecondary ) then
			local result = HandleCommand_Buy( self, commandInfo.m_classname )
	
			overallResult = self:CombineBuyResults( overallResult, result )

			boughtPrimary, boughtSecondary = self:PostAutoBuyCommandProcessing( commandInfo, boughtPrimary, boughtSecondary )
		end
	end
end

function meta:AutoBuy()
	if !self:IsInBuyZone() then
		return
	end

	local autobuyString = self:GetInfo( "cl_cs16_autobuy" )
	if autobuyString == "" then
		return
	end

	local boughtPrimary = false
	local boughtSecondary = false

	self.m_bIsInAutoBuy = true
	self:ParseAutoBuyString( autobuyString, boughtPrimary, boughtSecondary )
	self.m_bIsInAutoBuy = false

	self.m_bAutoReload = true
end

function BuildRebuyStruct( ply )
end

function AttemptToBuyWeapon( ply, class )
	if !ply:Alive() then return BUY_PLAYER_CANT_BUY end
	if !ply:CanPlayerBuy( true ) then return BUY_PLAYER_CANT_BUY end
	if ply:HasWeapon( class ) then 
		ply:OldPrintMessage( "csl_Already_bought" )
		return BUY_ALREADY_HAVE
	end

	local bPurchase = false
	local weaponInfo = weapons.GetStored( class )

	if ply:GetMoney() >= weaponInfo.Price then
		if weaponInfo.Slot == WEAPON_SLOT_RIFLE then
			if ply:HasShield() then
				ply:DropShield()
			end
			ply:DropRifle()
		elseif weaponInfo.Slot == WEAPON_SLOT_PISTOL then
			ply:DropPistol()
		end
		bPurchase = true
	else
		if !ply.m_bIsInAutoBuy and !ply.m_bIsInRebuy then
			ply:OldPrintMessage( "csl_Not_Enough_Money" )
		end
	end

	if bPurchase then
		if bPurchase and weaponInfo.Slot == WEAPON_SLOT_PISTOL then
			ply.m_bUsingDefaultPistol = false
		end
		ply:Give( class )
		ply:AddMoney( -weaponInfo.Price )
		ply:SelectWeapon( class )

		timer.Simple( 0.1, function() // hax
			local m_hWeapon = ply:GetActiveWeapon()
			if IsValid( ply ) then
				m_hWeapon:Deploy()
				m_hWeapon:CallOnClient( "Deploy" )
			end
		end)

		return BUY_BOUGHT
	end
	return BUY_CANT_AFFORD
end

local function BuyGunAmmo( player, weapon, bBlinkMoney )
	local cost
	local give

	if !player:CanPlayerBuy( true ) then return BUY_PLAYER_CANT_BUY end

	local nAmmo = weapon.Primary.Ammo

	if nAmmo == -1 or player:GetAmmoCount( nAmmo ) >= game.GetAmmoMax( game.GetAmmoID( nAmmo ) ) then
		return BUY_ALREADY_HAVE
	end
	if CS16_AmmoBuyTable[nAmmo] then
		cost = CS16_AmmoBuyTable[nAmmo].price
		give = CS16_AmmoBuyTable[nAmmo].give
	else
		return BUY_INVALID_ITEM
	end

	local max = game.GetAmmoMax( game.GetAmmoID( nAmmo ) )
	local current = player:GetAmmoCount( nAmmo )
	if current + give > max then
		give = max - current
		give = math.Clamp( give, 0, CS16_AmmoBuyTable[nAmmo].give )
	end
	if player:GetMoney() >= cost then
		player:GiveAmmo( give, nAmmo, true )
		player:AddMoney( -cost )
		umsg.Start( "AmmoPickup" )
			umsg.Entity( player )
		umsg.End()

		return BUY_BOUGHT
	end

	if bBlinkMoney then
		player:OldPrintMessage( "csl_Not_Enough_Money" )
	end
	return BUY_CANT_AFFORD
end

function AttemptToBuyAmmo( player, slot )
	if !player:Alive() then return BUY_PLAYER_CANT_BUY end
	if !player:CanPlayerBuy( true ) or slot > WEAPON_SLOT_PISTOL then return BUY_PLAYER_CANT_BUY end
	local pWeapon = player:Weapon_GetSlot( slot )
	if !IsValid( pWeapon ) then return BUY_PLAYER_CANT_BUY end

	local result = BuyGunAmmo( player, pWeapon, true )
	if result == BUY_BOUGHT then
		while BuyGunAmmo( player, pWeapon, false ) == BUY_BOUGHT do
			
		end
	end
	return result
end

function AttemptToBuyGrenade( ply, class )
	if !ply:Alive() then return BUY_PLAYER_CANT_BUY end
	if !ply:CanPlayerBuy( true ) then return BUY_PLAYER_CANT_BUY end

	local bPurchase = false
	local weaponInfo = weapons.GetStored( class )

	if class == "wep_cs16_flashbang" then
		if ply:GetAmmoCount( weaponInfo.Primary.Ammo ) >= 2 then
			ply:OldPrintMessage( "csl_Cannot_Carry_Anymore" )
			return BUY_ALREADY_HAVE
		end
	else
		if ply:HasWeapon( class ) then 
			ply:OldPrintMessage( "csl_Cannot_Carry_Anymore" )
			return BUY_ALREADY_HAVE
		end
	end

	if ply:GetMoney() >= weaponInfo.Price then
		bPurchase = true
	else
		if !ply.m_bIsInAutoBuy and !ply.m_bIsInRebuy then
			ply:OldPrintMessage( "csl_Not_Enough_Money" )
		end
	end

	if bPurchase then
		ply:Give( class )
		ply:AddMoney( -weaponInfo.Price )
		return BUY_BOUGHT
	end
	return BUY_CANT_AFFORD
end

function AttemptToBuyVest( ply )
	if !ply:Alive() then return BUY_PLAYER_CANT_BUY end
	if !ply:CanPlayerBuy( true ) then return BUY_PLAYER_CANT_BUY end
	local bPurchase = false

	if ply:Getm_iArmorValue() >= 100 then
		if !ply.m_bIsInAutoBuy and !ply.m_bIsInRebuy then
			ply:OldPrintMessage( "csl_Already_Have_Kevlar" )
		end
		return BUY_ALREADY_HAVE
	end
	if ply:GetMoney() >= 650 then
		bPurchase = true
	else
		if !ply.m_bIsInAutoBuy and !ply.m_bIsInRebuy then
			ply:OldPrintMessage( "csl_Not_Enough_Money" )
		end
	end

	if bPurchase then
		if ply:Getm_bHasHelmet() then
			ply:OldPrintMessage( "csl_Already_Have_Helmet_Bought_Kevlar" )
		end
		ply:Setm_iArmorValue( 100 )

		umsg.Start( "Kevlar" )
			umsg.Entity( ply )
		umsg.End()
		ply:AddMoney( -650 )
		return BUY_BOUGHT
	end
	return BUY_CANT_AFFORD
end
function AttemptToBuyVestHelmet( ply )
	if !ply:Alive() then return BUY_PLAYER_CANT_BUY end
	if !ply:CanPlayerBuy( true ) then return BUY_PLAYER_CANT_BUY end
	local fullArmor = ply:Getm_iArmorValue() >= 100 and 1 or 0
	local price = 0
	local enoughMoney = 0

	if fullArmor == 1 and ply:Getm_bHasHelmet() then
		if !ply.m_bIsInAutoBuy and !ply.m_bIsInRebuy then
			ply:OldPrintMessage( "csl_Already_Have_Kevlar_Helmet" )
		end
		return BUY_ALREADY_HAVE
	elseif fullArmor == 1 and !ply:Getm_bHasHelmet() and ply:GetMoney() >= 350 then
		enoughMoney = 1
		price = 350
		if !ply.m_bIsInAutoBuy and !ply.m_bIsInRebuy then
			ply:OldPrintMessage( "csl_Already_Have_Kevlar_Bought_Helmet" )
		end
	elseif fullArmor == 0 and ply:Getm_bHasHelmet() and ply:GetMoney() >= 650 then
		enoughMoney = 1
		price = 650
		if !ply.m_bIsInAutoBuy and !ply.m_bIsInRebuy then
			ply:OldPrintMessage( "csl_Already_Have_Helmet_Bought_Kevlar" )
		end
	elseif ply:GetMoney() >= 1000 then
		enoughMoney = 1
		price = 1000
	end
	if enoughMoney == 0 then
		if !ply.m_bIsInAutoBuy and !ply.m_bIsInRebuy then
			ply:OldPrintMessage( "csl_Not_Enough_Money" )
		end
		return BUY_CANT_AFFORD
	else
		ply:Setm_bHasHelmet( true )
		ply:Setm_iArmorValue( 100 )

		umsg.Start( "Kevlar" )
			umsg.Entity( ply )
		umsg.End()
		ply:AddMoney( -price )
		return BUY_BOUGHT
	end
end
function AttemptToBuyDefusalKit( ply )
	if !ply:Alive() then return BUY_PLAYER_CANT_BUY end
	if !ply:CanPlayerBuy( true ) then return BUY_PLAYER_CANT_BUY end

	if ply:HasDefuser() then
		ply:OldPrintMessage( "csl_Already_Have_One" )
		return BUY_ALREADY_HAVE
	end
	
	if ply:GetMoney() < 200 then
		if !ply.m_bIsInAutoBuy and !ply.m_bIsInRebuy then
			ply:OldPrintMessage( "csl_Not_Enough_Money" )
		end
		return BUY_CANT_AFFORD
	else
		ply:Setm_bHasDefuser( true )

		umsg.Start( "Pickup" )
			umsg.Entity( ply )
		umsg.End()
		ply:AddMoney( -200 )
		return BUY_BOUGHT
	end
end
function AttemptToBuyShield( ply )
	if !ply:Alive() then return BUY_PLAYER_CANT_BUY end
	if !ply:CanPlayerBuy( true ) then return BUY_PLAYER_CANT_BUY end

	if ply:HasShield() then
		ply:OldPrintMessage( "csl_Already_Have_One" )
		return BUY_ALREADY_HAVE
	end
	
	if ply:GetMoney() < 2200 then
		if !ply.m_bIsInAutoBuy and !ply.m_bIsInRebuy then
			ply:OldPrintMessage( "csl_Not_Enough_Money" )
		end
		return BUY_CANT_AFFORD
	else
		if ply:HasSecondaryWeapon() then
			local pWeapon = ply:Weapon_GetSlot( WEAPON_SLOT_PISTOL )
			local weaponInfo = weapons.GetStored( pWeapon:GetClass() )

			if weaponInfo.m_bCanUseWithShield == false or pWeapon:GetClass() == CS16_WEAPON_ELITE then
				return
			end
		end

		if ply:HasPrimaryWeapon() then
			ply:DropRifle()
		end
		
		ply:GiveShield()

		umsg.Start( "Pickup" )
			umsg.Entity( ply )
		umsg.End()

		local m_hWeapon = ply:GetActiveWeapon()
		if IsValid( ply ) then
			m_hWeapon:Deploy()
			m_hWeapon:CallOnClient( "Deploy" )
		end

		ply:AddMoney( -2200 )
		return BUY_BOUGHT
	end
end

function HandleCommand_Buy( ply, class )
	local result = !ply:CanPlayerBuy( false ) and BUY_PLAYER_CANT_BUY or BUY_INVALID_ITEM

	local weaponInfo = weapons.GetStored( class )
	if !weaponInfo then
		if class == "primammo" then
			result = AttemptToBuyAmmo( ply, 0 )
		elseif class == "secammo" then
			result = AttemptToBuyAmmo( ply, 1 )
		elseif class == "defuser" and ply:Team() == TEAM_CT then
			return AttemptToBuyDefusalKit( ply )
		elseif class == "kevlar" then
			return AttemptToBuyVest( ply )
		elseif class == "kevlarhelmet" then
			return AttemptToBuyVestHelmet( ply )	
		elseif class == "shield" and ply:Team() == TEAM_CT then
			return AttemptToBuyShield( ply )
		end

		if result == BUY_BOUGHT then
			BuildRebuyStruct( ply )
		end
	
		return result
	else
		if !weaponInfo then
			return BUY_INVALID_ITEM
		end

		if !ply:CanPlayerBuy( true ) then
			return BUY_PLAYER_CANT_BUY
		end

		local bPurchase = false

		if weaponInfo.iTeam and weaponInfo.iTeam != ply:Team() then
			result = BUY_NOT_ALLOWED
		elseif weaponInfo.Price <= 0 then

		elseif weaponInfo.IsGrenade then
			bPurchase = true
			result = AttemptToBuyGrenade( ply, class )
			if result != BUY_BOUGHT then
				bPurchase = false
			end
		else
			bPurchase = true
			result = AttemptToBuyWeapon( ply, class )
			if result != BUY_BOUGHT then
				bPurchase = false
			end
			if bPurchase then
				BuildRebuyStruct( ply )
			end
			return result
		end
	end
	return result
end

concommand.Add( "glock18", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_GLOCK18 )
end )
concommand.Add( "usp", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_USP )
end )
concommand.Add( "deagle", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_DEAGLE )
end )
concommand.Add( "p228", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_P228 )
end )
concommand.Add( "elites", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_ELITE )
end )
concommand.Add( "fiveseven", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_FIVESEVEN )
end )
concommand.Add( "mac10", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_MAC10 )
end )
concommand.Add( "tmp", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_TMP )
end )
concommand.Add( "ump45", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_UMP45 )
end )
concommand.Add( "mp5", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_MP5NAVY )
end )
concommand.Add( "p90", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_P90 )
end )
concommand.Add( "m3", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_M3 )
end )
concommand.Add( "xm1014", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_XM1014 )
end )
concommand.Add( "galil", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_GALIL )
end )
concommand.Add( "famas", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_FAMAS )
end )
concommand.Add( "scout", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_SCOUT )
end )
concommand.Add( "ak47", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_AK47 )
end )
concommand.Add( "m4a1", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_M4A1 )
end )
concommand.Add( "sg552", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_SG552 )
end )
concommand.Add( "aug", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_AUG )
end )
concommand.Add( "g3sg1", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_G3SG1 )
end )
concommand.Add( "sg550", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_SG550 )
end )
concommand.Add( "awp", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_AWP )
end )
concommand.Add( "m249", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_M249 )
end )
concommand.Add( "primammo", function( ply, cmd, args )
	HandleCommand_Buy( ply, "primammo" )
end )
concommand.Add( "secammo", function( ply, cmd, args )
	HandleCommand_Buy( ply, "secammo" )
end )
concommand.Add( "kevlar", function( ply, cmd, args )
	HandleCommand_Buy( ply, "kevlar" )
end )
concommand.Add( "kevlarhelmet", function( ply, cmd, args )
	HandleCommand_Buy( ply, "kevlarhelmet")
end )
concommand.Add( "hegrenade", function( ply, cmd, args )
	HandleCommand_Buy( ply, CS16_WEAPON_HEGRENADE )
end )
concommand.Add( "defusekit", function( ply, cmd, args )
	HandleCommand_Buy( ply, "defuser" )
end )
concommand.Add( "shield", function( ply, cmd, args )
	HandleCommand_Buy( ply, "shield" )
end )
concommand.Add( "autobuy", function( ply, cmd, args )
	ply:AutoBuy()
end )