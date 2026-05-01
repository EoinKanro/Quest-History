if not QH then QH = {} end

-- =========================
-- Sort table backwards. First value is the nearest day
-- =========================
function QH.SortDates(dates)
    table.sort(dates, function(a, b)
        local dayA, monthA, yearA = a:match("(%d+)%.(%d+)%.(%d+)")
        local dayB, monthB, yearB = b:match("(%d+)%.(%d+)%.(%d+)")

        if yearA ~= yearB then return yearA > yearB end
        if monthA ~= monthB then return monthA > monthB end
        return dayA > dayB
    end)
end
