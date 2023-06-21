include( "shared.lua" )

local baseFont = "CW_HUD72"
local ammoText = "CW_HUD60"

ENT.DisplayDistance = 256

ENT.UpOffset = Vector( 0, 0, 40 )
ENT.BaseHorSize = 620
ENT.HalfBaseHorSize = ENT.BaseHorSize * 0.5
ENT.VertFontSize = 72
ENT.HalfVertFontSize = ENT.VertFontSize * 0.5

local white, black = Color( 255, 255, 255, 255 ), Color( 0, 0, 0, 255 )

function ENT:Draw()
	self:DrawModel()

	local ply = LocalPlayer()
	if ply:GetPos():Distance( self:GetPos() ) > self.DisplayDistance then
		return
	end

	local eyeAng = EyeAngles()
	eyeAng.p = 0
	eyeAng.y = eyeAng.y - 90
	eyeAng.r = 90

	local type = self:GetType()
	local tier = self:GetTier()
	local health = self:GetArmorHealth()
	local rightHealth = self:GetRightHealth()

	cam.Start3D2D( self:GetPos() + self.UpOffset, eyeAng, 0.05 )
		local r, g, b, a = self:GetTopPartColor()
		surface.SetDrawColor( r, g, b, a )
		surface.DrawRect( -self.HalfBaseHorSize, 0, self.BaseHorSize, self.VertFontSize )

		surface.SetDrawColor( 0, 0, 0, 150 )
		surface.DrawRect( -self.HalfBaseHorSize, self.VertFontSize, self.BaseHorSize, self.VertFontSize * 3 )

		draw.ShadowText( self:GetArmorName(), baseFont, 0, self.HalfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.ShadowText( "Schützt " .. CInventory:TranslateArmor( type ), ammoText, 0, self.VertFontSize + self.HalfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		if type == "Arm" or type == "Leg" then
			draw.ShadowText( "Zustand (links): " .. ( ( health / ArmorTypes[type][tier].health or 0 ) * 100 ) .. "%", ammoText, 0, self.VertFontSize * 2 + self.HalfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.ShadowText( "Zustand (rechts): " .. ( ( rightHealth / ArmorTypes[type][tier].health or 0 ) * 100 ) .. "%", ammoText, 0, self.VertFontSize * 3 + self.HalfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			draw.ShadowText( "Zustand: " .. ( ( health / ArmorTypes[type][tier].health or 0 ) * 100 ) .. "%", ammoText, 0, self.VertFontSize * 2 + self.HalfVertFontSize, white, black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	cam.End3D2D()
end

function ENT:GetTopPartColor()
	return CustomizableWeaponry.ITEM_PACKS_TOP_COLOR.r, CustomizableWeaponry.ITEM_PACKS_TOP_COLOR.g, CustomizableWeaponry.ITEM_PACKS_TOP_COLOR.b, CustomizableWeaponry.ITEM_PACKS_TOP_COLOR.a
end

function ENT:Think()
end