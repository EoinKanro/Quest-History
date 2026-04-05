if not QH then QH = {} end
if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end
if not QuestHistoryHistoryDB then QuestHistoryHistoryDB = {} end

local completedQuests = 0

-- =========================
-- Save quest to database and chat log
-- =========================
function QH.SaveQuest(questId)
    if questId == nil or questId == 0 then
        QH.LogError("Can't process quest with nil id")
        return
    end

    local currentDateTime = date("%d.%m.%Y %H:%M:%S")
    local currentDate = currentDateTime:sub(1, 10)
    local currentTime = currentDateTime:sub(12, 20)

    local entry = {
        id = questId,
        date = currentDate,
        time = currentTime,
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

    QuestHistoryHistoryDB[currentDate] = QuestHistoryHistoryDB[currentDate] or {}
    local questDetails = QuestHistoryHistoryDB[currentDate]

    -- Save quest
    table.insert(questDetails, entry)

    QH.LogInfo("Saved " .. questId)

    -- Show warning
    completedQuests = completedQuests + 1
    local enableBackupWarning = QuestHistorySettingsDB.enableBackupWarning
    if enableBackupWarning ~= true then
        return
    end

    local warningQuestsAmount = QuestHistorySettingsDB.warningQuestsAmount
    if completedQuests >= warningQuestsAmount then
        local showPopupOnWarning = QuestHistorySettingsDB.showPopupOnWarning
        if showPopupOnWarning == true then
            StaticPopup_Show("QuestHistory_ReloadConfirmPopup")
        else
            QH.LogError("Send /reload to chat to save your progress")
        end
    end
end

-- todo debug delete
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
