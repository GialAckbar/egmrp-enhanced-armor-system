local EGMRP = GM or GAMEMODE
local Player = FindMetaTable( "Player" )

-- Gives the player a Armor of choosen type and tier. Overrides Armor of same type!
-- Will use the default Health value of the tier if no Health value is passed.
-- If armorType = "Arm" or "Leg" then it applies to both left and right sides.
--
-- @param String armorType
-- @param Number tier
-- ?@param Number armorHealth
-- @return Boolean success
function Player:GiveArmorType( armorType, tier, armorHealth )
    if not isstring( armorType ) or not ArmorTypes[armorType] or not isnumber( tier ) or tier < 1 or tier > #ArmorTypes[armorType] or
    hook.Run( "PreGiveArmorType", self, armorType, tier, armorHealth ) == false then return false end

    local health = ( isnumber( armorHealth ) and armorHealth >= 0 ) and armorHealth or ArmorTypes[armorType][tier].health

    if armorType == "Arm" or armorType == "Leg" then
        self:SetNWInt( "Left" .. armorType .. "ArmorTier", tier )
        self:SetNWInt( "Right" .. armorType .. "ArmorTier", tier )
        self:SetNWInt( "Left" .. armorType .. "ArmorHealth", health )
        self:SetNWInt( "Right" .. armorType .. "ArmorHealth", health )
    else
        self:SetNWInt( armorType .. "ArmorTier", tier )
        self:SetNWInt( armorType .. "ArmorHealth", health )
    end

    hook.Run( "PostGiveArmorType", self, armorType, tier, armorHealth )
    return true
end

-- Called directly before equipping a Armor to a Player.
-- If armorType = "Arm" or "Leg" then it applies to both left and right sides.
-- Return false to prevent Player from equipping the Armor.
--
-- @param Player ply
-- @param String armorType
-- @param Number tier
-- ?@param Number armorHealth
hook.Add( "PreGiveArmorType", "ArmorTypes.PreGiveArmorType", function( ply, armorType, tier, armorHealth ) end )

-- Called directly after the Player equipped his Armor.
-- If armorType = "Arm" or "Leg" then it applies to both left and right sides.
--
-- @param Player ply
-- @param String armorType
-- @param Number tier
-- ?@param Number armorHealth
hook.Add( "PostGiveArmorType", "ArmorTypes.PostGiveArmorType", function( ply, armorType, tier, armorHealth ) end )


-- Removes a players Armor of specific type.
-- If armorType = "Arm" or "Leg" then it applies to both left and right sides.
-- If no type is given, all Armor will be removed.
--
-- ?@param String armorType
-- @return Boolean success
function Player:RemoveArmorType( armorType )
    if armorType then
        if not isstring( armorType ) or not ArmorTypes[armorType] or
        hook.Run( "PreRemoveArmorType", self, armorType ) == false then return false end

        if armorType == "Arm" or armorType == "Leg" then
            self:SetNWInt( "Left" .. armorType .. "ArmorTier", 0 )
            self:SetNWInt( "Right" .. armorType .. "ArmorTier", 0 )
            self:SetNWInt( "Left" .. armorType .. "ArmorHealth", 0 )
            self:SetNWInt( "Right" .. armorType .. "ArmorHealth", 0 )
        else
            self:SetNWInt( armorType .. "ArmorTier", 0 )
            self:SetNWInt( armorType .. "ArmorHealth", 0 )
        end

        hook.Run( "PostRemoveArmorType", self, armorType )
        return true
    end

    local returnTbl = {}
    for _, bodyPart in ipairs( { "Head", "Chest", "Arm", "Leg" } ) do
        table.insert( returnTbl, self:RemoveArmorType( bodyPart ) )
    end

    return unpack( returnTbl )
end

-- Called directly before removing the Armor from a Player.
-- If armorType = "Arm" or "Leg" then it applies to both left and right sides.
-- Not called when the player lost his Armor due to damage! (Use "OnArmorDestroyed" instead)
-- ply.ArmorDeath will be true if the player should lose their Armor due to death.
-- Return false to prevent Player from losing the Armor.
--
-- @param Player ply
-- @param String armorType
hook.Add( "PreRemoveArmorType", "ArmorTypes.PreRemoveArmorType", function( ply, armorType ) end )

