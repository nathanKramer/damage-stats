function GetPlayer()
    local player = EntityGetWithTag("player_unit") or nil
    if player ~= nil then
        return player[1]
    end
end

function FormatDamage(dmg)
    local scaled = ScaleDamage(dmg)
    local rounded = math.floor(scaled + 0.5)
    if rounded > 1000.0 then
        rounded = string.format("%.2f", (rounded / 1000.0)) .. "K"
    end
    return tostring(rounded)
end

function ScaleDamage(dmg)
    return tonumber(dmg) * 25.0
end