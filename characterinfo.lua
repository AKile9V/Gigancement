settingsDB = settingsDB or {}

-- Decimal ilvl
local function DecimalILVL(statFrame, unit)
    if unit ~= "player" or (not settingsDB.enableDecimalILVL and not settingsDB.enableClassColorILVL) then
        return
    end
    local maxiLvl, equippediLvl = GetAverageItemLevel()
    local ilvlText
    if settingsDB.enableDecimalILVL then
        ilvlText = (equippediLvl ~= maxiLvl and string.format("%.2f".."/%.2f", equippediLvl, maxiLvl)) or string.format("%.2f", equippediLvl)
    end
    ilvlText = settingsDB.enableDecimalILVL and ilvlText or string.format("%d", equippediLvl)
    local classColor = (RAID_CLASS_COLORS[select(2, UnitClass(unit))]).colorStr or "ffa335ee"
    ilvlText = (settingsDB.enableClassColorILVL and "|c"..classColor..ilvlText.."|r") or ilvlText
    PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, ilvlText, false, ilvlText)  
end
hooksecurefunc("PaperDollFrame_SetItemLevel", DecimalILVL)
-- Decimal ilvl // END

-- CharacterInfo and InspectCharacter ILVL
local _G = _G
local defaultFont = STANDARD_TEXT_FONT
local defaultFontsize = 13
local defaultFontOutline = "OUTLINE"
local defaultGemSize = 14
local TwoHanders = {
    ["INVTYPE_RANGED"] = true,
    ["INVTYPE_RANGEDRIGHT"] = true,
    ["INVTYPE_2HWEAPON"] = true
}
local TWWHeadEnchants = {
    ["Lesser Void Ritual"] = {id = 239093, icon = 237131},
    ["Lesser Twisted Appendage"] = {id = 239088, icon = 237125},
    ["Lesser Gushing Wound"] = {id = 239084, icon = 237112},
    ["Lesser Infinite Stars"] = {id = 239078, icon = 237114},
    ["Lesser Echoing Void"] = {id = 238678, icon = 237113},
    ["Lesser Twilight Devastation"] = {id = 238403, icon = 237123},
    ["Greater Void Ritual"] = {id = 239095, icon = 237110},
    ["Greater Twisted Appendage"] = {id = 239090, icon = 237104},
    ["Greater Gushing Wound"] = {id = 239086, icon = 237091},
    ["Greater Infinite Stars"] = {id = 239080, icon = 237093},
    ["Greater Echoing Void"] = {id = 238680, icon = 237092},
    ["Greater Twilight Devastation"] = {id = 238405, icon = 237102},
}
local DKEnchants = {
    ["Hysteria"] = 460688,
    ["Razorice"] = 135842,
    ["Sanguination"] = 1778226,
    ["Spellwarding"] = 425952,
    ["Apocalypse"] = 237535,
    ["Fallen\nCrusader"] = 135957,
    ["Stoneskin\nGargoyle"] = 237480,
    ["Unending\nThirst"] = 3163621,
}
local TWWEnchants = {
    -- Rank3
    ["Cursed VersatilityProfessions-ChatIcon-Quality-Tier3"] = "+390 Versatility\n|cFFa335ee-115 Mastery|r",
    ["Cursed MasteryProfessions-ChatIcon-Quality-Tier3"] = "+390 Mastery\n|cFFa335ee-115 Critical Strike|r",
    ["Cursed HasteProfessions-ChatIcon-Quality-Tier3"] = "+390 Haste\n|cFFa335ee-115 Versatility|r",
    ["Cursed Critical StrikeProfessions-ChatIcon-Quality-Tier3"] = "+390 Critical Strike\n      |cFFa335ee-115 Haste|r",
    ["Cavalry's MarchProfessions-ChatIcon-Quality-Tier3"] = "+10% Mount",
    ["Scout's MarchProfessions-ChatIcon-Quality-Tier3"] = "+250 Speed",
    ["Defender's MarchProfessions-ChatIcon-Quality-Tier3"] = "+895 Stamina",
    ["Stormrider's AgilityProfessions-ChatIcon-Quality-Tier3"] = "+520 Agility\n+250 Speed",
    ["Council's IntellectProfessions-ChatIcon-Quality-Tier3"] = "+520 Intellect\n+5% Mana",
    ["Crystalline RadianceProfessions-ChatIcon-Quality-Tier3"] = "+745 Primary Stat",
    ["Oathsworn's StrengthProfessions-ChatIcon-Quality-Tier3"] = "+520 Strength\n+265 Stamina",
    ["Chant of Winged GraceProfessions-ChatIcon-Quality-Tier3"] = "+545 Avoidance\n-20% Fall Damage",
    ["Chant of Leeching FangsProfessions-ChatIcon-Quality-Tier3"] = "+1020 Leech\nHeal OOC",
    ["Chant of Burrowing RapidityProfessions-ChatIcon-Quality-Tier3"] = "+250 Speed     \nHearthstone CD",
    -- Rank2
    ["Cursed HasteProfessions-ChatIcon-Quality-Tier2"] = "+335 Haste\n|cFFa335ee-100 Versatility|r",
    ["Cursed Critical StrikeProfessions-ChatIcon-Quality-Tier2"] = "+335 Critical Strike\n      |cFFa335ee-100 Haste|r",
    ["Cursed VersatilityProfessions-ChatIcon-Quality-Tier2"] = "+335 Versatility\n|cFFa335ee-100 Mastery|r",
    ["Cursed MasteryProfessions-ChatIcon-Quality-Tier2"] = "+335 Mastery\n|cFFa335ee-100 Critical Strike|r",
    ["Cavalry's MarchProfessions-ChatIcon-Quality-Tier2"] = "+8% Mount",
    ["Scout's MarchProfessions-ChatIcon-Quality-Tier2"] = "+215 Speed",
    ["Defender's MarchProfessions-ChatIcon-Quality-Tier2"] = "+760 Stamina",
    ["Stormrider's AgilityProfessions-ChatIcon-Quality-Tier2"] = "+440 Agility\n+215 Speed",
    ["Council's IntellectProfessions-ChatIcon-Quality-Tier2"] = "+440 Intellect\n+4% Mana",
    ["Crystalline RadianceProfessions-ChatIcon-Quality-Tier2"] = "+630 Primary Stat",
    ["Oathsworn's StrengthProfessions-ChatIcon-Quality-Tier2"] = "+440 Strength\n+225 Stamina",
    ["Chant of Winged GraceProfessions-ChatIcon-Quality-Tier2"] = "+465 Avoidance\n-15% Fall Damage",
    ["Chant of Leeching FangsProfessions-ChatIcon-Quality-Tier2"] = "+865 Leech\nHeal OOC",
    ["Chant of Burrowing RapidityProfessions-ChatIcon-Quality-Tier2"] = "+210 Speed     \nHearthstone CD",
    -- Rank1
    ["Cursed HasteProfessions-ChatIcon-Quality-Tier1"] = "+270 Haste\n|cFFa335ee-80 Versatility|r",
    ["Cursed Critical StrikeProfessions-ChatIcon-Quality-Tier1"] = "+270 Critical Strike\n      |cFFa335ee-80 Haste|r",
    ["Cursed VersatilityProfessions-ChatIcon-Quality-Tier1"] = "+270 Versatility\n|cFFa335ee-80 Mastery|r",
    ["Cursed MasteryProfessions-ChatIcon-Quality-Tier1"] = "+270 Mastery\n|cFFa335ee-80 Critical Strike|r",
    ["Cavalry's MarchProfessions-ChatIcon-Quality-Tier1"] = "+6% Mount",
    ["Scout's MarchProfessions-ChatIcon-Quality-Tier1"] = "+175 Speed",
    ["Defender's MarchProfessions-ChatIcon-Quality-Tier1"] = "+625 Stamina",
    ["Stormrider's AgilityProfessions-ChatIcon-Quality-Tier1"] = "+360 Agility\n+180 Speed",
    ["Council's IntellectProfessions-ChatIcon-Quality-Tier1"] = "+360 Intellect\n+3% Mana",
    ["Crystalline RadianceProfessions-ChatIcon-Quality-Tier1"] = "+520 Primary Stat",
    ["Oathsworn's StrengthProfessions-ChatIcon-Quality-Tier1"] = "+365 Strength\n+185 Stamina",
    ["Chant of Winged GraceProfessions-ChatIcon-Quality-Tier1"] = "+380 Avoidance\n-10% Fall Damage",
    ["Chant of Leeching FangsProfessions-ChatIcon-Quality-Tier1"] = "+715 Leech\nHeal OOC",
    ["Chant of Burrowing RapidityProfessions-ChatIcon-Quality-Tier1"] = "+175 Speed     \nHearthstone CD",
}
local sumILVL = 0
local weaponLevel = 0
local characterSlots = {
    [1] = {id = 1, side = "LEFT", name = "Head", canEnchant = false},
    [2] = {id = 2, side = "LEFT", name = "Neck", canEnchant = false},
    [3] = {id = 3, side = "LEFT", name = "Shoulder", canEnchant = false},
    -- [4] = {id = 4, side = "LEFT", name = "Shirt", canEnchant = false},
    [5] = {id = 5, side = "LEFT", name = "Chest", canEnchant = true},
    [6] = {id = 6, side = "RIGHT", name = "Waist", canEnchant = false},
    [7] = {id = 7, side = "RIGHT", name = "Legs", canEnchant = true},
    [8] = {id = 8, side = "RIGHT", name = "Feet", canEnchant = true},
    [9] = {id = 9, side = "LEFT", name = "Wrist", canEnchant = true},
    [10] = {id = 10, side = "RIGHT", name = "Hands", canEnchant = false},
    [11] = {id = 11, side = "RIGHT", name = "Finger0", canEnchant = true},
    [12] = {id = 12, side = "RIGHT", name = "Finger1", canEnchant = true},
    [13] = {id = 13, side = "RIGHT", name = "Trinket0", canEnchant = false},
    [14] = {id = 14, side = "RIGHT", name = "Trinket1", canEnchant = false},
    [15] = {id = 15, side = "LEFT", name = "Back", canEnchant = true},
    [16] = {id = 16, side = "RIGHT", name = "MainHand", canEnchant = true},
    [17] = {id = 17, side = "LEFT", name = "SecondaryHand", canEnchant = true},
    -- [18] = {id = 18, side = "LEFT", name = "Ranged", canEnchant = false},
    [19] = {id = 19, side = "LEFT", name = "Tabard", canEnchant = false} -- using as an anchor for average ilvl
}
-- update these after each tier patch
local minUpgaradeLevel = 642
local maxUpgaradeLevel = 723
local maxUpgradeLevels = {
    [665] = {12265, 12266, 12267, 12268, 12269, 12270, 12271, 12272}, -- Explorer
    [678] = {12274, 12275, 12276, 12277, 12278, 12279, 12280, 12281}, -- Adventurer
    [691] = {12282, 12283, 12284, 12285, 12286, 12287, 12288, 12289}, -- Veteran
    [704] = {12290, 12291, 12292, 12293, 12294, 12295, 12296, 12297}, -- Champion
    [710] = {12350, 12351, 12352, 12353, 12354, 12355}, -- Hero
    [681] = {
        12050, -- Starlight Crafted
        11142, -- Blue crafted weather rune
        10841, -- Rank 5 blue gear
        }, -- Crafted Gear
    [723] = {12356, 12357, 12358, 12359, 12360, 12361}, -- Myth
}

