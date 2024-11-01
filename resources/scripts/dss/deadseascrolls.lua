local DSSModName = "Dead Sea Scrolls (Omori)"

local DSSCoreVersion = 7

local mod = OmoriMod

local MenuProvider = {}

local BREAK_LINE = {str = "", fsize = 1, nosel = true}

local function GenerateTooltip(str)
    local endTable = {}
    local currentString = ""
    for w in str:gmatch("%S+") do
        local newString = currentString .. w .. " "
        if newString:len() >= 15 then
            table.insert(endTable, currentString)
            currentString = ""
        end

        currentString = currentString .. w .. " "
    end

    table.insert(endTable, currentString)
    return {strset = endTable}
end

function MenuProvider.SaveSaveData()
    OmoriMod.saveManager.GetPersistentSave()
end

function MenuProvider.GetPaletteSetting()
    return OmoriMod.saveManager.GetPersistentSave().MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    OmoriMod.saveManager.GetPersistentSave().MenuPalette = var
end

function MenuProvider.GetGamepadToggleSetting()
    return OmoriMod.saveManager.GetPersistentSave().GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    OmoriMod.saveManager.GetPersistentSave().GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return OmoriMod.saveManager.GetPersistentSave().MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    OmoriMod.saveManager.GetPersistentSave().MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return OmoriMod.saveManager.GetPersistentSave().MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    OmoriMod.saveManager.GetPersistentSave().MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return OmoriMod.saveManager.GetPersistentSave().MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    OmoriMod.saveManager.GetPersistentSave().MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return OmoriMod.saveManager.GetPersistentSave().MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    OmoriMod.saveManager.GetPersistentSave().MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return OmoriMod.saveManager.GetPersistentSave().MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    OmoriMod.saveManager.GetPersistentSave().MenusPoppedUp = var
end

local dssmenucore = include("resources/scripts/dss/dssmenucore")
local dssmod = dssmenucore.init(DSSModName, MenuProvider)
local omoridir = {
    main = {
        title = "omori",
        buttons = {
            {str = "resume game", action = "resume"},
            {str = "settings", dest = "settings"},
            dssmod.changelogsButton
        },
        tooltip = dssmod.menuOpenToolTip
    },
    settings = {
        title = "settings",
        buttons = {
            {
                str = "emotion display",
                choices = {
                    "always",
					"pressing map btn",
                    "never",
                },
                setting = 1,
                variable = "emotionDisplay",
                load = function()
                    return OmoriMod.saveManager.GetDeadSeaScrollsSave().emotiondisplay or 1
                end,
                store = function(var)
                    OmoriMod.saveManager.GetDeadSeaScrollsSave().emotiondisplay = var
                end,
                tooltip = GenerateTooltip("choose the emotion title display mode")
			},
			{
                str = "emotion language",
                choices = {
                    "english",
					"spanish",
                    -- "never",
                },
                setting = 1,
                variable = "emotionLanguage",
                load = function()
                    return OmoriMod.saveManager.GetDeadSeaScrollsSave().emotionlanguage or 1
                end,
                store = function(var)
                    OmoriMod.saveManager.GetDeadSeaScrollsSave().emotionlanguage = var
                end,
                tooltip = GenerateTooltip("choose the emotion title display language")
			},
        }
    },
    menuOptions = {
        title = "menu options",
        buttons = {
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            dssmod.paletteButton,
            dssmod.menuHintButton,
            dssmod.menuBuzzerButton
        },
    },
}

local omoridirkey = {
    Item = omoridir.main,
    Main = "main",
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {}
}

DeadSeaScrollsMenu.AddMenu(
    "omori",
    {
        Run = dssmod.runMenu,
        Open = dssmod.openMenu,
        Close = dssmod.closeMenu,
        Directory = omoridir,
        DirectoryKey = omoridirkey
    }
)


