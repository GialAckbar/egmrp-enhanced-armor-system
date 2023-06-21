ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Base Armor Entity"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = "EGM:RP"

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "ArmorName" )
    self:NetworkVar( "String", 1, "Type" )
    self:NetworkVar( "Int", 0, "Tier" )
    self:NetworkVar( "Int", 1, "ArmorHealth" )
    self:NetworkVar( "Int", 2, "RightHealth" )

    if SERVER then
        self:NetworkVarNotify( "Tier", self.OnTierChanged )
        self:NetworkVarNotify( "Type", self.OnTypeChanged )
        self:SetValues()
    end
end