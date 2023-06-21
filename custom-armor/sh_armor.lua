local Player = FindMetaTable( "Player" )


-- Returns the current Tier of a specific armorType (0 counts as no Armor equipped).
--
-- @param String armorType
-- ?@param any fallback = -1
-- @return any Tier of given armorType as Number or fallback
function Player:GetArmorTier( armorType, fallback )
    if not armorType then return fallback or -1 end

    if armorType == "Arm" or armorType == "Leg" then
        return self:GetNWInt( "Left" .. armorType .. "ArmorTier", fallback or -1 ), self:GetNWInt( "Right" .. armorType .. "ArmorTier", fallback or -1 )
    end

    return self:GetNWInt( armorType .. "ArmorTier", fallback or -1 )
end


-- Returns the current Health of a specific armorType.
--
-- @param String armorType
-- ?@param any fallback = 0
-- @return any Health of given armorType as Number or fallback
function Player:GetArmorHealth( armorType, fallback )
    if not armorType then return fallback or 0 end

    if armorType == "Arm" or armorType == "Leg" then
        return self:GetNWInt( "Left" .. armorType .. "ArmorHealth", fallback or 0 ), self:GetNWInt( "Right" .. armorType .. "ArmorHealth", fallback or 0 )
    end

    return self:GetNWInt( armorType .. "ArmorHealth", fallback or 0 )
end


-- Returns a table containing all information about the player's currently equipped Armor (Tier and Health).
--
-- @return Table with information about the player's currently equipped Armor.
function Player:GetEquippedArmor()
    return {
       Head = { Tier = self:GetNWInt( "HeadArmorTier" ), Health = self:GetNWInt( "HeadArmorHealth" ) },
       Chest = { Tier = self:GetNWInt( "ChestArmorTier" ), Health = self:GetNWInt( "ChestArmorHealth" ) },
       LeftArm = { Tier = self:GetNWInt( "LeftArmArmorTier" ), Health = self:GetNWInt( "LeftArmArmorHealth" ) },
       RightArm = { Tier = self:GetNWInt( "RightArmArmorTier" ), Health = self:GetNWInt( "RightArmArmorHealth" ) },
       LeftLeg = { Tier = self:GetNWInt( "LeftLegArmorTier" ), Health = self:GetNWInt( "LeftLegArmorHealth" ) },
       RightLeg = { Tier = self:GetNWInt( "RightLegArmorTier" ), Health = self:GetNWInt( "RightLegArmorHealth" ) }
    }
end


local function CreateEntity( type, tier )
    local ENT = {}

    ENT.Base = "egmrp_armor_base"
    ENT.ClassName = "egmrp_" .. string.lower( type ) .. "_tier" .. tier

    ENT.PrintName = ArmorTypes[type][tier].Name or ENT.ClassName
    ENT.Category = "EGM:RP Rüstungen"
    ENT.Spawnable = true

    function ENT:SetValues()
        self:SetArmorName( self.PrintName )
        self:SetType( type )
        self:SetTier( tier )
        self:SetArmorHealth( ArmorTypes[type][tier].health or 100 )
        self:SetRightHealth( ArmorTypes[type][tier].health or 100 )
    end

    scripted_ents.Register( ENT, ENT.ClassName )
end

for i = 1, #ArmorTypes.Head do
    CreateEntity( "Head", i )
end

for i = 1, #ArmorTypes.Chest do
    CreateEntity( "Chest", i )
end

for i = 1, #ArmorTypes.Arm do
    CreateEntity( "Arm", i )
end

for i = 1, #ArmorTypes.Leg do
    CreateEntity( "Leg", i )
end