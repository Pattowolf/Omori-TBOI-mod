local mod = OmoriMod
local enums = mod.Enums
local items = enums.CollectibleType

local Table1 = {
    ["Neutral"] = "Angry",
    ["Angry"] = "Enraged",
    ["Enraged"] = "Furious",
}

---@param player EntityPlayer
function mod:OnSparklerUse(_, _, player)
    mod.EmotionUpdateItem(player, Table1, "Angry", "Enraged", "Furious")
    return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.OnSparklerUse, items.COLLECTIBLE_PRESENT)