local specIndex = {
    [250] = 1,
    [251] = 1,
    [252] = 1,
    [577] = 2,
    [581] = 2,
    [102] = 4,
    [103] = 2,
    [104] = 2,
    [105] = 4,
    [1467] = 4,
    [1468] = 4,
    [1473] = 4,
    [62] = 4,
    [63] = 4,
    [64] = 4,
    [268] = 2,
    [270] = 4,
    [269] = 2,
    [65] = 4,
    [66] = 1,
    [70] = 1,
    [253] = 2,
    [254] = 2,
    [255] = 2,
    [256] = 4,
    [257] = 4,
    [258] = 4,
    [259] = 2,
    [260] = 2,
    [261] = 2,
    [262] = 4,
    [263] = 2,
    [264] = 4,
    [265] = 4,
    [266] = 4,
    [267] = 4,
    [71] = 1,
    [72] = 1,
    [73] = 1,
}

local function GetPrimaryStatName(unitId)
    local id = unitId == "player" and select(6, GetSpecializationInfo(GetSpecialization())) or specIndex[GetInspectSpecialization(unitId)]
    if id == 1 then return "Strength"
    elseif id == 2 then return "Agility"
    elseif id == 4 then return "Intellect"
    else return "Primary Stat"
    end
end

local GetMaxUpgradeLevel = function(bonusId)
    for level, ids in pairs(maxUpgradeLevels) do
        for i, id in pairs(ids) do
            if id == bonusId then
                return level
            end
        end
    end
    return nil
