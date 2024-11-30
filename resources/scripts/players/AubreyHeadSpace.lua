local mod = OmoriMod
local enums = OmoriMod.Enums
local costumes = enums.NullItemID

---comment
---@param player EntityPlayer
function mod:InitAubrey(player)
    if not (OmoriMod:IsAubrey(player, true) or OmoriMod:IsAubrey(player, false)) then return end
    print("asoidnasiod")

    player:AddNullCostume(costumes.ID_AUBREY)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.InitAubrey)