-- Called directly after the Player lost his Armor.
-- If armorType = "Arm" or "Leg" then it applies to both left and right sides.
-- Not called when the player loses the Armor due to damage! (Use "OnArmorDestroyed" instead)
-- ply.ArmorDeath will be true if the player lost his Armor due to death.
--
-- @param Player ply
-- @param String armorType
hook.Add( "PostRemoveArmorType", "ArmorTypes.PostRemoveArmorType", function( ply, armorType ) end )


-- Calculates and applies damage to a player or NPC based on Armor (only for players) and damage multiplier
-- Used by ArmorTypes:ScaleDamage
--
-- @param Entity ent
-- @param String armorType
-- @param CTakeDamageInfo dmginfo
-- @param Number multiplier
function ArmorTypes:ApplyDamage( ent, armorType, dmginfo, multiplier )
    // Doesn't support Armor for NPC's (yet) -> Just apply multiplier and return
    if ent:IsNPC() then dmginfo:ScaleDamage( multiplier ) return end
    if not isstring( armorType ) or not ArmorTypes[armorType] then return end

    local tierTable = ArmorTypes[armorType]
    local tier = ent:GetNWInt( armorType .. "ArmorTier", 0 )

    // No armor -> Just apply multiplier and return
    if tier == 0 then
        dmginfo:ScaleDamage( multiplier )
        return
    end

    local dmg = dmginfo:GetDamage()
    local health = ent:GetNWInt( armorType .. "ArmorHealth", 0 )
    local remainHealth = health - dmg
    multiplier = tierTable[tier].disableMultiplier and 1 or multiplier

    // Armor gets destoryed -> Reduced damage with remaining health + piercing damage
    if remainHealth <= 0 then
        dmg = health * ( 1 - tierTable[tier].reduction ) * multiplier - ( remainHealth * multiplier )
        ent:SetNWInt( armorType .. "ArmorTier", 0 )
        ent:SetNWInt( armorType .. "ArmorHealth", 0 )
        hook.Run( "OnArmorDestroyed", ent, armorType, tier )

    // Armor survives -> Only reduced damage, no piercing damage
    else
        dmg = dmg * ( 1 - tierTable[tier].reduction ) * multiplier
        ent:SetNWInt( armorType .. "ArmorHealth", remainHealth )
    end

    dmginfo:SetDamage( dmg )
end

-- Scales the damage based on the hitgroup of the entity
-- Used by GM:ScalePlayerDamage and GM:ScaleNPCDamage
--
-- @param Entity ent
-- @param Number hitgroup
-- @param CTakeDamageInfo dmginfo
function ArmorTypes:ScaleDamage( ent, hitgroup, dmginfo )
    // In case the Realism module is disabled
    local Realism = Realism or {}

    if hitgroup == HITGROUP_HEAD then
        self:ApplyDamage( ent, "Head", dmginfo, Realism.DamageSystemEnabled and Realism.HeadDamageMultiplier or 1 )
    elseif hitgroup == HITGROUP_CHEST then
        self:ApplyDamage( ent, "Chest", dmginfo, Realism.DamageSystemEnabled and Realism.ChestDamageMultiplier or 1 )
    elseif hitgroup == HITGROUP_STOMACH or hitgroup == HITGROUP_GEAR then
        self:ApplyDamage( ent, "Chest", dmginfo, Realism.DamageSystemEnabled and Realism.StomachDamageMultiplier or 1 )
    elseif hitgroup == HITGROUP_LEFTARM then
        self:ApplyDamage( ent, "LeftArm", dmginfo, Realism.DamageSystemEnabled and Realism.ArmDamageMultiplier or 1 )
    elseif hitgroup == HITGROUP_RIGHTARM then
        self:ApplyDamage( ent, "RightArm", dmginfo, Realism.DamageSystemEnabled and Realism.ArmDamageMultiplier or 1 )
    elseif hitgroup == HITGROUP_LEFTLEG then
        self:ApplyDamage( ent, "LeftLeg", dmginfo, Realism.DamageSystemEnabled and Realism.LegDamageMultiplier or 1 )
    elseif hitgroup == HITGROUP_RIGHTLEG then
        self:ApplyDamage( ent, "RightLeg", dmginfo, Realism.DamageSystemEnabled and Realism.LegDamageMultiplier or 1 )
    end
end

-- https://wiki.facepunch.com/gmod/GM:ScalePlayerDamage
function EGMRP:ScalePlayerDamage( ply, hitgroup, dmginfo )
    ArmorTypes:ScaleDamage( ply, hitgroup, dmginfo )
