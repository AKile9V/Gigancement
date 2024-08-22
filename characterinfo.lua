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
local RetailEnchants = {
    -- Rank3
    ["Cursed VersatilityProfessions-ChatIcon-Quality-Tier3"] = "+375 Versatility\n|cFFa335ee-110 Mastery|r",
    ["Cursed MasteryProfessions-ChatIcon-Quality-Tier3"] = "+375 Mastery\n|cFFa335ee-110 Critical Strike|r",
    ["Cursed HasteProfessions-ChatIcon-Quality-Tier3"] = "+375 Haste\n|cFFa335ee-110 Versatility|r",
    ["Cursed Critical StrikeProfessions-ChatIcon-Quality-Tier3"] = "+375 Critical Strike\n      |cFFa335ee-110 Haste|r",
    ["Cavalry's MarchProfessions-ChatIcon-Quality-Tier3"] = "+10% Mount",
    ["Scout's MarchProfessions-ChatIcon-Quality-Tier3"] = "+250 Speed",
    ["Defender's MarchProfessions-ChatIcon-Quality-Tier3"] = "+131 Stamina",
    ["Stormrider's AgilityProfessions-ChatIcon-Quality-Tier3"] = "+111 Agility\n+250 Speed",
    ["Council's IntellectProfessions-ChatIcon-Quality-Tier3"] = "+111 Intellect\n+5% Mana",
    ["Crystalline RadianceProfessions-ChatIcon-Quality-Tier3"] = "+150 Strength",
    ["Oathsworn's StrengthProfessions-ChatIcon-Quality-Tier3"] = "+111 Strength\n+374 Stamina",
    ["Chant of Winged GraceProfessions-ChatIcon-Quality-Tier3"] = "+125 Avoidance\n-20% Fall Damage",
    ["Chant of Leeching FangsProfessions-ChatIcon-Quality-Tier3"] = "+125 Leech\nHeal OOC",
    ["Chant of Burrowing RapidityProfessions-ChatIcon-Quality-Tier3"] = "+125 Speed     \nHearthstone CD",
    -- TODO: Rank2/1
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
local minUpgaradeLevel = 558
local maxUpgaradeLevel = 639
local maxUpgradeLevels = {
    [580] = {10289, 10288, 10287, 10286, 10285, 10284, 10283, 10282}, -- Explorer
    [593] = {10297, 10296, 10295, 10294, 10293, 10292, 10291, 10290}, -- Adventurer
    [606] = {10281, 10280, 10279, 10278, 10277, 10276, 10275, 10274}, -- Veteran
    [619] = {10273, 10272, 10271, 10270, 10269, 10268, 10267, 10266}, -- Champion
    [626] = {10265, 10264, 10263, 10262, 10261, 10256}, -- Hero
    [636] = {
        10222, -- Omen Crafted
        11142, -- Blue crafted weather rune
        10841, -- Rank 5 blue gear
        }, -- Crafted Gear
    [639] = {10260, 10259, 10258, 10257, 10298, 10299}, -- Myth
}

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
    
    if itemLevel ~= nil and (itemLevel == maxLevel or itemLevel >= maxUpgaradeLevel or itemLevel < minUpgaradeLevel) then
        local itemRarityRed = tonumber("0x"..itemRarityColorHex:sub(1,2))/255
        local itemRarityGreen = tonumber("0x"..itemRarityColorHex:sub(3,4))/255
        local itemRarityBlue = tonumber("0x"..itemRarityColorHex:sub(5,6))/255
        parent.EquipmentSlotFrame.levelString:SetTextColor(itemRarityRed, itemRarityGreen, itemRarityBlue, 1)
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

local function SetupItemEnchant(parent, slot, itemEnchant, itemEnchantAtlas, itemEquipLoc)
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
            itemEnchant = itemEnchant:gsub("% ", "\n",1)
        elseif slot.id == 7 then
            itemEnchant = itemEnchant:gsub(" & ", "\n       ")
        end
        itemEnchant = itemEnchant:gsub("^%s+", ""):gsub("%s+$", "")

        parent.EquipmentSlotFrame.enchantString:SetTextColor(0, 1, 0, 1)
        if slot.side == "RIGHT" then
            parent.EquipmentSlotFrame.enchantString:SetText((RetailEnchants[itemEnchant..(itemEnchantAtlas or "")] or itemEnchant) .. " " ..
                                                            ((itemEnchantAtlas and ("|A:"..itemEnchantAtlas..":15:15|a")) or
                                                             (DKEnchants[itemEnchant] and ("|T"..DKEnchants[itemEnchant]..":15:15|t")) or ""))
        else
            parent.EquipmentSlotFrame.enchantString:SetText(((itemEnchantAtlas and ("|A:"..itemEnchantAtlas..":15:15|a")) or
                                                             (DKEnchants[itemEnchant] and ("|T"..DKEnchants[itemEnchant]..":15:15|t")) or "") ..
                                                            (RetailEnchants[itemEnchant..(itemEnchantAtlas or "")] or itemEnchant))
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

    SetupItemLevel(parent, itemLevel, itemPayloadSplit, string.sub(itemLink, 5, 10):gsub("#",""))
    itemEnchant, itemEnchantAtlas, itemSocketCount = GetItemInfoData(unitId, slotId, itemSockets)
    SetupItemEnchant(parent, slot, itemEnchant, itemEnchantAtlas, itemEquipLoc)
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
