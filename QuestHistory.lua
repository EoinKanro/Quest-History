-- =========================
-- Global Objects
-- =========================
if not QH then QH = {} end
if not QuestHistoryDB then QuestHistoryDB = {} end
if not QuestHistoryNpcDB then QuestHistoryNpcDB = {} end

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

    -- duplicate check (still simple)
    for _, v in ipairs(QuestHistoryDB) do
        if v == entry then
            QH.LogError(entry .. " has been already saved")
            return
        end
    end

    SendChatMessage("[QH] " .. entry, "WHISPER", nil, UnitName("player"))
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
        LoggingChat(true)
        QH.LogInfo("Chat logging activated")
        return
    end
end)
