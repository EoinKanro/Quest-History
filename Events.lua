if not QH then QH = {} end
if not QuestHistoryQuestsDB then QuestHistoryQuestsDB = {} end
if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end

local unknown = "Unknown"

local QHEventsFrame = CreateFrame("Frame")

function QHEventsFrame:OnEvent(event, ...)
    self[event](self, event, ...)
end

-- https://wowpedia.fandom.com/wiki/QUEST_DETAIL
function QHEventsFrame:QUEST_DETAIL(event, questStartItemID)
    local enableDebugLogging = QuestHistorySettingsDB.enableDebugLogging

    local questId = GetQuestID()
    if questId == nil then
        if enableDebugLogging == true then
            QH.LogError("Can't process current quest with id nil")
        end
        return
    end

    local title = GetTitleText() or unknown
    local description = GetQuestText() or unknown
    local objective = GetObjectiveText() or unknown
    local location = GetZoneText() or unknown

    local giver = nil
    if questStartItemID ~= nil then
        giver = C_Item.GetItemNameByID(questStartItemID)
    else
        giver = UnitName("npc")
    end

    if giver == nil then
        giver = UnitName("target") or unknown
    end

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
    if questId == nil then
        if enableDebugLogging == true then
            QH.LogError("Can't process current quest with id nil")
        end
        return
    end

    local progress = GetProgressText()
    if progress == nil then
        if enableDebugLogging == true then
            QH.LogError("Can't process current quest with progress text nil")
        end
        return
    end

    QuestHistoryQuestsDB[questId] = QuestHistoryQuestsDB[questId] or {}
    local questDetails = QuestHistoryQuestsDB[questId]
    questDetails.id = questId
    questDetails.progressText = progress

    if enableDebugLogging == true then
        QH.LogInfo("ID: " .. questId .. " Progress: " .. progress:sub(1, 15))
    end
end

-- https://wowpedia.fandom.com/wiki/QUEST_COMPLETE
function QHEventsFrame:QUEST_COMPLETE(event)
    local enableDebugLogging = QuestHistorySettingsDB.enableDebugLogging

    local questId = GetQuestID()
    if questId == nil then
        if enableDebugLogging == true then
            QH.LogError("Can't process current quest with id nil")
        end
        return
    end

    local complete = GetRewardText()
    if complete == nil then
        if enableDebugLogging == true then
            QH.LogError("Can't process current quest with complete text nil")
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

QHEventsFrame:RegisterEvent("QUEST_DETAIL")
QHEventsFrame:RegisterEvent("QUEST_PROGRESS")
QHEventsFrame:RegisterEvent("QUEST_COMPLETE")
QHEventsFrame:SetScript("OnEvent", QHEventsFrame.OnEvent)
