local path = "resources/scripts/"

local scriptTable = {
	"definitions",
	"functions/piberFuncs",
	"functions/functions",
	"items/shinyknife",
	"items/SelfHelpGuide",
	"items/CalmDown",
	"items/Overcome",
	"players/Omori",
	"players/Sunny",
	"players/AubreyHeadSpace",
	"misc/EmotionRender",
	"misc/EmotionLogic",
	"translations",
}

for k, v in pairs(scriptTable) do
	include(path .. v)
end