end

local CreateSlotFrame = function(unitId, slot)
    if slot == nil then
        return nil
    end
    
    local slotPrefix = unitId == "player" and "Character" or "Inspect"

    local parent = _G[slotPrefix .. slot.name .. "Slot"]
    if parent == nil then
        return nil
    end
    
    local relativePoint = slot.side == "LEFT" and "RIGHT" or "LEFT"
    local offsetX = slot.side == "LEFT" and 13 or -13
    local offsetEnchantY = ((slot.id == 16 or slot.id == 17) and -12) or 8
    
    if parent.EquipmentSlotFrame == nil then
        parent.EquipmentSlotFrame = CreateFrame("Frame", parent:GetName() .. "EquipmentSlotFrame", parent)
        parent.EquipmentSlotFrame:SetPoint("CENTER")
        parent.EquipmentSlotFrame:SetAllPoints(parent)
    else
        return parent
    end
    
    if parent.EquipmentSlotFrame.levelString == nil then
        parent.EquipmentSlotFrame.levelString = parent.EquipmentSlotFrame:CreateFontString(parent.EquipmentSlotFrame:GetName() .. "Level", "OVERLAY")
        parent.EquipmentSlotFrame.levelString:SetPoint("CENTER", parent.EquipmentSlotFrame, "CENTER", 0, 0)
        parent.EquipmentSlotFrame.levelString:SetFont(defaultFont, defaultFontsize, "OUTLINE")
        parent.EquipmentSlotFrame.levelString:Hide()
    end

    -- for average ilvl on inspect
    if slot.id == 19 then
        parent.EquipmentSlotFrame.levelString:SetPoint("CENTER", parent.EquipmentSlotFrame, "CENTER", 140, 0)
        parent.EquipmentSlotFrame.tex = parent.EquipmentSlotFrame:CreateTexture()
        parent.EquipmentSlotFrame.tex:SetPoint("CENTER", parent.EquipmentSlotFrame.levelString, "CENTER", 0, 0)
        parent.EquipmentSlotFrame.tex:SetAtlas("UI-Character-Info-ItemLevel-Bounce", true)
        parent.EquipmentSlotFrame.tex:SetAlpha((unitId~="player" and 0.298) or 0)

        return parent
    end
    
    if parent.EquipmentSlotFrame.maxLevelString == nil then
        parent.EquipmentSlotFrame.maxLevelString = parent.EquipmentSlotFrame:CreateFontString(parent.EquipmentSlotFrame:GetName() .. "MaxLevel", "OVERLAY")
        parent.EquipmentSlotFrame.maxLevelString:SetPoint("CENTER", parent.EquipmentSlotFrame, "CENTER", 0, -8)
        parent.EquipmentSlotFrame.maxLevelString:SetFont(defaultFont, defaultFontsize - 3, "OUTLINE")
        parent.EquipmentSlotFrame.maxLevelString:Hide()
    end
    
    if parent.EquipmentSlotFrame.enchantString == nil then
        parent.EquipmentSlotFrame.enchantString = parent.EquipmentSlotFrame:CreateFontString(parent.EquipmentSlotFrame:GetName() .. "Enchant", "OVERLAY")
        parent.EquipmentSlotFrame.enchantString:SetPoint(slot.side, parent.EquipmentSlotFrame, relativePoint,
        (slot.id == 17 and unitId~="player" and 3) or offsetX,
        (slot.id == 17 and unitId~="player" and 8) or offsetEnchantY)
        parent.EquipmentSlotFrame.enchantString:SetFont(defaultFont, defaultFontsize - 3, "OUTLINE")
        parent.EquipmentSlotFrame.enchantString:Hide()
    end
    
    if parent.EquipmentSlotFrame.socketFrame == nil then
        parent.EquipmentSlotFrame.socketFrame = {}
        for i = 1, 3 do
            if parent.EquipmentSlotFrame.socketFrame[i] == nil then
                parent.EquipmentSlotFrame.socketFrame[i] = CreateFrame("Button", parent.EquipmentSlotFrame:GetName() .. "Socket" .. i, parent.EquipmentSlotFrame, "SettingsCheckBoxTemplate")
                parent.EquipmentSlotFrame.socketFrame[i]:SetSize(defaultGemSize, defaultGemSize)
                local gemOffsetY = ((defaultGemSize) * ((i==1 and 1) or (i==2 and 0) or (i==3 and -1)))
                parent.EquipmentSlotFrame.socketFrame[i]:SetPoint(slot.side, parent.EquipmentSlotFrame:GetName(), relativePoint, slot.side=="LEFT" and -2 or 2, gemOffsetY)
                parent.EquipmentSlotFrame.socketFrame[i]:Disable()
                parent.EquipmentSlotFrame.socketFrame[i].gem = parent.EquipmentSlotFrame.socketFrame[i]:CreateTexture()
                parent.EquipmentSlotFrame.socketFrame[i].gem:ClearAllPoints()
                parent.EquipmentSlotFrame.socketFrame[i].gem:SetPoint("CENTER", parent.EquipmentSlotFrame.socketFrame[i], "CENTER", 0, 0)
                parent.EquipmentSlotFrame.socketFrame[i].gem:SetSize(defaultGemSize-6.5, defaultGemSize-6.5)
                parent.EquipmentSlotFrame.socketFrame[i]:Hide()
            end
        end
    end
    
    return parent
