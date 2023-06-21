AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

util.AddNetworkString( "ArmorVendor.OpenMenu" )
function ENT:Use( ply )
    net.Start( "ArmorVendor.OpenMenu" )
    net.Send( ply )

    self:EmitSound( "doors/door1_move.wav", 100, math.random( 75, 100 ) )
end