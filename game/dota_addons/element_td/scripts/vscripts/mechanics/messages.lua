function SendErrorMessage(playerID, msg)
    Notifications:ClearBottom(playerID)
    Notifications:Bottom(playerID, {
        text = msg, 
        style = {color='#E62020'},
        duration = 2
    })

    Sounds:EmitSoundOnClient(playerID, "General.Cancel")
end

function SendRewardsMessage(playerID, msg, name)
    Notifications:Bottom(playerID, {
        text = {text = msg, player = name}, 
        style = {color = '#2196f3', ['font-weight'] = 'bold'}, 
        duration = 5
    })

    Sounds:EmitSoundOnClient(playerID,"ui.npe_objective_complete")
end

function SendLumberMessage(playerID, msg, amount)
    Notifications:Bottom(playerID, {
        text = {text = msg, amount = amount}, 
        style = {color = '#008000', ['font-weight'] = 'bold'}, 
        duration = 4
    })

    Sounds:EmitSoundOnClient(playerID,"ui.inv_drop_wood")
end

function SendElementalMessage(playerID, msg)
    Notifications:ClearBottom(playerID)
    Notifications:Bottom(playerID, {
        text = msg, 
        style = {color = '#FFFFFF', ['font-weight'] = 'bold'}, 
        duration = 4
    })
    Sounds:EmitSoundOnClient(playerID,"General.PingWarning")
end

function SendEssenceMessage(playerID, msg, amount)
    Notifications:Bottom(playerID, {
        text = {text = msg, amount = amount}, 
        style = {color='#FFFFFF', ['font-weight'] = 'bold'}, 
        duration = 4
    })
    Sounds:EmitSoundOnClient(playerID,"Rune.Haste")
end

function ShowMessage(playerID, msg, duration)
    Notifications:ClearTop(playerID)
    Notifications:Top(playerID, {
        text = msg, 
        style = {["font-size"] = "70px"}, 
        duration = duration
    })
end

function ShowElementAcquiredMessage(playerID, element, level)
    local elem_color = rgbToHex(GetElementColor(element))
    Notifications:Bottom(playerID, {
        text = {text = "#etd_acquire_element", element = firstToUpper(element), level = level},
        style = {["font-weight"] = "bold", ["font-size"] = "30px", color = elem_color},
        duration = 5
    })
end

function ShowWaveBreakTimeMessage(playerID, waveNumber, breakTime, duration)
    Notifications:ClearTop(playerID)

    if not EXPRESS_MODE and waveNumber == WAVE_COUNT then
        ShowFirstBossWaveMessage(playerID)
        return
    end

    Notifications:Top(playerID, {
        text = {text = "#etd_next_wave", wave = waveNumber, breakTime = breakTime}, 
        class = "WaveBreakTime", 
        duration = duration
    })

    local element = string.gsub(creepsKV[WAVE_CREEPS[waveNumber]].CreepAbility1, "_armor", "") or "composite"
    local elem_color = rgbToHex(GetElementColor(element))
    local abilityName = creepsKV[WAVE_CREEPS[waveNumber]].CreepAbility2

    local abilityName2
    if CHALLENGE_MODE and abilityName ~= "creep_ability_boss" then
        abilityName = AbilitiesMode.ChallengeModeAbilities[waveNumber][1]
        abilityName2 = AbilitiesMode.ChallengeModeAbilities[waveNumber][2]

        Notifications:Top(playerID, {text=firstToUpper(element), style={["margin"]="-15px 0px 0px 0",["font-size"]="30px",color=elem_color, ["font-weight"]="bold"}, duration=duration})
        Notifications:Top(playerID, {text="#"..abilityName, style={["margin"]="-15px 15px 0px 15px",["font-size"]="30px",color=elem_color, ["font-weight"]="bold"}, continue=true, duration=duration})    
        Notifications:Top(playerID, {ability=abilityName, style={["border-radius"]="48px", border="2px solid black", width="48px", height="48px", ["margin"]="-13px 0px 0px 0px"}, continue=true, duration=duration})
        Notifications:Top(playerID, {text="#"..abilityName2, style={["margin"]="-15px 15px 0px 15px",["font-size"]="30px",color=elem_color, ["font-weight"]="bold"}, continue=true, duration=duration})    
        Notifications:Top(playerID, {ability=abilityName2, style={["border-radius"]="48px", border="2px solid black", width="48px", height="48px", ["margin"]="-13px 0px 0px 0px"}, continue=true, duration=duration})

    else
        Notifications:Top(playerID, {text=firstToUpper(element), style={["margin"]="-15px 15px 0px 15px",["font-size"]="30px",color=elem_color, ["font-weight"]="bold"}, duration=duration})
        if abilityName and abilityName ~= "" then
            Notifications:Top(playerID, {text="#"..abilityName, style={["margin"]="-15px 15px 0px 0px",["font-size"]="30px",color=elem_color, ["font-weight"]="bold"}, continue=true, duration=duration})    
            Notifications:Top(playerID, {ability=abilityName, style={["border-radius"]="48px", border="2px solid black", width="48px", height="48px", ["margin"]="-13px 0px 0px 0px"}, continue=true, duration=duration})
        end
    end
