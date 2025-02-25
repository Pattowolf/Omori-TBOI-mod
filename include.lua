local path = "resources/scripts/"
local players = "players/"
local far = players .. "Faraway/"
local dw = players .. "Dreamworld/"
local knifeSyn = "misc/KnifeSynergies/"
local items = "items/"
local passives = items .. "Passives/"
local actives = items .. "Actives/"

local scriptTable = {
	"definitions",
	"functions/piberFuncs",
	"functions/functions",
	passives .. "shinyknife",
	passives .. "MrPlantEgg",
	passives .. "NailBat",
	actives .. "EmotionChart",
	actives .. "CalmDown",
	actives .. "Overcome",
	dw .. "Omori",
	dw .. "Aubrey",
	far .. "Sunny",
	far .. "Aubrey",
	"misc/EmotionRender",
	"misc/EmotionLogic",
	"misc/Hud_Helper",
	"misc/MeleeWeaponApi-main/main",
	"translations",

	knifeSyn .. "Brimstone",
	knifeSyn .. "SpiritSword",
	knifeSyn .. "GodHead",
	knifeSyn .. "TechX",
	knifeSyn .. "HolyLight",
	knifeSyn .. "Terra",
	knifeSyn .. "Ludovico",
	knifeSyn .. "JacobsLadder",
	knifeSyn .. "MomsKnife",
	knifeSyn .. "OcularRift",
	knifeSyn .. "ChocolateMilk",
	knifeSyn .. "Technology",
	knifeSyn .. "HeadOfTheKeeper",
	knifeSyn .. "BombItems",
	knifeSyn .. "TearFlags",
	knifeSyn .. "DamageAdders",
	knifeSyn .. "CompoundFracture",
	knifeSyn .. "PlaydoughCookie",
}

for _, v in ipairs(scriptTable) do
	include(path .. v)
end