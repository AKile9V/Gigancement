local function DecimalILVL(statFrame, unit)
    if unit ~= "player" or (not GigaSettingsDB.decimalILVL and not GigaSettingsDB.classColorILVL) then
        return
    end
    local maxiLvl, equippediLvl = GetAverageItemLevel()
    local ilvlText
    if GigaSettingsDB.decimalILVL then
        ilvlText = (equippediLvl ~= maxiLvl and string.format("%.2f".."/%.2f", equippediLvl, maxiLvl)) or string.format("%.2f", equippediLvl)
    end
    ilvlText = GigaSettingsDB.decimalILVL and ilvlText or string.format("%d", equippediLvl)
    local classColor = (RAID_CLASS_COLORS[select(2, UnitClass(unit))]).colorStr or "ffa335ee"
    ilvlText = (GigaSettingsDB.classColorILVL and "|c"..classColor..ilvlText.."|r") or ilvlText
    PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, ilvlText, false, ilvlText)  
end
hooksecurefunc("PaperDollFrame_SetItemLevel", DecimalILVL)

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
    -- Rank2 Professions-ChatIcon-Quality-12-Tier2
    ["Enchant Helm - Blessing of SpeedProfessions-ChatIcon-Quality-12-Tier2"] = "+13 Speed",
    ["Enchant Helm - Rune of AvoidanceProfessions-ChatIcon-Quality-12-Tier2"] = "+22 Avoidance",
    ["Enchant Helm - Hex of LeechingProfessions-ChatIcon-Quality-12-Tier2"] = "+33 Leech",
    ["Enchant Helm - Empowered Blessing of SpeedProfessions-ChatIcon-Quality-12-Tier2"] = "+22 Speed\n|cFF9d9d9d+1 Vigor|r",
    ["Enchant Helm - Empowered Rune of AvoidanceProfessions-ChatIcon-Quality-12-Tier2"] = "+37 Avoidance\n|cFF9d9d9d+Burst MS|r",
    ["Enchant Helm - Empowered Hex of LeechingProfessions-ChatIcon-Quality-12-Tier2"] = "+55 Leech\n|cFF9d9d9d+3% Heal|r",
    ["Enchant Shoulders - Flight of the EagleProfessions-ChatIcon-Quality-12-Tier2"] = "+39 Speed",
    ["Enchant Shoulders - Nature's GraceProfessions-ChatIcon-Quality-12-Tier2"] = "+67 Avoidance",
    ["Enchant Shoulders - Thalassian RecoveryProfessions-ChatIcon-Quality-12-Tier2"] = "+99 Leech",
    ["Enchant Shoulders - Akil'zon's SwiftnessProfessions-ChatIcon-Quality-12-Tier2"] = "+65 Speed",
    ["Enchant Shoulders - Amirdrassil's GraceProfessions-ChatIcon-Quality-12-Tier2"] = "+111 Avoidance",
    ["Enchant Shoulders - Silvermoon's MendingProfessions-ChatIcon-Quality-12-Tier2"] = "+166 Leech",
    ["Enchant Chest - Mark of NalorakkProfessions-ChatIcon-Quality-12-Tier2"] = "+40 Strength\n+116 Stamina",
    ["Enchant Chest - Mark of the MagisterProfessions-ChatIcon-Quality-12-Tier2"] = "+40 Intellect\n+5% Mana",
    ["Enchant Chest - Mark of the RootwardenProfessions-ChatIcon-Quality-12-Tier2"] = "+40 Agility\n+15 Speed",
    ["Enchant Chest - Mark of the WorldsoulProfessions-ChatIcon-Quality-12-Tier2"] = "+50 Primary Stat",
    ["Enchant Boots - Lynx's DexterityProfessions-ChatIcon-Quality-12-Tier2"] = "+19 Avoidance\n+232 Stamina",
    ["Enchant Boots - Farstrider's HuntProfessions-ChatIcon-Quality-12-Tier2"] = "+11 Speed\n+232 Stamina",
    ["Enchant Boots - Shaladrassil's RootsProfessions-ChatIcon-Quality-12-Tier2"] = "+28 Leech\n+232 Stamina",
    ["Enchant Ring - Amani MasteryProfessions-ChatIcon-Quality-12-Tier2"] = "+24 Mastery",
    ["Enchant Ring - Nature's WrathProfessions-ChatIcon-Quality-12-Tier2"] = "+24 Critical Strike",
    ["Enchant Ring - Thalassian HasteProfessions-ChatIcon-Quality-12-Tier2"] = "+24 Haste",
    ["Enchant Ring - Thalassian VersatilityProfessions-ChatIcon-Quality-12-Tier2"] = "+24 Versatility",
    ["Enchant Ring - Silvermoon's TenacityProfessions-ChatIcon-Quality-12-Tier2"] = "+29 Versatility",
    ["Enchant Ring - Zul'jin's MasteryProfessions-ChatIcon-Quality-12-Tier2"] = "+29 Mastery",
    ["Enchant Ring - Silvermoon's AlacrityProfessions-ChatIcon-Quality-12-Tier2"] = "+29 Haste",
    ["Enchant Ring - Nature's FuryProfessions-ChatIcon-Quality-12-Tier2"] = "+29 Critical Strike",
    ["Enchant Ring - Eyes of the EagleProfessions-ChatIcon-Quality-12-Tier2"] = "+1% Crit Effectiveness",
    -- Rank1
    ["Enchant Helm - Blessing of SpeedProfessions-ChatIcon-Quality-12-Tier1"] = "+9 Speed",
    ["Enchant Helm - Rune of AvoidanceProfessions-ChatIcon-Quality-12-Tier1"] = "+15 Avoidance",
    ["Enchant Helm - Hex of LeechingProfessions-ChatIcon-Quality-12-Tier1"] = "+22 Leech",
    ["Enchant Helm - Empowered Blessing of SpeedProfessions-ChatIcon-Quality-12-Tier1"] = "+17 Speed\n|cFF9d9d9d+1 Vigor|r",
    ["Enchant Helm - Empowered Rune of AvoidanceProfessions-ChatIcon-Quality-12-Tier1"] = "+30 Avoidance\n|cFF9d9d9d+Burst MS|r",
    ["Enchant Helm - Empowered Hex of LeechingProfessions-ChatIcon-Quality-12-Tier1"] = "+44 Leech\n|cFF9d9d9d+2% Heal|r",
    ["Enchant Shoulders - Flight of the EagleProfessions-ChatIcon-Quality-12-Tier1"] = "+26 Speed",
    ["Enchant Shoulders - Nature's GraceProfessions-ChatIcon-Quality-12-Tier1"] = "+44 Avoidance",
    ["Enchant Shoulders - Thalassian RecoveryProfessions-ChatIcon-Quality-12-Tier1"] = "+66 Leech",
    ["Enchant Shoulders - Akil'zon's SwiftnessProfessions-ChatIcon-Quality-12-Tier1"] = "+52 Speed",
    ["Enchant Shoulders - Amirdrassil's GraceProfessions-ChatIcon-Quality-12-Tier1"] = "+89 Avoidance",
    ["Enchant Shoulders - Silvermoon's MendingProfessions-ChatIcon-Quality-12-Tier1"] = "+132 Leech",
    ["Enchant Chest - Mark of NalorakkProfessions-ChatIcon-Quality-12-Tier1"] = "+32 Strength\n+93 Stamina",
    ["Enchant Chest - Mark of the MagisterProfessions-ChatIcon-Quality-12-Tier1"] = "+32 Intellect\n+2% Mana",
    ["Enchant Chest - Mark of the RootwardenProfessions-ChatIcon-Quality-12-Tier1"] = "+32 Agility\n+12 Speed",
    ["Enchant Chest - Mark of the WorldsoulProfessions-ChatIcon-Quality-12-Tier1"] = "+36 Primary Stat",
    ["Enchant Boots - Lynx's DexterityProfessions-ChatIcon-Quality-12-Tier1"] = "+15 Avoidance\n+186 Stamina",
    ["Enchant Boots - Farstrider's HuntProfessions-ChatIcon-Quality-12-Tier1"] = "+9 Speed\n+186 Stamina",
    ["Enchant Boots - Shaladrassil's RootsProfessions-ChatIcon-Quality-12-Tier1"] = "+22 Leech\n+186 Stamina",
    ["Enchant Ring - Amani MasteryProfessions-ChatIcon-Quality-12-Tier1"] = "+22 Mastery",
    ["Enchant Ring - Nature's WrathProfessions-ChatIcon-Quality-12-Tier1"] = "+22 Critical Strike",
    ["Enchant Ring - Thalassian HasteProfessions-ChatIcon-Quality-12-Tier1"] = "+22 Haste",
    ["Enchant Ring - Thalassian VersatilityProfessions-ChatIcon-Quality-12-Tier1"] = "+22 Versatility",
    ["Enchant Ring - Silvermoon's TenacityProfessions-ChatIcon-Quality-12-Tier1"] = "+27 Versatility",
    ["Enchant Ring - Zul'jin's MasteryProfessions-ChatIcon-Quality-12-Tier1"] = "+27 Mastery",
    ["Enchant Ring - Silvermoon's AlacrityProfessions-ChatIcon-Quality-12-Tier1"] = "+27 Haste",
    ["Enchant Ring - Nature's FuryProfessions-ChatIcon-Quality-12-Tier1"] = "+27 Critical Strike",
    ["Enchant Ring - Eyes of the EagleProfessions-ChatIcon-Quality-12-Tier1"] = "+1% Crit Effectiveness",
}
local sumILVL = 0
local weaponLevel = 0
local characterSlots = {
    [1] = {id = 1, side = "LEFT", name = "Head", canEnchant = true},
    [2] = {id = 2, side = "LEFT", name = "Neck", canEnchant = false},
    [3] = {id = 3, side = "LEFT", name = "Shoulder", canEnchant = true},
    -- [4] = {id = 4, side = "LEFT", name = "Shirt", canEnchant = false},
    [5] = {id = 5, side = "LEFT", name = "Chest", canEnchant = true},
    [6] = {id = 6, side = "RIGHT", name = "Waist", canEnchant = false},
    [7] = {id = 7, side = "RIGHT", name = "Legs", canEnchant = true},
    [8] = {id = 8, side = "RIGHT", name = "Feet", canEnchant = true},
    [9] = {id = 9, side = "LEFT", name = "Wrist", canEnchant = false},
    [10] = {id = 10, side = "RIGHT", name = "Hands", canEnchant = false},
    [11] = {id = 11, side = "RIGHT", name = "Finger0", canEnchant = true},
    [12] = {id = 12, side = "RIGHT", name = "Finger1", canEnchant = true},
    [13] = {id = 13, side = "RIGHT", name = "Trinket0", canEnchant = false},
    [14] = {id = 14, side = "RIGHT", name = "Trinket1", canEnchant = false},
    [15] = {id = 15, side = "LEFT", name = "Back", canEnchant = false},
    [16] = {id = 16, side = "RIGHT", name = "MainHand", canEnchant = true},
    [17] = {id = 17, side = "LEFT", name = "SecondaryHand", canEnchant = true},
    -- [18] = {id = 18, side = "LEFT", name = "Ranged", canEnchant = false},
    [19] = {id = 19, side = "LEFT", name = "Tabard", canEnchant = false} -- ilvl anchor
}
-- Keep current with tier patches
local minUpgaradeLevel = 220
local maxUpgaradeLevel = 289
local maxUpgradeLevels = {
    [237] = {12769, 12770, 12771, 12772, 12773, 12774}, -- Adventurer
    [246] = {12247}, -- Crafted Adventurer/Veteran Gear
    [250] = {12777, 12778, 12779, 12780, 12781, 12782}, -- Veteran
    [263] = {12785, 12786, 12787, 12788, 12789, 12790}, -- Champion
    [276] = {12793, 12794, 12795, 12796, 12797, 12798}, -- Hero
    [285] = {12066}, -- Crafted Hero/Myth Gear
    [289] = {12801, 12802, 12803, 12804, 12805, 12806}, -- Myth
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
    local offsetEnchantY = ((slot.id == 16 or slot.id == 17) and -12) or 5
    
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

    -- For avg ilvl on inspect
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

    if not GigaSettingsDB.characterILVLInfo then
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
    if not GigaSettingsDB.characterILVLInfo then
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
    if not GigaSettingsDB.characterEnchantsInfo and not GigaSettingsDB.characterGemsInfo then return end
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
    if not GigaSettingsDB.characterEnchantsInfo then
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
            itemEnchant = itemEnchant:gsub("Enchant Weapon", "")
            itemEnchant = itemEnchant:gsub("-", "")
            itemEnchant = itemEnchant:gsub("of", "")
            itemEnchant = itemEnchant:gsub("the", "")
            itemEnchant = itemEnchant:gsub("Rune", "")
            itemEnchant = itemEnchant:gsub("^%s+", ""):gsub("%s+$", "")
            itemEnchant = itemEnchant:gsub("% ", "\n", 1)
            -- Range weapon
            itemEnchant = itemEnchant:gsub("High\nIntensity Thermal Scanner", "High Intensity\nThermal Scanner")
        elseif slot.id == 7 then
            itemEnchant = itemEnchant:gsub("&", "\n")
        end
        itemEnchant = itemEnchant:gsub("^%s+", ""):gsub("%s+$", "")

        parent.EquipmentSlotFrame.enchantString:SetTextColor(0.12, 1, 0, 1)
        parent.EquipmentSlotFrame.enchantString:SetJustifyH("RIGHT")
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
    if not GigaSettingsDB.characterGemsInfo then
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

function GigaSettingsInterface:UpdateEquipmentSlot(unitId, slotId)
    if not GigaSettingsDB.characterInfoFlag or 
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

function GigaSettingsInterface:UpdateAllEquipmentSlots(unitId)
    if not GigaSettingsDB.characterInfoFlag then
		return
	end
    sumILVL = 0
    weaponLevel = 0
    for slotId in pairs(characterSlots) do
        sumILVL = sumILVL + (GigaSettingsInterface:UpdateEquipmentSlot(unitId, slotId) or 0)
    end
    UpdateAverageItemLevel(unitId, 19)
end
