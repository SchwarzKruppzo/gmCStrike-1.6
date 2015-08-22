sound.Add(
{
    name = "OldHit.PShell",
    channel = CHAN_ITEM,
    volume = 0.5,
    level = 65,
    sound = {"cs16_shell1.wav","cs16_shell2.wav","cs16_shell3.wav"}
})
sound.Add(
{
    name = "OldHit.ShotgunShell",
    channel = CHAN_ITEM,
    volume = 0.5,
    level = 65,
    sound = {"cs16_sshell1.wav","cs16_sshell2.wav","cs16_sshell3.wav"}
})

CS16_Shells = {}
CS16_Shells["pshell"] = { model = "models/cs16/pshell.mdl", sound = Sound( "OldHit.PShell" ) }
CS16_Shells["rshell"] = { model = "models/cs16/rshell.mdl", sound = Sound( "OldHit.PShell" ) }
CS16_Shells["shotgunshell"] = { model = "models/cs16/shotgunshell.mdl", sound = Sound( "OldHit.ShotgunShell" ) }

local viewmodel

function CS16_SendWeaponAnim( weapon, sequence, speed, cycle, time )
	local ply = weapon.Owner and weapon.Owner or nil

	speed = speed and speed or 1
	cycle = cycle and cycle or 0
	time = time or 0
			
	if type( sequence ) == "table" then
		sequence = table.Random( sequence )
	end
	
	if weapon.Sounds[sequence] then
		weapon.CurrentSoundTable = weapon.Sounds[sequence]
		weapon.CurrentSoundEntry = 1
		weapon.SoundSpeed = speed
		weapon.SoundTime = CurTime() + time
	end
	
	if SERVER and game.SinglePlayer() then
		umsg.Start( "CS16_SendWeaponAnim", Entity( 1 ) )
			umsg.String( sequence )
			umsg.Float( speed )
			umsg.Float( cycle )
			umsg.Entity( weapon )
		umsg.End()
	elseif SERVER and !CLIENT then
		umsg.Start( "CS16_SendWeaponAnim", ply )
			umsg.String( sequence )
			umsg.Float( speed )
			umsg.Float( cycle )
			umsg.Entity( weapon )
		umsg.End()
	end
		
	if CLIENT then
		viewmodel = weapon.viewmodel
		
		weapon.CurrentAnim = string.lower( sequence )
		
		if viewmodel then
			viewmodel:SetCycle( cycle )
			viewmodel:SetSequence( sequence )
			viewmodel:SetPlaybackRate( speed )
		end
	end
end
function CS16_SpawnVShell( model, soundс, pos, ang, vel, time, removetime, angvel )
	if not model or not pos or not ang then
		return
	end
	
	vel = vel or Vector(0, 0, -100)
	vel = vel + VectorRand() * 5
	time = time or 0.5
	removetime = removetime or 5
		
	local ent = ClientsideModel( model, RENDERGROUP_BOTH ) 
	ent:SetPos( pos )
	ent:PhysicsInitBox( Vector(-0.5, -0.15, -0.5), Vector(0.5, 0.15, 0.5) )
	ent:SetAngles( ang )
	ent:SetMoveType( MOVETYPE_VPHYSICS ) 
	ent:SetSolid( SOLID_VPHYSICS ) 
	ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	ent.nextCollideSound = 0
	ent:AddCallback("PhysicsCollide", function( ent )
		if CurTime() >= ent.nextCollideSound then
			sound.Play( soundс, ent:GetPos() )
			ent.nextCollideSound = CurTime() + 0.2
		end
	end)
	local phys = ent:GetPhysicsObject()
	phys:SetMaterial( "gmod_silent" )
	phys:SetMass( 1 )
	phys:SetVelocity( vel )
	phys:AddAngleVelocity( angvel and angvel or VectorRand() * math.random(1000,5000) )
	
	SafeRemoveEntityDelayed( ent, removetime )
end

