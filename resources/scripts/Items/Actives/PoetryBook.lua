local mod = OmoriMod
local enums = mod.Enums
local items = enums.CollectibleType

local Table1 = {
    ["Neutral"] = "Sad",
    ["Sad"] = "Depressed",
    ["Depressed"] = "Miserable",
}

---@param player EntityPlayer
function mod:OnSparklerUse(_, _, player)
    mod.EmotionUpdateItem(player, Table1, "Sad", "Depressed", "Miserable")
    return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.OnSparklerUse, items.COLLECTIBLE_POETRY_BOOK)