end

function ShowFirstBossWaveMessage(playerID)
    Notifications:ClearTop(playerID)
    Notifications:Top(playerID, {
        text = {text = "#etd_next_boss_wave", breakTime = 60}, 
        class = "WaveBreakTime", 
        duration = 10
    })

    local elem_color = rgbToHex(GetElementColor("composite"))
    Notifications:Top(playerID, {text=firstToUpper("composite"), style={["margin"]="-15px 15px 0px 15px",["font-size"]="30px",color=elem_color, ["font-weight"]="bold"}, duration=10})
    Notifications:Top(playerID, {image="file://{images}/spellicons/osfrog.png", style={width="48px", height="48px", ["margin"]="-5px 0px 0px 0px"}, duration=10})
end

function ShowWaveSpawnMessage(playerID, waveNumber, duration)
    Notifications:ClearTop(playerID)
    Notifications:Top(playerID, {
        text = {text = "#etd_wave_spawn", wave = waveNumber}, 
        class = "WaveMessage", 
        duration = duration
    })

    local element = string.gsub(creepsKV[WAVE_CREEPS[waveNumber]].CreepAbility1, "_armor", "") or "composite"
    local elem_color = rgbToHex(GetElementColor(element))
    local abilityName = creepsKV[WAVE_CREEPS[waveNumber]].CreepAbility2

    local abilityName2
    if CHALLENGE_MODE and abilityName ~= "creep_ability_boss" then
        abilityName = AbilitiesMode.ChallengeModeAbilities[waveNumber][1]
        abilityName2 = AbilitiesMode.ChallengeModeAbilities[waveNumber][2]
    
        Notifications:Top(playerID, {text=firstToUpper(element), style={["margin"]="0px 15px 0px 15px",color=elem_color}, class="WaveMessageChallenge", duration=duration})
        Notifications:Top(playerID, {text="#"..abilityName, style={["margin"]="0px 15px 0px 15px",color=elem_color}, class="WaveMessageChallenge", continue=true, duration=duration})    
        Notifications:Top(playerID, {ability=abilityName, style={["border-radius"]="64px", border="2px solid black"; width="60px", height="60px"}, continue=true, duration=duration})
        Notifications:Top(playerID, {text="#"..abilityName2, style={["margin"]="0px 15px 0px 15px",color=elem_color}, class="WaveMessageChallenge", continue=true, duration=duration})    
        Notifications:Top(playerID, {ability=abilityName2, style={["border-radius"]="64px", border="2px solid black"; width="60px", height="60px"}, continue=true, duration=duration})
    else

        Notifications:Top(playerID, {text=firstToUpper(element), style={["margin"]="0px 15px 0px 15px",color=elem_color}, class="WaveMessage", continue=true, duration=duration})
        if abilityName and abilityName ~= "" then
            if abilityName ~= "creep_ability_boss" then
                Notifications:Top(playerID, {text="#"..abilityName, style={["margin-right"]="15px",color=elem_color}, class="WaveMessage", continue=true, duration=duration})    
                Notifications:Top(playerID, {ability=abilityName, style={["border-radius"]="64px", border="2px solid black"; width="60px", height="60px"}, continue=true, duration=duration})
            else
                Notifications:Top(playerID, {image="file://{images}/spellicons/osfrog.png", style={width="48px", height="48px", ["margin"]="-13px 0px 0px 0px"}, continue=true, duration=duration})
            end
        end
    end