local shellDir = {}
shellDir["default"] = function( attach )
	return -attach.Ang:Forward() + EyeAngles():Up() * math.Rand( 1.7, 2.5 ) + EyeAngles():Forward() * math.Rand( 0.5, 2 )
end
shellDir["wep_cs16_p90"] = function( attach )
	return attach.Ang:Forward() * 3 + EyeAngles():Up() * math.Rand( 1.7, 2.5 ) + EyeAngles():Forward() * math.Rand( 4, 6 )
end
shellDir["wep_cs16_tmp"] = function( attach )
	return -attach.Ang:Forward() + EyeAngles():Up() * math.Rand( 1.7, 3 ) + EyeAngles():Forward() * math.Rand( 0.5, 2 )
end
shellDir["wep_cs16_mac10"] = function( attach )
	return -attach.Ang:Forward() * math.Rand( 1, 2 ) + EyeAngles():Up() * math.Rand( 1.7, 1 ) + EyeAngles():Forward() * math.Rand( 0.5, 2 )
end
shellDir["wep_cs16_ump45"] = function( attach )
	return -attach.Ang:Forward() * math.Rand( 1, 2 ) + EyeAngles():Up() * math.Rand( 1, 2.3 ) + EyeAngles():Forward() * math.Rand( 0.5, 1.5 )
end
shellDir["wep_cs16_m3"] = function( attach )
	return -attach.Ang:Forward() * math.Rand( 1, 2 ) + EyeAngles():Up() * math.Rand( 1, 2.3 ) + EyeAngles():Forward() * math.Rand( 1, 2 )
end
shellDir["wep_cs16_xm1014"] = function( attach )
	return -attach.Ang:Forward() * math.Rand( 1.5, 2.5 ) + EyeAngles():Up() * math.Rand( 1.5, 3 ) + EyeAngles():Forward() * math.Rand( 3, 4 )
end
shellDir["wep_cs16_m249"] = function( attach )
	return attach.Ang:Forward() * 3 + EyeAngles():Up() * math.Rand( 1.7, 2.5 ) + EyeAngles():Forward() * math.Rand( 2, 6 )
end
shellDir["wep_cs16_ak47"] = function( attach )
	return -attach.Ang:Forward() * math.Rand( 2, 3 ) + EyeAngles():Up() * math.Rand( 1.7, 2.5 ) + EyeAngles():Forward() * math.Rand( 2, 6 )
end
shellDir["wep_cs16_galil"] = function( attach )
	return -attach.Ang:Forward() * math.Rand( 2, 3 ) + EyeAngles():Up() * math.Rand( 1.7, 2.5 ) + EyeAngles():Forward() * math.Rand( 2, 6 )
end
shellDir["wep_cs16_elite_left"] = function( attach )
	return -attach.Ang:Forward() * math.Rand( 1, 3 ) + EyeAngles():Up() * math.Rand( 1.7, 2.5 ) + EyeAngles():Forward() * math.Rand( 1.5, 2.5 )
end
shellDir["wep_cs16_elite_right"] = function( attach )
	return attach.Ang:Forward() * math.Rand( 1, 3 ) + EyeAngles():Up() * math.Rand( 1.7, 3.5 ) + EyeAngles():Forward() * math.Rand( 1.5, 2.5 )
end
shellDir["wep_cs16_m4a1"] = function( attach )
	return -attach.Ang:Forward() * math.Rand( 1.5, 2 ) + EyeAngles():Up() * math.Rand( 1, 2.5 ) + EyeAngles():Forward() * math.Rand( 2.5, 4 )
end
shellDir["wep_cs16_famas"] = function( attach )
	return attach.Ang:Forward() * math.Rand( 2, 4 ) + EyeAngles():Up() * math.Rand( 1, 2 ) + EyeAngles():Forward() * math.Rand( 2.8, 3 )
