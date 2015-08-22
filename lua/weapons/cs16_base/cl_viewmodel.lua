CL_BOBCYCLE = 0.8
CL_BOBUP = 0.5
CL_BOB = 0.01

local bob, bobcycle = 0, 0

function CalcBob()
	local bobtime = CurTime()

	bobcycle = bobtime - math.floor( ( bobtime / CL_BOBCYCLE ) ) * CL_BOBCYCLE
	bobcycle = bobcycle / CL_BOBCYCLE

	if bobcycle < CL_BOBUP then
		bobcycle = math.pi * bobcycle / CL_BOBUP
	else
		bobcycle = math.pi + math.pi * ( bobcycle - CL_BOBUP )/ ( 1.0 - CL_BOBUP )
	end
	
	local bobvel = LocalPlayer():GetVelocity()
	bobvel[3] = 0
 
	local sqrt = math.Clamp( bobvel[1] * bobvel[1] + bobvel[2] * bobvel[2], -170000, 170000 )

	bob = math.sqrt( sqrt ) * CL_BOB
	bob = bob * 0.3 + bob * 0.7 * math.sin( bobcycle )
	bob = math.Clamp( bob, -7, 4 )

	return bob
end


local viewmodel_new, viewmodel_old, eyepos, eyeang, frametime, curtime, matrix
local matrix_invert, matrix_normal = Vector(1, -1, 1), Vector(1, 1, 1)
/*
serverside_punchangle = serverside_punchangle or Vector( 0, 0, 0 )

net.Receive( "CS16_SetViewPunch", function()
	local xyz = net.ReadString()
	local vector = string.Explode( " ", xyz )

	if vector[1] != "nil" then
		serverside_punchangle[1] = tonumber(vector[1])
	end
	if vector[2] != "nil" then
		serverside_punchangle[2] = tonumber(vector[2])
	end
	if vector[3] != "nil" then
		serverside_punchangle[3] = tonumber(vector[3])
	end
end)
*/

function SWEP:PreDrawViewModel() 
	render.SetBlend( 0 )
end
function SWEP:PostDrawViewModel() 
	render.SetBlend( 1 )
	viewmodel_new, viewmodel_old, eyepos, eyeang, frametime, curtime = self.viewmodel, self.Owner:GetViewModel(), EyePos(), EyeAngles(), FrameTime(), CurTime()

	if self.ViewModelFlip then
		render.CullMode( MATERIAL_CULLMODE_CW )
		matrix = Matrix()
		matrix:Scale( matrix_invert )
		viewmodel_new:EnableMatrix( "RenderMultiply", matrix )
	else
		matrix = Matrix()
		matrix:Scale( matrix_normal )
		viewmodel_new:EnableMatrix( "RenderMultiply", matrix )
	end

	local bob_int = CalcBob()

	eyeang[1] = eyeang[1] - self.Owner:CS16_GetViewPunch()[1]
	eyeang[2] = eyeang[2] - self.Owner:CS16_GetViewPunch()[2]
	eyeang[3] = eyeang[3] - self.Owner:CS16_GetViewPunch()[3]

	eyepos = eyepos + ( (eyeang:Forward() - eyeang:Right() * 0.05 + eyeang:Up() * 0.1 ) * bob_int * 0.4)
	eyepos[3] = eyepos[3] - 1

	
	if IsValid( viewmodel_new ) then
		if self.FirstDeploy then
			CS16_SendWeaponAnim( self, self.Anims.Draw, 1 )
			self.FirstDeploy = false
		end

		cam.IgnoreZ( true )
		viewmodel_new:SetRenderOrigin( eyepos )
		viewmodel_new:SetRenderAngles( eyeang )

		render.CullMode( MATERIAL_CULLMODE_CCW )
		for k, v in pairs( osmes.GetEffects() ) do
			if !v.DrawViewModel then continue end
			if v.ThinkVM( v ) then
				v.RenderVM( v )
			else
				osmes.GetEffects()[k] = nil
			end
		end
		if self.ViewModelFlip then
			render.CullMode( MATERIAL_CULLMODE_CW )
		end


		viewmodel_new:FrameAdvance( frametime )
		viewmodel_new:SetupBones()
		viewmodel_new:SetParent( viewmodel_old )
		viewmodel_new:DrawModel()
		cam.IgnoreZ( false )
	end

	render.CullMode( MATERIAL_CULLMODE_CCW )
end
function SWEP:DrawWorldModel() 
	self:DrawModel() 
end
function SWEP:CalcView( ply, pos, ang, fov )
	if !LocalPlayer():ShouldDrawLocalPlayer() then
		local bob_int = CalcBob()

		pos[3] = pos[3] + bob_int
		ang[1] = ang[1] + ply:CS16_GetViewPunch()[1]
		ang[2] = ang[2] + ply:CS16_GetViewPunch()[2]
		ang[3] = ang[3] + ply:CS16_GetViewPunch()[3]
	end

	if self:GetIsInScope() then
		fov = 45.83
	end
	if self:GetScopeZoom() == 1 then
		fov = 33.3
	elseif self:GetScopeZoom() == 2 then
		if self:GetClass() == CS16_WEAPON_AWP then
			fov = 10
		elseif self:GetClass() == CS16_WEAPON_SCOUT or self:GetClass() == CS16_WEAPON_SG550 or self:GetClass() == CS16_WEAPON_G3SG1 then
			fov = 12.5
		end
	end

	return pos, ang, fov
end

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos - ang:Up() * 200

	return pos, ang
end

local pos, dir
function SWEP:GetTracerOrigin()
	local pos = LocalPlayer():GetShootPos() + LocalPlayer():EyeAngles():Right() * 5 + LocalPlayer():EyeAngles():Up() * -4 + LocalPlayer():GetForward() * 15
	return pos
end

hook.Add( "PostDrawOpaqueRenderables", "osmes.Effects", function()
	cam.Start3D( EyePos(), EyeAngles() ) 
	for k, v in pairs( osmes.GetEffects() ) do
		if !v.DrawWorldModel then continue end
		if v.ThinkWM( v ) then
			v.RenderWM( v )
		else
			osmes.GetEffects()[k] = nil
		end
	end
	cam.End3D()
end )