function EFFECT:Init(data)	
	self.Ent = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.AttachmentInfo = self.Ent.viewmodel:GetAttachment( self.Ent.viewmodel:LookupAttachment( self.Attachment ) )
	self.Pos = self.Ent.viewmodel:GetRenderOrigin()
	self.Refract = 0
	self.Size = 0
	self.mat = Material("cs16/muzzleflash2_"..math.random(1,3))
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	self.Size = 18 * self.Refract^(0.18)	
	//if self.Refract >= .03 then return false end	
	return true
end

function EFFECT:Render()
	local Muzzle = self:GetTracerShootPos( self.Pos, self.Ent.viewmodel, self.Attachment )
	//if !self.WeaponEnt or !IsValid(self.WeaponEnt) or !Muzzle then return end
	render.SetMaterial( self.mat )
	render.DrawSprite( self.Pos, self.Size, self.Size, Color( 255, 255, 255, 150 ) )
	self:SetRenderBoundsWS( self.Pos - Vector(3000,3000,3000), self.Pos + Vector(3000,3000,3000) )
end