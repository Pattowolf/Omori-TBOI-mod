local mod = OmoriMod
local enums = OmoriMod.Enums
local utils = enums.Utils
local costumes = enums.NullItemID
local sfx = utils.SFX
local sounds = enums.SoundEffect
local game = utils.Game
local tables = enums.Tables
local HBParams = tables.AubreyHeadButtParams

local NeutralColor = Color(1, 1, 1, 1, 0.2, 0.2, 0.2)
local AngryColor = Color(1, 1, 1, 1, 0.6)

---comment
---@param player EntityPlayer
---@param changeEmotion boolean
---@param SetEmotionCounter boolean
local function TriggerHBParams(player, changeEmotion, SetEmotionCounter)
    changeEmotion = changeEmotion or false
    SetEmotionCounter = SetEmotionCounter or false
    local emotion = OmoriMod.GetEmotion(player)
    local playerData = OmoriMod:GetData(player) 

    playerData.HeadButtCounter = HBParams[emotion].HeadButtCooldown
    playerData.HeadButt = false
    playerData.FixedDir = nil

    if SetEmotionCounter == true then
        playerData.EmotionCounter = HBParams[emotion].EmotionCooldown
    end

    if changeEmotion == true then
        OmoriMod.SetEmotion(player, HBParams[emotion].Emotion)
        player:SetColor(AngryColor, 8, -1, true, true)
    end
end

---comment
---@param player EntityPlayer
function mod:InitAubrey(player)
    if not (OmoriMod:IsAubrey(player, true) or OmoriMod:IsAubrey(player, false)) then return end
    player:AddNullCostume(costumes.ID_AUBREY)

    local playerData = OmoriMod:GetData(player)

    playerData.HeadButt = false
    playerData.FixedDir = nil
    playerData.HeadButtCounter = 0
    playerData.EmotionCounter = 0

    OmoriMod.SetEmotion(player, "Neutral")
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.InitAubrey)

function mod:AubreyStats(player, flags)

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.AubreyStats)

function mod:AubreyInputs(player)
    if not OmoriMod:IsAubrey(player, false) then return end

    local emotion = OmoriMod.GetEmotion(player)
    local playerData = OmoriMod:GetData(player)

    if playerData.HeadButtCounter ~= 0 then return end

    if OmoriMod:IsEmotionChangeTriggered(player) then 
        if not OmoriMod:IsPlayerMoving(player) then return end
        if playerData.HeadButt == false then
            playerData.HeadButt = true

            sfx:Play(sounds.SOUND_HEADBUTT_START)
        end
    end

    if playerData.HeadButt == true then
        if not playerData.FixedDir then
            playerData.FixedDir = player:GetMovementInput()
        end
    end

    if player:CollidesWithGrid() then
        if playerData.HeadButt == true then  

            TriggerHBParams(player, true, true)
            game:ShakeScreen(10)

            sfx:Play(sounds.SOUND_HEADBUTT_KILL)
        end       
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.AubreyInputs)

function mod:AubreyButthead(player)
    if not OmoriMod:IsAubrey(player, false) then return end

    local playerData = OmoriMod:GetData(player)
    local HBCounter = playerData.HeadButt

    if not playerData.HeadButt then
        if playerData.HeadButtCounter > 0 then
            playerData.HeadButtCounter = playerData.HeadButtCounter - 1

            
        end

        if playerData.EmotionCounter > 0 then
            if OmoriMod.GetEmotion(player) ~= "Neutral" then
                playerData.EmotionCounter = playerData.EmotionCounter - 1

                if playerData.EmotionCounter <= 30 and playerData.EmotionCounter % 10 == 0 then
                    player:SetColor(NeutralColor, 8, -1, true, true)
                    if playerData.EmotionCounter ~= 0 then
                        sfx:Play(SoundEffect.SOUND_BEEP)
                end
                end
            end
        else
            -- player:SetColor(NeutralColor, 8, -1, true, true)
            OmoriMod.SetEmotion(player, "Neutral")
        end
    end

    print(playerData.EmotionCounter, playerData.HeadButtCounter)

    if not playerData.HeadButt then return end

    player.Velocity = playerData.FixedDir:Resized(12)
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.AubreyButthead)

---@param player EntityPlayer
---@param collider Entity
---@return boolean
function mod:AubreyHittingButthead(player, collider)
    local playerData = OmoriMod:GetData(player)
    
    if playerData.HeadButt == false then return end 

    if not (collider:IsActiveEnemy() and collider:IsVulnerableEnemy()) then return end
        
    sfx:Play(sounds.SOUND_HEADBUTT_HIT)
    local DamageFormula = (player.Damage * 2) * math.max(player.MoveSpeed, 1)

    print(DamageFormula)

    playerData.EmotionCounter = math.max(playerData.EmotionCounter - 5, 0)

    collider:TakeDamage(DamageFormula, 0, EntityRef(player), 0)

    game:ShakeScreen(10)
    player:SetMinDamageCooldown(20)

    TriggerHBParams(player, false, false)

    collider.Velocity = (collider.Position - player.Position) * 2

    return true
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, mod.AubreyHittingButthead)

function mod:OnAubreyNewRoom()
    local players = PlayerManager.GetPlayers()

    for _, player in ipairs(players) do
        local playerData = OmoriMod:GetData(player)

        if playerData.HeadButt then
            playerData.HeadButt = false
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.OnAubreyNewRoom)