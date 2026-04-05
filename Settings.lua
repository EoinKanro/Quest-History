if not QH then QH = {} end
if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end

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

    local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)
    setting:SetValueChangedCallback(OnSettingChanged)

    local tooltip =
    "Backup info about completed quests to chat log. If switched off, you can lose your data if game crashes"
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

    local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)

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

    local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)

    local tooltip =
    "Warn to do /reload if you completed a lot of quests. It's important bcz if your game crashes then all your data from the session will be lost. WoW saves data to disk only on reload or exit."
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

    local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)

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

    local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)

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

    local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue,
        SetValue)

    local tooltip = "Log additional info to chat"
    Settings.CreateCheckbox(category, setting, tooltip)
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

    layout:AddInitializer(exportButton)
end

Settings.RegisterAddOnCategory(category)
