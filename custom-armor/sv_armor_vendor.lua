util.AddNetworkString( "ArmorVendor.BuyArmor" )

net.Receive( "ArmorVendor.BuyArmor", function( len, ply )
    local index = net.ReadInt( 11 )

    if not ArmorTypes.Shop[index] then
        Notify:Danger( ply, "Ungültige Rüstung!", "Die von dir gewählte Rüstung ist nicht gültig!" )
        return
    end

    local char = ply:GetCurrentCharacter()
    if not char then return end

    local data = ArmorTypes.Shop[index]
    local class = data.Class or "Chest"
    local tier = data.Tier or 1

    local success = char:GiveArmor( { Type = class, Tier = tier }, 1 )

    if not success then
        Notify:Danger( ply, "Nicht genug Platz!", "Du hast nicht genug Platz im Inventar, um die Rüstung rauszuholen!" )
        return
    end

    Notify:Success( ply, "Rüstung abgeholt!", "Du kannst nun die Rüstung über das Inventar anziehen!" )
end )