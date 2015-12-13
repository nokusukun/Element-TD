-- Well tower's Spring Forward ability

well_tower_spring_forward = class({})
LinkLuaModifier("modifier_spring_forward", "towers/duals/well/modifier_spring_forward", LUA_MODIFIER_MOTION_NONE)

function well_tower_spring_forward:OnSpellStart()
	local target = self:GetCursorTarget()
	EmitSoundOn("DOTA_Item.ClarityPotion.Activate", self:GetCaster())
	target:AddNewModifier(self:GetCaster(), self, "modifier_spring_forward", {
		duration = self:GetSpecialValueFor("duration")
	})
end

function well_tower_spring_forward:CastFilterResultTarget(target)
	local result = UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, self:GetCaster():GetTeamNumber())
	if result ~= UF_SUCCESS then
		return result;
	end
	if target:HasModifier("modifier_support_tower") then
		return UF_FAIL_CUSTOM;
	end
	return UF_SUCCESS;
end

function well_tower_spring_forward:GetCustomCastErrorTarget(target)
	if target:HasModifier("modifier_support_tower") then
		return "#etd_error_support_tower";
	end
	return "";
end