end

local function UpdateAverageItemLevel(unitId, positionBySlot)
    if unitId == nil or UnitGUID(unitId) == nil or positionBySlot == nil or
       characterSlots[positionBySlot] == nil then
		return
	end

    local slot = characterSlots[positionBySlot]
    local parent = CreateSlotFrame(unitId, slot)
    if parent == nil or parent.EquipmentSlotFrame == nil then
        return
    end

    if not settingsDB.enableCharacterILVLInfo then
        parent.EquipmentSlotFrame:Hide()
        return
    end

    local averageILVL = (unitId~="player" and string.format("%.2f", (sumILVL+weaponLevel)/16)) or ""
    local classColor = (RAID_CLASS_COLORS[select(2, UnitClass(unitId))]).colorStr or "ffa335ee"
    parent.EquipmentSlotFrame.levelString:SetText("|c"..classColor..averageILVL.."|r")
    parent.EquipmentSlotFrame.levelString:Show()
    parent.EquipmentSlotFrame:Show()
end

local function SetupItemLevel(parent, itemLevel, itemPayloadSplit, itemRarityColorHex)
    if not settingsDB.enableCharacterILVLInfo then
        parent.EquipmentSlotFrame.levelString:Hide()
        parent.EquipmentSlotFrame.maxLevelString:Hide()
        return
    end

    local maxLevel = nil

    parent.EquipmentSlotFrame.levelString:SetTextColor(1, 1, 1, 1)
    parent.EquipmentSlotFrame.maxLevelString:SetTextColor(0, 1, 0, 1)

    if itemLevel == nil then
        parent.EquipmentSlotFrame.levelString:Hide()
        parent.EquipmentSlotFrame.maxLevelString:Hide()
        return
    else
        parent.EquipmentSlotFrame.levelString:SetText(tostring(itemLevel))
        parent.EquipmentSlotFrame.levelString:Show()
        parent.EquipmentSlotFrame.maxLevelString:Show()
    end

    local numBonuses = tonumber(itemPayloadSplit[13])
    if numBonuses ~= nil and numBonuses > 0 then
        for i = 14, 13 + numBonuses do
            local bonusId = tonumber(itemPayloadSplit[i])
            if bonusId ~= nil then
                local maxLevelUpgrade = GetMaxUpgradeLevel(bonusId)
                if maxLevelUpgrade ~= nil then
                    maxLevel = maxLevelUpgrade
                end
            end
        end
    end
    
    if maxLevel == nil or itemLevel < minUpgaradeLevel then
        parent.EquipmentSlotFrame.levelString:SetPoint("CENTER", parent.EquipmentSlotFrame, "CENTER", 0, 0)
        parent.EquipmentSlotFrame.maxLevelString:Hide()
    else
        parent.EquipmentSlotFrame.maxLevelString:SetText(tostring(maxLevel))
        if itemLevel ~= maxLevel then
            parent.EquipmentSlotFrame.levelString:SetPoint("CENTER", parent.EquipmentSlotFrame, "CENTER", 0, 4)
            parent.EquipmentSlotFrame.maxLevelString:Show()
        else
            parent.EquipmentSlotFrame.levelString:SetPoint("CENTER", parent.EquipmentSlotFrame, "CENTER", 0, 0)
            parent.EquipmentSlotFrame.maxLevelString:Hide()
        end
    end
    
    if itemLevel ~= nil and (itemLevel == maxLevel or itemLevel >= maxUpgaradeLevel or itemLevel < minUpgaradeLevel) or maxLevel == nil then
        parent.EquipmentSlotFrame.levelString:SetText(itemRarityColorHex..tostring(itemLevel).."|r")
    end
