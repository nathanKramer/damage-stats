dofile("mods/damage_stats/files/utils.lua")

function damage_received( damage, message, _entity_thats_responsible, _is_fatal, _projectile_thats_responsible )
    local damageType = string.gsub(message, "$damage_", "")
    damageType = string.gsub(damageType, "damage from material: ", "")

    local player = GetPlayer()
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

    local totalDamage = currentDamage + damage

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