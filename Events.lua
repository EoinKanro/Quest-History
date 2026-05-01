if not QH then QH = {} end
if not QuestHistoryQuestsDB then QuestHistoryQuestsDB = {} end
if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end
if not QuestHistoryBackupDB then QuestHistoryBackupDB = {} end

local npcUnit = "npc"
local unknown = "Unknown"

local function GetString(str)
    if str then
        return tostring(str)
    end
    return nil
end

local function IsQuestIdCorrect(questId, enableDebugLogging)
    if questId == nil or questId == 0 then
        if enableDebugLogging == true then
            QH.LogError(QH.Locale.EventsQuestIdNil)
        end
        return false
    end
    return true
end

local function FindQuestStartItemInBag(questId)
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemQuestInfo(bag, slot)
            if info ~= nil and info.questID == questId then
                local itemId = C_Container.GetContainerItemID(bag, slot)
                return GetString(C_Item.GetItemNameByID(itemId))
            end
        end
    end
    return nil
end

local function FindQuestStartItemInQuestLog(questId)
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(i)
        if info ~= nil and info.questID == questId then
            local link = GetString(GetQuestLogSpecialItemInfo(i))
            if link ~= nil then
                local itemId = tonumber(link:match("item:(%d+)"))
                if itemId ~= nil then
                    return GetString(C_Item.GetItemNameByID(itemId))
                end
            end
            break
        end
    end
    return nil
end

local function GetQuestGiverName(questId, questStartItemID)
    if questStartItemID ~= nil and questStartItemID ~= 0 then
        return GetString(C_Item.GetItemNameByID(questStartItemID))
    end

    local npcName = GetString(UnitName(npcUnit))
    if npcName ~= nil and not UnitIsPlayer(npcUnit) then
        return npcName
    end

    local giver = FindQuestStartItemInBag(questId)
    if giver ~= nil then
        return giver
    end

    giver = FindQuestStartItemInQuestLog(questId)
    if giver ~= nil then
        return giver
    end

    return unknown
end

local QHEventsFrame = CreateFrame("Frame")
function QHEventsFrame:OnEvent(event, ...)
    self[event](self, event, ...)
end

-- https://wowpedia.fandom.com/wiki/QUEST_DETAIL
function QHEventsFrame:QUEST_DETAIL(event, questStartItemID)
    local enableDebugLogging = QuestHistorySettingsDB.enableDebugLogging

    local questId = GetQuestID()
    if not IsQuestIdCorrect(questId, enableDebugLogging) then
        return
    end

    local title = GetString(GetTitleText()) or unknown
    local description = GetString(GetQuestText()) or unknown
    local objective = GetString(GetObjectiveText()) or unknown
    local location = GetString(GetZoneText()) or unknown

    local giver = GetQuestGiverName(questId, questStartItemID)

    QuestHistoryQuestsDB[questId] = QuestHistoryQuestsDB[questId] or {}
    local questDetails = QuestHistoryQuestsDB[questId]
    questDetails.id = questId
    questDetails.title = title
    questDetails.giver = giver
    questDetails.location = location
    questDetails.descriptionText = description
    questDetails.objectiveText = objective

    if enableDebugLogging == true then
        QH.LogInfo("ID: " .. questId .. " Title: " .. title .. " Giver: " .. giver .. " Description: "
            .. description:sub(1, 15) .. "... Objective: " .. objective:sub(1, 15) .. "...")
    end
end

-- https://wowpedia.fandom.com/wiki/QUEST_PROGRESS
function QHEventsFrame:QUEST_PROGRESS(event)
    local enableDebugLogging = QuestHistorySettingsDB.enableDebugLogging

    local questId = GetQuestID()
    if not IsQuestIdCorrect(questId, enableDebugLogging) then
        return
    end

    local progress = GetString(GetProgressText())
    if progress == nil then
        if enableDebugLogging == true then
            QH.LogError(QH.Locale.EventsProgressTextNil)
        end
        return
    end

    QuestHistoryQuestsDB[questId] = QuestHistoryQuestsDB[questId] or {}
    local questDetails = QuestHistoryQuestsDB[questId]
    questDetails.id = questId
    questDetails.progressText = progress

    if enableDebugLogging == true then
        QH.LogInfo("ID: " .. questId .. " Progress: " .. progress:sub(1, 15) .. "...")
    end
end

-- https://wowpedia.fandom.com/wiki/QUEST_COMPLETE
function QHEventsFrame:QUEST_COMPLETE(event)
    local enableDebugLogging = QuestHistorySettingsDB.enableDebugLogging

    local questId = GetQuestID()
    if not IsQuestIdCorrect(questId, enableDebugLogging) then
        return
    end

    local complete = GetString(GetRewardText())
    if complete == nil then
        if enableDebugLogging == true then
            QH.LogError(QH.Locale.EventsCompleteTextNil)
        end
        return
    end

    QuestHistoryQuestsDB[questId] = QuestHistoryQuestsDB[questId] or {}
    local questDetails = QuestHistoryQuestsDB[questId]
    questDetails.id = questId
    questDetails.completeText = complete

    if enableDebugLogging == true then
        QH.LogInfo("ID: " .. questId .. " Complete: " .. complete:sub(1, 15) .. "...")
    end
end

function QHEventsFrame:QUEST_TURNED_IN(event, questId)
    QH.SaveQuest(questId)
end

function QHEventsFrame:PLAYER_LOGIN(event)
    QH.LogInfo(QH.Locale.BackupLastSessionStarted)
    local allCompletedQuests = C_QuestLog.GetAllCompletedQuestIDs()
    local snapshot = QuestHistoryBackupDB.snapshot or {}

    -- save first snapshot ever
    if next(snapshot) == nil then
        for _, questId in ipairs(allCompletedQuests) do
            snapshot[questId] = true
        end
        QuestHistoryBackupDB.snapshot = snapshot
        QH.LogInfo(QH.Locale.BackupLastSessionFirstRun)
        return
    end

    local backupQuests = {}
    for _, questId in ipairs(allCompletedQuests) do
        if snapshot[questId] == nil then
            table.insert(backupQuests, questId)
            snapshot[questId] = true
        end
    end

    if #backupQuests == 0 then
        QH.LogInfo(QH.Locale.BackupLastSessionNothingToBackup)
        return
    end

    local MAX_BACKUP_ENTRIES = 50
    local backup = QuestHistoryBackupDB.backup or {}
    backup[time()] = backupQuests

    -- remove oldest if hit the limit
    local keys = {}
    for k in pairs(backup) do
        table.insert(keys, k)
    end

    if #keys > MAX_BACKUP_ENTRIES then
        table.sort(keys)
        backup[keys[1]] = nil
    end

    QuestHistoryBackupDB.backup = backup
    QuestHistoryBackupDB.snapshot = snapshot
    QH.LogInfo(QH.Locale.BackupLastSessionFinished)
end

-- https://wowpedia.fandom.com/wiki/Events
-- https://warcraft.wiki.gg/wiki/Events
QHEventsFrame:RegisterEvent("QUEST_DETAIL")
QHEventsFrame:RegisterEvent("QUEST_PROGRESS")
QHEventsFrame:RegisterEvent("QUEST_COMPLETE")
QHEventsFrame:RegisterEvent("QUEST_TURNED_IN")
QHEventsFrame:RegisterEvent("PLAYER_LOGIN")
QHEventsFrame:SetScript("OnEvent", QHEventsFrame.OnEvent)
