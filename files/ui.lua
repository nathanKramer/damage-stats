gui = nil
-- Todo, make positioning a setting


local compact = true

function DisplayReport(damageReport)
    gui = gui or GuiCreate();
    GuiStartFrame(gui);

    if not damageReport.player then return end

    local screen_width, screen_height = GuiGetScreenDimensions(gui)
    local padding = 10
    local displayLimit = tonumber(
        ModSettingGet("damage_stats.display_limit") or 20
    )
    local fromTop = tonumber(ModSettingGet("damage_stats.positionFromTop") or 180)
    local fromRight = tonumber(ModSettingGet("damage_stats.positionFromRight") or 20)
    local compactFromTop = tonumber(ModSettingGet("damage_stats.compactPositionFromTop") or 9)
    local compactFromRight = tonumber(ModSettingGet("damage_stats.compactPositionFromRight") or 38)
    local compact = ModSettingGet("damage_stats.compact_display_mode")

    local widestString = padding

    -- Unpack report attributes
    local damageTypesWithDamage = damageReport.damageTypesWithDamage
    local sortedDamageKeys = damageReport.sortedDamageKeys
    local totalDamage = damageReport.totalDamage

    if totalDamage == 0 then

        if compact then
            local icon = "mods/damage_stats/files/icons/perfect.png"
            local x, y = screen_width - (10 + compactFromRight), compactFromTop
            GuiImage( gui, iconId, x, y, icon, 0.7, 1, 1)
            GuiTooltip(gui, "Perfect Run", "")
        else
            local valueDimensions = GuiGetTextDimensions(gui, "Damage Report")
            GuiColorSetForNextWidget(gui, 0.5, 0.5, 0.5, 0.5)
            local x, y = screen_width - (fromRight + valueDimensions), fromTop
            GuiText(gui, x, y, "Damage Report")

            local icon = "mods/damage_stats/files/icons/perfect.png"
            local x, y = screen_width - (10 + fromRight), fromTop + 10
            GuiImage( gui, iconId, x, y, icon, 0.7, 1, 1)
            GuiTooltip(gui, "Perfect Run", "")
        end

        return
    end

    local titleDimensions = GuiGetTextDimensions(gui, "Damage Report")
    local titleX, titleY = screen_width - (fromRight + titleDimensions), fromTop
    if not compact then
        GuiColorSetForNextWidget(gui, 0.6, 0.6, 0.6, 0.6)
        GuiText(gui, titleX, titleY, "Damage Report")
    end

    -- Find widest string width
    for _key, damage in pairs(damageTypesWithDamage) do
        local valueDimensions = GuiGetTextDimensions(gui, FormatDamage(damage))
        local valueWidth = valueDimensions + padding
        if valueWidth > widestString then widestString = valueWidth end
    end
    local totalWidth = GuiGetTextDimensions(gui, FormatDamage(totalDamage))
    if totalWidth > widestString then widestString = totalWidth end

    local count = 0
    local iconId = 1
    for idx, damageKey in pairs(sortedDamageKeys) do
        if idx > displayLimit then break end

        local damage = damageTypesWithDamage[damageKey]
        local valueDimensions = GuiGetTextDimensions(gui, FormatDamage(damage))

        local icon = "mods/damage_stats/files/icons/" .. damageKey .. ".png"
        local dim = GuiGetImageDimensions(gui, icon, 1)
        if dim == 0 then
            icon = "mods/damage_stats/files/icons/unknown.png"
        end

        if compact then                     
            local x, y = screen_width - (compactFromRight + (10 * (idx + 1))), compactFromTop
            GuiImage(gui, iconId, x, y, icon, 0.8, 1, 1)
            GuiTooltip(gui, InitialCase(damageKey), FormatDamage(damage))
            iconId = iconId + 1
        else
            local x, y = screen_width - (widestString + fromRight + padding),
                     fromTop + (10 * idx)

            GuiImage(gui, iconId, x, y, icon, 0.8, 1, 1)
            GuiTooltip(gui, InitialCase(damageKey), "")
            iconId = iconId + 1
            GuiColorSetForNextWidget(gui, 0.7, 0.7, 0.7, 0.7)
            GuiText(gui, screen_width - (fromRight + valueDimensions),
                    fromTop + (10 * idx), FormatDamage(damage))
        end

        count = count + 1
    end

    if compact then
        local icon = "mods/damage_stats/files/icons/total.png"
        local x, y = screen_width - (compactFromRight + 10), compactFromTop 
        GuiImage(gui, iconId, x, y, icon, 0.8, 1, 1)
        GuiTooltip(gui, "Total Damage Taken", FormatDamage(totalDamage))
        iconId = iconId + 1
    else
        local icon = "mods/damage_stats/files/icons/total.png"
        local x, y = screen_width - (widestString + fromRight + padding),
                     fromTop + (10 * (count + 1))
        GuiImage(gui, iconId, x, y, icon, 0.8, 1, 1)
        GuiTooltip(gui, "Total Damage Taken", "")
        iconId = iconId + 1
            
        local valueDimensions = GuiGetTextDimensions(gui, FormatDamage(totalDamage))
        GuiColorSetForNextWidget(gui, 0.7, 0.7, 0.7, 0.7)
        GuiText(gui, screen_width - (fromRight + valueDimensions),
                fromTop + (10 * (count + 1)), FormatDamage(totalDamage))
    end
end
