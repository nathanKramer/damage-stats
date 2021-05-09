damageGroupings = {
    ["mat: cursed rock"] = "curse",
    ["$damage_rock_curse"] = "curse",
    ["$damage_holy_mountains_curse"] = "curse",
    ["$ethereal_damage"] = "curse",
    ["$animal_failed_alchemist_b"] = "projectile",
    ["mat: toxic gold"] = "radioactive",
    ["mat: toxic rock"] = "radioactive",
    ["mat: poison"] = "poison",
    ["mat: freezing vapour"] = "ice",
    ["mat: freezing liquid"] = "ice",
    ["mat: toxic ice"] = "ice", 
    ["mat: frozen acid"] = "acid",
}

local function parseDamageType(rawDamageType)
    return string.gsub(
        string.gsub(rawDamageType, "$damage_", ""),
        "mat: ", ""
    )
end

function DamageReport()
    local player = GetPlayer()
    local damageStats = EntityGetComponent(player, "VariableStorageComponent", "damage_stats")

    -- Total damage
    local totalDamage = 0

    -- Damage by damage type
    local damageTypesWithDamage = {}

    -- Sorted damage keys
    local damageKeys = {}
    
    if not damageStats then
        return {
            player = player,
            totalDamage = 0,
            damageTypesWithDamage = {},
            sortedDamageKeys = {}
        }
    end

    -- Accumulate damage, count total damage, sort
    for idx, component in pairs(damageStats) do
        local rawDamageType = ComponentGetValue2(component, "name")
        local damage = ComponentGetValue2(component, "value_float")
        print(rawDamageType)

        local parsedDamageType = parseDamageType(rawDamageType)
        local grouping = damageGroupings[rawDamageType] or parsedDamageType

        if damage > 0.0 then
            totalDamage = totalDamage + damage
        end

        damageTypesWithDamage[grouping] = (damageTypesWithDamage[grouping] or 0) + damage 
    end

    local function compareDamage(a, b)
        return math.abs(damageTypesWithDamage[a]) > math.abs(damageTypesWithDamage[b])
    end

    
    for k, _ in pairs(damageTypesWithDamage) do table.insert(damageKeys, k) end
    table.sort(damageKeys, compareDamage)

    return {
        player = player,
        totalDamage = totalDamage,
        damageTypesWithDamage = damageTypesWithDamage,
        sortedDamageKeys = damageKeys
    }
end
    