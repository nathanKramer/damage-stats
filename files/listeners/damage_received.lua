dofile("mods/damage_stats/files/utils.lua")

function damage_received( damage, message, _entity_thats_responsible, _is_fatal, _projectile_thats_responsible )
    local damageType = string.gsub(message, "$damage_", "")
    damageType = string.gsub(damageType, "damage from material: ", "")

    local player = GetPlayer()
    local damageModel = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
    local damageMultiplier = ComponentObjectGetValue2(damageModel, "damage_multipliers", damageType) or 1.0

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

    -- local damageTaken = (damage * damageMultiplier)
    -- For some reason this is not working out. (based on my observation of explosion damage in the mines)
    local damageTaken = damage
    local blocked = damage - damageTaken
    local totalDamage = currentDamage + damageTaken

    local nonDOTDamage = (damageTaken * 25.0) > 1.0
    if ModSettingGet("damage_stats.print_damage_messages") and nonDOTDamage then
        local message = "Took " .. FormatDamage(damageTaken) .. " " .. damageType .. " damage"
        if blocked > 0.0 then
            message = message .. ", blocked " .. FormatDamage(blocked)
        end
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