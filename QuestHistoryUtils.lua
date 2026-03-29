-- =========================
-- Global Objects
-- =========================
if not QH then QH = {} end


function QH.LogInfo(message)
    print("|cFF00FF00[QH]:|r " .. message)
end

function QH.LogError(message)
    print("|cFFFF0000[QH Error]:|r " .. message)
end
