function ArmorTypes:OpenMenu()
    local w, h = ScrW() * 0.4, ScrH() * 0.45
    local selectedArmor = ""

    self:CloseMenu()

    self.Frame = vgui.Create("DFrame")
    self.Frame:SetPos((ScrW() - w) / 2, (ScrH() - h) / 2)
    self.Frame:SetSize(w, h)
    self.Frame:SetTitle("")
    self.Frame:ShowCloseButton(false)
    function self.Frame:Paint(width, height)
		draw.RoundedBox(0, 0, 0, width, height, GetColor("darkgray"))
		self:DrawOutlinedRect()
	end

    self.Title = vgui.Create("DPanel", self.Frame)
    self.Title:SetPos(w * 0.1, h * 0.01)
    self.Title:SetSize(w * 0.8, h * 0.12)
    function self.Title:Paint(width, height)
		draw.RoundedBox(0, w * 0.05, 0, width - w * 0.05 * 2, height, UI.BackgroundColor2)

		surface.SetDrawColor(UI.BackgroundColor2)
		draw.NoTexture()

		surface.DrawPoly({
			{x = 0, y = 0},
			{x = w * 0.051, y = 0},
			{x = w * 0.051, y = height}
		})
		surface.DrawPoly({
			{x = width - w * 0.051, y = 0},
			{x = width, y = 0},
			{x = width - w * 0.051, y = height}
		})

		draw.DrawText("Wähle deine Rüstung", "EGMText", width / 2, height * 0.15, UI.ForegroundColor, TEXT_ALIGN_CENTER)
	end

    self.Close = vgui.Create("EGMCloseButton", self.Frame)
	self.Close:SetPanel(self.Frame)
	self.Close:SetPos(w * 0.95, h * 0.01)
	self.Close:SetSize(h * 0.07, h * 0.07)

    self.ArmorList = vgui.Create("EGMListView", self.Frame)
	self.ArmorList:SetSize(w * 0.5, h * 0.6)
	self.ArmorList:SetPos(w * 0.005, h * 0.2)
	self.ArmorList:SetMultiSelect(false)
	self.ArmorList:SetSortable(false)
	self.ArmorList:SetHeaderHeight(h * 0.1)
	self.ArmorList:SetDataHeight(h * 0.075)
	self.ArmorList:AddCustomColumn("Aufsätze")
    function self.ArmorList:OnRowSelected(index, line)
		local infoPanel = ArmorTypes.ArmorInfo
		local armor = line.armor

		infoPanel:SetText("")

		infoPanel:InsertColorChange(GetColor2("blue"))
		infoPanel:AppendText(ArmorTypes[ArmorTypes.Shop[armor].Class][ArmorTypes.Shop[armor].Tier].Name .. "\n\n")
		infoPanel:InsertColorChange(GetColor2("white"))
        infoPanel:AppendText( "Benötigte Slots: " .. ( ArmorTypes[ArmorTypes.Shop[armor].Class][ArmorTypes.Shop[armor].Tier].space or CInventory.ArmorSlots[ArmorTypes.Shop[armor].Class] ) .. "\n" )
		infoPanel:AppendText( "Gewicht: " .. ( ArmorTypes[ArmorTypes.Shop[armor].Class][ArmorTypes.Shop[armor].Tier].weight or CInventory.ArmorWeights[ArmorTypes.Shop[armor].Class] ) .. "\n\n" )
        infoPanel:AppendText( "(Doppelklick zum Ausrüsten)" )

		selectedArmor = armor
	end
	function self.ArmorList:DoDoubleClick( lineID, line )
		net.Start( "ArmorVendor.BuyArmor" )
			net.WriteInt( line.armor, 11 )
		net.SendToServer()
	end
	function self.ArmorList:Refresh(searchValue)
		if not searchValue then searchValue = "" end
		self:Clear()

		for armor, armorData in pairs( ArmorTypes.Shop ) do
			if string.find(string.lower(ArmorTypes[armorData.Class][armorData.Tier].Name), string.lower(searchValue)) then
				local line = self:AddCustomLine(ArmorTypes[armorData.Class][armorData.Tier].Name)
				line.armor = armor
				line.armorData = armorData
			end
		end
	end
	self.ArmorList:Refresh()

	self.ArmorFilter = vgui.Create("DTextEntry", self.Frame)
	self.ArmorFilter:SetPos(w * 0.005, h * 0.91)
	self.ArmorFilter:SetSize(w * 0.5, h * 0.08)
	self.ArmorFilter:SetUpdateOnType(false)
	self.ArmorFilter:SetPlaceholderText("Rüstung suchen...")
	function self.ArmorFilter:OnValueChange(newFilter)
		ArmorTypes.ArmorList:Refresh(newFilter)
	end

	self.ArmorInfo = vgui.Create("RichText", self.Frame)
	self.ArmorInfo:SetSize(w * 0.5, h * 0.7)
	self.ArmorInfo:SetPos(w * 0.51, h * 0.2)
	self.ArmorInfo:SetVerticalScrollbarEnabled(false)
	self.ArmorInfo:SetText("")
	function self.ArmorInfo:PerformLayout()
		self:SetFontInternal("EGMText10")
	end

	self.Frame:MakePopup()
end

function ArmorTypes:CloseMenu()
	if IsValid( self.Frame ) then
		self.Frame:Close()
	end
end

net.Receive( "ArmorVendor.OpenMenu", function()
    ArmorTypes:OpenMenu()
end )