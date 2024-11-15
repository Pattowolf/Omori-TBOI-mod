-- Omori Mod's (Totally Not Lifted) Code. (Thanks Sag)-

-- Rework trabajado por Kotry / Rework made by Kotry 

OmoriMod = RegisterMod("Omori", 1)

if not REPENTOGON then 
    local font = Font()
    font:Load("font/pftempestasevencondensed.fnt")

    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        local text = "REPENTOGON is missing"
        local text2 = "check repentogon.com"
        font:DrawStringScaledUTF8(text, Isaac.GetScreenWidth()/1.1 - font:GetStringWidthUTF8(text)/2, Isaac.GetScreenHeight()/1.2, 1, 1, KColor(2,.5,.5,1), 1, true )
        font:DrawStringScaledUTF8(text2, Isaac.GetScreenWidth()/1.1 - font:GetStringWidthUTF8(text2)/2, Isaac.GetScreenHeight()/1.2 + 8, 1, 1, KColor(2,.5,.5,1), 1, true )
    end)

    return
end

local myFolder = "resources.scripts.OmoriLibraryOfIsaac"
local LOCAL_TSIL = require(myFolder .. ".TSIL")
LOCAL_TSIL.Init(myFolder)

OmoriMod.saveManager = include("resources.scripts.misc.save_manager") 
OmoriMod.saveManager.Init(OmoriMod)


-- Globals end

OmoriMod.costumeProtector = include("resources.scripts.characterCostumeProtector")
OmoriMod.costumeProtector:Init(OmoriMod)



-- if REPENTOGON then
-- include("resources.scripts.EID")
include("include")

-- function mod:setRNGseed(isContinue)
	-- modrng:SetSeed(game:GetSeeds():GetStartSeed(), 35)
	-- for key, player in pairs(OmoriMod:GetPlayers()) do
		-- OmoriMod.SetEmotion(player, OmoriMod.saveManager.GetRunSave().PlayerEmotion)
	-- end
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.setRNGseed)

-- function mod:OnGameExit(bool)
	-- for key, player in pairs(OmoriMod:GetPlayers()) do
		-- OmoriMod.saveManager.GetRunSave().PlayerEmotion = OmoriMod.GetEmotion(player)
	-- end
-- end
-- mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.OnGameExit)


include("resources/scripts/dss/deadseascrolls")
-- end

-- function mod:HealthStuff(player, amount, healthtype, optArg)
	-- print(amount)
	-- player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, mod.HealthStuff)

-- function mod:AddDamageOnHearts(player, cacheFlags)
	-- if cacheFlags == CacheFlag.CACHE_DAMAGE then
		-- player.Damage = player.Damage * (player:GetHearts())
	-- end
-- end
-- mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.AddDamageOnHearts)