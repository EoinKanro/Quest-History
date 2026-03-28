-- 1. Global object
QH = {}

local f = CreateFrame("Frame")

if not QuestHistoryDB then QuestHistoryDB = {} end
if not QuestHistoryNpcDB then QuestHistoryNpcDB = {} end

-- =========================
-- Save quest to database and chat log
-- =========================

function QH.SaveQuest(questId)
    if not questId or questId == 0 then
        print("|cFFFF0000[QH Error]:|r Can't process quest")
        return
    end

    local title = C_QuestLog.GetTitleForQuestID(questId) or "Unknown Title"
    local zone = GetZoneText() or "Unknown Zone"
    local giver = QuestHistoryNpcDB[questId] or UnitName("npc") or UnitName("target") or "Unknown NPC"

    local entry = zone .. "; " .. giver .. "; " .. title .. "; " .. questId

    -- duplicate check (still simple)
    for _, v in ipairs(QuestHistoryDB) do
        if v == entry then
            print("|cFFFFFF00[QH Error]:|r " .. entry .. " has been already saved")
            return
        end
    end

    SendChatMessage("[QH] " .. entry, "WHISPER", nil, UnitName("player"))
    table.insert(QuestHistoryDB, entry)
    print("|cFF00FF00[QH]:|r Saved " .. entry)
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
        print("|cFFFF0000[QH Error]:|r No active quest. Talk to NPC or open quest log")
    end
end

-- =========================
-- Events
-- =========================
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("QUEST_TURNED_IN")
f:RegisterEvent("QUEST_ACCEPTED")

f:SetScript("OnEvent", function(_, event, ...)
    -- =========================
    -- Auto enable chat log for backup in case game crashes
    -- =========================
    if event == "PLAYER_LOGIN" then
        LoggingChat(true)
        print("|cFF00FF00[QH]:|r Chat logging activated")
        return
    end

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
    if event == "QUEST_ACCEPTED" then
        local questId = ...
        questId = questId or GetQuestID()
        print("|cFF00FF00[QH]:|r Quest accepted " .. questId)

        local npcName = UnitName("npc") or UnitName("target")
        if npcName then
            print("|cFF00FF00[QH]:|r Quest: " .. questId .. " Npc: " .. npcName)
            QuestHistoryNpcDB[questId] = npcName
        end
        return
    end
end)
