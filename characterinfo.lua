settingsDB = settingsDB or {}

-- Decimal ilvl
function DecimalILVL(statFrame, unit)
    if unit ~= "player" then
        return
    end
    local maxiLvl, equippediLvl = GetAverageItemLevel()
    local ilvlText
    if equippediLvl ~= maxiLvl then
        ilvlText = string.format("%.2f".."/%.2f", equippediLvl, maxiLvl)
    else
        ilvlText = string.format("%.2f", equippediLvl)
    end
    local classColor = ((settingsDB.enableClassColorILVL) and (RAID_CLASS_COLORS[select(2, UnitClass(unit))]).colorStr or "ffa335ee")
    ilvlText = "|c"..classColor..ilvlText.."|r"
    PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, ilvlText, false, ilvlText)  
end
-- Decimal ilvl // END
