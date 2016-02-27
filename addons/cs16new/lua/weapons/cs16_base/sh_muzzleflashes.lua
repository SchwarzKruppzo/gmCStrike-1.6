// Oldschool Sprite Muzzleflash Effects System

osmes = osmes or {}
if CLIENT then 
	osmes.buffer = {}

	CS16_MuzzleFlashes = {}
	CS16_MuzzleFlashes["muzzleflash1"] = {
		Init = function( self )
			self.DieTime = nil
			self.SizeVM = 0
			self.SizeWM = 0
			self.Mat = Material("cs16/muzzleflash1")
			self.Rotate = 180 + math.random(-10,10)
		end,
		ThinkVM  = function( self )
			return false
		end,
		RenderVM  = function( self )
			return false
		end,
		ThinkWM  = function( self )
			if !self.DieTime then
				self.DieTime = UnPredictedCurTime() + 0.025
			end
			if !IsValid( self.Ent ) then return false end
			if IsValid( self.Ent.Owner ) then
				if self.Ent.Owner == LocalPlayer() then
					if !self.Ent.Owner:ShouldDrawLocalPlayer() then
						return false
					end
				end
			end
			local attachment = self.Ent:GetAttachment( self.Ent:LookupAttachment( self.atID and self.atID or "muzzle" ) )
			if !attachment then
				local pos, ang = self.Ent.Owner:GetBonePosition( self.Ent.Owner:LookupBone( "Bip01 R Hand" ) )
				if pos then
					attachment = {}
					attachment.Pos = pos + ang:Forward() * 12
				end
			end
			if !attachment then return false end

			self.PosWM = attachment.Pos

			self.SizeWM = ( self.CustomSizeWM and self.CustomSizeWM or 16 ) * 0.001 ^ 0.08

			if CurTime() >= self.DieTime then return false end	
			return true
		end,
		RenderWM  = function( self )
			render.SetMaterial( self.Mat )
			render.DrawQuadEasy( self.PosWM, -EyeAngles():Forward(), self.SizeWM, self.SizeWM, Color( 255, 255, 255, 255 ), self.Rotate ) 
		end
	}
	CS16_MuzzleFlashes["muzzleflash4"] = {
		Init = function( self )
			self.DieTime = nil
			self.SizeVM = 0
			self.SizeWM = 0
			self.Mat = Material("cs16/muzzleflash4")
			self.Rotate = 180 + math.random(-10,10)
		end,
		ThinkVM  = function( self )
			return false
		end,
		RenderVM  = function( self )
			return false
		end,
		ThinkWM  = function( self )
			if !self.DieTime then
				self.DieTime = UnPredictedCurTime() + 0.025
			end
			if !IsValid( self.Ent ) then return false end
			if IsValid( self.Ent.Owner ) then
				if self.Ent.Owner == LocalPlayer() then
					if !self.Ent.Owner:ShouldDrawLocalPlayer() then
						return false
					end
				end
			end
			local attachment = self.Ent:GetAttachment( self.Ent:LookupAttachment( self.atID and self.atID or "muzzle" ) )
			if !attachment then
				local pos, ang = self.Ent.Owner:GetBonePosition( self.Ent.Owner:LookupBone( "Bip01 R Hand" ) )
				if pos then
					attachment = {}
					attachment.Pos = pos + ang:Forward() * 12
				end
			end
			if !attachment then return false end

			self.PosWM = attachment.Pos

			self.SizeWM = ( self.CustomSizeWM and self.CustomSizeWM or 16 ) * 0.001 ^ 0.08

			if CurTime() >= self.DieTime then return false end	
			return true
		end,
		RenderWM  = function( self )
			render.SetMaterial( self.Mat )
			render.DrawQuadEasy( self.PosWM, -EyeAngles():Forward(), self.SizeWM, self.SizeWM, Color( 255, 255, 255, 255 ), self.Rotate ) 
		end
	}
	CS16_MuzzleFlashes["muzzleflash2"] = {
		Init = function( self )
			self.DieTime = nil
			self.SizeVM = 0
			self.SizeWM = 0
			self.Mat = Material("cs16/muzzleflash2_"..math.random(1,3))
		end,
		ThinkVM  = function( self )
			if !IsValid( self.Ent ) then return false end
			if !IsValid( self.Ent.viewmodel ) then return false end
			if !self.DieTime then self.DieTime = 0 end
			local attachment = self.Ent.viewmodel:GetAttachment( self.Ent.viewmodel:LookupAttachment( self.atID and self.atID or "0" ) )
			if !attachment then return false end

			self.PosVM = attachment.Pos

			self.DieTime = self.DieTime + FrameTime()
			self.SizeVM = ( self.CustomSizeVM and self.CustomSizeVM or 8 ) * self.DieTime ^ 0.08

			if self.DieTime >= .035 then return false end	
			return true
		end,
		RenderVM  = function( self )
			render.SetMaterial( self.Mat )
			render.DrawSprite( self.PosVM, self.SizeVM, self.SizeVM, Color( 255, 255, 255, 255 ) )
		end,
		ThinkWM  = function( self )
			if !self.DieTime then
				self.DieTime = UnPredictedCurTime() + 0.025
			end
			if !IsValid( self.Ent ) then return false end
			local attachment = self.Ent:GetAttachment( self.Ent:LookupAttachment( "muzzle" ) )
			if !attachment then return false end

			self.PosWM = attachment.Pos

			self.SizeWM = ( self.CustomSizeWM and self.CustomSizeWM or 16 ) * 0.001 ^ 0.08

			if CurTime() >= self.DieTime then return false end	
			return true
		end,
		RenderWM  = function( self )
			render.SetMaterial( self.Mat )
			render.DrawSprite( self.PosWM, self.SizeWM, self.SizeWM, Color( 255, 255, 255, 255 ) )
		end
	}
	CS16_MuzzleFlashes["muzzleflash3"] = {
		Init = function( self )
			self.DieTime = 0
			self.SizeVM = 0
			self.SizeWM = 0
			self.Mat = Material("cs16/muzzleflash3_"..math.random(1,3))
			self.Rotate = math.random( -360,360 ) 
		end,
		ThinkVM  = function( self )
			if !IsValid( self.Ent ) then return false end
			if !IsValid( self.Ent.viewmodel ) then return false end
			local attachment = self.Ent.viewmodel:GetAttachment( self.Ent.viewmodel:LookupAttachment( self.atID and self.atID or "0" ) )
			if !attachment then return false end

			self.PosVM = attachment.Pos

			self.DieTime = self.DieTime + FrameTime()
			self.SizeVM = ( self.CustomSizeVM and self.CustomSizeVM or 8 ) * self.DieTime ^ 0.1

			if self.DieTime >= .038 then return false end	
			return true
		end,
		RenderVM  = function( self )
			// Мы не можем использовать render.DrawSprite так как его нельзя вращать.
			render.SetMaterial( self.Mat )
			render.DrawQuadEasy( self.PosVM, -EyeAngles():Forward(), self.SizeVM, self.SizeVM, Color( 255, 255, 255, 255 ), self.Rotate ) 
		end,
		ThinkWM  = function( self )
			// TODO: WORLD MUZZLEFLASH
			/*
				if !IsValid( self.Ent ) then return false end
				local attachment = self.Ent:GetAttachment( self.Ent:LookupAttachment( "muzzle" ) )
				if !attachment then return false end

				self.PosWM = attachment.Pos

				self.DieTime = self.DieTime + FrameTime()
				self.SizeWM = ( self.CustomSizeWM and self.CustomSizeWM or 16 ) * self.DieTime ^ 0.08

				if self.DieTime >= .038 then return false end	
				return true
			*/
			return false
		end,
		RenderWM  = function( self )
			// TODO: WORLD MUZZLEFLASH
			//render.SetMaterial( self.Mat )
			//render.DrawSprite( self.PosWM, self.SizeWM, self.SizeWM, Color( 255, 255, 255, 255 ) )
		end
	}

	function osmes.GetEffects()
		return osmes.buffer
	end
	function osmes.SpawnEffect( name, parent, data )
		if !CS16_MuzzleFlashes[ name ] then
			return
		end
		if parent.GetScopeZoom and parent:GetScopeZoom() != 0 then return end

		local id = table.insert( osmes.buffer, table.Copy( CS16_MuzzleFlashes[ name ] ) )
		for k, v in pairs( data ) do
			osmes.buffer[id][k] = v
		end
		osmes.buffer[id].Init( osmes.buffer[id] )
		osmes.buffer[id].Ent = parent
	end

	local function osmes_Effect( data )
		local name = data:ReadString()
		local ent = data:ReadEntity()
		local string_data = data:ReadString()
		local table_data = util.JSONToTable( string_data ) 

		osmes.SpawnEffect( name, ent, table_data )
	end
	usermessage.Hook( "osmes.Effect", osmes_Effect )

	hook.Add( "Think", "osmes.Effect", function()
		for k, v in pairs( osmes.GetEffects() ) do
			if v.DrawWorldModel then
				if !v.ThinkWM( osmes.GetEffects()[k] ) then
					osmes.GetEffects()[k] = nil
				end
			elseif v.DrawViewModel then
				if !v.ThinkVM( osmes.GetEffects()[k] ) then
					osmes.GetEffects()[k] = nil
				end
			end
		end
	end )
else
	function osmes.SpawnEffect( ply, name, parent, data )
		local filter = RecipientFilter()
		if ply then
			filter:AddPlayer( ply )

			for k, v in pairs( player.GetAll() ) do
				if !v:IsObserver() then continue end
				if v == ply then continue end
				if v:GetObserverTarget() != ply then continue end
				
				filter:AddPlayer( v )
			end
		else
			filter:AddAllPlayers()
		end

		umsg.Start( "osmes.Effect", filter )
			umsg.String( name )
			umsg.Entity( parent )
			umsg.String( util.TableToJSON( data ) )
		umsg.End()
	end
end