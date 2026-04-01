if not QH then QH = {} end

local completedQuests = 0

-- =========================
-- Settings
-- =========================
local function InitializeSettings()
    local category, layout = Settings.RegisterVerticalLayoutCategory("Quest History")

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
    	local name = "Enable backup warning"
    	local variable = "QuestHistory_EnableBackupWarning"
    	local defaultValue = true

        if QuestHistorySettingsDB.enableBackupWarning == nil then
            QuestHistorySettingsDB.enableBackupWarning = defaultValue
        end

    	local function GetValue()
            return QuestHistorySettingsDB.enableBackupWarning
        end

        local function SetValue(value)
        	QuestHistorySettingsDB.enableBackupWarning = value
        end

        local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue, SetValue)

    	local tooltip = "Warn to do /reload if you completed a lot of quests. It's important bcz if your game crashes then all your data from the session will be lost. WoW saves data to disk only on reload or exit."
    	Settings.CreateCheckbox(category, setting, tooltip)
    end

    do
    	local name = "Show popup for reload on warning"
    	local variable = "QuestHistory_ShowPopupOnWarning"
    	local defaultValue = false

        if QuestHistorySettingsDB.showPopupOnWarning == nil then
            QuestHistorySettingsDB.showPopupOnWarning = defaultValue
        end

    	local function GetValue()
            return QuestHistorySettingsDB.showPopupOnWarning
        end

        local function SetValue(value)
        	QuestHistorySettingsDB.showPopupOnWarning = value
        end

        local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue, SetValue)

    	local tooltip = "Show popup when you hit max amount of completed quests. It will reload your interface on accept"
    	Settings.CreateCheckbox(category, setting, tooltip)
    end

    do
    	local name = "Warning quests amount"
    	local variable = "QuestHistory_WarningQuestsAmount"
    	local defaultValue = 10
    	local minValue = 1
    	local maxValue = 100
    	local step = 1

    	if QuestHistorySettingsDB.warningQuestsAmount == nil then
            QuestHistorySettingsDB.warningQuestsAmount = defaultValue
        end

    	local function GetValue()
    		return QuestHistorySettingsDB.warningQuestsAmount
    	end

    	local function SetValue(value)
    		QuestHistorySettingsDB.warningQuestsAmount = value
    	end

    	local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue, SetValue)

    	local tooltip = "Amount of quests you need to complete to get a warning"
    	local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    	options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
    	Settings.CreateSlider(category, setting, options, tooltip)
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

    do
        local exportButton = CreateSettingsButtonInitializer(
                "Export Data",
                "Export",
                function()
                    local data = QH.ExportData()
                    QH.ShowExportPopup(data)
                end,
                "Export your quest history",
                true,
                nil,
                nil
        )

        layout:AddInitializer(exportButton)
    end

    Settings.RegisterAddOnCategory(category)
end

-- =========================
-- Popup for reloading
-- =========================
StaticPopupDialogs["QH_RELOAD_CONFIRM"] = {
	text = "You hit max amount of completed quests. Reload?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
       ReloadUI()
 	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

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

    completedQuests = completedQuests + 1
    local warningQuestsAmount = QuestHistorySettingsDB.warningQuestsAmount
    if completedQuests >= warningQuestsAmount then
        local showPopupOnWarning = QuestHistorySettingsDB.showPopupOnWarning
        if showPopupOnWarning == true then
            StaticPopup_Show("QH_RELOAD_CONFIRM")
        else
            QH.LogError("Send /reload to chat to save your progress")
        end
    end
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
-- Export history
-- =========================
function QH.ExportData()
    if not QuestHistoryDB or #QuestHistoryDB == 0 then
        return "No data"
    end

    local result = {}

    for _, v in ipairs(QuestHistoryDB) do
        local line = string.format(
            "%d | %s | %s | %s | %s",
            v.questId or 0,
            v.title or "Unknown",
            v.giver or "Unknown",
            v.location or "Unknown",
            v.date or "Unknown"
        )
        table.insert(result, line)
    end

    return table.concat(result, "\n")
end

-- =========================
-- Export Popup
-- =========================
function QH.ShowExportPopup(text)
    if not QH.ExportFrame then
        local exportFrame = CreateFrame("Frame", "QH_ExportFrame", UIParent, "BackdropTemplate")
        exportFrame:SetSize(650, 450)
        exportFrame:SetPoint("CENTER")
        exportFrame:SetFrameStrata("DIALOG")

        exportFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
        })
        exportFrame:SetBackdropColor(0, 0, 0, 0.9)

        local title = exportFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -10)
        title:SetText("Quest History Export")

        local closeButton = CreateFrame("Button", nil, exportFrame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", 0, 0)
        closeButton:SetScript("OnClick", function()
            exportFrame:Hide()
        end)

        local scrollFrame = CreateFrame("ScrollFrame", nil, exportFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 15, -40)
        scrollFrame:SetPoint("BOTTOMRIGHT", -35, 15)

        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetFontObject(ChatFontNormal)
        editBox:SetWidth(580)
        editBox:SetAutoFocus(false)
        editBox:SetMaxLetters(9999999)

        editBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
            exportFrame:Hide()
        end)

        exportFrame:SetScript("OnHide", function()
            editBox:SetText("")
        end)

        editBox:SetScript("OnEditFocusGained", function(self)
            self:HighlightText()
        end)

        scrollFrame:SetScrollChild(editBox)

        exportFrame.ScrollFrame = scrollFrame
        exportFrame.EditBox = editBox
        exportFrame.CloseButton = closeButton
        exportFrame.Title = title

        QH.ExportFrame = exportFrame
    end

    local exportFrame = QH.ExportFrame
    local editBox = exportFrame.EditBox

    editBox:SetText(text or "")
    editBox:SetCursorPosition(0)

    exportFrame:Show()
    editBox:SetFocus()
end

-- =========================
-- Events
-- =========================
local frame = CreateFrame("Frame")
local lastQuestGiver = nil

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("QUEST_TURNED_IN")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("QUEST_DETAIL")

frame:SetScript("OnEvent", function(self, event, ...)
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
    -- Init databases and settings
    -- =========================
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "QuestHistory" then
            if not QuestHistoryDB then QuestHistoryDB = {} end
            if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end

            if not QuestHistoryNpcDB then QuestHistoryNpcDB = {} end
            if not QuestHistoryLocationDB then QuestHistoryLocationDB = {} end
            if not QuestHistoryTitleDB then QuestHistoryTitleDB = {} end

            InitializeSettings()
            QH.ReloadChatLogging()

            self:UnregisterEvent("ADDON_LOADED")
        end
        return
    end

    -- =========================
    -- Auto enable chat log for backup in case game crashes
    -- =========================
    if event == "PLAYER_LOGIN" then
        QH.ReloadChatLogging()
        self:UnregisterEvent("PLAYER_LOGIN")
        return
    end
end)
