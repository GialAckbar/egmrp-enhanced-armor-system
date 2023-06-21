ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Rüstungs-Schrank"
ENT.Category = "EGM:RP"
ENT.Author = "Gial Ackbar"
ENT.Purpose = ""

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.WorldModel = "models/props_wasteland/controlroom_storagecloset001a.mdl"

function ENT:Initialize()
    self.WorldModel = "models/props_wasteland/controlroom_storagecloset001a.mdl"

    if util.IsValidModel( self.WorldModel ) then
        self:SetModel( self.WorldModel )
    else
        self:SetModel( "models/props_wasteland/controlroom_storagecloset001a.mdl" )
    end
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    if SERVER then
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetUseType( SIMPLE_USE )
    end

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
        phys:SetMass( 50 )
    end
end