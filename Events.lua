if not QH then QH = {} end
if not QuestHistoryQuestsDB then QuestHistoryQuestsDB = {} end
if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end

local unknown = "Unknown"

local function FindQuestStartItemInBag(questId)
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemQuestInfo(bag, slot)
            if info ~= nil and info.questID == questId then
                local itemId = C_Container.GetContainerItemID(bag, slot)
                return C_Item.GetItemNameByID(itemId)
            end
        end
    end
    return nil
end

local function FindQuestStartItemInQuestLog(questId)
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(i)
        if info ~= nil and info.questID == questId then
            local link = GetQuestLogSpecialItemInfo(i)
            if link ~= nil then
                local itemId = tonumber(link:match("item:(%d+)"))
                if itemId ~= nil then
                    return C_Item.GetItemNameByID(itemId)
                end
            end
            break
        end
    end
    return nil
end

local function GetQuestGiverName(questId, questStartItemID)
    if questStartItemID ~= nil and questStartItemID ~= 0 then
        return C_Item.GetItemNameByID(questStartItemID)
    end

    local npcName = UnitName("npc")
    if npcName ~= nil then
        local playerName = UnitName("player")
        if npcName ~= playerName then
            return npcName
        end
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
    if questId == nil or questId == 0 then
        if enableDebugLogging == true then
            QH.LogError("Can't process current quest with id nil")
        end
        return
    end

    local title = GetTitleText() or unknown
    local description = GetQuestText() or unknown
    local objective = GetObjectiveText() or unknown
    local location = GetZoneText() or unknown

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
        QH.LogInfo("ID: " .. questId .. " Progress: " .. progress:sub(1, 15) .. "...")
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

function QHEventsFrame:QUEST_TURNED_IN(event, questId)
    QH.SaveQuest(questId)
end

-- https://wowpedia.fandom.com/wiki/Events
-- https://warcraft.wiki.gg/wiki/Events
QHEventsFrame:RegisterEvent("QUEST_DETAIL")
QHEventsFrame:RegisterEvent("QUEST_PROGRESS")
QHEventsFrame:RegisterEvent("QUEST_COMPLETE")
QHEventsFrame:RegisterEvent("QUEST_TURNED_IN")
QHEventsFrame:SetScript("OnEvent", QHEventsFrame.OnEvent)
