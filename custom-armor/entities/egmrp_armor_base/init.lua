AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/dayz/vest_police.mdl" )

    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use( activator )
    if not activator:IsPlayer() and activator:Alive() then return end

    local char = activator:GetCurrentCharacter()
    if not char then return end

    local success = char:GiveArmor( { Type = self:GetType(), Tier = self:GetTier(), Health = self:GetArmorHealth(), RightHealth = self:GetRightHealth() }, 1 )
    if not success then
        Notify:Danger( activator, "Nicht genug Platz!", "Du hast nicht genug Platz, um diese Rüstung aufzuheben!" )
        return
    end

    SafeRemoveEntity( self )
end

function ENT:SetValues()
    self:SetArmorName( "Rüstung" )
    self:SetType( "chest" )
    self:SetTier( 1 )
    self:SetArmorHealth( 100 )
    self:SetRightHealth( 0 )
end

function ENT:OnTierChanged( name, old, new )
    if name ~= "Tier" then return end

    local type = self:GetType()

    if not ArmorTypes[type] or not ArmorTypes[type][new] then return end

    if ArmorTypes[type][new].Model then
        self:SetModel( ArmorTypes[type][new].Model )
    end

    if ArmorTypes[type][new].Name then
        self:SetArmorName( ArmorTypes[type][new].Name )
    end
end

function ENT:OnTypeChanged( name, old, new )
    if name ~= "Type" then return end

    local tier = self:GetTier()

    if not ArmorTypes[new] or not ArmorTypes[new][tier] then return end

    if ArmorTypes[new][tier].Name then
        self:SetArmorName( ArmorTypes[new][tier].Name )
    end
end