end

local function GetItemInfoData(unitId, slotId, itemSockets)
    if not settingsDB.enableCharacterEnchantsInfo and not settingsDB.enableCharacterGemsInfo then return end
    local itemEnchant = nil
    local itemEnchantAtlas = ""
    local itemSocketCount = 0

    local enchantPattern = ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.*)")
    local enchantAtlasPattern = "(.*)|A:(.*):20:20|a"

    local tooltipData = C_TooltipInfo.GetInventoryItem(unitId, slotId)
    if tooltipData ~= nil then
        for i, line in pairs(tooltipData.lines) do 
            local text = line.leftText
            local enchantString = string.match(text, enchantPattern)
            if enchantString ~= nil then
                if string.find(enchantString, "|A:") then
                    itemEnchant, itemEnchantAtlas = string.match(enchantString, enchantAtlasPattern)
                else
                    itemEnchant = enchantString
                    itemEnchantAtlas = nil
                end
            end
            if line.type == Enum.TooltipDataLineType.GemSocket then
                if line.gemIcon then
                    itemSocketCount = itemSocketCount + 1
                    itemSockets[itemSocketCount] = line.gemIcon
                elseif line.socketType then
                    itemSocketCount = itemSocketCount + 1
                    itemSockets[itemSocketCount] = "character-emptysocket"
                end
            end
        end
    end

    return itemEnchant, itemEnchantAtlas, itemSocketCount
