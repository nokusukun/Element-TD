-- holds important functions and variables for our cooperative mode

if not COOP_WAVE then
    COOP_WAVE = 1 -- the current wave 
    CREEPS_PER_WAVE_COOP = 120 -- number of creeps in each wave
    CURRENT_WAVE_OBJECT = nil -- hold sthe WaveCoop 'object' of the wave that is currently active

    COOP_HEALTH = 0
    COOP_LIFE_TOWER_KILLS = 0
    COOP_LIFE_TOWER_KILLS_TOTAL = 0
end

-- entry point
function CoopStart()
    COOP_HEALTH = GameSettings:GetMapSetting("Lives");
    
    local initialBreakTime = GameSettings.length.PregameTime
    StartBreakTimeCoop(initialBreakTime)

    Timers:CreateTimer(AbandonThinker)
end

function OpenCoopPortal()
    CoopPortal = Entities:FindByName(nil, "coop_portal")
    CoopPortal.particle = ParticleManager:CreateParticle("particles/custom/portals/coop_portal.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(CoopPortal.particle, 0, CoopPortal:GetAbsOrigin())
    UpdateCoopPortal(1)
    ShowArrowHelp()
end

function UpdateCoopPortal(wave)
    if not CoopPortal then OpenCoopPortal() end

    local element = string.gsub(creepsKV[WAVE_CREEPS[wave]].Ability1, "_armor", "")
    ParticleManager:SetParticleControl(CoopPortal.particle, 15, GetElementColor(element))

    if CoopPortal.vortex then
        ParticleManager:DestroyParticle(CoopPortal.vortex, true)
    end

    if element ~= composite then
        CoopPortal.vortex = ParticleManager:CreateParticle("particles/custom/portals/"..element.."_vortex.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(CoopPortal.vortex, 0, CoopPortal:GetAbsOrigin())
    end
end

function CloseCoopPortal()
    local portal = Entities:FindByName(nil, "coop_portal")
    if portal and portal.particle then
        ParticleManager:DestroyParticle(portal.particle, true)
    end
end

function ShowArrowHelp()
    CoopPortal.arrows = {}

    local arrows = Entities:FindAllByName("arrow*")
    for _,v in pairs(arrows) do
        local names = split(v:GetName(), ",")
        local particleName = names[1]
        local lookup = Entities:FindByName(nil, names[2])
        
        local arrow = ParticleManager:CreateParticle("particles/custom/tutorial/"..particleName..".vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(arrow, 0, v:GetAbsOrigin())
        ParticleManager:SetParticleControl(arrow, 1, lookup:GetAbsOrigin())
        table.insert(CoopPortal.arrows, arrow)
    end
end

function CloseArrowHelp()
    local portal = Entities:FindByName(nil, "coop_portal")
    if portal and portal.arrows then
        for _,v in pairs(CoopPortal.arrows) do
            ParticleManager:DestroyParticle(v, true)
        end
        portal.arrows = nil
    end
end

function SpawnWaveCoop()
    Log:info("Spawning co-op wave " .. COOP_WAVE)

    CURRENT_WAVE_OBJECT = WaveCoop(COOP_WAVE)
    
    -- First wave marks the start of the game
    if START_GAME_TIME == 0 then
        START_GAME_TIME = GameRules:GetGameTime()
        CloseArrowHelp()
    end

    for _, playerID in pairs(playerIDs) do
        local playerData = GetPlayerData(playerID)
        CustomGameEventManager:Send_ServerToAllClients("SetTopBarWaveValue", {playerId = playerID, wave = COOP_WAVE})
        
        -- not sure about these
        playerData.waveObject = CURRENT_WAVE_OBJECT 
        playerData.waveObjects[COOP_WAVE] = CURRENT_WAVE_OBJECT
    end

    if not InterestManager:IsStarted() then
        InterestManager:StartInterest()
    end
    -- InterestManager:CheckForIncorrectPausing() -- not needed?

    CURRENT_WAVE_OBJECT:SetOnCompletedCallback(function()
        if COOP_HEALTH == 0 then return end

        EmitGlobalSound("ui.npe_objective_complete")
        InterestManager:CompletedWave(COOP_WAVE)

        -- Game cleared?
        if COOP_WAVE+1 == WAVE_COUNT then
            ForAllPlayerIDs(function(playerID)
                local playerData = GetPlayerData(playerID)
                playerData.clearTime = GameRules:GetGameTime() - START_GAME_TIME -- Used to determine the End Speed Bonus
                playerData.scoreObject:UpdateScore( SCORING_WAVE_CLEAR, COOP_WAVE )
                Timers:CreateTimer(2, function()
                    playerData.scoreObject:UpdateScore( SCORING_GAME_CLEAR )
                end)
            end)            
        end

        if COOP_WAVE < WAVE_COUNT then
            COOP_WAVE = COOP_WAVE + 1
        end

        -- Boss Wave completed starts the new one with no breaktime
        if CURRENT_BOSS_WAVE > 0 then
            print("[COOP] Completed boss wave "..CURRENT_BOSS_WAVE)

            -- Boss wave score
            ForAllPlayerIDs(function(playerID)
                local playerData = GetPlayerData(playerID)
                playerData.scoreObject:UpdateScore( SCORING_BOSS_WAVE_CLEAR, COOP_WAVE )
                playerData.bossWaves = playerData.bossWaves + 1
            end)

            CURRENT_BOSS_WAVE = CURRENT_BOSS_WAVE + 1

            ForAllPlayerIDs(function(playerID)
                ShowBossWaveMessage(playerID, CURRENT_BOSS_WAVE)
                UpdateWaveInfo(playerID, COOP_WAVE)
            end)

            SpawnWaveCoop() 
            return
        end
        
        print("[COOP] Completed wave "..COOP_WAVE)
        ForAllPlayerIDs(function(playerID)
            local playerData = GetPlayerData(playerID)
            playerData.scoreObject:UpdateScore( SCORING_WAVE_CLEAR, COOP_WAVE )
        end)

        -- Start the breaktime for the next wave
        StartBreakTimeCoop(GameSettings:GetGlobalDifficulty():GetWaveBreakTime(COOP_WAVE))
    end)

    CURRENT_WAVE_OBJECT:SpawnWave()
end


function CreateMoveTimerForCreepCoop(creep, sector)
    local destination = EntityEndLocations[sector]

    Timers:CreateTimer(0.1, function()
        if IsValidEntity(creep) and creep:IsAlive() then
            creep:MoveToPosition(destination)

            if (creep:GetAbsOrigin() - destination):Length2D() <= 100 then
                if GameSettings:GetEndless() ~= "Endless" then
                    InterestManager:LeakedWave(creep.waveObject.waveNumber)
                end

                -- Boss Wave leaks = 3 lives
                local lives = 1
                if CURRENT_BOSS_WAVE > 0 then
                    lives = 3
                end

                -- Bulky creeps count as 2
                if creep:HasAbility("creep_ability_bulky") then
                    lives = lives * 2
                end

                CURRENT_WAVE_OBJECT.leaks = CURRENT_WAVE_OBJECT.leaks + lives

                COOP_HEALTH = COOP_HEALTH - 1
                for _, playerID in pairs(playerIDs) do
                    ReduceLivesForPlayer(playerID, lives)
                end

                creep.recently_leaked = true
                Timers:CreateTimer(10, function()
                    if IsValidEntity(creep) then creep.recently_leaked = nil end
                end)

                creep.times_leaked = creep.times_leaked and creep.times_leaked + 1 or 1
                FindClearSpaceForUnit(creep, EntityStartLocations[sector], true)

                creep:SetForwardVector(Vector(0, -1, 0))
            end
            return 0.1
        else
            return
        end
    end)
end

function StartBreakTimeCoop(breakTime)
    ElementTD:PrecacheWave(COOP_WAVE)

    local msgTime = 5 -- how long to show the message for
    if COOP_WAVE > 1 and (COOP_WAVE - 1) % 5 == 0 then
        breakTime = 30
    end
    -- First boss breaktime 60 seconds
    if COOP_WAVE == WAVE_COUNT and CURRENT_BOSS_WAVE == 0 then
        breakTime = 60
    end
    if msgTime >= breakTime then
        msgTime = breakTime - 0.5
    end

    -- show countdown timer for all players
    Log:debug("Starting co-op break time for wave " .. COOP_WAVE)
    local bShowButton = PlayerResource:GetPlayerCount() == 1 and COOP_WAVE == 1
    CustomGameEventManager:Send_ServerToAllClients("etd_update_wave_timer", {time = breakTime, button = bShowButton})

    -- show sector portals
    for i = 1, 6 do
        ShowPortalForSector(i, COOP_WAVE)
    end
    UpdateCoopPortal(COOP_WAVE)

    -- set up each individual player
    for _, playerID in pairs(playerIDs) do
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        local playerData = GetPlayerData(playerID)

        ShowWaveBreakTimeMessage(playerID, COOP_WAVE, breakTime, msgTime)

        if PlayerIsAlive(playerID) then

            -- Grant Lumber and Essence to all players the moment the next wave is set
            if WaveGrantsLumber(COOP_WAVE - 1) then
                ModifyLumber(playerID, 1)
                if IsPlayerUsingRandomMode( playerID ) then
                    Notifications:ClearBottom(playerID)
                    local element = GetRandomElementForPlayerWave(playerID, COOP_WAVE - 1)

                    Log:info("Randoming element for player "..playerID..": "..element)

                    if element == "pure" then
                        SendEssenceMessage(playerID, "#etd_random_essence")
                        ModifyLumber(playerID, -1)
                        ModifyPureEssence(playerID, 1)
                        playerData.pureEssenceTotal = playerData.pureEssenceTotal + 1

                        -- Track pure essence purchasing as part of the element order
                        playerData.elementOrder[#playerData.elementOrder + 1] = "Pure"
                        
                        -- Gold bonus for Pure Essence randoming (removed in 1.5)
                        -- GivePureEssenceGoldBonus(playerID)
                    else
                        SendEssenceMessage(playerID, "#etd_random_elemental")
                        SummonElemental({caster = playerData.summoner, Elemental = element .. "_elemental"})
                    end
                else
                    Log:info("Giving 1 lumber to " .. playerData.name)
                end
            end

            if WaveGrantsEssence(COOP_WAVE - 1) then
                ModifyPureEssence(playerID, 1) 
                Log:info("Giving 1 pure essence to " .. playerData.name)
                playerData.pureEssenceTotal = playerData.pureEssenceTotal + 1
            end
        end
    end

    -- create the timer to wait for wave spawn
    Timers:CreateTimer("SpawnWaveDelay_Coop", {
        endTime = breakTime,
        callback = function()
            if END_TIME then return end

            if COOP_WAVE == WAVE_COUNT then
                CURRENT_BOSS_WAVE = 1
                Log:info("Spawning the first co-op boss wave")
                
                for _, playerID in pairs(playerIDs) do
                    local playerData = GetPlayerData(playerID)
                    playerData.iceFrogKills = 0
                    playerData.bossWaves = CURRENT_BOSS_WAVE
                    ShowBossWaveMessage(playerID, CURRENT_BOSS_WAVE)
                    UpdateWaveInfo(playerID, COOP_WAVE)
                end
            else
                for _, playerID in pairs(playerIDs) do
                    ShowWaveSpawnMessage(playerID, COOP_WAVE) -- show wave spawn message
                    UpdateWaveInfo(playerID, COOP_WAVE) -- update wave info
                end
            end

            if COOP_WAVE == 1 then
                EmitAnnouncerSound("announcer_announcer_battle_begin_01")
            end

            -- spawn dat wave
            SpawnWaveCoop() 
        end
    })
end

-- Checks all player heroes, if someone has abandoned then share its units and split its gold
function AbandonThinker()
    local splitNum = PlayerResource:GetPlayerCountWithoutLeavers()

    ForAllPlayerIDs(function(playerID)
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        if hero and hero:HasOwnerAbandoned() then
            local gold = hero:GetGold()
            local gold_split = gold/splitNum

            ForAllConnectedPlayerIDs(function(otherPlayerID)
                -- Share units
                PlayerResource:SetUnitShareMaskForPlayer(playerID, otherPlayerID, 2, true)

                -- Split gold between teammates
                local hero = PlayerResource:GetSelectedHeroEntity(otherPlayerID)
                if hero and gold_split >= 1 then
                    hero:ModifyGold(gold_split)
                    hero:ModifyGold(-gold_split)
                end
            end)
        end
    end)
    return 1
end