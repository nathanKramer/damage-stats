-- all functions below are optional and can be left out

--[[

function OnModPreInit()
    print("Mod - OnModPreInit()") -- First this is called for all mods
end

function OnModInit()
    print("Mod - OnModInit()") -- After that this is called for all mods
end

function OnModPostInit()
    GamePrint("Initialized Mod: Damage Stats")
    print("Mod - OnModPostInit()") -- Then this is called for all mods
end

function OnPlayerSpawned( player_entity ) -- This runs when player entity has been created
    GamePrint( "OnPlayerSpawned() - Player entity id: " .. tostring(player_entity) )
end

function OnWorldInitialized() -- This is called once the game world is initialized. Doesn't ensure any world chunks actually exist. Use OnPlayerSpawned to ensure the chunks around player have been loaded or created.
    GamePrint( "OnWorldInitialized() " .. tostring(GameGetFrameNum()) )
end

function OnWorldPreUpdate() -- This is called every time the game is about to start updating the world
    GamePrint( "Pre-update hook " .. tostring(GameGetFrameNum()) )
end

function OnWorldPostUpdate() -- This is called every time the game has finished updating the world
    GamePrint( "Post-update hook " .. tostring(GameGetFrameNum()) )
end

]]--

dofile("mods/damage_stats/files/utils.lua")
dofile("mods/damage_stats/files/listeners/damage_received.lua")
function OnPlayerSpawned(player)
    local component_id = EntityAddComponent(player, "LuaComponent", {
        script_damage_received = "mods/damage_stats/files/listeners/damage_received.lua",
        remove_after_executed = "0",
        execute_every_n_frame = "5"
    })
    EntitySetComponentIsEnabled(player, component_id, true)

    -- local damageModels = EntityGetComponent(player, "DamageModelComponent")

    -- for _, damageModel in pairs(damageModels) do
    --     local damageTypes = ComponentObjectGetMembers(damageModel, "damage_multipliers")
    --     for a, b in pairs(damageTypes) do
    --         print("Damage Type: " .. tostring(a) .. ", " .. tostring(b))
    --     end
    -- end
end

damageGroupings = {
    ["$damage_radioactive"] = "toxic",
    ["mat: cursed rock"] = "curse",
    ["$damage_rock_curse"] = "curse",
    ["$damage_holy_mountains_curse"] = "curse",
    ["$ethereal_damage"] = "ethereal",
    ["mat: toxic rock"] = "toxic",
    ["mat: poison"] = "poison",
    ["mat: freezing vapour"] = "ice",
    ["mat: freezing liquid"] = "ice"
}

gui = nil
groupSimilarDamageTypes = true -- todo, make this a setting
function OnWorldPostUpdate()
    local shouldDisplay = ModSettingGet("damage_stats.display_damage_report")
    if not shouldDisplay or shouldDisplay == "false" then
        return
    end

    gui = gui or GuiCreate();
    GuiStartFrame( gui );
    local screen_width, screen_height = GuiGetScreenDimensions(gui)


    local player = GetPlayer()
    local damageStats = EntityGetComponent(player, "VariableStorageComponent", "damage_stats")

    local displayLimit = tonumber(ModSettingGet("damage_stats.display_limit") or 10)

    if damageStats ~= nil then
        GuiColorSetForNextWidget( gui, 0.8, 0.8, 0.8, 0.8 )
        local h = 180
        local w = GuiGetTextDimensions(gui, "Damage Report")
        local padding = 15
        GuiText(gui, screen_width - (w + padding), h, "Damage Report")

        local totalDamage = 0
        local damageTypesWithDamage = {}

        -- First we do a pass over all of the damage types to sort them, and to check for the longest strings we need to display
        for idx, component in pairs(damageStats) do
            local rawDamageType = ComponentGetValue2(component, "name")
            local damage = ComponentGetValue2(component, "value_float")

            local parsedDamageType = string.gsub(
                string.gsub(rawDamageType, "$damage_", ""),
                "mat: ", ""
            )
            local grouping = parsedDamageType
            if groupSimilarDamageTypes then
                grouping = damageGroupings[rawDamageType] or parsedDamageType
            end

            local labelDimensions = GuiGetTextDimensions(gui, grouping .. ":")
            local valueDimensions = GuiGetTextDimensions(gui, FormatDamage(damage))
            local valueWidth = labelDimensions + valueDimensions + (padding / 2)
            if valueWidth > w then
                w = valueWidth
            end

            if damage > 0.0 then
                totalDamage = totalDamage + damage
            end

            damageTypesWithDamage[grouping] = (damageTypesWithDamage[grouping] or 0) + damage 
        end

        local function compareDamage(a, b)
            return math.abs(damageTypesWithDamage[a]) > math.abs(damageTypesWithDamage[b])
        end

        local damageKeys = {}
        for k, _ in pairs(damageTypesWithDamage) do table.insert(damageKeys, k) end
        table.sort(damageKeys, compareDamage)

        local count = 0
        for idx, damageKey in pairs(damageKeys) do
            if idx > displayLimit then
                break
            end

            local damage = damageTypesWithDamage[damageKey]
            local valueDimensions = GuiGetTextDimensions(gui, FormatDamage(damage))

            GuiColorSetForNextWidget( gui, 0.4, 0.4, 0.4, 0.7 )

            local keyStr = damageKey .. ":"
            GuiText(gui, screen_width - (w + padding), h + (10 * idx), keyStr)
            GuiColorSetForNextWidget( gui, 0.7, 0.7, 0.7, 0.7 )
            GuiText(gui, screen_width - (padding + valueDimensions), h + (10 * idx), FormatDamage(damage))

            count = count + 1
        end

        
        local valueDimensions = GuiGetTextDimensions(gui, FormatDamage(totalDamage))
        GuiColorSetForNextWidget( gui, 0.4, 0.4, 0.4, 0.7 )
        GuiText(gui, screen_width - (w + padding), h + (10 * (count+1)), "Total:")
        GuiColorSetForNextWidget( gui, 0.7, 0.7, 0.7, 0.7 )
        GuiText(gui, screen_width - (padding + valueDimensions), h + (10 * (count+1)), FormatDamage(totalDamage))
    end
end

function OnMagicNumbersAndWorldSeedInitialized() -- this is the last point where the Mod* API is available. after this materials.xml will be loaded.
    local x = ProceduralRandom(0,0)
    print( "===================================== random " .. tostring(x) )
end


-- This code runs when all mods' filesystems are registered
-- ModLuaFileAppend( "data/scripts/gun/gun_actions.lua", "mods/example/files/actions.lua" ) -- Basically dofile("mods/example/files/actions.lua") will appear at the end of gun_actions.lua
-- ModMagicNumbersFileAdd( "mods/example/files/magic_numbers.xml" ) -- Will override some magic numbers using the specified file
-- ModRegisterAudioEventMappings( "mods/example/files/audio_events.txt" ) -- Use this to register custom fmod events. Event mapping files can be generated via File -> Export GUIDs in FMOD Studio.
-- ModMaterialsFileAdd( "mods/example/files/materials_rainbow.xml" ) -- Adds a new 'rainbow' material to materials
-- ModLuaFileAppend( "data/scripts/items/potion.lua", "mods/example/files/potion_appends.lua" )

--print("Example mod init done")