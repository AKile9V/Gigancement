settingsDB = settingsDB or {}

local GetNameplateByID = C_NamePlate.GetNamePlateForUnit

local defaultSettings = {
    m_currentInspec = nil,
    enableHPTextNameplate = false,
    enableHPTextFriendlyNameplate = false,
    formatHPText = {
        [1] = {
            label = "Numeric Value",
            text = "Numeric Value",
            value = false,
            tooltip = "256.3M",
            index = 1,
        },
        [2] = {
            label = "Percentage",
            text = "Percentage",
            value = false,
            tooltip = "100%",
            index = 2,
        },
        [3] = {
            label = "Both",
            text = "Both",
            value = true,
            tooltip = "256.3M (100%)",
            index = 3,
        }
    },
    enableCastTimerNameplate = false,
    enableShorterKeybinds = true,
    enableHideKeybindText = false,
    enableHideMacroText = false,
    enableLinksInChat = true,
    colorLinkRed = 0,
    colorLinkGreen = 0.7,
    colorLinkBlue = 1,
    enableRolesInChat = true,
    enableShorterChannelNames = true,
    enableChatMouseoverItemTooltip = false,
    enableInspectLFG = true,
    enableDoubleClickLFG = true,
    enableSkipRoleCheck = true,
    enableMuteApplicantSound = true,
    enableApplicantRaceTooltip = false,
    enableSortApplicants = false,
    enableUpgradedCastbar = true,
    castbarTextPosition = {
        [1] = {
            label = "Left",
            text = "Left",
            value = false,
            index = 1,
            info = "BOTTOMLEFT",
        },
        [2] = {
            label = "Center",
            text = "Center",
            value = true,
            index = 2,
            info = "BOTTOM",
        },
        [3] = {
            label = "Right",
            text = "Right",
            value = false,
            index = 3,
            info = "BOTTOMRIGHT",
        }
    },
    enableClassColorsUnitFrames = true,
    enableUpgradedRaidFrames = true,
    enableDecimalILVL = true,
    enableClassColorILVL = true,
    enableCharacterILVLInfo = true,
    enableCharacterEnchantsInfo = true,
    enableCharacterGemsInfo = true,
    characterInfoFlag = true,
    c_disableLGMessage = false,
}
local roleTex = {
    ["DAMAGER"]     = "|A:groupfinder-icon-role-micro-dps:",
    ["HEALER"]      = "|A:groupfinder-icon-role-micro-heal:",
    ["TANK"]        = "|A:groupfinder-icon-role-micro-tank:",
    ["DAMAGERCHAT"] = "|A:GM-icon-role-dps:",
    ["HEALERCHAT"] = "|A:GM-icon-role-healer:",
    ["TANKCHAT"]    = "|A:GM-icon-role-tank:",
    ["NONE"]        = ""
}
function getRoleTex(role, height, width)
    local str = roleTex[role]
    if str == nil or not str then
        return roleTex["NONE"]
    end
    return str .. tostring(height) .. ":" .. tostring(width) .. "|a"
end

local settingsInterface = CreateFrame("Frame") -- options panel for tweaking the addon

--Color Picker
local function ShowColorPicker(red, green, blue, alpha, objectColor, changedCallback)
    ColorPickerFrame.Content.ColorPicker:SetColorRGB(red, green, blue)
    ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (alpha ~= nil), alpha
    ColorPickerFrame.previousValues = {red, green, blue, alpha}
    ColorPickerFrame.func, ColorPickerFrame.swatchFunc, ColorPickerFrame.cancelFunc =  changedCallback, changedCallback, changedCallback
    ColorPickerFrame.objectColor = objectColor
    ColorPickerFrame:Hide()
    ColorPickerFrame:Show()
end

function ColorCallback(restore)
    local newR, newG, newB, newA
    if restore then
     newR, newG, newB, newA = unpack(restore)
    else
     newA, newR, newG, newB = ColorPickerFrame:GetColorAlpha(), ColorPickerFrame:GetColorRGB()
    end 
    if ColorPickerFrame.objectColor == settingsInterface.linkColor then
        settingsDB.colorLinkRed, settingsDB.colorLinkGreen, settingsDB.colorLinkBlue = newR, newG, newB
    end
    ColorPickerFrame.objectColor.color:SetVertexColor(newR, newG, newB)
end

local function HandleLFGHooks()
    if settingsDB.enableInspectLFG then
        hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", SetupLFGTooltip)
    end
    if settingsDB.enableApplicantRaceTooltip then
        hooksecurefunc("LFGListApplicantMember_OnEnter", AddApplicantRaceInTooltip)
    end
    if settingsDB.enableSortApplicants then
        LFGListUtil_SortApplicants = SortApplicantsByRating
    end
end

local function UntriggerDisabledEvents()
    if not settingsDB.enableHPTextNameplate then
        settingsInterface:UnregisterEvent("UNIT_HEALTH")
        settingsInterface:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
    end
    if not settingsDB.enableClassColorsUnitFrames then
        settingsInterface:UnregisterEvent("PLAYER_TARGET_CHANGED")
        settingsInterface:UnregisterEvent("PLAYER_FOCUS_CHANGED")
    end
    if not settingsDB.enableCastTimerNameplate then
        settingsInterface:UnregisterEvent("UNIT_SPELLCAST_START")
        settingsInterface:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    end
    if not settingsDB.characterInfoFlag then
        settingsInterface:UnregisterEvent("INSPECT_READY")
        settingsInterface:UnregisterEvent("UNIT_INVENTORY_CHANGED")
        settingsInterface:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
        settingsInterface:UnregisterEvent("ENCHANT_SPELL_COMPLETED")
        settingsInterface:UnregisterEvent("SOCKET_INFO_UPDATE")
    end