end

local function SetupItemEnchant(parent, slot, itemEnchant, itemEnchantAtlas, itemEquipLoc, unitId)
    if not settingsDB.enableCharacterEnchantsInfo then
        parent.EquipmentSlotFrame.enchantString:Hide()
        return
    end

    if itemEnchant == nil then
        if slot.canEnchant == true then
            itemEnchant = "No enchant"
            parent.EquipmentSlotFrame.enchantString:SetText(itemEnchant)
            parent.EquipmentSlotFrame.enchantString:SetTextColor(1, 0, 0, 1)
            if (itemEquipLoc ~= "INVTYPE_HOLDABLE" and itemEquipLoc ~= "INVTYPE_SHIELD") then
                parent.EquipmentSlotFrame.enchantString:Show()
            else
                parent.EquipmentSlotFrame.enchantString:Hide()
            end
            parent.EquipmentSlotFrame.enchantString:SetScript("OnEnter", function()
                return
            end)
        else
            parent.EquipmentSlotFrame.enchantString:Hide()
        end
    else
        if slot.id == 16 or slot.id == 17 then
            itemEnchant = itemEnchant:gsub("Authority", "")
            itemEnchant = itemEnchant:gsub("the", "")
            itemEnchant = itemEnchant:gsub("of", "")
            itemEnchant = itemEnchant:gsub("Rune", "")
            itemEnchant = itemEnchant:gsub("^%s+", ""):gsub("%s+$", "")
            itemEnchant = itemEnchant:gsub("% ", "\n", 1)
            -- Range weapon
            itemEnchant = itemEnchant:gsub("High\nIntensity Thermal Scanner", "High Intensity\nThermal Scanner")
        elseif slot.id == 7 then
            itemEnchant = itemEnchant:gsub(" & ", "\n       ")
        end
        itemEnchant = itemEnchant:gsub("^%s+", ""):gsub("%s+$", "")

        parent.EquipmentSlotFrame.enchantString:SetTextColor(0.12, 1, 0, 1)
        if slot.side == "RIGHT" then
            parent.EquipmentSlotFrame.enchantString:SetText((TWWEnchants[itemEnchant..(itemEnchantAtlas or "")] or itemEnchant) .. " " ..
                                                            ((itemEnchantAtlas and ("|A:"..itemEnchantAtlas..":15:15|a")) or
                                                             (DKEnchants[itemEnchant] and ("|T"..DKEnchants[itemEnchant]..":15:15|t")) or ""))
        else
            parent.EquipmentSlotFrame.enchantString:SetText(((itemEnchantAtlas and ("|A:"..itemEnchantAtlas..":15:15|a")) or
                                                             (DKEnchants[itemEnchant] and ("|T"..DKEnchants[itemEnchant]..":15:15|t")) or
                                                             (TWWHeadEnchants[itemEnchant] and ("|T"..TWWHeadEnchants[itemEnchant].icon..":15:15|t")) or "") ..
                                                            ((TWWEnchants[itemEnchant..(itemEnchantAtlas or "")] or itemEnchant):gsub("Primary Stat", GetPrimaryStatName(unitId))))
        end
        if TWWHeadEnchants[itemEnchant] then
            local GreaterEnchantQuality = string.match(itemEnchant, "Greater") and true or string.match(itemEnchant, "Lesser") and false or nil
            parent.EquipmentSlotFrame.enchantString:SetTextColor(not GreaterEnchantQuality and 0 or GreaterEnchantQuality and 0.64 or 0,
                                                                 not GreaterEnchantQuality and 0.44 or GreaterEnchantQuality and 0.21 or 1,
                                                                 not GreaterEnchantQuality and 0.87 or GreaterEnchantQuality and 0.93 or 0, 1)
            local _, enchantLink = C_Item.GetItemInfo(TWWHeadEnchants[itemEnchant].id)
            parent.EquipmentSlotFrame.enchantString:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(parent.EquipmentSlotFrame.enchantString, "ANCHOR_CURSOR")
                    GameTooltip:SetHyperlink(enchantLink)
                    GameTooltip:Show()
            end)
            parent.EquipmentSlotFrame.enchantString:SetScript("OnLeave", function()
                    GameTooltip:Hide()
            end)
        end
        parent.EquipmentSlotFrame.enchantString:Show()
    end
