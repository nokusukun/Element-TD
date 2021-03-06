-- Temporal Creep class
-- Waves Classic: 6, 12, 21, 31, 40, 44, 48
CreepTemporal = createClass({
		creep = nil,
		creepClass = "",

		constructor = function(self, creep, creepClass)
            self.creep = creep
            self.creepClass = creepClass or self.creepClass
        end
	},
	{
		className = "CreepTemporal"
	},
CreepBasic);

function CreepTemporal:OnSpawned()
	local creep = self.creep
	self.ability = self.creep:FindAbilityByName("creep_ability_time_lapse") or self.creep:FindAbilityByName("creep_ability_time_lapse_super")
	self.health_threshold = self.ability:GetSpecialValueFor("health_threshold")
    self.backtrack_duration = self.ability:GetSpecialValueFor("backtrack_duration")
    self.health = {}
    self.position = {}

    -- Initial cooldown
    self.ability:StartCooldown(self.backtrack_duration)
    Timers:CreateTimer(self.backtrack_duration, function()
        if IsValidEntity(creep) and creep:IsAlive() and creep:HasAbility("creep_ability_time_lapse") then
            self.ability:ApplyDataDrivenModifier(creep, creep, "modifier_time_lapse", {})
        end
    end)

    -- We only store values during the backtrack duration with 1 decimal point
    local i = string.format("%.1f", GameRules:GetGameTime())
    local think_interval = 0.1
    self.health[i] = creep:GetHealth()
    self.position[i] = creep:GetAbsOrigin()

    self.temporalTimer = Timers:CreateTimer(think_interval, function()
        if not IsValidEntity(self.creep) or not creep:IsAlive() then return end
        local time = string.format("%.1f", GameRules:GetGameTime())

        self.health[time] = creep:GetHealth()
        self.position[time] = creep:GetAbsOrigin()

        -- Forget the old value
        local backtrack_target_time = tostring(tonumber(time)-self.backtrack_duration-1)
        if self.health[backtrack_target_time] then
            self.health[backtrack_target_time] = nil
            self.position[backtrack_target_time] = nil
        end

        return think_interval
    end)
end

function CreepTemporal:Backtrack()
    local gameTime = GameRules:GetGameTime()
    local time = string.format("%.1f", gameTime)
    local backtrack_target_time = tostring(tonumber(time)-self.backtrack_duration)

    -- Approximate a value if we don't have an exact time stored
    if not self.health[backtrack_target_time] then
        local closest = 100
        for pTime,_ in pairs(self.health) do
            local diff = math.abs(tonumber(time)-tonumber(pTime))
            if diff < closest and diff >= self.backtrack_duration then
                closest = diff
                backtrack_target_time = pTime
            end
        end

        if not self.health[backtrack_target_time] then
            return
        end
    end

    local origin = self.creep:GetAbsOrigin()
    local particle = ParticleManager:CreateParticle("particles/custom/creeps/temporal/timelapse.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, origin)

    self.creep:RemoveModifierByName("modifier_time_lapse") --This stops the ability from triggering again through the damage function
    self.creep:SetHealth(self.health[backtrack_target_time])
    self.creep:SetAbsOrigin(self.position[backtrack_target_time])
    self.ability:SetHidden(true)
    Timers:RemoveTimer(self.temporalTimer)
   
    ParticleManager:SetParticleControl(particle, 2, self.position[backtrack_target_time])
end

RegisterCreepClass(CreepTemporal, CreepTemporal.className)