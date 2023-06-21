if not RequireModules({"realism"}) then
    return false
end

ArmorTypes = {}
ArmorTypes.Head = {}
ArmorTypes.Chest = {}
ArmorTypes.Arm = {}
ArmorTypes.LeftArm = {}
ArmorTypes.RightArm = {}
ArmorTypes.Leg = {}
ArmorTypes.LeftLeg = {}
ArmorTypes.RightLeg = {}

if SERVER then
    AddCSLuaFile("sh_config.lua")
    AddCSLuaFile("sh_armor.lua")
    AddCSLuaFile("cl_menu.lua")

    include("sh_config.lua")
    include("sh_armor.lua")
    include("sv_armor.lua")
    include("sv_armor_vendor.lua")
end

if CLIENT then
    include("sh_config.lua")
    include("sh_armor.lua")
    include("cl_menu.lua")
end