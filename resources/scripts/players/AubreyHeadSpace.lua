local mod = OmoriMod
local enums = OmoriMod.Enums
local utils = enums.Utils
local costumes = enums.NullItemID
local sfx = utils.SFX
local sounds = enums.SoundEffect
local game = utils.Game
local tables = enums.Tables

---comment
---@param player EntityPlayer
function mod:InitAubrey(player)
    if not (OmoriMod:IsAubrey(player, true) or OmoriMod:IsAubrey(player, false)) then return end
    player:AddNullCostume(costumes.ID_AUBREY)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.InitAubrey)

function mod:AubreyInputs(player)
    if not OmoriMod:IsAubrey(player, false) then return end

    local playerData = OmoriMod:GetData(player)

    if OmoriMod:IsEmotionChangeTriggered(player) then 
        if not OmoriMod:IsPlayerMoving(player) then return end
        if playerData.HeadButt ~= true then
            playerData.HeadButt = true

            playerData.FixedDir = player:GetHeadDirection()

            sfx:Play(sounds.SOUND_HEADBUTT_START)
        end
    end

    if player:CollidesWithGrid() then
        print(OmoriMod:GetAceleration(player))
        if playerData.HeadButt == true then  
            playerData.HeadButt = false
            
            game:ShakeScreen(10)

            sfx:Play(sounds.SOUND_HEADBUTT_KILL)
        end       
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.AubreyInputs)

function mod:AubreyButthead(player)
    if not OmoriMod:IsAubrey(player, false) then return end

    local playerData = OmoriMod:GetData(player)

    if not playerData.HeadButt then return end

    local vec = tables.DirectionToVector[playerData.FixedDir] * 2

    -- print(vec)

    player.Velocity = vec:Resized(14)
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.AubreyButthead)

---	
---@param player EntityPlayer
---@param collider Entity
---@return boolean
function mod:AubreyHittingButthead(player, collider)
    local playerData = OmoriMod:GetData(player)
    
    if playerData.HeadButt == false then return end 

    if not (collider:IsActiveEnemy() and collider:IsVulnerableEnemy()) then return end
        
    sfx:Play(sounds.SOUND_HEADBUTT_HIT)

    collider:TakeDamage(5, 0, EntityRef(player), 0)

    -- print("Hit")

    collider.Velocity = (collider.Position - player.Position) * 4

    return true

    -- if collider:IsActiveEnemy() and collider:IsVulnerableEnemy() then
    --     print("asdmasod")
    --     collider:TakeDamage(5, 0, EntityRef(player), 0)

    --     collider.Velocity = (collider.Position - player.Position) * 4



    --     return true
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, mod.AubreyHittingButthead)