end

-- https://wiki.facepunch.com/gmod/GM:ScaleNPCDamage
function EGMRP:ScaleNPCDamage( npc, hitgroup, dmginfo )
    ArmorTypes:ScaleDamage( npc, hitgroup, dmginfo )
end

local function RemoveArmorOnDeath( ply )
    if not ply.ChangingCharacter then
        ply.LastDeathHeadArmorTier = ply:GetNWInt( "HeadArmorTier", 0 )
        ply.LastDeathHeadArmorHealth = ply:GetNWInt( "HeadArmorHealth", 0 )

        ply.LastDeathChestArmorTier = ply:GetNWInt( "ChestArmorTier", 0 )
        ply.LastDeathChestArmorHealth = ply:GetNWInt( "ChestArmorHealth", 0 )

        ply.LastDeathLeftArmArmorTier = ply:GetNWInt( "LeftArmArmorTier", 0 )
        ply.LastDeathLeftArmArmorHealth = ply:GetNWInt( "LeftArmArmorHealth", 0 )

        ply.LastDeathRightArmArmorTier = ply:GetNWInt( "RightArmArmorTier", 0 )
        ply.LastDeathRightArmArmorHealth = ply:GetNWInt( "RightArmArmorHealth", 0 )

        ply.LastDeathLeftLegArmorTier = ply:GetNWInt( "LeftLegArmorTier", 0 )
        ply.LastDeathLeftLegArmorHealth = ply:GetNWInt( "LeftLegArmorHealth", 0 )

        ply.LastDeathRightLegArmorTier = ply:GetNWInt( "RightLegArmorTier", 0 )
        ply.LastDeathRightLegArmorHealth = ply:GetNWInt( "RightLegArmorHealth", 0 )
    end

    ply.ArmorDeath = true
    ply:RemoveArmorType()
    ply.ArmorDeath = false
end
hook.Add( "PlayerDeath", "ArmorTypes.RemoveOnDeath", RemoveArmorOnDeath )
hook.Add( "PlayerSilentDeath", "ArmorTypes.RemoveOnSilentDeath", RemoveArmorOnDeath )

hook.Add( "DeathSystem.Revive", "ArmorTypes.ResetOnRevive", function( ply )
    ply:SetNWInt( "HeadArmorTier", ply.LastDeathHeadArmorTier or 0 )
    ply:SetNWInt( "HeadArmorHealth", ply.LastDeathHeadArmorHealth or 0 )

    ply:SetNWInt( "ChestArmorTier", ply.LastDeathChestArmorTier or 0 )
    ply:SetNWInt( "ChestArmorHealth", ply.LastDeathChestArmorHealth or 0 )

    ply:SetNWInt( "LeftArmArmorTier", ply.LastDeathLeftArmArmorTier or 0 )
    ply:SetNWInt( "LeftArmArmorHealth", ply.LastDeathLeftArmArmorHealth or 0 )

    ply:SetNWInt( "RightArmArmorTier", ply.LastDeathRightArmArmorTier or 0 )
    ply:SetNWInt( "RightArmArmorHealth", ply.LastDeathRightArmArmorHealth or 0 )

    ply:SetNWInt( "LeftLegArmorTier", ply.LastDeathLeftLegArmorTier or 0 )
    ply:SetNWInt( "LeftLegArmorHealth", ply.LastDeathLeftLegArmorHealth or 0 )

    ply:SetNWInt( "RightLegArmorTier", ply.LastDeathRightLegArmorTier or 0 )
    ply:SetNWInt( "RightLegArmorHealth", ply.LastDeathRightLegArmorHealth or 0 )
end )

local function CreateEntity( armorType, tier )
    local ENT = {}

    ENT.Base = "egmrp_armor_base"
    ENT.ClassName = "egmrp_" .. string.lower( armorType ) .. "_tier" .. tier

    ENT.PrintName = ArmorTypes[armorType][tier].Name or armorType .. " Tier " .. tier
    ENT.Category = "EGM:RP Rüstungen"
    ENT.Spawnable = true

    function ENT:SetValues()
        self:SetArmorName( self.PrintName )
        self:SetType( armorType )
        self:SetTier( tier )
        self:SetArmorHealth( ArmorTypes[armorType][tier].health or 100 )
        self:SetRightHealth( ArmorTypes[armorType][tier].health or 100 )
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