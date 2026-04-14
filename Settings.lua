if not QH then QH = {} end
if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end

local mainCategory, mainLayout = Settings.RegisterVerticalLayoutCategory("Quest History")
local generalCategory, generalLayout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, QH.Locale.SettingsGeneral)
local backupCategory, backupLayout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, QH.Locale.SettingsBackup)
local debugCategory, debugLayout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, QH.Locale.SettingsDebug)
local exportCategory, exportLayout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, QH.Locale.SettingsExport)

-- =========================
-- Description
-- =========================
do
   local name = "QuestHistory"
   local version = C_AddOns.GetAddOnMetadata(name, "Version")
   local author = C_AddOns.GetAddOnMetadata(name, "Author")

   local function CreateTextInitializer(text)
       return Settings.CreateElementInitializer("SettingsListSectionHeaderTemplate", {name = text})
   end

   mainLayout:AddInitializer(CreateTextInitializer("Version: " .. version .. "\n\nAuthor: " .. author))
end

-- =========================
-- Settings
-- =========================
do
    local name = QH.Locale.SettingsSaveRepeatableQuests
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

    local tooltip = QH.Locale.SettingsSaveRepeatableQuestsTooltip
    Settings.CreateCheckbox(generalCategory, setting, tooltip)
end

do
    local name = QH.Locale.SettingsLanguage
    local variable = "QuestHistory_Language"
    local defaultValue = "en"

    if QuestHistorySettingsDB.language == nil then
        QuestHistorySettingsDB.language = defaultValue
    end

    local function GetValue()
        return QuestHistorySettingsDB.language
    end

    local function SetValue(value)
        QuestHistorySettingsDB.language = value
        QH.ReloadAddonLanguage(value)
    end

    local function GetOptions()
        local container = Settings.CreateControlTextContainer()
        container:Add("en", "English")
        container:Add("ru", "Русский")
        return container:GetData()
    end

    local setting = Settings.RegisterProxySetting(generalCategory,variable, type(defaultValue), name, defaultValue,
        GetValue, SetValue)

    local tooltip = QH.Locale.SettingsLanguageTooltip
    Settings.CreateDropdown(generalCategory, setting, GetOptions, tooltip)
end

do
    local name = QH.Locale.SettingsEnableBackupToChat
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

    local tooltip = QH.Locale.SettingsEnableBackupToChatTooltip
    Settings.CreateCheckbox(backupCategory, setting, tooltip)
end

do
    local name = QH.Locale.SettingsEnableReloadWarning
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

    local tooltip = QH.Locale.SettingsEnableReloadWarningTooltip
    Settings.CreateCheckbox(backupCategory, setting, tooltip)
end

do
    local name = QH.Locale.SettingsShowPopupOnWarning
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

    local tooltip = QH.Locale.SettingsShowPopupOnWarningTooltip
    Settings.CreateCheckbox(backupCategory, setting, tooltip)
end

do
    local name = QH.Locale.SettingsWarningQuestAmount
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

    local tooltip = QH.Locale.SettingsWarningQuestAmountTooltip
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
    local name = QH.Locale.SettingsEnableExportDescriptionsOfQuests
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

    local tooltip = QH.Locale.SettingsEnableExportDescriptionsOfQuestsTooltip
    Settings.CreateCheckbox(exportCategory, setting, tooltip)
end

do
    local exportButton = CreateSettingsButtonInitializer(
        QH.Locale.SettingsExportHistory,
        QH.Locale.SettingsExport,
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
        QH.Locale.SettingsExportTooltip,
        true,
        nil,
        nil
    )

    exportLayout:AddInitializer(exportButton)
end

Settings.RegisterAddOnCategory(mainCategory)
