if CLIENT then
	include("autorun/sh_wpnshared.lua")

	CreateClientConVar( "cl_cs16_dynamiccrosshair", "1", true, false )
	CreateClientConVar( "cl_cs16_crosshair_color", "50 250 50", true, false )
	CreateClientConVar( "cl_cs16_crosshair_size", "auto", true, false )
	CreateClientConVar( "cl_cs16_crosshair_translucent", "1", true, false )

	CS16_CrosshairParameters = {}
	CS16_CrosshairLimitSpeed = {}

	CS16_CrosshairParameters[CS16_WEAPON_P228] = { distance = 8, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_HEGRENADE] = { distance = 8, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_FIVESEVEN] = { distance = 8, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_USP] = { distance = 8, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_GLOCK18] = { distance = 8, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_AWP] = { distance = 8, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_FLASHBANG] = { distance = 8, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_DEAGLE] = { distance = 8, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_MP5NAVY] = { distance = 6, deltaDistance = 2 }
	CS16_CrosshairParameters[CS16_WEAPON_M3] = { distance = 8, deltaDistance = 6 }
	CS16_CrosshairParameters[CS16_WEAPON_G3SG1] = { distance = 6, deltaDistance = 4 }
	CS16_CrosshairParameters[CS16_WEAPON_AK47] = { distance = 4, deltaDistance = 4 }
	CS16_CrosshairParameters[CS16_WEAPON_TMP] = { distance = 7, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_KNIFE] = { distance = 7, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_P90] = { distance = 7, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_XM1014] = { distance = 9, deltaDistance = 4 }
	CS16_CrosshairParameters[CS16_WEAPON_MAC10] = { distance = 9, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_AUG] = { distance = 3, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_C4] = { distance = 6, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_UMP45] = { distance = 7, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_M249] = { distance = 7, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_SCOUT] = { distance = 5, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_SG550] = { distance = 5, deltaDistance = 3 }
	CS16_CrosshairParameters[CS16_WEAPON_SG552] = { distance = 5, deltaDistance = 3 }
	CS16_CrosshairParameters["_default"] = { distance = 4, deltaDistance = 3 }

	CS16_CrosshairLimitSpeed[CS16_WEAPON_MAC10] = 140
	CS16_CrosshairLimitSpeed[CS16_WEAPON_SG550] = 140
	CS16_CrosshairLimitSpeed[CS16_WEAPON_GALIL] = 140
	CS16_CrosshairLimitSpeed[CS16_WEAPON_MP5NAVY] = 140
	CS16_CrosshairLimitSpeed[CS16_WEAPON_M3] = 140
	CS16_CrosshairLimitSpeed[CS16_WEAPON_DEAGLE] = 140
	CS16_CrosshairLimitSpeed[CS16_WEAPON_SG552] = 140
	CS16_CrosshairLimitSpeed[CS16_WEAPON_KNIFE] = 170

	local function GetWeaponAccuracyFlags( weapon )
		if weapon:GetClass() == CS16_WEAPON_USP then
			if weapon:GetSilenced() then
				return 15
			else
				return 7
			end
		elseif weapon:GetClass() == CS16_WEAPON_GLOCK18 then
			if weapon:GetBurstMode() then
				return 12
			else
				return 7
			end
		elseif weapon:GetClass() == CS16_WEAPON_M4A1 then
			if weapon:GetSilenced() then
				return 11
			else
				return 3
			end
		elseif weapon:GetClass() == CS16_WEAPON_FAMAS then
			if weapon:GetBurstMode() then
				return 19
			else
				return 3
			end
		end

		if weapon:GetClass() == CS16_WEAPON_MAC10 or weapon:GetClass() == CS16_WEAPON_UMP45 or weapon:GetClass() == CS16_WEAPON_MP5NAVY or weapon:GetClass() == CS16_WEAPON_TMP then
			return 1
		end

		if weapon:GetClass() == CS16_WEAPON_AUG or weapon:GetClass() == CS16_WEAPON_GALIL or weapon:GetClass() == CS16_WEAPON_M249 or weapon:GetClass() == CS16_WEAPON_SG552 or weapon:GetClass() == CS16_WEAPON_AK47 or weapon:GetClass() == CS16_WEAPON_P90 then
			return 3
		end

		if weapon:GetClass() == CS16_WEAPON_P228 or weapon:GetClass() == CS16_WEAPON_FIVESEVEN or weapon:GetClass() == CS16_WEAPON_DEAGLE then
			return 7
		end

		return 0
	end

	local m_iAmmoLastCheck = 0
	local m_flCrosshairDistance = 0
	local m_iAlpha = 255
	local m_iCrosshairScaleBase = 0
	local m_flLastCalcTime = 0

	local function CalculateCrosshairColor()
		local startTime = CurTime()
		local value = GetConVar( "cl_cs16_crosshair_color" ):GetString()
		local tbl = string.Explode( " ", value )
		local cvarR, cvarG, cvarB

		cvarR = math.Clamp( tonumber( tbl[1] ), 0, 255 )
		cvarG = math.Clamp( tonumber( tbl[2] ), 0, 255 )
		cvarB = math.Clamp( tonumber( tbl[3] ), 0, 255 )

		return Color( cvarR, cvarG, cvarB, m_iAlpha )
	end
	local function CalculateCrosshairDrawMode()
		return false
	end
	local function CalculateCrosshairSize()
		local value = GetConVar( "cl_cs16_crosshair_size" ):GetString()
		local ScreenWidth = ScrW()
		local ScreenHeight = ScrH()

		if !value then return end

		local size = tonumber( value )
		if size and size != 0 then
			if size > 3 then
				size = -1
			end
		else
			if value == "0" then
				size = -1
			end
		end

		if value == "auto" then
			size = 0
		elseif value == "small" then
			size = 1
		elseif value == "medium" then
			size = 2
		elseif value == "large" then
			size = 3
		end

		if size == -1 then return end

		if size == 0 then
			if ScreenWidth >= 1024 then
				m_iCrosshairScaleBase = 640
			elseif ScreenWidth >= 800 then
				m_iCrosshairScaleBase = 800
			else
				m_iCrosshairScaleBase = 1024
			end
		elseif size == 1 then
			m_iCrosshairScaleBase = 1024
		elseif size == 2 then
			m_iCrosshairScaleBase = 800
		elseif size == 3 then
			m_iCrosshairScaleBase = 640
		end
	end

	local color = Color( 0, 0, 0, 0 )
	local iDistance = 4
	local iDeltaDistance = 3
	function DrawCrosshair( flTime, weapon )
		local LP = LocalPlayer()
		if !LP:Alive() then return end
		if !weapon then return end
		if !weapon.IsCS16 then return end

		local cl_dynamiccrosshair = GetConVar("cl_cs16_dynamiccrosshair"):GetInt()
		local g_iShotsFired = weapon:Getm_iShotsFired() or 0
		if weapon:GetClass() == CS16_WEAPON_GLOCK18 and weapon:GetBurstMode() then
			g_iShotsFired = weapon:Getm_iGlock18ShotsFired() or g_iShotsFired
		end
		local iWeaponAccuracyFlags = 0
		local iBarSize = 0
		local flCrosshairDistance = 0

		local ScreenWidth = ScrW()
		local ScreenHeight = ScrH()
		
		iDistance = CS16_CrosshairParameters[weapon:GetClass()] and CS16_CrosshairParameters[weapon:GetClass()].distance or 4 
		iDeltaDistance = CS16_CrosshairParameters[weapon:GetClass()] and CS16_CrosshairParameters[weapon:GetClass()].deltaDistance or 3
		local drawmode = false

		iWeaponAccuracyFlags = GetWeaponAccuracyFlags( weapon )
		if iWeaponAccuracyFlags != 0 and cl_dynamiccrosshair != 0 then
			if LP:IsOnGround() then
				if LP:Crouching() and bit.band( iWeaponAccuracyFlags, 4 ) != 0 then
					iDistance = iDistance * 0.5
				else
					local flLimitSpeed = CS16_CrosshairLimitSpeed[weapon:GetClass()] and CS16_CrosshairLimitSpeed[weapon:GetClass()] or 170
					if LP:GetVelocity():Length2D() > flLimitSpeed and bit.band( iWeaponAccuracyFlags, 2 ) != 0 then
						iDistance = iDistance * 1.5
					end
				end
			else
				iDistance = iDistance * 2
			end
			if bit.band( iWeaponAccuracyFlags, 8 ) != 0 then
				iDistance = iDistance * 1.4
			end
		end
		
		if g_iShotsFired > m_iAmmoLastCheck then
			m_flCrosshairDistance = m_flCrosshairDistance + iDeltaDistance
			m_iAlpha = m_iAlpha - 40

			if m_flCrosshairDistance > 15 then
				m_flCrosshairDistance = 15
			end
			if m_iAlpha < 120 then
				m_iAlpha = 120
			end
		elseif m_flCrosshairDistance > iDistance then
			m_flCrosshairDistance = m_flCrosshairDistance - (0.032 * m_flCrosshairDistance) + 0.01
			m_iAlpha = m_iAlpha + 2
		end

		if g_iShotsFired > 600 then
			g_iShotsFired = 1
		end

		m_iAmmoLastCheck = g_iShotsFired

		if m_flCrosshairDistance < iDistance then
			m_flCrosshairDistance = iDistance
		end

		if m_iAlpha > 255 then
			m_iAlpha = 255
		end

		iBarSize = ((m_flCrosshairDistance - iDistance) * 0.5) + 5

		if CurTime() > m_flLastCalcTime + 1 then
			color = CalculateCrosshairColor()
			drawmode = CalculateCrosshairDrawMode()
			CalculateCrosshairSize()

			m_flLastCalcTime = CurTime()
		end

		local flCrosshairDistance = m_flCrosshairDistance

		if m_iCrosshairScaleBase != ScreenWidth then
			flCrosshairDistance = flCrosshairDistance * ScreenWidth / m_iCrosshairScaleBase
			iBarSize = (ScreenWidth * iBarSize) / m_iCrosshairScaleBase
		end

		DrawCrosshairEx( flTime, weapon, iBarSize, flCrosshairDistance, drawmode, color )
	end
	function DrawCrosshairEx( flTime, weapon, iBarSize, flCrosshairDistance, bAdditive, color )
		local ScreenWidth = ScrW()
		local ScreenHeight = ScrH()

		surface.SetDrawColor( color )
		surface.DrawRect( ( ScreenWidth / 2 ) - flCrosshairDistance - iBarSize + 1, ScreenHeight / 2, iBarSize, 1 )
		surface.DrawRect( ( ScreenWidth / 2 ) + flCrosshairDistance, ScreenHeight / 2, iBarSize, 1 )
		surface.DrawRect( ScreenWidth / 2, (ScreenHeight / 2) - flCrosshairDistance - iBarSize + 1, 1, iBarSize )
		surface.DrawRect( ScreenWidth / 2, (ScreenHeight / 2) + flCrosshairDistance, 1, iBarSize )
	end

	hook.Add( "HUDPaint", "gmCStrike", function()
		DrawCrosshair( CurTime(), LocalPlayer():GetActiveWeapon() )
	end )
end