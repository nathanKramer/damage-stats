-- all functions below are optional and can be left out

--[[

function OnModPreInit()
    print("Mod - OnModPreInit()") -- First this is called for all mods
end

function OnModInit()
    print("Mod - OnModInit()") -- After that this is called for all mods
end

function OnModPostInit()
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
    GamePrint("[Damage Stats] Listening for damage...")

    component_id = EntityAddComponent(player, "LuaComponent", {
        script_damage_received = "mods/damage_stats/files/listeners/damage_received.lua",
        remove_after_executed = "0",
        execute_every_n_frame = "5"
    })
    EntitySetComponentIsEnabled(player, component_id, true)
end

gui = nil
function OnWorldPostUpdate()
    local shouldDisplay = ModSettingGet("damage_stats.display_damage_report")
    if not shouldDisplay or shouldDisplay == "false" then
        return
    end

    local function formatDamage(dmg)
        local formatted = math.floor(tonumber(dmg) * 25)
        if formatted == 0 then formatted = 1 end
        if formatted > 1000 then
            formatted = string.format("%.2f", (formatted / 1000.0)) .. "K"
        end
        return formatted
    end

    gui = gui or GuiCreate();
    GuiStartFrame( gui );
    local screen_width, screen_height = GuiGetScreenDimensions(gui)

    GuiIdPushString( gui, "damage_stats")

    local player = GetPlayer()
    local damageStats = EntityGetComponent(player, "VariableStorageComponent", "damage_stats")

    if damageStats ~= nil then
        GuiColorSetForNextWidget( gui, 0.8, 0.8, 0.8, 0.8 )
        local h = 200
        local w = GuiGetTextDimensions(gui, "Damage Report")
        local padding = 15
        GuiText(gui, screen_width - (w + padding), h, "Damage Report")

        -- Make sure the w & padding values are viable for all the currently displaying damage types
        for idx, component in pairs(damageStats) do
            local damageType = ComponentGetValue2(component, "name")
            local damage = formatDamage(ComponentGetValue2(component, "value_float"))

            local labelDimensions = GuiGetTextDimensions(gui, damageType .. ":")
            local valueDimensions = GuiGetTextDimensions(gui, tostring(damage))
            local valueWidth = labelDimensions + valueDimensions + (padding / 2)
            if valueWidth > w then
                w = valueWidth
            end
        end

        for idx, component in pairs(damageStats) do
            local damageType = ComponentGetValue2(component, "name")
            local damage = formatDamage(ComponentGetValue2(component, "value_float"))
            local valueDimensions = GuiGetTextDimensions(gui, damage)
            GuiColorSetForNextWidget( gui, 0.4, 0.4, 0.4, 0.7 )
            GuiText(gui, screen_width - (w + padding), h + (10 * idx), damageType .. ":")
            GuiColorSetForNextWidget( gui, 0.7, 0.7, 0.7, 0.7 )
            GuiText(gui, screen_width - (padding + valueDimensions), h + (10 * idx), tostring(damage))
            idx = idx + 1
        end
    end
end

function OnMagicNumbersAndWorldSeedInitialized() -- this is the last point where the Mod* API is available. after this materials.xml will be loaded.
    local x = ProceduralRandom(0,0)
    print( "===================================== random " .. tostring(x) )
end


-- This code runs when all mods' filesystems are registered
ModLuaFileAppend( "data/scripts/gun/gun_actions.lua", "mods/example/files/actions.lua" ) -- Basically dofile("mods/example/files/actions.lua") will appear at the end of gun_actions.lua
ModMagicNumbersFileAdd( "mods/example/files/magic_numbers.xml" ) -- Will override some magic numbers using the specified file
ModRegisterAudioEventMappings( "mods/example/files/audio_events.txt" ) -- Use this to register custom fmod events. Event mapping files can be generated via File -> Export GUIDs in FMOD Studio.
ModMaterialsFileAdd( "mods/example/files/materials_rainbow.xml" ) -- Adds a new 'rainbow' material to materials
ModLuaFileAppend( "data/scripts/items/potion.lua", "mods/example/files/potion_appends.lua" )

--print("Example mod init done")