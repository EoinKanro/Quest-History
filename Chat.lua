if not QH then QH = {} end
if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end

function QH.LogInfo(message)
    print("|cFF00FF00[QH]:|r " .. message)
end

function QH.LogError(message)
    print("|cFFFF0000[QH Error]:|r " .. message)
end

-- =========================
-- Enable or disable chat logging
-- =========================
function QH.ReloadChatLogging(value)
    if value == nil then
        value = QuestHistorySettingsDB.enableChatBackup
    end
    if value == nil then
        value = true
    end

    LoggingChat(value)
    if value == true then
        QH.LogInfo(QH.Locale.ChatLoggingActive)
    else
        QH.LogInfo(QH.Locale.ChatLoggingInactive)
    end
end
