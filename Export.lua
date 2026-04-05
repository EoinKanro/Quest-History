if not QH then QH = {} end
if not QuestHistorySettingsDB then QuestHistorySettingsDB = {} end
if not QuestHistoryQuestsDB then QuestHistoryQuestsDB = {} end
if not QuestHistoryHistoryDB then QuestHistoryHistoryDB = {} end

local unknown = "Unknown"

-- =========================
-- Export menu popup with buttons
-- =========================
function QH.ShowExportMenuPopup(buttonData)
    if not QH.ExportMenuFrame then
        local exportMenuFrame = CreateFrame("Frame", "QuestHistory_ExportMenuFrame", UIParent, "BackdropTemplate")
        exportMenuFrame:SetSize(400, 500)
        exportMenuFrame:SetPoint("CENTER")
        exportMenuFrame:SetFrameStrata("DIALOG")

        exportMenuFrame:EnableMouse(true)
        exportMenuFrame:SetMovable(true)
        exportMenuFrame:RegisterForDrag("LeftButton")
        exportMenuFrame:SetScript("OnDragStart", exportMenuFrame.StartMoving)
        exportMenuFrame:SetScript("OnDragStop", exportMenuFrame.StopMovingOrSizing)

        exportMenuFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
        })
        exportMenuFrame:SetBackdropColor(0, 0, 0, 0.9)

        local title = exportMenuFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -10)
        title:SetText("Quest History Export")

        local closeButton = CreateFrame("Button", nil, exportMenuFrame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", 0, 0)
        closeButton:SetScript("OnClick", function()
            exportMenuFrame:Hide()
        end)

        local scrollFrame = CreateFrame("ScrollFrame", nil, exportMenuFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 15, -40)
        scrollFrame:SetPoint("BOTTOMRIGHT", -35, 15)

        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetSize(1, 1)
        scrollFrame:SetScrollChild(scrollChild)

        exportMenuFrame:SetScript("OnHide", function()
            for _, button in ipairs(exportMenuFrame.Buttons) do
                button:Hide()
                button:SetParent(nil)
            end
            exportMenuFrame.Buttons = {}
        end)

        exportMenuFrame.ScrollFrame = scrollFrame
        exportMenuFrame.ScrollChild = scrollChild
        exportMenuFrame.CloseButton = closeButton
        exportMenuFrame.Title = title
        exportMenuFrame.Buttons = {}

        QH.ExportMenuFrame = exportMenuFrame
    end

    local exportMenuFrame = QH.ExportMenuFrame
    local scrollChild = exportMenuFrame.ScrollChild

    local padding = 7
    local buttonHeight = 25
    local yOffset = -padding
    for i, data in ipairs(buttonData) do
        local button = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
        button:SetSize(300, buttonHeight)
        button:SetPoint("TOPLEFT", 27, yOffset)
        button:SetText(data.text or "Unknown")
        button:SetScript("OnClick", function()
            data.callback()
        end)

        yOffset = yOffset - buttonHeight - padding
        table.insert(exportMenuFrame.Buttons, button)
    end

    scrollChild:SetHeight(-yOffset + padding)
    exportMenuFrame:Show()
end

-- =========================
-- Export popup with actual data
-- =========================
function QH.ShowExportPopup(text)
    if not QH.ExportFrame then
        local exportFrame = CreateFrame("Frame", "QuestHistory_ExportFrame", UIParent, "BackdropTemplate")
        exportFrame:SetSize(650, 500)
        exportFrame:SetPoint("CENTER")
        exportFrame:SetFrameStrata("DIALOG")

        exportFrame:EnableMouse(true)
        exportFrame:SetMovable(true)
        exportFrame:RegisterForDrag("LeftButton")
        exportFrame:SetScript("OnDragStart", exportFrame.StartMoving)
        exportFrame:SetScript("OnDragStop", exportFrame.StopMovingOrSizing)

        exportFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
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

        scrollFrame:SetScrollChild(editBox)

        editBox:SetScript("OnEditFocusGained", function(self)
            self:HighlightText()
        end)

        editBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
            exportFrame:Hide()
        end)

        exportFrame:SetScript("OnHide", function()
            editBox:SetText("")
        end)

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
-- Export dates backwords
-- =========================
function QH.GetDates()
    local keys = {}
    for key in pairs(QuestHistoryHistoryDB) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        local dayA, monthA, yearA = a:match("(%d+)%.(%d+)%.(%d+)")
        local dayB, monthB, yearB = b:match("(%d+)%.(%d+)%.(%d+)")

        if yearA ~= yearB then return yearA > yearB end
        if monthA ~= monthB then return monthA > monthB end
        return dayA > dayB
    end)

    return keys
end

function QH.ExportData(date)
    if not QuestHistoryHistoryDB or QuestHistoryHistoryDB[date] == nil then
        return "No data"
    end

    local result = {}
    local exportDescription = QuestHistorySettingsDB.enableExportDescriptionsOfQuests

    for _, v in ipairs(QuestHistoryHistoryDB[date]) do
        local quest = QuestHistoryQuestsDB[v.id] or {}
        local line = nil
        if exportDescription == true then
            line = string.format(
                "{\"questId\":%d,\"date\":\"%s\",\"time\":\"%s\",\"title\":\"%s\",\"giver\":\"%s\",\"location\":\"%s\",\"descriptionText\":\"%s\",\"objectiveText\":\"%s\",\"progressText\":\"%s\",\"completeText\":\"%s\"}",
                v.id or 0,
                v.date,
                v.time,
                quest.title or unknown,
                quest.giver or unknown,
                quest.location or unknown,
                quest.descriptionText or unknown,
                quest.objectiveText or unknown,
                quest.progressText or unknown,
                quest.completeText or unknown
            )
        else
            line = string.format(
                "{\"questId\":%d,\"date\":\"%s\",\"time\":\"%s\",\"title\":\"%s\",\"giver\":\"%s\",\"location\":\"%s\"}",
                v.id or 0,
                v.date,
                v.time,
                quest.title or unknown,
                quest.giver or unknown,
                quest.location or unknown
            )
        end

        table.insert(result, line)
    end

    return "[" .. table.concat(result, ",\n") .. "]"
end
