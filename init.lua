dofile("mods/damage_stats/files/utils.lua")
dofile("mods/damage_stats/files/damage_report.lua")
dofile("mods/damage_stats/files/ui.lua")

function OnPlayerSpawned(player)
    local component_id = EntityAddComponent(player, "LuaComponent", {
        script_damage_received = "mods/damage_stats/files/listeners/damage_received.lua",
        remove_after_executed = "0",
        execute_every_n_frame = "5"
    })
    EntitySetComponentIsEnabled(player, component_id, true)
end

function OnWorldPostUpdate()
    local shouldDisplay = ModSettingGet("damage_stats.display_damage_report")
    if not shouldDisplay or shouldDisplay == "false" then
        return
    end

    damageReport = DamageReport()
    DisplayReport(damageReport)
end