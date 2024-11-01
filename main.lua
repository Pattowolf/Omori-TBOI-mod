-- Omori Mod's (Totally Not Lifted) Code. (Thanks Sag)-

-- Rework trabajado por Kotry / Rework made by Kotry 

OmoriMod = RegisterMod("Omori", 1)
local mod = OmoriMod
local game = Game()
local modrng = RNG()

OmoriMod.Enums = {}

if not REPENTOGON then return end

local myFolder = "resources.scripts.OmoriLibraryOfIsaac"
local LOCAL_TSIL = require(myFolder .. ".TSIL")
LOCAL_TSIL.Init(myFolder)

-- Globals

-- Players
OmoriMod.Enums.PlayerType = {}
OmoriMod.Enums.PlayerType.PLAYER_OMORI = Isaac.GetPlayerTypeByName("Omori")
OmoriMod.Enums.PlayerType.PLAYER_OMORI_B = Isaac.GetPlayerTypeByName("Sunny", true)
--

-- Null Items
OmoriMod.Enums.NullItemID = {}
OmoriMod.Enums.NullItemID.ID_OMORI = Isaac.GetCostumeIdByPath("gfx/characters/costume_omori.anm2")
OmoriMod.Enums.NullItemID.ID_SUNNY = Isaac.GetCostumeIdByPath("gfx/characters/costume_omori2.anm2")
OmoriMod.Enums.NullItemID.ID_OMORI_EMOTION = Isaac.GetCostumeIdByPath("gfx/characters/costume_omori_emotion.anm2")
OmoriMod.Enums.NullItemID.ID_SUNNY_EMOTION = Isaac.GetCostumeIdByPath("gfx/characters/costume_omori2_emotion.anm2")

-- SoundEffects
OmoriMod.Enums.SoundEffect = {}
OmoriMod.Enums.SoundEffect.SOUND_BLADE_SLASH = Isaac.GetSoundIdByName("Blade Slash")
OmoriMod.Enums.SoundEffect.SOUND_OMORI_HEART_BEAT = Isaac.GetSoundIdByName("Heartbeat")
OmoriMod.Enums.SoundEffect.SOUND_VIOLIN_BOW_SLASH = Isaac.GetSoundIdByName("Bow Slash")
OmoriMod.Enums.SoundEffect.SOUND_OMORI_FEAR = Isaac.GetSoundIdByName("Omori Fear")
OmoriMod.Enums.SoundEffect.SOUND_CALM_DOWN = Isaac.GetSoundIdByName("Calm Down")
OmoriMod.Enums.SoundEffect.SOUND_OVERCOME = Isaac.GetSoundIdByName("Overcome")

OmoriMod.Enums.SoundEffect.SOUND_RIGHT_IN_THE_HEART = Isaac.GetSoundIdByName("Right In The Heart")
OmoriMod.Enums.SoundEffect.SOUND_MISS_ATTACK = Isaac.GetSoundIdByName("Fail Attack")

OmoriMod.Enums.SoundEffect.SOUND_HAPPY_UPGRADE = Isaac.GetSoundIdByName("Happy Upgrade")
OmoriMod.Enums.SoundEffect.SOUND_HAPPY_UPGRADE_2 = Isaac.GetSoundIdByName("Happy Upgrade 2")
OmoriMod.Enums.SoundEffect.SOUND_HAPPY_UPGRADE_3 = Isaac.GetSoundIdByName("Happy Upgrade 3")
OmoriMod.Enums.SoundEffect.SOUND_SAD_UPGRADE = Isaac.GetSoundIdByName("Sad Upgrade")
OmoriMod.Enums.SoundEffect.SOUND_SAD_UPGRADE_2 = Isaac.GetSoundIdByName("Sad Upgrade 2")
OmoriMod.Enums.SoundEffect.SOUND_SAD_UPGRADE_3 = Isaac.GetSoundIdByName("Sad Upgrade 3")
OmoriMod.Enums.SoundEffect.SOUND_ANGRY_UPGRADE = Isaac.GetSoundIdByName("Angry Upgrade")
OmoriMod.Enums.SoundEffect.SOUND_ANGRY_UPGRADE_2 = Isaac.GetSoundIdByName("Angry Upgrade 2")
OmoriMod.Enums.SoundEffect.SOUND_ANGRY_UPGRADE_3 = Isaac.GetSoundIdByName("Angry Upgrade 3")
OmoriMod.Enums.SoundEffect.SOUND_BACK_NEUTRAL = Isaac.GetSoundIdByName("Back to Neutral")
--

-- Effects 
OmoriMod.Enums.EffectVariant = {}
OmoriMod.Enums.EffectVariant.EFFECT_EMOTION_GLOW = Isaac.GetEntityVariantByName("Emotion Glow")
OmoriMod.Enums.EffectVariant.EFFECT_SHINY_KNIFE = Isaac.GetEntityVariantByName("Shiny Knife")
--

-- Collectibles
OmoriMod.Enums.CollectibleType = {}
OmoriMod.Enums.CollectibleType.COLLECTIBLE_SHINY_KNIFE = Isaac.GetItemIdByName("Shiny Knife")
OmoriMod.Enums.CollectibleType.COLLECTIBLE_SELF_HELP_GUIDE = Isaac.GetItemIdByName("Self-Help Guide")
OmoriMod.Enums.CollectibleType.COLLECTIBLE_CALM_DOWN = Isaac.GetItemIdByName("Calm Down")
OmoriMod.Enums.CollectibleType.COLLECTIBLE_OVERCOME = Isaac.GetItemIdByName("Overcome")
--

-- Globals end

OmoriMod.costumeProtector = include("resources.scripts.characterCostumeProtector")
OmoriMod.costumeProtector:Init(OmoriMod)



-- if REPENTOGON then
-- include("resources.scripts.EID")
include("resources.scripts.functions.piberFuncs")
include("resources.scripts.functions.functions")
include("resources.scripts.items.shinyknife")
include("resources.scripts.items.SelfHelpGuide")
include("resources.scripts.items.CalmDown")
include("resources.scripts.items.Overcome")
include("resources.scripts.players.Omori")
include("resources.scripts.players.Sunny")
include("resources.scripts.misc.EmotionRender")
include("resources.scripts.misc.EmotionLogic")
include("resources.scripts.translations")


function mod:setRNGseed(isContinue)
	modrng:SetSeed(game:GetSeeds():GetStartSeed(), 35)
	for key, player in pairs(OmoriMod:GetPlayers()) do
		OmoriMod.SetEmotion(player, OmoriMod.saveManager.GetRunSave().PlayerEmotion)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.setRNGseed)

function mod:OnGameExit(bool)
	for key, player in pairs(OmoriMod:GetPlayers()) do
		OmoriMod.saveManager.GetRunSave().PlayerEmotion = OmoriMod.GetEmotion(player)
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.OnGameExit)

OmoriMod.saveManager = include("resources.scripts.misc.save_manager") 
OmoriMod.saveManager.Init(OmoriMod)

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