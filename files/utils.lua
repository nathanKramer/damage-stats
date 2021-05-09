function GetPlayer()
    local player = EntityGetWithTag("player_unit") or nil
    if player ~= nil then
        return player[1]
    end
end

function FormatDamage(dmg)
    local formatted = ScaleDamage(dmg)
    if math.abs(formatted) > 1000.0 then
        formatted = string.format("%.2f", (formatted / 1000.0)) .. "K"
    else
        formatted = string.format("%.1f", formatted)
    end
    return tostring(formatted)
end

function ScaleDamage(dmg)
    return tonumber(dmg) * 25.0
end

function InitialCase(str)
    return (str:gsub("^%l", string.upper))
end