end

local function SetupItemGems(parent, itemLink, itemSockets, itemSocketCount)
    if not settingsDB.enableCharacterGemsInfo then
        parent.EquipmentSlotFrame.socketFrame[1]:Hide()
        parent.EquipmentSlotFrame.socketFrame[2]:Hide()
        parent.EquipmentSlotFrame.socketFrame[3]:Hide()
        return
    end
    for i = 1, 3 do
        local _, gemLink = C_Item.GetItemGem(itemLink, i)
        local socketFrame = parent.EquipmentSlotFrame.socketFrame[i]
        local point, relativeTo, relativePoint, offset_x, offset_y = socketFrame:GetPoint()

        if i==1 and itemSockets[2]==nil then
            parent.EquipmentSlotFrame.socketFrame[1]:SetPoint(point, relativeTo, relativePoint, offset_x, 0)
        elseif i==2 and itemSockets[2] ~=nil and itemSockets[3]==nil then
            parent.EquipmentSlotFrame.socketFrame[1]:SetPoint(point, relativeTo, relativePoint, offset_x, defaultGemSize/2)
            parent.EquipmentSlotFrame.socketFrame[2]:SetPoint(point, relativeTo, relativePoint, offset_x, -defaultGemSize/2)
        elseif i==3 and itemSockets[3]~=nil then
            parent.EquipmentSlotFrame.socketFrame[1]:SetPoint(point, relativeTo, relativePoint, offset_x, defaultGemSize)
            parent.EquipmentSlotFrame.socketFrame[2]:SetPoint(point, relativeTo, relativePoint, offset_x, 0)
        end
        
        if gemLink == nil then
            if i <= itemSocketCount then
                if itemSockets[i] ~= nil then
                    socketFrame:SetNormalAtlas(itemSockets[i])
                    socketFrame:Show()
                    socketFrame.gem:Hide()
                else
                    socketFrame:Hide()
                end
            else
                socketFrame:Hide()
            end
            socketFrame:SetScript("OnEnter", function()
                return
            end)
        else
            socketFrame:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(socketFrame, "ANCHOR_CURSOR")
                    GameTooltip:SetHyperlink(gemLink)
                    GameTooltip:Show()
            end)
            socketFrame:SetScript("OnLeave", function()
                    GameTooltip:Hide()
            end)
            if itemSockets[i] ~= nil then
                socketFrame:SetNormalAtlas("character-emptysocket")
                socketFrame:Show()
                socketFrame.gem:SetTexture(itemSockets[i])
                socketFrame.gem:SetDrawLayer("Overlay", 0)
                socketFrame.gem:SetTexCoord(.08, .92, .08, .92)
                socketFrame.gem:Show()
            else
                socketFrame:Hide()
                socketFrame.gem:Hide()
            end
        end
    end
