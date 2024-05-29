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

-- CharacterInfo and InspectCharacter ILVL
local _G = _G
local defaultFont = STANDARD_TEXT_FONT
local defaultFontsize = 13
local defaultFontOutline = "OUTLINE"
local TwoHanders = {
    ["INVTYPE_RANGED"] = true,
    ["INVTYPE_RANGEDRIGHT"] = true,
    ["INVTYPE_2HWEAPON"] = true
}
local DKEnchants = {
    ["Rune\nof Hysteria"] = 460688,
    ["Rune\nof Razorice"] = 135842,
    ["Rune\nof Sanguination"] = 1778226,
    ["Rune\nof Spellwarding"] = 425952,
    ["Rune\nof the Apocalypse"] = 237535,
    ["Rune\nof the Fallen Crusader"] = 135957,
    ["Rune\nof the Stoneskin Gargoyle"] = 237480,
    ["Rune\nof Unending Thirst"] = 3163621,
}
local sumILVL = 0
local weaponLevel = 0
local characterSlots = {
    [1] = {id = 1, side = "LEFT", name = "Head", canEnchant = true},
    [2] = {id = 2, side = "LEFT", name = "Neck", canEnchant = false},
    [3] = {id = 3, side = "LEFT", name = "Shoulder", canEnchant = false},
    -- [4] = {id = 4, side = "LEFT", name = "Shirt", canEnchant = false},
    [5] = {id = 5, side = "LEFT", name = "Chest", canEnchant = true},
    [6] = {id = 6, side = "RIGHT", name = "Waist", canEnchant = true},
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
    --    [18] = {id = 18, side = "LEFT", name = "Ranged", canEnchant = false},
    [19] = {id = 19, side = "LEFT", name = "Tabard", canEnchant = false} -- using anchor for average ilvl
}
-- update these after each tier patch
local maxUpgaradeLevel = 535
local maxUpgradeLevels = {
    [476] = {10321, 10322, 10323, 10324, 10325, 10326, 10327, 10328}, -- Explorer
    [489] = {10305, 10306, 10307, 10308, 10309, 10310, 10311, 10312}, -- Adventurer
    [502] = {10341, 10342, 10343, 10344, 10345, 10346, 10347, 10348}, -- Veteran
    [515] = {10313, 10314, 10315, 10316, 10317, 10318, 10319, 10320}, -- Champion
    [522] = {10329, 10330, 10331, 10332, 10333, 10334}, -- Hero
    [525] = {
        9401,9402,9403,9404,9405, -- Qualities
        8785,
        8845,8846,
    9373,9374,9375,9376}, -- Crafted
    [528] = {10335, 10336, 10337, 10338, 10407, 10408, 10409, 10410, 10411, 10412, 10413, 10414, 10415, 10416, 10417, 10418}, -- Myth + Awakened
    -- [528] = {10407, 10408, 10409, 10410, 10411, 10412, 10413, 10414, 10415, 10416, 10417, 10418}, -- Awakened
    [535] = {10490, 10491, 10492, 10493, 10494, 10495, 10496, 10497, 10498, 10499, 10500, 10501, 10502, 10503} -- Awakened+
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
    
    local slotPrefix = "Inspect"
    if unitId == "player" then
        slotPrefix = "Character"
    end
    
    local parent = _G[slotPrefix .. slot.name .. "Slot"]
    if parent == nil then
        return nil
    end
    
    local relativePoint = slot.side == "LEFT" and "RIGHT" or "LEFT"
    local offsetX = slot.side == "LEFT" and 9 or -10
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
    end

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

        parent.EquipmentSlotFrame.upgradeArrow = parent.EquipmentSlotFrame:CreateFontString(parent.EquipmentSlotFrame:GetName() .. "Upgrade", "OVERLAY")
        parent.EquipmentSlotFrame.upgradeArrow:SetPoint("TOPLEFT", parent.EquipmentSlotFrame, "TOPLEFT", -2, -1)
        parent.EquipmentSlotFrame.upgradeArrow:SetFont(defaultFont, defaultFontsize + 1, "OUTLINE")
    end
    
    if parent.EquipmentSlotFrame.enchantString == nil then
        parent.EquipmentSlotFrame.enchantString = parent.EquipmentSlotFrame:CreateFontString(parent.EquipmentSlotFrame:GetName() .. "Enchant", "OVERLAY")
        parent.EquipmentSlotFrame.enchantString:SetPoint(slot.side, parent.EquipmentSlotFrame, relativePoint, offsetX, offsetEnchantY)
        parent.EquipmentSlotFrame.enchantString:SetFont(defaultFont, defaultFontsize - 3, "OUTLINE")
    end
    
    if parent.EquipmentSlotFrame.socketFrame == nil then
        parent.EquipmentSlotFrame.socketFrame = {}
        for i = 1, 3 do
            if parent.EquipmentSlotFrame.socketFrame[i] == nil then
                parent.EquipmentSlotFrame.socketFrame[i] = CreateFrame("Button", parent.EquipmentSlotFrame:GetName() .. "Socket" .. i, parent.EquipmentSlotFrame, "UIPanelButtonTemplate")
                parent.EquipmentSlotFrame.socketFrame[i]:SetSize(14, 14)
                local gemOffsetX = offsetX - 3 - (15 * (i - 1))
                if slot.side == "LEFT" then
                    gemOffsetX = offsetX + 3 + (15 * (i - 1))
                end
                parent.EquipmentSlotFrame.socketFrame[i]:SetPoint(slot.side, parent.EquipmentSlotFrame:GetName(), relativePoint, gemOffsetX, 0)
            end
        end
    end
    
    return parent
end

function UpdateEquipmentSlot(unitId, slotId)
    if not settingsDB.enableCharacterILVLInfo then
		return
	end
    if unitId == nil or UnitGUID(unitId) == nil or slotId == nil then
        return
    end
    
    local slot = characterSlots[slotId]
    if slot == nil then
        return
    end
    
    local parent = CreateSlotFrame(unitId, slot)
    if parent == nil then
        return
    end
    
    if parent.EquipmentSlotFrame == nil then
        return
    end
    
    if slotId == 19 then
        local averageILVL = (unitId~="player" and string.format("%.2f", (sumILVL+weaponLevel)/16)) or ""
        local classColor = (RAID_CLASS_COLORS[select(2, UnitClass(unitId))]).colorStr or "ffa335ee"
        parent.EquipmentSlotFrame.levelString:SetText("|c"..classColor..averageILVL.."|r")
        
        parent.EquipmentSlotFrame.levelString:Show()
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
    
    local itemRarityColorHex = string.sub(itemLink, 5, 10):gsub("#","")
    local itemRarityRed = tonumber("0x"..itemRarityColorHex:sub(1,2))/255
    local itemRarityGreen = tonumber("0x"..itemRarityColorHex:sub(3,4))/255
    local itemRarityBlue = tonumber("0x"..itemRarityColorHex:sub(5,6))/255
    local itemPayloadSplit = { strsplit(":", itemPayload) }
    local itemEnchant = nil
    local itemEnchantAtlas = ""
    local itemSocketCount = 0
    local itemSockets = {}
    local MaxLevel = nil
    local enchantPattern = ENCHANTED_TOOLTIP_LINE:gsub('%%s', '(.*)');
    local enchantAtlasPattern = "(.*)|A:(.*):20:20|a";
    
    local itemEquipLoc =select(9,GetItemInfo(itemLink))
    local itemLevel = select(1,GetDetailedItemLevelInfo(itemLink))
    if itemLevel == nil then
        parent.EquipmentSlotFrame.levelString:Hide()
        parent.EquipmentSlotFrame.maxLevelString:Hide()
        parent.EquipmentSlotFrame.upgradeArrow:Hide()
    else
        parent.EquipmentSlotFrame.levelString:SetText(itemLevel)
        parent.EquipmentSlotFrame.levelString:Show()
        parent.EquipmentSlotFrame.maxLevelString:Show()
        parent.EquipmentSlotFrame.upgradeArrow:Show()
    end
    
    local tooltipData = C_TooltipInfo.GetInventoryItem(unitId, slotId);
    if tooltipData ~= nil then
        for i, line in pairs(tooltipData.lines) do
            
            local text = line.leftText;
            local enchantString = string.match(text, enchantPattern);
            if enchantString ~= nil then
                if string.find(enchantString, "|A:") then
                    itemEnchant, itemEnchantAtlas = string.match(enchantString, enchantAtlasPattern)
                else
                    itemEnchant = enchantString
                end
            end
            
            TooltipUtil.SurfaceArgs(line);
            if line.gemIcon then
                itemSocketCount = itemSocketCount + 1
                itemSockets[itemSocketCount] = line.gemIcon
            elseif line.socketType then
                itemSocketCount = itemSocketCount + 1
                itemSockets[itemSocketCount] = string.format("Interface\\ItemSocketingFrame\\UI-EmptySocket-%s", line.socketType)
            end
        end
    end
    
    local numBonuses = tonumber(itemPayloadSplit[13])
    if numBonuses ~= nil and numBonuses > 0 then
        for i = 14, 13 + numBonuses do
            local bonusId = tonumber(itemPayloadSplit[i])
            if bonusId ~= nil then
                local maxLevelUpgrade = GetMaxUpgradeLevel(bonusId)
                if maxLevelUpgrade ~= nil then
                    MaxLevel = maxLevelUpgrade
                end
            end
        end
    end
    
    if MaxLevel == nil then
        parent.EquipmentSlotFrame.levelString:SetPoint("CENTER", parent.EquipmentSlotFrame, "CENTER", 0, 0)
        parent.EquipmentSlotFrame.maxLevelString:Hide()
        parent.EquipmentSlotFrame.upgradeArrow:Hide()
    else
        parent.EquipmentSlotFrame.maxLevelString:SetText(MaxLevel)
        parent.EquipmentSlotFrame.upgradeArrow:SetText("|A:loottoast-arrow-green:12:8|a")
        if itemLevel ~= MaxLevel then
            parent.EquipmentSlotFrame.levelString:SetPoint("CENTER", parent.EquipmentSlotFrame, "CENTER", 0, 4)
            parent.EquipmentSlotFrame.maxLevelString:Show()
            parent.EquipmentSlotFrame.upgradeArrow:Show()
        else
            parent.EquipmentSlotFrame.levelString:SetPoint("CENTER", parent.EquipmentSlotFrame, "CENTER", 0, 0)
            parent.EquipmentSlotFrame.maxLevelString:Hide()
            parent.EquipmentSlotFrame.upgradeArrow:Hide()
        end
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
        itemEnchant = itemEnchant:gsub("+", "")
        parent.EquipmentSlotFrame.enchantString:SetTextColor(0, 1, 0, 1)

        if slot.id == 16 or slot.id == 17 then
            itemEnchant = string.gsub(itemEnchant,"% ", "\n",1)
        end
        
        if slot.side == "RIGHT" and DKEnchants[itemEnchant]==nil then
            parent.EquipmentSlotFrame.enchantString:SetText(itemEnchant .. "|A:" .. itemEnchantAtlas .. ":12:12|a")
        elseif slot.side == "LEFT" and DKEnchants[itemEnchant]==nil then
            parent.EquipmentSlotFrame.enchantString:SetText("|A:" .. itemEnchantAtlas .. ":12:12|a" .. itemEnchant)
        elseif slot.side == "RIGHT" and DKEnchants[itemEnchant] then
            parent.EquipmentSlotFrame.enchantString:SetText(string.sub(itemEnchant, 2):match'%u.*' .. "|T" .. DKEnchants[itemEnchant] .. ":15:15|t")
        else
            parent.EquipmentSlotFrame.enchantString:SetText("|T" .. DKEnchants[itemEnchant] .. ":15:15|t" .. string.sub(itemEnchant, 2):match'%u.*')
        end
        parent.EquipmentSlotFrame.enchantString:Show()
    end
    
    if slot.id ~= 16 and slot.id ~= 17 then
        local point, relativeTo, relativePoint, offset_x = parent.EquipmentSlotFrame.enchantString:GetPoint()
        if itemSocketCount > 0 or (slot.id == 9 or slot.id == 14) then
            parent.EquipmentSlotFrame.enchantString:SetPoint(point, relativeTo, relativePoint, offset_x, 8)
        else
            parent.EquipmentSlotFrame.enchantString:SetPoint(point, relativeTo, relativePoint, offset_x, 0)
        end
    end
    
    for i = 1, 3 do
        local _, gemLink = GetItemGem(itemLink, i)
        local socketFrame = parent.EquipmentSlotFrame.socketFrame[i]
        local point, relativeTo, relativePoint, offset_x = socketFrame:GetPoint()
        
        if gemLink == nil then
            if i <= itemSocketCount then
                if itemSockets[i] ~= nil then
                    socketFrame:SetNormalTexture(itemSockets[i])
                    socketFrame:Show()
                else
                    socketFrame:Hide()
                end
            else
                socketFrame:Hide()
            end
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
                socketFrame:SetNormalTexture(itemSockets[i])
                socketFrame:Show()
            else
                socketFrame:Hide()
            end
        end
        
        if itemEnchant ~= nil or (slot.id == 9 or slot.id == 14) then
            socketFrame:SetPoint(point, relativeTo, relativePoint, offset_x, -8)
        else
            socketFrame:SetPoint(point, relativeTo, relativePoint, offset_x, 0)
        end
    end
    
    parent.EquipmentSlotFrame.levelString:SetTextColor(1, 1, 1, 1)
    parent.EquipmentSlotFrame.maxLevelString:SetTextColor(0, 1, 0, 1)
    
    if itemLevel ~= nil then
        if itemLevel == MaxLevel or itemLevel >= maxUpgaradeLevel then
            parent.EquipmentSlotFrame.levelString:SetTextColor(itemRarityRed, itemRarityGreen, itemRarityBlue, 1)
        end
    end
    
    parent.EquipmentSlotFrame:Show()
    
    local _, _, _, weaponType = GetItemInfoInstant(itemLink)
    if(slotId == 16 and TwoHanders[weaponType] and GetInspectSpecialization(unitId) ~= 72) then
        weaponLevel = itemLevel
    end
    return itemLevel
end

function UpdateAllEquipmentSlots(unitId)
    if not settingsDB.enableCharacterILVLInfo then
		return
	end
    sumILVL = 0
    weaponLevel = 0
    for slotId in pairs(characterSlots) do
        sumILVL = sumILVL + (UpdateEquipmentSlot(unitId, slotId) or 0)
    end
    UpdateEquipmentSlot(unitId, 19)
end
