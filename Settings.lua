if not QH then QH = {} end
if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end

local mainCategory, mainLayout = Settings.RegisterVerticalLayoutCategory("Quest History")
local generalCategory, generalLayout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, "General")
local backupCategory, backupLayout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, "Backup")
local debugCategory, debugLayout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, "Debug")
local exportCategory, exportLayout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, "Export")

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

    local setting = Settings.RegisterProxySetting(generalCategory, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)

    local tooltip = "You may not want to save daily quests"
    Settings.CreateCheckbox(generalCategory, setting, tooltip)
end

do
    local name = "Enable backup to chat log"
    local variable = "QuestHistory_EnableChatBackup"
    local defaultValue = true

    if QuestHistorySettingsDB.enableChatBackup == nil then
        QuestHistorySettingsDB.enableChatBackup = defaultValue
    end

    local function GetValue()
        return QuestHistorySettingsDB.enableChatBackup
    end

    local function SetValue(value)
        QuestHistorySettingsDB.enableChatBackup = value
    end

    local function OnSettingChanged(_, value)
        QH.ReloadChatLogging(value)
    end

    local setting = Settings.RegisterProxySetting(backupCategory, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)
    setting:SetValueChangedCallback(OnSettingChanged)

    local tooltip =
    "You will see messages from yourself in chat with ids of quests. If you game crashes you will be able to restore the history using World of Warcraft/_retail_/Logs/WowChat.log"
    Settings.CreateCheckbox(backupCategory, setting, tooltip)
end

do
    local name = "Enable reload warning"
    local variable = "QuestHistory_EnableReloadWarning"
    local defaultValue = true

    if QuestHistorySettingsDB.enableReloadWarning == nil then
        QuestHistorySettingsDB.enableReloadWarning = defaultValue
    end

    local function GetValue()
        return QuestHistorySettingsDB.enableReloadWarning
    end

    local function SetValue(value)
        QuestHistorySettingsDB.enableReloadWarning = value
    end

    local setting = Settings.RegisterProxySetting(backupCategory, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)

    local tooltip =
    "Warn to do /reload if you've completed a lot of quests. There is a WoW limitation that it saves database only on reload or exit. So if your game crashes you can loose you history. Do /reload time to time"
    Settings.CreateCheckbox(backupCategory, setting, tooltip)
end

do
    local name = "Show popup on warning"
    local variable = "QuestHistory_ShowPopupOnWarning"
    local defaultValue = true

    if QuestHistorySettingsDB.showPopupOnWarning == nil then
        QuestHistorySettingsDB.showPopupOnWarning = defaultValue
    end

    local function GetValue()
        return QuestHistorySettingsDB.showPopupOnWarning
    end

    local function SetValue(value)
        QuestHistorySettingsDB.showPopupOnWarning = value
    end

    local setting = Settings.RegisterProxySetting(backupCategory, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)

    local tooltip = "Show warning popup instead of chat notification. On accept it will call /reload automatically"
    Settings.CreateCheckbox(backupCategory, setting, tooltip)
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

    local setting = Settings.RegisterProxySetting(backupCategory, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)

    local tooltip = "Amount of quests you need to complete to get a warning"
    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
    Settings.CreateSlider(backupCategory, setting, options, tooltip)
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

    local setting = Settings.RegisterProxySetting(debugCategory, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)

    local tooltip = "Log additional debug info to chat"
    Settings.CreateCheckbox(debugCategory, setting, tooltip)
end

do
    local name = "Enable export descriptions of quests"
    local variable = "QuestHistory_EnableExportDescriptionsOfQuests"
    local defaultValue = true

    if QuestHistorySettingsDB.enableExportDescriptionsOfQuests == nil then
        QuestHistorySettingsDB.enableExportDescriptionsOfQuests = defaultValue
    end

    local function GetValue()
        return QuestHistorySettingsDB.enableExportDescriptionsOfQuests
    end

    local function SetValue(value)
        QuestHistorySettingsDB.enableExportDescriptionsOfQuests = value
    end

    local setting = Settings.RegisterProxySetting(exportCategory, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)

    local tooltip = "Export descriptions of quests like main text, progress and on complete"
    Settings.CreateCheckbox(exportCategory, setting, tooltip)
end

do
    local exportButton = CreateSettingsButtonInitializer(
        "Export Data",
        "Export",
        function()
            local years = QH.GetDates()
            local buttons = {}

            for _, v in ipairs(years) do
                local buttonData = {
                    text = v,
                    callback = function()
                        QH.ExportMenuFrame:Hide()
                        local data = QH.ExportData(v)
                        QH.ShowExportPopup(data)
                    end
                }

                table.insert(buttons, buttonData)
            end

            QH.ShowExportMenuPopup(buttons)
        end,
        "Export your quest history",
        true,
        nil,
        nil
    )

    exportLayout:AddInitializer(exportButton)
end

Settings.RegisterAddOnCategory(mainCategory)
