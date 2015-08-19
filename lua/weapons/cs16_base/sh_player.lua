local meta = FindMetaTable("Player")

local function RandomizeXYZ( x, y, z )
	math.randomseed( CurTime() )
	x = math.Rand( -0.5, 0.5 ) + math.Rand( -0.5, 0.5 )
	y = math.Rand( -0.5, 0.5 ) + math.Rand( -0.5, 0.5 )
	z = x * x + y * y
end

function meta:FireBullets3( vecSrc, shootAngles, flSpread, flDistance, iPenetration, strAmmoType, iDamage, flRangeModifier, attacker, bPistol, shared_rand )
	local vecDirShooting, vecRight, vecUp 
	vecDirShooting = shootAngles:Forward()
	vecRight = shootAngles:Right()
	vecUp = shootAngles:Up()

	local originalPenetration = iPenetration
	local penetrationPower = 0
	local penetrationDistance = 0

	local currentDamage = iDamage
	local currentDistance = 0

	local tr
	local tr2

	local hitMetal = false

	if CS16_Penetration_Info[strAmmoType] then
		penetrationPower = CS16_Penetration_Info[strAmmoType].power
		penetrationDistance = CS16_Penetration_Info[strAmmoType].distance
	else
		penetrationPower = 0
		penetrationDistance = 0
	end

	if !attacker then attacker = self end

	local x, y, z = 0, 0, 0

	if self:IsPlayer() then
		x = util.SharedRandom( "FireBullets3player" .. shared_rand, -0.5, 0.5, 0 ) + util.SharedRandom( "FireBullets3player" .. shared_rand, -0.5, 0.5, 1 )
		y = util.SharedRandom( "FireBullets3player" .. shared_rand, -0.5, 0.5, 2 ) + util.SharedRandom( "FireBullets3player" .. shared_rand, -0.5, 0.5, 3 )
	else
		RandomizeXYZ( x, y, z )

		while z > 1 do 
			RandomizeXYZ( x, y, z )
		end
	end
	local vecDir = vecDirShooting + ( x * flSpread * vecRight ) + ( y * flSpread * vecUp )
	vecDir:Normalize()
	local vecEnd = vecSrc + vecDir * flDistance

	local damageModifier = 0.5
	while iPenetration != 0 do
		local tracedata = {}
		tracedata.start = vecSrc
		tracedata.endpos = vecEnd
		tracedata.mask = MASK_SHOT
		tracedata.filter = self
		tr = util.TraceLine( tracedata )

		if CS16_Bullet_Mat_Info[tr.MatType] then
			local tbl = CS16_Bullet_Mat_Info[tr.MatType]

			hitMetal = tbl.metal
			penetrationPower = tbl.power and (penetrationPower * tbl.power) or penetrationPower
			damageModifier = tbl.damageMul and tbl.damageMul or damageModifier
		end

		if tr.Fraction != 1.0 then
			local ent = tr.Entity

			iPenetration = iPenetration - 1

			currentDistance = tr.Fraction * flDistance
			currentDamage = currentDamage * math.pow( flRangeModifier, currentDistance / 500 )

			if currentDistance > penetrationDistance then
				iPenetration = 0
			end

			local distanceModifier = 0

			if tr.Entity:GetSolid() != SOLID_BSP and iPenetration == 0 then
				penetrationPower = 42.0
				distanceModifier = 0.75
				damageModifier = 0.75
			else
				distanceModifier = 0.75
			end
			
			local bullet = {}
			bullet.Num = 1
			bullet.Src = vecSrc
			bullet.Dir = vecDir
			bullet.Spread = Vector( 0, 0, 0 )
			bullet.Tracer = 0
			bullet.Force = 5
			bullet.Damage = currentDamage
			bullet.AmmoType = strAmmoType

			vecSrc = tr.HitPos + (vecDir * penetrationPower)
			flDistance = (flDistance - currentDistance) * distanceModifier
			vecEnd = vecSrc + (vecDir * flDistance)

			self:LagCompensation( true )
			self:FireBullets( bullet )
			self:LagCompensation( false )

			currentDamage = currentDamage * damageModifier
		else
			iPenetration = 0
		end
	end
end