local meta = FindMetaTable("Player")

DAMAGE_NO = 0
DAMAGE_YES = 1
DEAD_NO	= 0 
DEAD_DYING = 1
DEAD_DEAD = 2

if SERVER then 
	function meta:Killed( pAttacker, iGib )
		local cCount = 0
		local fDone = false

		self:EmitSound( "common/null.wav" )

		self.takedamage = DAMAGE_NO
		self.deadflag = DEAD_DEAD

		if self:Health() < -99 then
			self:SetHealth( 0 )
		end
		self.dmg_attacker = pAttacker

		self:Kill()
	end

	function meta:TakeDamage( flDamage, pAttacker, pInflictor, bitsDamageType )
		if !self.m_bitsDamageType then
			self.m_bitsDamageType = 0
		end
		if !self.deadflag then
			self.deadflag = 0
		end
		if !self.dmg_inflictor then
			self.dmg_inflictor = 0
		end
		if !self.dmg_take then
			self.dmg_take = 0
		end
		local dmgInfo = DamageInfo()
		dmgInfo:SetDamage( flDamage )
		dmgInfo:SetAttacker( pAttacker )
		dmgInfo:SetInflictor( pInflictor )

		local flTake = 0
		local vecDir

		bitsDamageType = bitsDamageType and bitsDamageType or DMG_GENERIC
		dmgInfo:SetDamageType( bitsDamageType )

		if self.takedamage == 0 then
			return
		end
		if !self:Alive() then
			return
		end
		if self.deadflag == DEAD_NO then
			print("painsound")
		end

		if hook.Run( "EntityTakeDamage", self, dmgInfo ) then
			return
		end

		flTake = dmgInfo:GetDamage()

		self.m_bitsDamageType = bit.band( self.m_bitsDamageType, bitsDamageType )

		vecDir = Vector( 0, 0, 0 )

		if IsValid( pInflictor ) then
			vecDir = (pInflictor:OBBCenter() - Vector(0, 0, 10) - self:OBBCenter()):Normalize()
			self.vecAttackDir = vecDir
		end

		if self:IsPlayer() then
			if pInflictor then
				self.dmg_inflictor = pInflictor
			end

			self.dmg_take = self.dmg_take + flTake

			if bit.band( self:GetFlags(), FL_GODMODE ) > 0 then
				return 0
			end

			if ( !IsValid( pInflictor ) ) and (self:GetMoveType() == MOVETYPE_WALK) and (!pInflictor or pAttacker:GetSolid() != SOLID_BSP) then 
				print("force")
			end
		end

		self:SetHealth( self:Health() - flTake )

		umsg.Start( "PlayerHurt" )
			umsg.Short( self:Health() )
			umsg.Short( self:EntIndex() )
			umsg.Short( pAttacker:EntIndex() )
		umsg.End()
		
		if self:Health() <= 0 then
			self.pLastInflictor = pInflictor

			if bit.band( bitsDamageType, DMG_ALWAYSGIB ) then
				self:Killed( pAttacker, GIB_ALWAYS )
			elseif bit.band( bitsDamageType, DMG_NEVERGIB ) then
				self:Killed( pAttacker, GIB_NEVER )
			else
				self:Killed( pAttacker, GIB_NORMAL )
			end

			self.pLastInflictor = nil
			return 0
		end

		return 1
	end

	function meta:TakeDamageInfo( dmgInfo )
		if !self.m_bitsDamageType then
			self.m_bitsDamageType = 0
		end
		if !self.deadflag then
			self.deadflag = 0
		end
		if !self.dmg_inflictor then
			self.dmg_inflictor = 0
		end
		if !self.dmg_take then
			self.dmg_take = 0
		end

		local pInflictor = dmgInfo:GetInflictor()
		local pAttacker = dmgInfo:GetAttacker()
		local bitsDamageType = dmgInfo:GetDamageType()
		local flTake = 0
		local vecDir

		if self.takedamage == 0 then
			return
		end
		if !self:Alive() then
			return
		end
		if self.deadflag == DEAD_NO then
			print("painsound")
		end

		if hook.Run( "EntityTakeDamage", self, dmgInfo ) then
			return
		end

		flTake = dmgInfo:GetDamage()

		self.m_bitsDamageType = bit.band( self.m_bitsDamageType, bitsDamageType )

		vecDir = Vector( 0, 0, 0 )

		if IsValid( pInflictor ) then
			vecDir = (pInflictor:OBBCenter() - Vector(0, 0, 10) - self:OBBCenter()):Normalize()
			self.vecAttackDir = vecDir
		end
		
		if self:IsPlayer() then
			if pInflictor then
				self.dmg_inflictor = pInflictor
			end

			self.dmg_take = self.dmg_take + flTake

			if bit.band( self:GetFlags(), FL_GODMODE ) > 0 then
				return 0
			end

			if ( !IsValid( pInflictor ) ) and (self:GetMoveType() == MOVETYPE_WALK) and (!pInflictor or pAttacker:GetSolid() != SOLID_BSP) then 
				print("force")
			end
		end
		self:SetHealth( self:Health() - flTake )

		umsg.Start( "PlayerHurt" )
			umsg.Short( self:Health() )
			umsg.Short( self:EntIndex() )
			umsg.Short( pAttacker:EntIndex() )
		umsg.End()

		if self:Health() <= 0 then
			self.pLastInflictor = pInflictor

			if bit.band( bitsDamageType, DMG_ALWAYSGIB ) then
				self:Killed( pAttacker, GIB_ALWAYS )
			elseif bit.band( bitsDamageType, DMG_NEVERGIB ) then
				self:Killed( pAttacker, GIB_NEVER )
			else
				self:Killed( pAttacker, GIB_NORMAL )
			end

			self.pLastInflictor = nil
			return 0
		end

		return 1
	end

	function RadiusDamage( vecSrc, pevInflictor, pevAttacker, flDamage, flRadius, bitsDamageType, bIgnoreWorld)
		local tr
		local flAdjustedDamage
		local falloff
		local vecSpot

		if flRadius then
			falloff = flDamage / flRadius
		else
			falloff = 1.0
		end

		local bInWater = (util.PointContents( vecSrc ) == CONTENTS_WATER)

		vecSrc.z = vecSrc.z + 1

		if !IsValid( pevAttacker ) then
			pevAttacker = pevInflictor
		end

		for k, pEntity in pairs( ents.FindInSphere( vecSrc, flRadius ) ) do
			if pEntity.takedamage != DAMAGE_NO then
				if !bIgnoreWorld then
					if bInWater and pEntity:WaterLevel() == 0 then
						continue
					end
					if !bInWater and pEntity:WaterLevel() == 3 then
						continue
					end
				end

				vecSpot = pEntity:BodyTarget( vecSrc, false )

				local tracedata = {}
				tracedata.start = vecSrc
				tracedata.endpos = vecSpot
				tr = util.TraceLine( tracedata )

				if tr.Fraction == 1 or tr.Hit == pEntity or bIgnoreWorld then
					if !bIgnoreWorld then
						if tr.StartSolid then
							tr.HitPos = vecSrc
							tr.Fraction = 0.0
						end
					end

					flAdjustedDamage = (vecSrc - tracedata.endpos):Length() * falloff
					flAdjustedDamage = flDamage - flAdjustedDamage

					if flAdjustedDamage < 0 then
						flAdjustedDamage = 0
					end
					
					if tr.Fraction != 1 then
						local damageInfo = DamageInfo()
						damageInfo:SetDamageType( bitsDamageType )
						damageInfo:SetDamage( flAdjustedDamage )
						damageInfo:SetAttacker( pevAttacker )
						damageInfo:SetInflictor( pevInflictor )
						pEntity:TakeDamageInfo( damageInfo )
					else
						pEntity:TakeDamage( flAdjustedDamage, pevAttacker, pevInflictor, bitsDamageType )
					end
				end
			end
		end
	end
end