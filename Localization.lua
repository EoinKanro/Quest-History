if not QH then QH = {} end
if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end

QH.Locale = {}

function QH.ReloadAddonLanguage(locale)
    if locale == "ru" then
        QH.Locale.ChatLoggingActive = "Сохранение чата активировано"
        QH.Locale.ChatLoggingInactive = "Сохранение чата выключено"

        QH.Locale.EventsQuestIdNil = "Не удается получить id квеста"
        QH.Locale.EventsProgressTextNil = "Не удается получить текс прогресса квеста"
        QH.Locale.EventsCompleteTextNil = "Не удается получить текст завершения квеста"

        QH.Locale.ExportTitle = "Quest History Экспорт"
        QH.Locale.ExportNoData = "Нет данных"

        QH.Locale.QuestsRepeatable = "Пропускаем повторяющийся квест с id %d"
        QH.Locale.QuestsSaved = "Сохранен %d"
        QH.Locale.QuestsChatReloadWarning = "Отправьте команду /reload в чат, чтобы сохранить прогресс"
        QH.Locale.QuestsPopupReloadWarning = "Выполнено максимальное заданное количество квестов. Перезагрузить UI?"
        QH.Locale.QuestsPopupReloadWarningYes = "Да"
        QH.Locale.QuestsPopupReloadWarningNo = "Нет"

        QH.Locale.SettingsGeneral = "Общее"
        QH.Locale.SettingsBackup = "Бекап"
        QH.Locale.SettingsDebug = "Дебаг"
        QH.Locale.SettingsExport = "Экспорт"
        QH.Locale.SettingsSaveRepeatableQuests = "Сохранять повторяемые квесты"
        QH.Locale.SettingsSaveRepeatableQuestsTooltip = "Возможно вы можете не захотеть сохранять дейлики в истории"
        QH.Locale.SettingsLanguage = "Язык"
        QH.Locale.SettingsLanguageTooltip = "Язык аддона. Вам понадобится сделать /reload для применения изменений"
        QH.Locale.SettingsEnableBackupToChat = "Активировать бекап в лог чата"
        QH.Locale.SettingsEnableBackupToChatTooltip = "Вам будут приходить сообщениях от вас самих с id квестов в чате. Если игра вылетит, вы сможете восстановить историю по сообщениям из World of Warcraft/_retail_/Logs/WowChat.log"
        QH.Locale.SettingsEnableReloadWarning = "Активировать предупреждение для перезагрузки"
        QH.Locale.SettingsEnableReloadWarningTooltip = "Предубреждать делать /reload при выполнении большого количества квестов. Это нужно для того, чтобы WoW сохранил базу данных на диск, иначе в случае вылета игры, данные могут быть утеряны. К сожалению, это ограничения игры."
        QH.Locale.SettingsShowPopupOnWarning = "Показывать всплывающее окно при предупреждении"
        QH.Locale.SettingsShowPopupOnWarningTooltip = "Показывать всплывающее окно вместо оповещения в чате. При соглашении UI будет перезагружен автоматически"
        QH.Locale.SettingsWarningQuestAmount = "Количество квестов для предупреждения"
        QH.Locale.SettingsWarningQuestAmountTooltip = "Количество квестов, после которых будет показываться предупреждение"
        QH.Locale.SettingsEnableExportDescriptionsOfQuests = "Экспортировать тексты квестов"
        QH.Locale.SettingsEnableExportDescriptionsOfQuestsTooltip = "Экспортировать описания квестов, тексты завершения и тд"
        QH.Locale.SettingsExportHistory = "Экспортировать историю"
        QH.Locale.SettingsExportTooltip = "Экспортировать историю квестов в JSON"
    else
        QH.Locale.ChatLoggingActive = "Chat logging activated"
        QH.Locale.ChatLoggingInactive = "Chat logging deactivated"

        QH.Locale.EventsQuestIdNil = "Can't process current quest with id nil"
        QH.Locale.EventsProgressTextNil = "Can't process current quest with progress text nil"
        QH.Locale.EventsCompleteTextNil = "Can't process current quest with complete text nil"

        QH.Locale.ExportTitle = "Quest History Export"
        QH.Locale.ExportNoData = "No data"

        QH.Locale.QuestsRepeatable = "Quest %d is repeatable. Skipping."
        QH.Locale.QuestsSaved = "Saved %d"
        QH.Locale.QuestsChatReloadWarning = "Send /reload to chat to save your progress"
        QH.Locale.QuestsPopupReloadWarning = "You hit max amount of completed quests. Reload UI?"
        QH.Locale.QuestsPopupReloadWarningYes = "Yes"
        QH.Locale.QuestsPopupReloadWarningNo = "No"

        QH.Locale.SettingsGeneral = "General"
        QH.Locale.SettingsBackup = "Backup"
        QH.Locale.SettingsDebug = "Debug"
        QH.Locale.SettingsExport = "Export"
        QH.Locale.SettingsSaveRepeatableQuests = "Save repeatable quests"
        QH.Locale.SettingsSaveRepeatableQuestsTooltip = "You may not want to save daily quests"
        QH.Locale.SettingsLanguage = "Language"
        QH.Locale.SettingsLanguageTooltip = "Language of addon. You will need to do /reload on change"
        QH.Locale.SettingsEnableBackupToChat = "Enable backup to chat log"
        QH.Locale.SettingsEnableBackupToChatTooltip = "You will see messages from yourself in chat with ids of quests. If you game crashes you will be able to restore the history using World of Warcraft/_retail_/Logs/WowChat.log"
        QH.Locale.SettingsEnableReloadWarning = "Enable reload warning"
        QH.Locale.SettingsEnableReloadWarningTooltip = "Warn to do /reload if you've completed a lot of quests. There is a WoW limitation that it saves database only on reload or exit. So if your game crashes you can loose you history. Do /reload time to time"
        QH.Locale.SettingsShowPopupOnWarning = "Show popup on warning"
        QH.Locale.SettingsShowPopupOnWarningTooltip = "Show warning popup instead of chat notification. On accept it will call /reload automatically"
        QH.Locale.SettingsWarningQuestAmount = "Warning quests amount"
        QH.Locale.SettingsWarningQuestAmountTooltip = "Amount of quests you need to complete to get a warning"
        QH.Locale.SettingsEnableExportDescriptionsOfQuests = "Enable export descriptions of quests"
        QH.Locale.SettingsEnableExportDescriptionsOfQuestsTooltip = "Export descriptions of quests like main text, progress and on complete"
        QH.Locale.SettingsExportHistory = "Export History"
        QH.Locale.SettingsExportTooltip = "Export your quest history into JSON"
    end
end

do
    local locale = QuestHistorySettingsDB.language
    if locale == nil then
        locale = "en"
    end
    QH.ReloadAddonLanguage(locale)
end
