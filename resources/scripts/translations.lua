-- Debe haber una mejor manera de hacer esto

local itemConfig = Isaac.GetItemConfig()

-- local items = {
	-- [OmoriMod.Enums.CollectibleType.COLLECTIBLE_SHINY_KNIFE] = 
	-- {Name = "Cuchillo Brillante", Description = "Puedes ver tu reflejo en la hoja"},
	-- [OmoriMod.Enums.CollectibleType.COLLECTIBLE_SELF_HELP_GUIDE] = {Name = "Guía de auto-ayuda", Description = "Un libro sobre batallas, escrito por HERO. Wow..."},
	-- [OmoriMod.Enums.CollectibleType.COLLECTIBLE_CALM_DOWN] = {Name = "Calmarse", Description = "Respira profundo"},
	-- [OmoriMod.Enums.CollectibleType.COLLECTIBLE_OVERCOME] = {Name = "Superar", Description = "Ármate de valor"},
-- }


if Options.Language == "es" then
	local items = {
		[OmoriMod.Enums.CollectibleType.COLLECTIBLE_SHINY_KNIFE] = {Name = "Cuchillo Brillante", Description = "Puedes ver tu reflejo en la hoja"},
		[OmoriMod.Enums.CollectibleType.COLLECTIBLE_SELF_HELP_GUIDE] = {Name = "Cuadro de emociones", Description = "Una guía sobre emociones"},
		[OmoriMod.Enums.CollectibleType.COLLECTIBLE_CALM_DOWN] = {Name = "Calmarse", Description = "Respira profundo"},
		[OmoriMod.Enums.CollectibleType.COLLECTIBLE_OVERCOME] = {Name = "Superar", Description = "Ármate de valor"},
	}
	
	for key, value in pairs(items) do
		itemConfig:GetCollectible(key).Name = items[key].Name
		itemConfig:GetCollectible(key).Description = items[key].Description
	end
end

local Alumnos = {
	"Angel Eduardo",
	"Martin Alejandro",
	"Erick",
	"Angel Gael",
	"Luis Adrian",
	"Karen Guadalupe",
	"Angel Gabriel",
	"Manuel Santiago",
	"David Emilio",
	"Jose Gustavo",
	"Jesus Adolfo",
	"Jose Joel",
	"Brian Eduardo",
	"Jose Felipe",
	"Luis Alberto",
	"Jade Anahy",
}
print(Alumnos[math.random(1, #Alumnos)])