AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Draw()
    self:DrawModel()
end