end

function UpdateEquipmentSlot(unitId, slotId)
    if not settingsDB.characterInfoFlag or 
       unitId == nil or UnitGUID(unitId) == nil or slotId == nil or
       characterSlots[slotId] == nil or slotId == 19 then
		return
	end

    local slot = characterSlots[slotId]
    local parent = CreateSlotFrame(unitId, slot)
    if parent == nil or parent.EquipmentSlotFrame == nil then
        return
    end
    
    local itemLink = GetInventoryItemLink(unitId, slotId)
    if itemLink == nil or itemLink == "" then
        parent.EquipmentSlotFrame:Hide()
        return
    end
    
    local itemPayload = string.match(itemLink, "item:([%-?%d:]+)")
    if itemPayload == nil then
        parent.EquipmentSlotFrame:Hide()
        return
    end
    
    local itemEnchant = nil
    local itemEnchantAtlas = nil
    local itemSocketCount = 0
    local itemSockets = {}
    
    local itemPayloadSplit = {strsplit(":", itemPayload)}
    local itemEquipLoc =select(9,C_Item.GetItemInfo(itemLink))
    local itemLevel = select(1,C_Item.GetDetailedItemLevelInfo(itemLink))

    SetupItemLevel(parent, itemLevel, itemPayloadSplit, string.sub(itemLink, 1, 7))
    itemEnchant, itemEnchantAtlas, itemSocketCount = GetItemInfoData(unitId, slotId, itemSockets)
    SetupItemEnchant(parent, slot, itemEnchant, itemEnchantAtlas, itemEquipLoc, unitId)
    SetupItemGems(parent, itemLink, itemSockets, itemSocketCount)
    
    parent.EquipmentSlotFrame:Show()
    
    local _, _, _, weaponType = C_Item.GetItemInfoInstant(itemLink)
    if(slotId == 16 and TwoHanders[weaponType] and GetInspectSpecialization(unitId) ~= 72) then
        weaponLevel = itemLevel
    end
    return itemLevel
end

function UpdateAllEquipmentSlots(unitId)
    if not settingsDB.characterInfoFlag then
		return
	end
    sumILVL = 0
    weaponLevel = 0
    for slotId in pairs(characterSlots) do
        sumILVL = sumILVL + (UpdateEquipmentSlot(unitId, slotId) or 0)
    end
    UpdateAverageItemLevel(unitId, 19)
end