end

local function ToggleEventRegister(event, flag)
    if flag==true then
        settingsInterface:RegisterEvent(event)
    else
        settingsInterface:UnregisterEvent(event)
    end
end

function InitVariables()
    if not settingsDB then
        settingsDB = {}
    end
    for key, defaultValue in pairs(defaultSettings) do
        if settingsDB[key] == nil then
            settingsDB[key] = defaultValue
        end
    end
end

local needToReloadOptions = {
    ["enableHPTextNameplate"] = true,
    ["enableHPTextFriendlyNameplate"] = true,
    ["enableShorterKeybinds"] = true,
    ["enableUpgradedCastbar"] = true,
    ["enableClassColorsUnitFrames"] = true,
    ["enableCastTimerNameplate"] = true,
    ["enableInspectLFG"] = true,
    ["enableApplicantRaceTooltip"] = true,
    ["enableSortApplicants"] = true,
}

local function DropDownMenuDisableNotSelected(option, activeIndex)
    for index, option in pairs(settingsDB[option]) do
        if index ~= activeIndex then
            option.value = false
        else
            option.value = true
        end
    end
end
local function DropDownMenuGetSelected(option)
    for index, option in pairs(settingsDB[option]) do
        if option.value then
            return option.info
        end
    end
end
function CreateDropDownMenu(option, label, parent, width, tooltip, new, subDD)
    local dropDownControl = CreateFrame("Frame", nil, parent, "SettingsDropdownWithButtonsTemplate")
	dropDownControl.Dropdown:SetWidth(width);
    dropDownControl.option = option
    dropDownControl.Label = dropDownControl:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropDownControl.Label:SetText(label)
    dropDownControl.Label:SetPoint("LEFT", dropDownControl, "LEFT", -197, -1.5)
    if subDD == 1 then
        local fontFile, _, flags = dropDownControl.Label:GetFont()
        dropDownControl.Label:SetFont(fontFile, 10, flags)
        dropDownControl.Label:SetPoint("LEFT", dropDownControl, "LEFT", -182, -1.5)
    end
    if new == 1 then
        local NewFeature = CreateFrame("Frame", nil, dropDownControl, "NewFeatureLabelTemplate")
        NewFeature:SetScale(0.8)
        NewFeature:SetPoint("RIGHT", dropDownControl, "LEFT", -261, -3)
        NewFeature:Show()
    end
    dropDownControl.HoverBGFrame = CreateFrame("Frame", nil, dropDownControl)
    dropDownControl.HoverBGFrame:SetPoint("TOPLEFT", dropDownControl, "TOPLEFT", -247, -8)
    dropDownControl.HoverBGFrame:SetSize(250, 26)
    dropDownControl.HoverBGFrame:SetFrameLevel(dropDownControl.Dropdown:GetFrameLevel()-1)
    dropDownControl.HoverBGFrame.HoverBackground = dropDownControl.HoverBGFrame:CreateTexture(nil, "BACKGROUND")
    dropDownControl.HoverBGFrame.HoverBackground:SetColorTexture(1, 1, 1, 0.1)
    dropDownControl.HoverBGFrame.HoverBackground:SetPoint("TOPLEFT", dropDownControl.HoverBGFrame, "TOPLEFT", 0, 0)
    dropDownControl.HoverBGFrame.HoverBackground:SetSize(640, 26)
    dropDownControl.HoverBGFrame.HoverBackground:Hide()
    if tooltip then
        dropDownControl.TooltipText = tooltip
        for _, opt in pairs(settingsDB[option]) do
            local optionLabel = nil
            if opt.tooltip then
                optionLabel = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(opt.label)
                dropDownControl.TooltipText = dropDownControl.TooltipText .. "\n\n" .. optionLabel .. ": " .. opt.tooltip
            end
        end
        dropDownControl.Dropdown:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(dropDownControl.TooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        dropDownControl.Dropdown:SetScript("OnLeave", function(self)
            GameTooltip_Hide()
        end)
        dropDownControl.Label:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(dropDownControl.HoverBGFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(dropDownControl.TooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
            dropDownControl.HoverBGFrame.HoverBackground:Show()
        end)
        dropDownControl.Label:SetScript("OnLeave", function(self)
            GameTooltip_Hide()
            dropDownControl.HoverBGFrame.HoverBackground:Hide()
        end)
        dropDownControl.HoverBGFrame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(dropDownControl.HoverBGFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(dropDownControl.TooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
            dropDownControl.HoverBGFrame.HoverBackground:Show()
        end)
        dropDownControl.HoverBGFrame:SetScript("OnLeave", function(self)
            GameTooltip_Hide()
            dropDownControl.HoverBGFrame.HoverBackground:Hide()
        end)
    end

    local function populatedValues()
        return settingsDB[option]
    end
    local inserter = Settings.CreateDropdownOptionInserter(populatedValues);
    local function IsSelected(optionData)
		return settingsDB[dropDownControl.option][optionData.index].value
	end
	
	local function OnSelect(optionData)
        DropDownMenuDisableNotSelected(dropDownControl.option, optionData.index)
        if dropDownControl.option == "castbarTextPosition" then
            UpgradeDefaultCastbar(optionData.info)
        end
        dropDownControl.Dropdown:GenerateMenu()
		return MenuResponse.Close
	end
    dropDownControl.Dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetGridMode(MenuConstants.VerticalGridDirection);
		inserter(rootDescription, IsSelected, OnSelect);
	end);

    return dropDownControl
end

function CreateCheckbox(option, label, parent, tooltip, new, subCB)
    local checkBox = CreateFrame("CheckButton", nil, parent, "SettingsCheckBoxTemplate")
    checkBox.Text = checkBox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    checkBox.Text:SetText(label)
    checkBox.Text:SetPoint("LEFT", checkBox, "LEFT", -200, 0)
    checkBox.option = option
    if subCB == 1 then
        local fontFile, _, flags = checkBox.Text:GetFont()
        checkBox.Text:SetFont(fontFile, 10, flags)
        checkBox.Text:SetPoint("LEFT", checkBox, "LEFT", -185, 0)
    end
    checkBox.HoverBGFrame = CreateFrame("Frame", nil, checkBox)
    checkBox.HoverBGFrame:SetPoint("TOPLEFT", checkBox, "TOPLEFT", -247, -1.5)
    checkBox.HoverBGFrame:SetSize(250, 26)
    checkBox.HoverBGFrame:SetFrameLevel(checkBox:GetFrameLevel()-1)
    checkBox.HoverBGFrame.HoverBackground = checkBox.HoverBGFrame:CreateTexture(nil, "BACKGROUND")
    checkBox.HoverBGFrame.HoverBackground:SetColorTexture(1, 1, 1, 0.1)
    checkBox.HoverBGFrame.HoverBackground:SetPoint("TOPLEFT", checkBox.HoverBGFrame, "TOPLEFT", 0, 0)
    checkBox.HoverBGFrame.HoverBackground:SetSize(640, 26)
    checkBox.HoverBGFrame.HoverBackground:Hide()
    if tooltip then
        checkBox.TooltipText = tooltip
        checkBox:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.TooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
            checkBox.HoverBGFrame.HoverBackground:Show()

        end)
        checkBox:SetScript("OnLeave", function(self)
            GameTooltip_Hide()
            checkBox.HoverBGFrame.HoverBackground:Hide()
        end)
        checkBox.Text:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(checkBox.HoverBGFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(checkBox.TooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
            checkBox.HoverBGFrame.HoverBackground:Show()
        end)
        checkBox.Text:SetScript("OnLeave", function(self)
            GameTooltip_Hide()
            checkBox.HoverBGFrame.HoverBackground:Hide()
        end)
        checkBox.HoverBGFrame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(checkBox.HoverBGFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(checkBox.TooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
            checkBox.HoverBGFrame.HoverBackground:Show()
        end)
        checkBox.HoverBGFrame:SetScript("OnLeave", function(self)
            GameTooltip_Hide()
            checkBox.HoverBGFrame.HoverBackground:Hide()
        end)
    end
    if new == 1 then
        local NewFeature = CreateFrame("Frame", nil, checkBox, "NewFeatureLabelTemplate")
        NewFeature:SetScale(0.8)
        NewFeature:SetPoint("RIGHT", checkBox, "LEFT", -265, 0)
        NewFeature:Show()
    end

    -- update things when clicked
    local function UpdateOption(value, clicked)
        settingsDB[checkBox.option] = value
        checkBox:SetChecked(value)
        if clicked == 1 and needToReloadOptions[checkBox.option] then
            settingsInterface.reloadButton:Show()
        end
        -- realtime changes (without need to reload)
        if checkBox.option == "enableCharacterILVLInfo" or checkBox.option == "enableCharacterEnchantsInfo" or checkBox.option == "enableCharacterGemsInfo" then
            local flag = settingsDB.enableCharacterILVLInfo or settingsDB.enableCharacterEnchantsInfo or settingsDB.enableCharacterGemsInfo
            ToggleEventRegister("INSPECT_READY", flag)
            ToggleEventRegister("UNIT_INVENTORY_CHANGED", flag)
            ToggleEventRegister("PLAYER_EQUIPMENT_CHANGED", flag)
            ToggleEventRegister("ENCHANT_SPELL_COMPLETED", flag)
            ToggleEventRegister("SOCKET_INFO_UPDATE", flag)

            settingsDB.characterInfoFlag = settingsDB.characterInfoFlag or flag
            C_Timer.After(0, function() UpdateAllEquipmentSlots("player") end)
            settingsDB.characterInfoFlag = flag
            if clicked == 1 and not settingsDB.characterInfoFlag then
                settingsInterface.reloadButton:Show()
            end
            return
        end
        if checkBox.option == "enableHideKeybindText" or checkBox.option == "enableHideMacroText" then
            ShouldHideActionbarButtonsText()
            return
        end
        if checkBox.option == "enableUpgradedCastbar" and settingsInterface.castTimePosition ~= nil then
            settingsInterface.castTimePosition:SetEnabled(settingsDB.enableUpgradedCastbar)
            settingsInterface.castTimePosition.Label:SetTextColor(settingsDB.enableUpgradedCastbar and 1 or 0.502, 
                                                              settingsDB.enableUpgradedCastbar and 0.8235 or 0.502, 
                                                              settingsDB.enableUpgradedCastbar and 0 or 0.502, 1)
            return
        end
        if checkBox.option == "enableLinksInChat" and settingsDB.enableLinksInChat and settingsInterface.linkColor ~= nil then
            settingsInterface.linkColor:Enable()
            settingsInterface.linkColor.color:SetVertexColor(settingsDB.colorLinkRed, settingsDB.colorLinkGreen, settingsDB.colorLinkBlue, 1)
            return
        elseif checkBox.option == "enableLinksInChat" and not settingsDB.enableLinksInChat and settingsInterface.linkColor ~= nil then
            settingsInterface.linkColor:Disable()
            settingsInterface.linkColor.color:SetVertexColor(settingsDB.colorLinkRed, settingsDB.colorLinkGreen, settingsDB.colorLinkBlue, 0.3)
            return
        end
        if checkBox.option == "enableHPTextNameplate" and settingsDB.enableHPTextNameplate and settingsInterface.hpTextFriendlyNameplate ~= nil and
           settingsInterface.hpTextFormat ~= nil then
            settingsInterface.hpTextFriendlyNameplate:Enable()
            settingsInterface.hpTextFriendlyNameplate.Text:SetTextColor(1, 0.8235, 0, 1)
            settingsInterface.hpTextFormat:SetEnabled(true)
            settingsInterface.hpTextFormat.Label:SetTextColor(1, 0.8235, 0, 1)
            return
        elseif checkBox.option == "enableHPTextNameplate" and not settingsDB.enableHPTextNameplate and settingsInterface.hpTextFriendlyNameplate ~= nil and
               settingsInterface.hpTextFormat ~= nil then
            settingsInterface.hpTextFriendlyNameplate:Disable()
            settingsInterface.hpTextFriendlyNameplate.Text:SetTextColor(0.502, 0.502, 0.502, 1)
            settingsInterface.hpTextFormat:SetEnabled(false)
            settingsInterface.hpTextFormat.Label:SetTextColor(0.502, 0.502, 0.502, 1)
            return
        end
        if checkBox.option == "enableMuteApplicantSound" then
            MuteApplicationSignupSound()
            return
        end
        if checkBox.option == "enableUpgradedRaidFrames" then
            ToggleEventRegister("DISPLAY_SIZE_CHANGED", settingsDB.enableUpgradedRaidFrames)
            ToggleEventRegister("UI_SCALE_CHANGED", settingsDB.enableUpgradedRaidFrames)
            ToggleEventRegister("GROUP_ROSTER_UPDATE", settingsDB.enableUpgradedRaidFrames)
            ToggleEventRegister("UPDATE_ACTIVE_BATTLEFIELD", settingsDB.enableUpgradedRaidFrames)
            ToggleEventRegister("UNIT_FLAGS", settingsDB.enableUpgradedRaidFrames)
            ToggleEventRegister("PLAYER_FLAGS_CHANGED", settingsDB.enableUpgradedRaidFrames)
            ToggleEventRegister("PARTY_LEADER_CHANGED", settingsDB.enableUpgradedRaidFrames)
            ToggleEventRegister("RAID_TARGET_UPDATE", settingsDB.enableUpgradedRaidFrames)
            UpgradeRaidFrames()
            return
        end
        if checkBox.option == "enableChatMouseoverItemTooltip" then
            ToggleEventRegister("CHAT_MSG_WHISPER", settingsDB.enableChatMouseoverItemTooltip)
            ToggleEventRegister("CHAT_MSG_WHISPER_INFORM", settingsDB.enableChatMouseoverItemTooltip)
            ToggleEventRegister("CHAT_MSG_BN_WHISPER", settingsDB.enableChatMouseoverItemTooltip)
            ToggleEventRegister("CHAT_MSG_BN_WHISPER_INFORM", settingsDB.enableChatMouseoverItemTooltip)
            return
        end
        if checkBox.option == "enableDoubleClickLFG" then
            ToggleEventRegister("LFG_LIST_SEARCH_RESULTS_RECEIVED", settingsDB.enableDoubleClickLFG)
            return
        end
    end

    local initValue = settingsDB[checkBox.option]
    UpdateOption(initValue, 0)
     
    checkBox:HookScript("OnClick", function(_, btn, down)
        UpdateOption(checkBox:GetChecked(), 1)
    end)

    return checkBox
end

function CreateColorSwatch(ored, ogreen, oblue, oalpha, label, parent, tooltip)
    local colorSwatch = CreateFrame("CheckButton", nil, parent, BackdropTemplateMixin and "SettingsCheckBoxTemplate,BackdropTemplate" or "SettingsCheckBoxTemplate")
    colorSwatch.Text = colorSwatch:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    if(label) then
        colorSwatch.Text:SetText(label)
        colorSwatch.Text:SetPoint("RIGHT", colorSwatch, "LEFT", 3, 0)
    end
    if(tooltip) then
        colorSwatch.TooltipText = tooltip
        colorSwatch:SetScript("OnEnter", function(self, motion)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.TooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        colorSwatch:SetScript("OnLeave", GameTooltip_Hide)
        colorSwatch.Text:SetScript("OnEnter", function(self, motion)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(colorSwatch.TooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        colorSwatch.Text:SetScript("OnLeave", GameTooltip_Hide)
    end
    colorSwatch.color = colorSwatch:CreateTexture()
	colorSwatch.color:SetWidth(15)
	colorSwatch.color:SetHeight(15)
	colorSwatch.color:SetPoint("CENTER")
	colorSwatch.color:SetTexture("Interface/ChatFrame/ChatFrameColorSwatch")
	colorSwatch:SetBackdrop({bgFile="Interface/ChatFrame/ChatFrameColorSwatch",insets={left=3,right=3,top=3,bottom=3}})
	colorSwatch:SetPushedTexture(colorSwatch.color)
	colorSwatch:SetNormalTexture(colorSwatch.color)
    colorSwatch:SetBackdropColor(0.3, 0.3, 0.3)
    colorSwatch.color:SetVertexColor(ored, ogreen, oblue)

    return colorSwatch
end

function settingsInterface:Initialize()
    -- header
    self.name = "Gigancement"
    self.bigTitle = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
    self.bigTitle:SetJustifyH("LEFT")
    self.bigTitle:SetText(self.name .. " v" .. C_AddOns.GetAddOnMetadata("Gigancement", "Version"))
	self.bigTitle:SetPoint("TOPLEFT", 7, -22)
	
    self.HorizontalDivider = self:CreateTexture()
    self.HorizontalDivider:SetAtlas("Options_HorizontalDivider", true)
    self.HorizontalDivider:SetPoint("TOPLEFT", self.bigTitle, "TOPLEFT", 7, -28)

    -- reload button
    self.reloadButton = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
    self.reloadButton:SetText("RELOAD")
    self.reloadButton:SetWidth(96)
    self.reloadButton:SetPoint("TOPRIGHT", -36, -16)
    self.reloadButton:SetScript("OnClick", function()
        ReloadUI()
    end)
    self.reloadButton:Hide()
    self.HelpFrame = CreateFrame("Frame", nil, self, "GlowBoxTemplate")
    self.HelpFrame:SetPoint("RIGHT", self.reloadButton, "LEFT", -15, 0)
    self.HelpFrame:SetWidth(120)
    self.HelpFrame:SetHeight(40)
    self.HelpFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    self.HelpFrame:SetParent(self.reloadButton)
    self.HelpFrame:Show()
    self.HelpFrame.arrow = self.HelpFrame:CreateTexture()
    self.HelpFrame.arrow:ClearAllPoints()
	self.HelpFrame.arrow:SetPoint("LEFT", self.HelpFrame, "RIGHT", -10, 0)
	self.HelpFrame.arrow:SetSize(40, 21)
	self.HelpFrame.arrow:SetTexture("Interface\\TalentFrame\\TalentFrame-Parts")
    self.HelpFrame.arrow:SetTexCoord(0.78515625, 0.99218750, 0.54687500, 0.58789063)
    self.HelpFrame.arrow:SetRotation(math.pi/2)
    self.HelpFrame.arrow:Show()
    self.HelpFrame.text = self.HelpFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightLeft")
    self.HelpFrame.text:SetText("Reload required")
    self.HelpFrame.text:ClearAllPoints()
	self.HelpFrame.text:SetPoint("CENTER", self.HelpFrame, "CENTER")

    self.scrollFrame = CreateFrame("ScrollFrame", nil, self, "ScrollFrameTemplate")
    self.scrollFrame:SetPoint("TOPLEFT", self.HorizontalDivider, "TOPLEFT", -20, -8)
	self.scrollFrame:SetPoint("BOTTOMRIGHT", -26, 0)
	self.scrollChild = CreateFrame("Frame")
	self.scrollFrame:SetScrollChild(self.scrollChild)
	self.scrollChild:SetWidth(1)
	self.scrollChild:SetHeight(1)
    
    -- nameplate module
    self.nameplateModuleTitle = self.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    self.nameplateModuleTitle:SetText("Nameplate")
    self.nameplateModuleTitle:SetPoint("TOPLEFT", self.scrollChild, "BOTTOMLEFT", 23.5, -19)
    self.hpTextNameplate = CreateCheckbox("enableHPTextNameplate", "Health on Enemy Nameplates", self.scrollChild, "Show health on enemy nameplates.\n|cffFF0000Reload|r is required.")
    self.hpTextNameplate:SetPoint("TOPLEFT",  self.nameplateModuleTitle, "BOTTOMLEFT", 230, -20)
    self.hpTextFriendlyNameplate = CreateCheckbox("enableHPTextFriendlyNameplate", "Health on Friendly Nameplates", self.scrollChild, "Show health on friendly nameplates.\n|cffFF0000Reload|r is required.",1,1)
    self.hpTextFriendlyNameplate:SetPoint("TOPLEFT",  self.hpTextNameplate, "BOTTOMLEFT", 0, -10)
    self.hpTextFormat = CreateDropDownMenu("formatHPText", "Health Text Format", self.scrollChild, 150, "Display health text as numbers, percentage or both.", 1, 1)
    self.hpTextFormat:SetPoint("TOPLEFT",  self.hpTextFriendlyNameplate, "BOTTOMLEFT", -3, -6)
    if not settingsDB.enableHPTextNameplate then 
        self.hpTextFriendlyNameplate.Text:SetTextColor(0.502, 0.502, 0.502, 1)
        self.hpTextFriendlyNameplate:Disable()
        self.hpTextFormat.Label:SetTextColor(0.502, 0.502, 0.502, 1)
        self.hpTextFormat:SetEnabled(false)
    end
    self.castTimerNameplate = CreateCheckbox("enableCastTimerNameplate", "Cast Time on Nameplates", self.scrollChild, "Show cast bar timer on all nameplates.\n|cffFF0000Reload|r is required.")
    self.castTimerNameplate:SetPoint("TOPLEFT",  self.hpTextFormat, "BOTTOMLEFT", 3, -6)
    -- actionbar module
    self.actionbarModuleTitle = self.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    self.actionbarModuleTitle:SetText("Action Bar")
    self.actionbarModuleTitle:SetPoint("TOPLEFT", self.castTimerNameplate, "BOTTOMLEFT", -230, -20)
    self.shorterKeybinds = CreateCheckbox("enableShorterKeybinds", "Shorter Keybind Names", self.scrollChild, "Show keybinds as S1, A1, M1 instead of s-1, a-1, Mouse...\n|cffFF0000Reload|r is required.")
    self.shorterKeybinds:SetPoint("TOPLEFT",  self.actionbarModuleTitle, "BOTTOMLEFT", 230, -20)
    self.hideKeybindText = CreateCheckbox("enableHideKeybindText", "Hide Keybind Text", self.scrollChild, "Hide keybind text from all action bar buttons.")
    self.hideKeybindText:SetPoint("TOPLEFT",  self.shorterKeybinds, "BOTTOMLEFT", 0, -10)
    self.hideMacroText = CreateCheckbox("enableHideMacroText", "Hide Macro Text", self.scrollChild, "Hide macro text from all action bar buttons.")
    self.hideMacroText:SetPoint("TOPLEFT",  self.hideKeybindText, "BOTTOMLEFT", 0, -10)
    -- chat module
    self.chatModuleTitle = self.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    self.chatModuleTitle:SetText("Chat")
    self.chatModuleTitle:SetPoint("TOPLEFT", self.hideMacroText, "BOTTOMLEFT", -230, -20)
    self.linksInChat = CreateCheckbox("enableLinksInChat", "Links in Chat", self.scrollChild, "Recognize a link in chat and allow clicking on it to open a popup from where it can be copied.")
    self.linksInChat:SetPoint("TOPLEFT", self.chatModuleTitle, "BOTTOMLEFT", 230, -20)
    self.linkColor = CreateColorSwatch(settingsDB.colorLinkRed, settingsDB.colorLinkGreen, settingsDB.colorLinkBlue, nil, "Link Color: ", self.scrollChild, "Choose the link color.")
    if not settingsDB.enableLinksInChat then
        self.linkColor:Disable()
        self.linkColor.color:SetVertexColor(settingsDB.colorLinkRed, settingsDB.colorLinkGreen, settingsDB.colorLinkBlue, 0.3)
    end
    self.linkColor:HookScript("OnClick", function()
        self.linkColor:SetChecked(false)
        ShowColorPicker(settingsDB.colorLinkRed, settingsDB.colorLinkGreen, settingsDB.colorLinkBlue, nil, self.linkColor, ColorCallback)
    end)
    self.linkColor:SetPoint("LEFT", self.linksInChat, "RIGHT", 80, 0)
    self.rolesInChat = CreateCheckbox("enableRolesInChat", "Roles in Chat", self.scrollChild, "Show |A:GM-icon-role-tank:20:20|a, |A:GM-icon-role-healer:20:20|a or |A:GM-icon-role-dps:20:20|a role in chat next to player's names.")
    self.rolesInChat:SetPoint("TOPLEFT", self.linksInChat, "BOTTOMLEFT", 0, -10)
    self.shorterChannelNames = CreateCheckbox("enableShorterChannelNames", "Shorter Default Channel Names", self.scrollChild, "[R] for [Raid], [P] for [Party], etc.")
    self.shorterChannelNames:SetPoint("TOPLEFT", self.rolesInChat, "BOTTOMLEFT", 0, -10)
    self.chatMouseoverItemTooltip = CreateCheckbox("enableChatMouseoverItemTooltip", "Chat Mouseover Tooltips", self.scrollChild, "Show the mouse tooltip when mouseovering an item/mount/pet/achievement (or anything else that requires a click on it to show a tooltip) in chat.")
    self.chatMouseoverItemTooltip:SetPoint("TOPLEFT", self.shorterChannelNames, "BOTTOMLEFT", 0, -10)
    -- LFG module
    self.lfgModuleTitle = self.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    self.lfgModuleTitle:SetText("LFG")
    self.lfgModuleTitle:SetPoint("TOPLEFT", self.chatMouseoverItemTooltip, "BOTTOMLEFT", -230, -20)
    self.inspectLFG = CreateCheckbox("enableInspectLFG", "Inspect Groups in Tooltip", self.scrollChild, "On mouseover inspect any premade group and show the leader, all specs and roles in the tooltip. Ignores M+ groups, because the Blizzard has implemented that in 10.2.7.\n|cffFF0000Reload|r is required.")
    self.inspectLFG:SetPoint("TOPLEFT", self.lfgModuleTitle, "BOTTOMLEFT", 230, -20)
    self.doubleClickLFG = CreateCheckbox("enableDoubleClickLFG", "Double-click Sign Up", self.scrollChild, "Double left click to sign up for premade groups.")
    self.doubleClickLFG:SetPoint("TOPLEFT", self.inspectLFG, "BOTTOMLEFT", 0, -10)
    self.skipRoleCheck = CreateCheckbox("enableSkipRoleCheck", "Auto Role Check and\nSkip the Note Popup", self.scrollChild, "Automatically accept the role check popup when a party leader is applying your group to a Raid/M+ group and skip the note popup. If you want to sign up with a note, hold |cff00FF00Shift|r when signing up.", 1)
    self.skipRoleCheck:SetPoint("TOPLEFT", self.doubleClickLFG, "BOTTOMLEFT", 0, -10)
    self.muteApplicantSound = CreateCheckbox("enableMuteApplicantSound", "Silence Application Sound", self.scrollChild, "Mute the annoying application sign up sound when you are creating a group.")
    self.muteApplicantSound:SetPoint("TOPLEFT", self.skipRoleCheck, "BOTTOMLEFT", 0, -10)
    self.applicantRaceTooltip = CreateCheckbox("enableApplicantRaceTooltip", "Show Applicant Race", self.scrollChild, "Show applicant race in LFG Tooltip under the name of the applicant.\n|cffFF0000Reload|r is required.", 1)
    self.applicantRaceTooltip:SetPoint("TOPLEFT", self.muteApplicantSound, "BOTTOMLEFT", 0, -10)
    self.sortApplicants = CreateCheckbox("enableSortApplicants", "Sort Applicants by Rating", self.scrollChild, "Sort applicants by their M+ score.\n|cffFF0000Reload|r is required.", 1)
    self.sortApplicants:SetPoint("TOPLEFT", self.applicantRaceTooltip, "BOTTOMLEFT", 0, -10)
    -- UI
    self.uiModuleTitle = self.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    self.uiModuleTitle:SetText("UI")
    self.uiModuleTitle:SetPoint("TOPLEFT", self.sortApplicants, "BOTTOMLEFT", -230, -20)
    self.upgradedCastbar = CreateCheckbox("enableUpgradedCastbar", "Upgrade Default Castbar", self.scrollChild, "Show the spell icon, remaining and total cast time on the Player, Target and Focus casting bars.\n|cffFF0000Reload|r is required.")
    self.upgradedCastbar:SetPoint("TOPLEFT", self.uiModuleTitle, "BOTTOMLEFT", 230, -20)
    self.castTimePosition = CreateDropDownMenu("castbarTextPosition", "Castbar Text Position", self.scrollChild, 150, "Select the position for cast bar text.", 1, 1)
    self.castTimePosition:SetPoint("TOPLEFT",  self.upgradedCastbar, "BOTTOMLEFT", -3, -6)
    if not settingsDB.enableUpgradedCastbar then 
        self.castTimePosition.Label:SetTextColor(0.502, 0.502, 0.502, 1)
        self.castTimePosition:SetEnabled(false)
    end
    self.upgradedRaidFrames = CreateCheckbox("enableUpgradedRaidFrames", "Upgrade Default Raid Frames", self.scrollChild, "Show raid marks, leader and co-leader icons on default Blizzard Raid Plates.")
    self.upgradedRaidFrames:SetPoint("TOPLEFT", self.castTimePosition, "BOTTOMLEFT", 3, -6)
    self.classColorsUnitFrames = CreateCheckbox("enableClassColorsUnitFrames", "Class Color Unit Frames", self.scrollChild, "Use class colors on default Blizzard unit frames such as Player, Pet, Target and Focus frames.\n|cffFF0000Reload|r is required.")
    self.classColorsUnitFrames:SetPoint("TOPLEFT", self.upgradedRaidFrames, "BOTTOMLEFT", 0, -10)
    -- CharacterInfo
    self.characterInfoTitle = self.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    self.characterInfoTitle:SetText("Character Info")
    self.characterInfoTitle:SetPoint("TOPLEFT", self.classColorsUnitFrames, "BOTTOMLEFT", -230, -20)
    self.decimalILVL = CreateCheckbox("enableDecimalILVL", "Equipped/Max Item Level", self.scrollChild, "Show |cffa335eeequipped/maximum|r item level with an accuracy of two decimal places.")
    self.decimalILVL:SetPoint("TOPLEFT", self.characterInfoTitle, "BOTTOMLEFT", 230, -20)
    self.classColorILVL = CreateCheckbox("enableClassColorILVL", "Class Color Item Level", self.scrollChild, "Show |c"..RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr.."equipped/maximum|r item level in class color.")
    self.classColorILVL:SetPoint("TOPLEFT", self.decimalILVL, "BOTTOMLEFT", 0, -10)
    self.characterILVLInfo = CreateCheckbox("enableCharacterILVLInfo", "Show Item Level", self.scrollChild, "Show item level on the Character and Inspect frames for each equipment slot.", 1)
    self.characterILVLInfo:SetPoint("TOPLEFT", self.classColorILVL, "BOTTOMLEFT", 0, -10)
    self.characterEnchantsInfo = CreateCheckbox("enableCharacterEnchantsInfo", "Show Enchants", self.scrollChild, "Show enchants on the Character and Inspect frames for each equipment slot.", 1)
    self.characterEnchantsInfo:SetPoint("TOPLEFT", self.characterILVLInfo, "BOTTOMLEFT", 0, -10)
    self.characterGemsInfo = CreateCheckbox("enableCharacterGemsInfo", "Show Gems", self.scrollChild, "Show gems on the Character and Inspect frames for each equipment slot.", 1)
    self.characterGemsInfo:SetPoint("TOPLEFT", self.characterEnchantsInfo, "BOTTOMLEFT", 0, -10)

    local category = Settings.RegisterCanvasLayoutCategory(self, "Gigancement")
    category.ID = "Gigancement"
    Settings.RegisterAddOnCategory(category)
end

settingsInterface:RegisterEvent("ADDON_LOADED")
settingsInterface:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
settingsInterface:RegisterEvent("DISPLAY_SIZE_CHANGED")
settingsInterface:RegisterEvent("UI_SCALE_CHANGED")
settingsInterface:RegisterEvent("GROUP_ROSTER_UPDATE")
settingsInterface:RegisterEvent("UPDATE_ACTIVE_BATTLEFIELD")
settingsInterface:RegisterEvent("UNIT_FLAGS")
settingsInterface:RegisterEvent("PLAYER_FLAGS_CHANGED")
settingsInterface:RegisterEvent("PARTY_LEADER_CHANGED") 
settingsInterface:RegisterEvent("RAID_TARGET_UPDATE")
settingsInterface:RegisterEvent("PLAYER_ENTERING_WORLD")
settingsInterface:RegisterEvent("UNIT_SPELLCAST_START")
settingsInterface:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
settingsInterface:RegisterEvent("CHAT_MSG_WHISPER")
settingsInterface:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
settingsInterface:RegisterEvent("CHAT_MSG_BN_WHISPER")
settingsInterface:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
settingsInterface:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
settingsInterface:RegisterEvent("INSPECT_READY")
settingsInterface:RegisterEvent("UNIT_INVENTORY_CHANGED")
settingsInterface:RegisterEvent("PLAYER_TARGET_CHANGED")
settingsInterface:RegisterEvent("PLAYER_FOCUS_CHANGED")
settingsInterface:RegisterEvent("UNIT_HEALTH")
settingsInterface:RegisterEvent("NAME_PLATE_UNIT_ADDED")
settingsInterface:RegisterEvent("ENCHANT_SPELL_COMPLETED")
settingsInterface:RegisterEvent("SOCKET_INFO_UPDATE")

settingsInterface:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "Gigancement" then
        -- Init
        InitVariables()
        settingsInterface:Initialize()
        -- Enable modules
        ShouldHideActionbarButtonsText()
        HandleShortenKeybinds()
        LinksInChat()
        ChatFramesModifications() -- ShortChannelNames & MouseoverItemTooltip
        MuteApplicationSignupSound()
        UpgradeDefaultCastbar(DropDownMenuGetSelected("castbarTextPosition"))
        HandleLFGHooks()
        UntriggerDisabledEvents()
        EventRegistry:RegisterCallback("CharacterFrame.Show", function()
            C_Timer.After(0, function() UpdateAllEquipmentSlots("player") end)
        end)
    elseif event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" then
        LFGDoubleClick()
    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        local nameplate = GetNameplateByID(arg1)
        if not nameplate then return end
        CastTimerNameplate(nameplate)
    elseif event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_WHISPER_INFORM" or event == "CHAT_MSG_BN_WHISPER" or event == "CHAT_MSG_BN_WHISPER_INFORM" then
        ChatWhispersMouseoverItemTooltip()
    elseif event == "PLAYER_ENTERING_WORLD" then
        if settingsDB.enableClassColorsUnitFrames then
            UnitFrameClassColor("player", PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar)
            UnitFrameClassColor("player", PetFrameHealthBar)
        end
        if arg1==true then
            C_Timer.After(0, function() UpdateAllEquipmentSlots("player") end)
        end
    elseif event == "PLAYER_EQUIPMENT_CHANGED" and arg1 ~= nil then
        UpdateEquipmentSlot("player", arg1)
    elseif event == "UNIT_INVENTORY_CHANGED" and arg1 ~= nil then
        if (UnitGUID(arg1) ~= UnitGUID("player") and settingsDB.m_currentInspec~= nil and settingsDB.m_currentInspec == UnitGUID(arg1)) then
            C_Timer.After(0, function() UpdateAllEquipmentSlots(arg1) end)
        end
    elseif event == "ENCHANT_SPELL_COMPLETED" and arg1==true and arg2 and arg2.equipmentSlotIndex then
        C_Timer.After(0.5, function() UpdateEquipmentSlot("player", arg2.equipmentSlotIndex) end)
    elseif event == "SOCKET_INFO_UPDATE" then
        UpdateEquipmentSlot("player", 1)
        UpdateEquipmentSlot("player", 2)
        UpdateEquipmentSlot("player", 6)
        UpdateEquipmentSlot("player", 9)
        UpdateEquipmentSlot("player", 11)
        UpdateEquipmentSlot("player", 12)
    elseif event == "INSPECT_READY" then
        if not _G.InspectFrame or not _G.InspectFrame.unit then return end
        local unit = _G.InspectFrame.unit
        settingsDB.m_currentInspec = UnitGUID(unit or "target")
        C_Timer.After(0, function() UpdateAllEquipmentSlots(unit or "target") end)
    elseif event == "PLAYER_TARGET_CHANGED" then
        UnitFrameClassColor("target", TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar)
    elseif event == "PLAYER_FOCUS_CHANGED" then
        UnitFrameClassColor("focus", FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar)
    elseif event == "NAME_PLATE_UNIT_ADDED" or event == "UNIT_HEALTH" then
        HPTextNameplate(arg1)
    else
        UpgradeRaidFrames()
    end

end)
