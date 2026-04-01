-- =========================
-- Global Objects
-- =========================
if not QH then QH = {} end
if not QuestHistoryDB then QuestHistoryDB = {} end
if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end

if not QuestHistoryNpcDB then QuestHistoryNpcDB = {} end
if not QuestHistoryLocationDB then QuestHistoryLocationDB = {} end
if not QuestHistoryTitleDB then QuestHistoryTitleDB = {} end

-- =========================
-- Settings
-- =========================
local category = Settings.RegisterVerticalLayoutCategory("Quest History")

do
	local name = "Enable backup to chat log"
	local variable = "QuestHistory_EnableLogBackup"
	local defaultValue = true

	if QuestHistorySettingsDB.enableLogBackup == nil then
        QuestHistorySettingsDB.enableLogBackup = defaultValue
    end

	local function GetValue()
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
	local name = "Save repeatable quests"
	local variable = "QuestHistory_SaveRepeatable"
	local defaultValue = true

    if QuestHistorySettingsDB.saveRepeatable == nil then
        QuestHistorySettingsDB.saveRepeatable = defaultValue
    end

	local function GetValue()
        return QuestHistorySettingsDB.saveRepeatable
    end

    local function SetValue(value)
    	QuestHistorySettingsDB.saveRepeatable = value
    end

    local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue, SetValue)

	local tooltip = "Save or not repeatable quests to history"
	Settings.CreateCheckbox(category, setting, tooltip)
end

do
	local name = "Enable debug logging"
	local variable = "QuestHistory_EnableDebugLogging"
	local defaultValue = false

	if QuestHistorySettingsDB.enableDebugLogging == nil then
        QuestHistorySettingsDB.enableDebugLogging = defaultValue
    end

	local function GetValue()
        return QuestHistorySettingsDB.enableDebugLogging
    end

    local function SetValue(value)
    	QuestHistorySettingsDB.enableDebugLogging = value
    end

    local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue, SetValue)

	local tooltip = "Log additional info to chat"
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

    local entry = {
        questId = questId,
        title = QuestHistoryTitleDB[questId] or C_QuestLog.GetTitleForQuestID(questId) or "Unknown Title",
        location = QuestHistoryLocationDB[questId] or GetZoneText() or "Unknown Zone",
        giver = QuestHistoryNpcDB[questId] or UnitName("target") or "Unknown NPC",
        date = date("%d-%m-%Y %H:%M:%S"),
    }

    local saveRepeatable = QuestHistorySettingsDB.saveRepeatable
    if saveRepeatable == false then
        local isRepeatable = C_QuestLog.IsRepeatableQuest(questID)
        if isRepeatable == true then
            QH.LogError("Quest " .. questId .. " is repeatable. Skipping.")
            return
        end
    end

    local enableLogBackup = QuestHistorySettingsDB.enableLogBackup
    if enableLogBackup == true then
        SendChatMessage("[QH] " .. questId, "WHISPER", nil, UnitName("player"))
    end

    table.insert(QuestHistoryDB, entry)
    QH.LogInfo("Saved " .. questId)
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
    if value == true then
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
    -- Save quest titles, givers and locations
    -- =========================
    if event == "QUEST_DETAIL" then
        lastQuestGiver = UnitName("target")
        return
    end

    if event == "QUEST_ACCEPTED" then
        local questId = ...
        questId = questId or GetQuestID()
        QH.LogInfo("Quest accepted " .. questId)

        local title = C_QuestLog.GetTitleForQuestID(questId)
        local npcName = lastQuestGiver or UnitName("target")
        local location = GetZoneText()
        lastQuestGiver = nil

        if title then
            QuestHistoryTitleDB[questId] = title
        end
        if npcName then
            QuestHistoryNpcDB[questId] = npcName
        end
        if location then
            QuestHistoryLocationDB[questId] = location
        end

        local enableDebugLogging = QuestHistorySettingsDB.enableDebugLogging
        if enableDebugLogging == true then
            QH.LogInfo("Quest: " .. questId .. "; Title: " .. title .. "; Npc: " .. npcName .. "; Location: " .. location)
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