end

function ShowBossWaveMessage(playerID, waveNumber)
    Notifications:ClearTop(playerID)
    Notifications:Top(playerID, {image="file://{images}/spellicons/osfrog.png", class="IcefrogFaceNoSpace", duration=5})
    Notifications:Top(playerID, {text={text="#etd_boss_wave", wave = waveNumber}, class="BossWaveMessage", continue=true, duration=5})
    Notifications:Top(playerID, {image="file://{images}/spellicons/osfrog.png", class="IcefrogFaceNoSpace", continue=true, duration=5})    
end

function ShowWarnMessage(playerID, msg, duration)
    duration = duration or 2
    Notifications:ClearBottom(playerID)
    Notifications:Bottom(playerID, {text=msg, style={color='#E62020'}, duration=duration})
    EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(playerID))
end

function ShowSandboxCommand(playerID, str)
    Notifications:ClearBottom(playerID)
    Notifications:Bottom(playerID, {text = str, duration = 3})
end

function ShowSandboxToggleCommand(playerID, str, state)
    Notifications:ClearBottom(playerID)
    Notifications:Bottom(playerID, {text = str, duration = 3})

    if state == true then
        Notifications:Bottom(playerID, {text ="ON", style={color='#00CC00', ["margin-left"]="10px", ["font-size"] = "30px"}, continue=true, duration = 3})
    else
        Notifications:Bottom(playerID, {text ="OFF", style={color='#FF0000', ["margin-left"]="10px", ["font-size"] = "30px"}, continue=true, duration = 3})
    end
end

function ShowElementLevel(playerID, element, level)
    Notifications:ClearBottom(playerID)

    local elem_color = rgbToHex(GetElementColor(element))
    Notifications:Bottom(playerID, {
        text = {text = "#sandbox_elem_level", element = firstToUpper(element), level = level},
        style = {["font-weight"] = "bold", ["font-size"] = "30px", color = elem_color},
        duration = 5
    })
end

function ShowHighscoreMessage(playerID, percentile)
    if GameRules.sandBoxEnabled then return end
    
    -- Possible names: firstblood, doublekill, triplekill, rampage, multikill_generic
    local name = "doublekill"
    if percentile < 5 then
        name = "rampage"
    elseif percentile < 20 then
        name = "multikill_generic"
    elseif percentile < 40 then
        name = "triplekill"
    end

    local particleName = "particles/econ/events/killbanners/screen_killbanner_compendium14_"..name..".vpcf"
    local particle = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_EYES_FOLLOW, PlayerResource:GetSelectedHeroEntity(playerID), PlayerResource:GetPlayer(playerID))

    Notifications:ClearTop(playerID)
    Notifications:Top(playerID, {text = "#etd_highscore_new", class = "NewHighscore", duration = 5})

    GameRules:SendCustomMessage("#etd_highscore_message", playerID, 0)
end

function ShowFirstHighscoreMessage(playerID)
    if GameRules.sandBoxEnabled then return end
    
    local particleName = "particles/econ/events/killbanners/screen_killbanner_compendium14_firstblood.vpcf"
    local particle = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_EYES_FOLLOW, PlayerResource:GetSelectedHeroEntity(playerID), PlayerResource:GetPlayer(playerID))

    Notifications:ClearTop(playerID)
    Notifications:Top(playerID, {text = "#etd_highscore_new", class = "NewHighscore", duration = 5})

    GameRules:SendCustomMessage("#etd_highscore_message", playerID, 0)
end