local questManager = nil
local enemyManager = nil
local hwKB = nil
local killAll = false
local clearQuest = false
local timer = 0.0

local app_type = sdk.find_type_definition("via.Application")
local get_elapsed_second = app_type:get_method("get_UpTimeSecond")

local function get_time()
    return get_elapsed_second:call(nil)
end

re.on_pre_application_entry("UpdateBehavior", function() 
    if not questManager then
        questManager = sdk.get_managed_singleton("snow.QuestManager")
        if not questManager then
            return nil
        end
    end

    if not hwKB then
        hwKB = sdk.get_managed_singleton("snow.GameKeyboard"):get_field("hardKeyboard")
    end

    if not enemyManager then
        enemyManager = sdk.get_managed_singleton("snow.enemy.EnemyManager")
        if not enemyManager then
            return nil
        end
    end

    local endFlow = questManager:get_field("_EndFlow")
    if endFlow == 0 and clearQuest then
        questManager:call("setQuestClear")
    end
    
end)

re.on_draw_ui(function()
    changed, killAll = imgui.checkbox("KillAll", killAll)
    changed, clearQuest = imgui.checkbox("ClearQuest", clearQuest)
    -- if changed then
    --     enable = true
    --     timer = get_time()
    -- end
end)

re.on_frame(function()
    -- if enable then
    --     local now = get_time()
    --     local delta = now - timer

    --     if delta > 1.0 then
    --         enable = false
    --         timer = 0.0
    --     end
    -- end
end)

local function pre_enemy_update(args)
    local endFlow = questManager:get_field("_EndFlow")
    local questType = questManager:get_field("_QuestType")

    if killAll and endFlow == 0 and questType ~= 4 then
        local enemy = sdk.to_managed_object(args[2])
        enemy:call("dieSelf")
    end
end

local function post_enemy_update(retval)
    return retval
end

sdk.hook(
    sdk.find_type_definition("snow.enemy.EnemyCharacterBase"):get_method("update"),
    pre_enemy_update,
    post_enemy_update
)