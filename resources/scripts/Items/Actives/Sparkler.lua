local mod = OmoriMod
local enums = mod.Enums
local items = enums.CollectibleType

local Table1 = {
    ["Neutral"] = "Happy",
    ["Happy"] = "Ecstatic",
    ["Ecstatic"] = "Manic",
}

---@param player EntityPlayer
function mod:OnSparklerUse(_, _, player)
    mod.EmotionUpdateItem(player, Table1, "Happy","Ecstatic", "Manic")
    return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.OnSparklerUse, items.COLLECTIBLE_SPARKLER)

function mod:myFunction(ID, Volume, FrameDelay, Loop, Pitch, Pan)
    local random = mod.randomfloat(0.8, 1.2, enums.Utils.RNG)
    
    if ID == 194 or ID == 195 then
        return {ID, Volume, FrameDelay, false, random, Pan}
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, mod.myFunction)