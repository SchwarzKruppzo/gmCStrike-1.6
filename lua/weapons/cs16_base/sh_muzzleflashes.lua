// Oldschool Sprite Muzzleflash Effects System

osmes = osmes or {}
if CLIENT then 
	osmes.buffer = {}

	CS16_MuzzleFlashes = {}
	CS16_MuzzleFlashes["muzzleflash2"] = {
		Init = function( self )
			self.DieTime = 0
			self.SizeVM = 0
			self.SizeWM = 0
			self.Mat = Material("cs16/muzzleflash2_"..math.random(1,3))
		end,
		ThinkVM  = function( self )
			if !IsValid( self.Ent ) then return false end
			if !IsValid( self.Ent.viewmodel ) then return false end
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
			// TODO: WORLD MUZZLEFLASH
				/*
				if !IsValid( self.Ent ) then return false end
				local attachment = self.Ent:GetAttachment( self.Ent:LookupAttachment( "muzzle" ) )
				if !attachment then return false end

				self.PosWM = attachment.Pos

				self.DieTime = self.DieTime + FrameTime()
				self.SizeWM = ( self.CustomSizeWM and self.CustomSizeWM or 16 ) * self.DieTime ^ 0.08

				if self.DieTime >= .035 then return false end	
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
		osmes.buffer[id].Init( osmes.buffer[id] )
		osmes.buffer[id].Ent = parent

		for k, v in pairs( data ) do
			osmes.buffer[id][k] = v
		end
	end

	net.Receive( "osmes.Effect", function()
		local name = net.ReadString()
		local ent = net.ReadEntity()
		local data = net.ReadTable()

		osmes.SpawnEffect( name, ent, data )
	end)

	hook.Add( "Think", "osmes.Effect", function()
		for k, v in pairs( osmes.GetEffects() ) do
			if !v.ThinkWM( v ) and v.DrawWorldModel then
				osmes.GetEffects()[k] = nil
			end
			if !v.ThinkVM( v ) and v.DrawViewModel then
				osmes.GetEffects()[k] = nil
			end
		end
	end )
else
	util.AddNetworkString("osmes.Effect")


	function osmes.SpawnEffect( ply, name, parent, data )
		net.Start( "osmes.Effect" )
			net.WriteString( name )
			net.WriteEntity( parent )
			net.WriteTable( data )
		if ply then
			net.Send( ply )
		else
			net.Broadcast()
		end
	end
end