OmoriMod.Enums = {
	PlayerType = {
		PLAYER_OMORI = Isaac.GetPlayerTypeByName("Omori"),
		PLAYER_OMORI_B = Isaac.GetPlayerTypeByName("Sunny", true),
	},
	NullItemID = {
		ID_OMORI = Isaac.GetCostumeIdByPath("gfx/characters/costume_omori.anm2"),
		ID_SUNNY = Isaac.GetCostumeIdByPath("gfx/characters/costume_omori2.anm2"),
		ID_OMORI_EMOTION = Isaac.GetCostumeIdByPath("gfx/characters/costume_omori_emotion.anm2"),
		ID_SUNNY_EMOTION = Isaac.GetCostumeIdByPath("gfx/characters/costume_omori2_emotion.anm2"),
	},
	SoundEffect = {
		SOUND_BLADE_SLASH = Isaac.GetSoundIdByName("Blade Slash"),
		SOUND_OMORI_HEART_BEAT = Isaac.GetSoundIdByName("Heartbeat"),
		SOUND_VIOLIN_BOW_SLASH = Isaac.GetSoundIdByName("Bow Slash"),
		SOUND_OMORI_FEAR = Isaac.GetSoundIdByName("Omori Fear"),
		SOUND_CALM_DOWN = Isaac.GetSoundIdByName("Calm Down"),
		SOUND_OVERCOME = Isaac.GetSoundIdByName("Overcome"),
		SOUND_RIGHT_IN_THE_HEART = Isaac.GetSoundIdByName("Right In The Heart"),
		SOUND_MISS_ATTACK = Isaac.GetSoundIdByName("Fail Attack"),
		SOUND_HAPPY_UPGRADE = Isaac.GetSoundIdByName("Happy Upgrade"),
		SOUND_HAPPY_UPGRADE_2 = Isaac.GetSoundIdByName("Happy Upgrade 2"),
		SOUND_HAPPY_UPGRADE_3 = Isaac.GetSoundIdByName("Happy Upgrade 3"),
		SOUND_SAD_UPGRADE = Isaac.GetSoundIdByName("Sad Upgrade"),
		SOUND_SAD_UPGRADE_2 = Isaac.GetSoundIdByName("Sad Upgrade 2"),
		SOUND_SAD_UPGRADE_3 = Isaac.GetSoundIdByName("Sad Upgrade 3"),
		SOUND_ANGRY_UPGRADE = Isaac.GetSoundIdByName("Angry Upgrade"),
		SOUND_ANGRY_UPGRADE_2 = Isaac.GetSoundIdByName("Angry Upgrade 2"),
		SOUND_ANGRY_UPGRADE_3 = Isaac.GetSoundIdByName("Angry Upgrade 3"),
		SOUND_BACK_NEUTRAL = Isaac.GetSoundIdByName("Back to Neutral"),
	},
	EffectVariant = {
		EFFECT_EMOTION_GLOW = Isaac.GetEntityVariantByName("Emotion Glow"),
		EFFECT_SHINY_KNIFE = Isaac.GetEntityVariantByName("Shiny Knife"),
	
	},
	CollectibleType = {
		COLLECTIBLE_SHINY_KNIFE = Isaac.GetItemIdByName("Shiny Knife"),
		COLLECTIBLE_EMOTION_CHART = Isaac.GetItemIdByName("Emotion Chart"),
		COLLECTIBLE_CALM_DOWN = Isaac.GetItemIdByName("Calm Down"),
		COLLECTIBLE_OVERCOME = Isaac.GetItemIdByName("Overcome"),
	},
	Utils = {
		Game = Game(),
		SFX = SFXManager(),
		RNG = RNG(),
	},
	Tables = {
		NoDischargeEmotions = {
			["Neutral"] = true,
			["Manic"] = true,
			["Miserable"] = true,
			["Furious"] = true,
		},
		HappinessTiers = {
			["Happy"] = true,
			["Ecstatic"] = true,
			["Manic"] = true,
		},
		EmotionChartFrame = {
			Neutral = 0,
			Happy = 1,
			Sad = 2,
			Angry = 3,
		},
		EmotionUpgradesOmori = {
			["Happy"] = "Ecstatic",
			["Ecstatic"] = "Manic",
			["Sad"] = "Depressed",
			["Depressed"] = "Miserable",
			["Angry"] = "Enraged",
			["Enraged"] = "Furious",
		},
		EmotionUpgradesOmoriCarBattery = {
			["Happy"] = "Manic",
			["Ecstatic"] = "Manic",
			["Sad"] = "Miserable",
			["Depressed"] = "Miserable",
			["Angry"] = "Furious",
			["Enraged"] = "Furious",
		},
		EmotionUpgrades = {
			["Neutral"] = "Happy",
			["Happy"] = "Sad",
			["Sad"] = "Angry",
			["Angry"] = "Happy",
		},
		EmotionUpgradesCarBattery = {
			["Neutral"] = "Ecstatic",
			["Happy"] = "Depressed",
			["Sad"] = "Enraged",
			["Angry"] = "Ecstatic",
			["Ecstatic"] = "Depressed",
			["Depressed"] = "Enraged",
			["Enraged"] = "Ecstatic",
		},
		EmotionToChange = {
			["Neutral"] = "Happy",
			["Happy"] = "Sad",
			["Sad"] = "Angry",
			["Angry"] = "Neutral",
			["Ecstatic"] = "Sad",
			["Depressed"] = "Angry",
			["Enraged"] = "Neutral",
			["Manic"] = "Sad",
			["Miserable"] = "Angry",
			["Furious"] = "Neutral",
		},
		DamageAlterEmotions = {
			["Sad"] = { EmotionDamageMult = 0.75, damageMult = 1, birthrightMult = 0.9 },
			["Depressed"] = { EmotionDamageMult = 0.625, damageMult = 1, birthrightMult = 0.9 },
			["Miserable"] = { EmotionDamageMult = 0.5, damageMult = 1, birthrightMult = 0.9 },
			["Angry"] = { EmotionDamageMult = 1.3, damageMult = 1.2, birthrightMult = 1.15 },
			["Enraged"] = { EmotionDamageMult = 1.6, damageMult = 1.2, birthrightMult = 1.15 },
			["Furious"] = { EmotionDamageMult = 2, damageMult = 1.2, birthrightMult = 1.15 },
		},
		TearsAlterEmotions = {
			["Sad"] = { tearsMult = 1.3, birthrightMult = 1.2 },
			["Depressed"] = { tearsMult = 1.4, birthrightMult = 1.2 },
			["Miserable"] = { tearsMult = 1.5, birthrightMult = 1.2 },
			["Angry"] = { tearsMult = 0.8, birthrightMult = 0.9 },
			["Enraged"] = { tearsMult = 0.75, birthrightMult = 0.9 },
			["Furious"] = { tearsMult = 0.65, birthrightMult = 0.9 },
		},
		SpeedAlterEmotions = {
			["Happy"] = { speedMult = 1.25, birthrightMult = 1.1 },
			["Ecstatic"] = { speedMult = 1.375, birthrightMult = 1.1 },
			["Manic"] = { speedMult = 1.5, birthrightMult = 1.1 },
			["Sad"] = { speedMult = 0.8, birthrightMult = 0.9 },
			["Depressed"] = { speedMult = 0.7, birthrightMult = 0.9 },
			["Miserable"] = { speedMult = 0.6, birthrightMult = 0.9 },
		},
		LuckAlterEmotions = {
			["Happy"] = 1,
			["Ecstatic"] = 2,
			["Manic"] = 3,
		},
	},
	Misc = {
		SelfHelpRenderPos = Vector(16, 16),
		SelfHelpRenderScale = Vector.One,
	},
}
-- Globals end

local game = OmoriMod.Enums.Utils.Game

local function setRNG()
	local rng = OmoriMod.Enums.Utils.RNG
	local RECOMMENDED_SHIFT_IDX = 35
	
	local seeds = game:GetSeeds()
	local startSeed = seeds:GetStartSeed()
	
	rng:SetSeed(startSeed, RECOMMENDED_SHIFT_IDX)	
end

function OmoriMod:GameStartedFunction()
	setRNG()
end
OmoriMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, OmoriMod.GameStartedFunction)
OmoriMod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, OmoriMod.GameStartedFunction)

function OmoriMod:SetObjects()
	OmoriMod.Enums.Utils.Room = game:GetRoom()
	OmoriMod.Enums.Utils.Level = game:GetLevel()
	
	-- print(OmoriMod.Enums.Utils.Room, OmoriMod.Enums.Utils.Level)
end
OmoriMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, OmoriMod.SetObjects)