gui = nil
-- Todo, make positioning a setting
local fromTop = 180
local fromRight = 24

function DisplayReport(damageReport)
    gui = gui or GuiCreate();
    GuiStartFrame(gui);

    if not damageReport.player then return end

    local screen_width, screen_height = GuiGetScreenDimensions(gui)
    local padding = 15
    local displayLimit = tonumber(
        ModSettingGet("damage_stats.display_limit") or 20
    )

    local widestString = padding

    -- Unpack report attributes
    local damageTypesWithDamage = damageReport.damageTypesWithDamage
    local sortedDamageKeys = damageReport.sortedDamageKeys
    local totalDamage = damageReport.totalDamage

    if totalDamage == 0 then
        local valueDimensions = GuiGetTextDimensions(gui, "Perfect Run")
        GuiColorSetForNextWidget(gui, 0.5, 0.5, 0.5, 0.5)
        local x, y = screen_width - (fromRight + valueDimensions), fromTop
        GamePrint(tostring(gui) .. tostring(x) .. ", " .. tostring(y))
        GuiText(gui, x, y, "Perfect Run")

        local icon = "mods/damage_stats/files/icons/perfect.png"
        local x, y = screen_width - (10 + fromRight), fromTop + 10
        GuiImage( gui, iconId, x, y, icon, 0.7, 1, 1)

        return
    end

    local titleDimensions = GuiGetTextDimensions(gui, "Damage Report")
    local titleX, titleY = screen_width - (fromRight + titleDimensions), fromTop
    GuiColorSetForNextWidget(gui, 0.6, 0.6, 0.6, 0.6)
    GuiText(gui, titleX, titleY, "Damage Report")

    -- Find widest string width
    for _key, damage in pairs(damageTypesWithDamage) do
        local valueDimensions = GuiGetTextDimensions(gui, FormatDamage(damage))
        local valueWidth = valueDimensions + padding
        if valueWidth > widestString then widestString = valueWidth end
    end

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

        local x, y = screen_width - (widestString + fromRight),
                     fromTop + (10 * idx)
        GuiImage(gui, iconId, x, y, icon, 0.8, 1, 1)
        GuiTooltip(gui, InitialCase(damageKey), "")
        iconId = iconId + 1
        GuiColorSetForNextWidget(gui, 0.7, 0.7, 0.7, 0.7)
        GuiText(gui, screen_width - (fromRight + valueDimensions),
                fromTop + (10 * idx), FormatDamage(damage))

        count = count + 1
    end

    local icon = "mods/damage_stats/files/icons/total.png"
    local x, y = screen_width - (widestString + fromRight),
                 fromTop + (10 * (count + 1))
    GuiImage(gui, iconId, x, y, icon, 0.8, 1, 1)
    GuiTooltip(gui, "Total Damage Taken", "")
    iconId = iconId + 1

    local valueDimensions = GuiGetTextDimensions(gui, FormatDamage(totalDamage))
    GuiColorSetForNextWidget(gui, 0.7, 0.7, 0.7, 0.7)
    GuiText(gui, screen_width - (fromRight + valueDimensions),
            fromTop + (10 * (count + 1)), FormatDamage(totalDamage))
end
