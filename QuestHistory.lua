-- =========================
-- Global Objects
-- =========================
if not QH then QH = {} end
if not QuestHistoryDB then QuestHistoryDB = {} end
if not QuestHistoryNpcDB then QuestHistoryNpcDB = {} end
if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end

-- =========================
-- Settings
-- =========================
local category = Settings.RegisterVerticalLayoutCategory("Quest History")

do
	local name = "Enable backup to chat log"
	local variable = "QuestHistory_EnableLogBackup"
	local defaultValue = true

	local function GetValue()
        if QuestHistorySettingsDB.enableLogBackup == nil then
           return defaultValue
        end
        return QuestHistorySettingsDB.enableLogBackup
    end

    local function SetValue(value)
    	QuestHistorySettingsDB.enableLogBackup = value
    end

    local function OnSettingChanged(_, value)
	    QH.ReloadChatLogging(value)
    end

    local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue, SetValue)
    setting:SetValueChangedCallback(OnSettingChanged)

	local tooltip = "Backup info about completed quests to chat log. If switched off, you can lose your data if game crashes"
	Settings.CreateCheckbox(category, setting, tooltip)
end

do
	local name = "Save quest duplicates"
	local variable = "QuestHistory_SaveDuplicates"
	local defaultValue = false

	local function GetValue()
        if QuestHistorySettingsDB.saveDuplicates == nil then
            return defaultValue
        end
        return QuestHistorySettingsDB.saveDuplicates
    end

    local function SetValue(value)
    	QuestHistorySettingsDB.saveDuplicates = value
    end

    local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue, SetValue)

	local tooltip = "Save or not quests to history that were already completed"
	Settings.CreateCheckbox(category, setting, tooltip)
end

Settings.RegisterAddOnCategory(category)

-- =========================
-- Save quest to database and chat log
-- =========================
function QH.SaveQuest(questId)
    if not questId or questId == 0 then
        QH.LogError("Can't process quest")
        return
    end

    local title = C_QuestLog.GetTitleForQuestID(questId) or "Unknown Title"
    local zone = GetZoneText() or "Unknown Zone"
    local giver = QuestHistoryNpcDB[questId] or UnitName("target") or "Unknown NPC"

    local entry = zone .. "; " .. giver .. "; " .. title .. "; " .. questId

    local saveDuplicates = QuestHistorySettingsDB.saveDuplicates
    if saveDuplicates == false then
        -- duplicate check (still simple)
        for _, v in ipairs(QuestHistoryDB) do
            if v == entry then
                QH.LogError(entry .. " has been already saved")
                return
            end
        end
    end

    local enableLogBackup = QuestHistorySettingsDB.enableLogBackup
    if enableLogBackup == true then
        SendChatMessage("[QH] " .. entry, "WHISPER", nil, UnitName("player"))
    end

    table.insert(QuestHistoryDB, entry)
    QH.LogInfo("Saved " .. entry)
end

-- =========================
-- Save current quest. Might be used in macro
-- =========================
function QH.SaveCurrentQuest()
    local questId = GetQuestID()
    if not questId or questId == 0 then
        questId = C_QuestLog.GetSelectedQuest()
    end

    if questId and questId > 0 then
        QH.SaveQuest(questId)
    else
       QH.LogError("No active quest. Talk to NPC or open quest log")
    end
end

-- =========================
-- Enable or disable chat logging
-- =========================
function QH.ReloadChatLogging(value)
    if value == nil then
        value = QuestHistorySettingsDB.enableLogBackup
    end
    if value == nil then
        value = true
    end

    LoggingChat(value)
    if value then
        QH.LogInfo("Chat logging activated")
    else
        QH.LogInfo("Chat logging deactivated")
    end
end

-- =========================
-- Events
-- =========================
local frame = CreateFrame("Frame")
local lastQuestGiver = nil

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("QUEST_TURNED_IN")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("QUEST_DETAIL")

frame:SetScript("OnEvent", function(_, event, ...)
    -- =========================
    -- Save completed quest
    -- =========================
    if event == "QUEST_TURNED_IN" then
        local questId = ...
        questId = questId or GetQuestID()
        QH.SaveQuest(questId)
        return
    end

    -- =========================
    -- Save quest givers
    -- =========================
    if event == "QUEST_DETAIL" then
        lastQuestGiver = UnitName("target")
        return
    end

    if event == "QUEST_ACCEPTED" then
        local questId = ...
        questId = questId or GetQuestID()
        QH.LogInfo("Quest accepted " .. questId)

        local npcName = lastQuestGiver or UnitName("target")
        lastQuestGiver = nil
        if npcName then
            QH.LogInfo("Quest: " .. questId .. " Npc: " .. npcName)
            QuestHistoryNpcDB[questId] = npcName
        end
        return
    end

    -- =========================
    -- Auto enable chat log for backup in case game crashes
    -- =========================
    if event == "PLAYER_LOGIN" then
        QH.ReloadChatLogging()
        return
    end
end)
