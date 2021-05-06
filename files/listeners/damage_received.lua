dofile("mods/damage_stats/files/utils.lua")

lastHp = nil
function damage_received( damage, message, _entity_thats_responsible, _is_fatal, _projectile_thats_responsible )
    local damageType = string.gsub(message, "$damage_", "")
    damageType = string.gsub(damageType, "damage from material: ", "")

    local player = GetPlayer()
    local damageModel = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
    local currentHp = ComponentGetValue2(damageModel, "hp")

    if currentHp == lastHp then
        return
    end
    lastHp = currentHp

    -- local damageMultiplier = ComponentObjectGetValue2(damageModel, "damage_multipliers", damageType) or 1.0

    local currentDamage = 0
    local currentDamageComponents = EntityGetComponent(player, "VariableStorageComponent", "damage_stats")

    local existingComponent = nil
    if currentDamageComponents ~= nil then
        for _, component in pairs(currentDamageComponents) do
            val = ComponentGetValue2(component, "name")
            if val == damageType then
                existingComponent = component
                currentDamage = ComponentGetValue2(component, "value_float")
            end
        end
    end

    local totalDamage = currentDamage + damageTaken
    local nonDOTDamage = math.abs(ScaleDamage(damageTaken)) > 1.0
    if ModSettingGet("damage_stats.print_damage_messages") and nonDOTDamage then
        local firstWord = "Took "
        local damageStr = " damage"
        if damageTaken < 0.0 then
            firstWord = "Healed "
            damageStr = " health"
        end
        local message = firstWord .. FormatDamage(damageTaken) .. " " .. damageType .. damageStr
        GamePrint(message .. ".")
    end

    if existingComponent then
        ComponentSetValue2(existingComponent, "value_float", totalDamage)
    else
        local component = EntityAddComponent(player, "VariableStorageComponent", {
            name = damageType,
            value_float = totalDamage
        })
        ComponentAddTag(component, "damage_stats")
        EntitySetComponentIsEnabled(player, component, true)
    end
end