end
shellDir["wep_cs16_aug"] = function( attach )
	return attach.Ang:Forward() * math.Rand( 2, 3.5 ) + EyeAngles():Up() * math.Rand( 1, 4 ) + EyeAngles():Forward() * math.Rand( 2, 3.5 )
end
shellDir["wep_cs16_sg552"] = function( attach )
	return -attach.Ang:Forward() * math.Rand( 2, 3 ) + EyeAngles():Up() * math.Rand( 2, 4 ) + EyeAngles():Forward() * math.Rand( 1, 2 )
end
shellDir["wep_cs16_scout"] = function( attach )
	return -attach.Ang:Forward() + EyeAngles():Up() - EyeAngles():Right() + EyeAngles():Forward() * math.Rand( 1, 2 )
end
shellDir["wep_cs16_awp"] = function( attach )
	return -attach.Ang:Forward() + EyeAngles():Up() - EyeAngles():Right() + EyeAngles():Forward() * math.Rand( 1, 2 )
end
shellDir["wep_cs16_sg550"] = function( attach )
	return -attach.Ang:Forward() * math.Rand( 2, 3 ) + EyeAngles():Up() * math.Rand( 2, 4 ) + EyeAngles():Forward() * math.Rand( 1, 2 )
end
shellDir["wep_cs16_g3sg1"] = function( attach )
	return -attach.Ang:Forward() * math.Rand( 2, 3 ) + EyeAngles():Up() * math.Rand( 2, 4 ) + EyeAngles():Forward() * math.Rand( 1, 2 )
end

function SWEP:CreateShell( shell, attachment, client )
	if (SERVER and !CLIENT) or (SERVER and game.SinglePlayer()) then
		umsg.Start( "CS16_CreateShell", self.Owner )
			umsg.String( shell )
			umsg.String( attachment )
			umsg.Entity( self )
		umsg.End()
		return
	elseif CLIENT and client then
		if !game.SinglePlayer() then
			if !IsFirstTimePredicted() then return end
		end
		if self.Owner:ShouldDrawLocalPlayer() then
			return
		end
		if !CS16_Shells[shell] then
			return
		end
		local attach = self.viewmodel:GetAttachment( self.viewmodel:LookupAttachment( attachment ) )

		if attach then
			local angvel = nil
			local posOffset = Vector()
			if shellDir[self:GetClass()] then
				dir = shellDir[self:GetClass()]( attach )
			else
				dir = shellDir["default"]( attach )
			end
			if self:GetClass() == CS16_WEAPON_M3 or self:GetClass() == CS16_WEAPON_XM1014 then
				angvel = VectorRand() * 1000
			end
			if self:GetClass() == CS16_WEAPON_ELITE then
				if self:GetLeftMode() then
					dir = shellDir["wep_cs16_elite_left"]( attach )
				else
					dir = shellDir["wep_cs16_elite_right"]( attach )
				end
			end

			if self:GetScopeZoom() != 0 then
				posOffset = -EyeAngles():Right() * 10
			end

			CS16_SpawnVShell( CS16_Shells[shell].model, CS16_Shells[shell].sound, attach.Pos + dir / 2 + posOffset, EyeAngles(), dir * 35, 0.6, 5, angvel )
		end
		return
	end
end

if CLIENT then
	local function CS16_PlayAnimation( data )
		local sequence = data:ReadString()
		local speed = data:ReadFloat()
		local cycle = data:ReadFloat()
		local weapon = data:ReadEntity()

		if IsValid( weapon ) and weapon.IsCS16 then
			CS16_SendWeaponAnim( weapon, sequence, speed, cycle )
		end
	end

	usermessage.Hook( "CS16_SendWeaponAnim", CS16_PlayAnimation )

	local function CS16_CreateShell( data )
		local shell = data:ReadString()
		local attachment = data:ReadString()
		local weapon = data:ReadEntity()
		
		weapon:CreateShell( shell, attachment, true )
	end

	usermessage.Hook( "CS16_CreateShell", CS16_CreateShell )
end

