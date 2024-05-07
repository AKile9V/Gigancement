settingsDB = settingsDB or {}

local GetNameplateByID = C_NamePlate.GetNamePlateForUnit

local defaultSettings = {
    m_currentInspec = nil,
    enableHPTextNameplate = false,
    enableCastTimerNameplate = false,
    enableShorterKeybinds = true,
    enableHideKeybindText = false,
    enableHideMacroText = false,
    enableLinksInChat = true,
    colorLinkRed = 1,
    colorLinkGreen = 0.5,
    colorLinkBlue = 1,
    enableRolesInChat = true,
    enableShorterChannelNames = true,
    enableChatMouseoverItemTooltip = false,
    enableInspectLFG = true,
    enableDoubleClickLFG = true,
    enableMuteApplicantSound = true,
    enableUpgradedCastbar = true,
    enableClassColorsUnitFrames = true,
    enableUpgradedRaidFrames = true,
    enableDecimalILVL = true,
    enableClassColorILVL = true,
    enableCharacterILVLInfo = true,
}
local roleTex = {
    DAMAGER = "|A:UI-LFG-RoleIcon-DPS-Micro:15:15|a",
    HEALER  = "|A:UI-LFG-RoleIcon-Healer-Micro:15:15|a",
    TANK    = "|A:UI-LFG-RoleIcon-Tank-Micro:15:15|a",
    NONE    = ""
}
function getRoleTex(role)
    local str = roleTex[role]
    if str == nil or not str then
        return roleTex["NONE"]
    end
    return str
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

local function HandlePlatesHook()
    if settingsDB.enableHPTextNameplate then
        hooksecurefunc("CompactUnitFrame_UpdateHealth", HPTextNameplate)
    end
end

local function HandleLFGTooltipHook(tooltip, resultID, autoAcceptOption)
    if settingsDB.enableInspectLFG then
        SetupLFGTooltip(tooltip, resultID, autoAcceptOption)
    end
end

local function HandleUnitFramePortraitClassColorsUpdate()
    if settingsDB.enableClassColorsUnitFrames then
        hooksecurefunc("UnitFramePortrait_Update", UnitFramesClassColors)
    end
end

local function HandleCharacterInfoILVLHook(statFrame, unit)
    if settingsDB.enableDecimalILVL then
        DecimalILVL(statFrame, unit)
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
    ["enableShorterKeybinds"] = true,
    ["enableUpgradedCastbar"] = true,
    ["enableClassColorsUnitFrames"] = true,
    ["enableCastTimerNameplate"] = true,
    ["enableCharacterILVLInfo"] = true,
}

function CreateCheckbox(option, label, parent, tooltip, new)
    local checkBox = CreateFrame("CheckButton", nil, parent, "SettingsCheckBoxTemplate")
    checkBox.Text = checkBox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    checkBox.Text:SetText(label)
    checkBox.Text:SetPoint("LEFT", checkBox, "LEFT", -200, 0)
    if(tooltip) then
        checkBox.TooltipText = tooltip
        checkBox:SetScript("OnEnter", function(self, motion)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.TooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        checkBox:SetScript("OnLeave", GameTooltip_Hide)
        checkBox.Text:SetScript("OnEnter", function(self, motion)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(checkBox.TooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        checkBox.Text:SetScript("OnLeave", GameTooltip_Hide)
    end
    if(new == 1) then
        local NewFeature = CreateFrame("Frame", nil, checkBox, "NewFeatureLabelTemplate")
        NewFeature:SetScale(0.8)
        NewFeature:SetPoint("RIGHT", checkBox.Text, "LEFT", -37, 0)
        NewFeature:Show()
    end

    -- update things when clicked
    local function UpdateOption(value, clicked)
        local modValue = value
        settingsDB[option] = modValue
        checkBox:SetChecked(value)
        if clicked == 1 and (needToReloadOptions[option]) then
            settingsInterface.reloadButton:Show()
        end
        -- realtime changes (without need to reload)
        if option == "enableHideKeybindText" or option == "enableHideMacroText" then
            ShouldHideActionbarButtonsText()
            return
        end
        if option == "enableLinksInChat" and settingsDB.enableLinksInChat and settingsInterface.linkColor ~= nil then
            settingsInterface.linkColor:Enable()
            settingsInterface.linkColor.color:SetVertexColor(settingsDB.colorLinkRed, settingsDB.colorLinkGreen, settingsDB.colorLinkBlue, 1)
            return
        elseif option == "enableLinksInChat" and not settingsDB.enableLinksInChat and settingsInterface.linkColor ~= nil then
            settingsInterface.linkColor:Disable()
            settingsInterface.linkColor.color:SetVertexColor(settingsDB.colorLinkRed, settingsDB.colorLinkGreen, settingsDB.colorLinkBlue, 0.3)
            return
        end
        if option == "enableMuteApplicantSound" then
            MuteApplicationSignupSound()
            return
        end
        if option == "enableUpgradedRaidFrames" then
            UpgradeRaidFrames()
            return
        end
    end    

    local initValue = settingsDB[option]
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
    self.bigTitle:SetText(self.name .. " v" .. GetAddOnMetadata("Gigancement", "Version"))
	self.bigTitle:SetPoint("TOPLEFT", 7, -22)
	
    self.HorizontalDivider = self:CreateTexture()
    self.HorizontalDivider:SetAtlas("Options_HorizontalDivider", true)
    self.HorizontalDivider:SetPoint("TOPLEFT", self.bigTitle, "TOPLEFT", 7, -28)
    self.reloadButton = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
    self.reloadButton:SetText("RELOAD")
    self.reloadButton:SetWidth(96)
    self.reloadButton:SetPoint("TOPRIGHT", -36, -16)
    self.reloadButton:SetScript("OnClick", function()
        ReloadUI()
    end)
    self.reloadButton:Hide()

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
    self.hpTextNameplate = CreateCheckbox("enableHPTextNameplate", "Health % on Nameplates", self.scrollChild, "Show health and health % on all nameplates.\n|cffFF0000Reload|r is required.")
    self.hpTextNameplate:SetPoint("TOPLEFT",  self.nameplateModuleTitle, "BOTTOMLEFT", 230, -20)
    self.castTimerNameplate = CreateCheckbox("enableCastTimerNameplate", "Cast time on Nameplates", self.scrollChild, "Show cast bar timer on all nameplates.\n|cffFF0000Reload|r is required.")
    self.castTimerNameplate:SetPoint("TOPLEFT",  self.hpTextNameplate, "BOTTOMLEFT", 0, -10)
    -- actionbar module
    self.actionbarModuleTitle = self.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    self.actionbarModuleTitle:SetText("Action Bar")
    self.actionbarModuleTitle:SetPoint("TOPLEFT", self.castTimerNameplate, "BOTTOMLEFT", -230, -20)
    self.shorterKeybinds = CreateCheckbox("enableShorterKeybinds", "Shorter keybind names", self.scrollChild, "Show keybinds as S1, A1, M1 instead of s-1, a-1, Mouse...\n|cffFF0000Reload|r is required.")
    self.shorterKeybinds:SetPoint("TOPLEFT",  self.actionbarModuleTitle, "BOTTOMLEFT", 230, -20)
    self.hideKeybindText = CreateCheckbox("enableHideKeybindText", "Hide keybind text", self.scrollChild, "Hide keybind text from all action bar buttons.")
    self.hideKeybindText:SetPoint("TOPLEFT",  self.shorterKeybinds, "BOTTOMLEFT", 0, -10)
    self.hideMacroText = CreateCheckbox("enableHideMacroText", "Hide macro text", self.scrollChild, "Hide macro text from all action bar buttons.")
    self.hideMacroText:SetPoint("TOPLEFT",  self.hideKeybindText, "BOTTOMLEFT", 0, -10)
    -- chat module
    self.chatModuleTitle = self.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    self.chatModuleTitle:SetText("Chat")
    self.chatModuleTitle:SetPoint("TOPLEFT", self.hideMacroText, "BOTTOMLEFT", -230, -20)
    self.linksInChat = CreateCheckbox("enableLinksInChat", "Links in chat", self.scrollChild, "Recognize a link in chat and allow clicking on it to open a popup from where it can be copied.")
    self.linksInChat:SetPoint("TOPLEFT", self.chatModuleTitle, "BOTTOMLEFT", 230, -20)
    self.linkColor = CreateColorSwatch(settingsDB.colorLinkRed, settingsDB.colorLinkGreen, settingsDB.colorLinkBlue, nil, "Link color: ", self.scrollChild, "Choose the link color.")
    if(settingsDB.enableLinksInChat) then 
        self.linkColor:Enable() 
        self.linkColor.color:SetVertexColor(settingsDB.colorLinkRed, settingsDB.colorLinkGreen, settingsDB.colorLinkBlue, 1)
    else 
        self.linkColor:Disable()
        self.linkColor.color:SetVertexColor(settingsDB.colorLinkRed, settingsDB.colorLinkGreen, settingsDB.colorLinkBlue, 0.3)
    end
    self.linkColor:HookScript("OnClick", function()
        self.linkColor:SetChecked(false)
        ShowColorPicker(settingsDB.colorLinkRed, settingsDB.colorLinkGreen, settingsDB.colorLinkBlue, nil, self.linkColor, ColorCallback)
    end)
    self.linkColor:SetPoint("LEFT", self.linksInChat, "RIGHT", 80, 0)
    self.rolesInChat = CreateCheckbox("enableRolesInChat", "Roles in chat", self.scrollChild, "Show |A:UI-LFG-RoleIcon-Tank-Micro:15:15|a, |A:UI-LFG-RoleIcon-Healer-Micro:15:15|a or |A:UI-LFG-RoleIcon-DPS-Micro:15:15|a role in chat next to player's names.")
    self.rolesInChat:SetPoint("TOPLEFT", self.linksInChat, "BOTTOMLEFT", 0, -10)
    self.shorterChannelNames = CreateCheckbox("enableShorterChannelNames", "Shorter default channel names", self.scrollChild, "[R] for [Raid], [P] for [Party], etc.")
    self.shorterChannelNames:SetPoint("TOPLEFT", self.rolesInChat, "BOTTOMLEFT", 0, -10)
    self.chatMouseoverItemTooltip = CreateCheckbox("enableChatMouseoverItemTooltip", "Chat Mouseover tooltips", self.scrollChild, "Show the mouse tooltip when mouseover an item/mount/pet/achievement (or anything else that requires a click on it to show a tooltip) in chat.")
    self.chatMouseoverItemTooltip:SetPoint("TOPLEFT", self.shorterChannelNames, "BOTTOMLEFT", 0, -10)
    -- lfg module
    self.lfgModuleTitle = self.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    self.lfgModuleTitle:SetText("LFG")
    self.lfgModuleTitle:SetPoint("TOPLEFT", self.chatMouseoverItemTooltip, "BOTTOMLEFT", -230, -20)
    self.inspectLFG = CreateCheckbox("enableInspectLFG", "Inspect groups in tooltip", self.scrollChild, "On mouseover inspect any premade group and show the leader, all specs and roles in the tooltip.")
    self.inspectLFG:SetPoint("TOPLEFT", self.lfgModuleTitle, "BOTTOMLEFT", 230, -20)
    self.doubleClickLFG = CreateCheckbox("enableDoubleClickLFG", "Double click sign up", self.scrollChild, "Double left click to sign up for premade groups, automatically skipping the note popup. If you want to sign up with a note, hold |cff00FF00Shift|r when double-clicking.")
    self.doubleClickLFG:SetPoint("TOPLEFT", self.inspectLFG, "BOTTOMLEFT", 0, -10)
    self.muteApplicantSound = CreateCheckbox("enableMuteApplicantSound", "Silence Application sound", self.scrollChild, "Mute the annoying application sign up sound when you are creating a group.")
    self.muteApplicantSound:SetPoint("TOPLEFT", self.doubleClickLFG, "BOTTOMLEFT", 0, -10)
    -- UI
    self.uiModuleTitle = self.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    self.uiModuleTitle:SetText("UI")
    self.uiModuleTitle:SetPoint("TOPLEFT", self.muteApplicantSound, "BOTTOMLEFT", -230, -20)
    self.upgradedCastbar = CreateCheckbox("enableUpgradedCastbar", "Upgraded default castbar", self.scrollChild, "Show the spell icon, remaining and total cast time on the Player, Target and Focus casting bars.\n|cffFF0000Reload|r is required.")
    self.upgradedCastbar:SetPoint("TOPLEFT", self.uiModuleTitle, "BOTTOMLEFT", 230, -20)
    self.upgradedRaidFrames = CreateCheckbox("enableUpgradedRaidFrames", "Upgraded default raid frames", self.scrollChild, "Show raid marks, leader and co-leader icons on the default Blizzard Raid Plates.")
    self.upgradedRaidFrames:SetPoint("TOPLEFT", self.upgradedCastbar, "BOTTOMLEFT", 0, -10)
    self.classColorsUnitFrames = CreateCheckbox("enableClassColorsUnitFrames", "Class color unit frames", self.scrollChild, "Use class colors on default Blizzard unit frames such as Player, Target and Focus frames.\n|cffFF0000Reload|r is required.")
    self.classColorsUnitFrames:SetPoint("TOPLEFT", self.upgradedRaidFrames, "BOTTOMLEFT", 0, -10)
    -- PaperDoll-CharacterInfo
    self.characterInfoTitle = self.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    self.characterInfoTitle:SetText("Character Info")
    self.characterInfoTitle:SetPoint("TOPLEFT", self.classColorsUnitFrames, "BOTTOMLEFT", -230, -20)
    self.decimalILVL = CreateCheckbox("enableDecimalILVL", "Equipped/Max item level", self.scrollChild, "Show |cffa335eeequipped/maximum|r item level with an accuracy of two decimal places.")
    self.decimalILVL:SetPoint("TOPLEFT", self.characterInfoTitle, "BOTTOMLEFT", 230, -20)
    self.classColorILVL = CreateCheckbox("enableClassColorILVL", "Class color item level", self.scrollChild, "Show |c"..RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr.."equipped/maximum|r item level in class color.")
    self.classColorILVL:SetPoint("TOPLEFT", self.decimalILVL, "BOTTOMLEFT", 0, -10)
    self.characterILVLInfo = CreateCheckbox("enableCharacterILVLInfo", "Item level on Player and\nInspect frame", self.scrollChild, "Show ilvl, enchants and gems on the Character and Inspect frames for each equipment slot.\n|cffFF0000Reload|r is required.", 1)
    self.characterILVLInfo:SetPoint("TOPLEFT", self.classColorILVL, "BOTTOMLEFT", 0, -10)

    InterfaceOptions_AddCategory(self)
end

settingsInterface:RegisterEvent("ADDON_LOADED")
settingsInterface:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
settingsInterface:RegisterEvent("DISPLAY_SIZE_CHANGED")
settingsInterface:RegisterEvent("UI_SCALE_CHANGED")
settingsInterface:RegisterEvent("GROUP_ROSTER_UPDATE")
settingsInterface:RegisterEvent("UPDATE_ACTIVE_BATTLEFIELD")
settingsInterface:RegisterEvent("UNIT_FLAGS")
settingsInterface:RegisterEvent("PLAYER_FLAGS_CHANGED")
settingsInterface:RegisterEvent("PLAYER_ENTERING_WORLD")
settingsInterface:RegisterEvent("PARTY_LEADER_CHANGED") 
settingsInterface:RegisterEvent("RAID_TARGET_UPDATE")
settingsInterface:RegisterEvent("UNIT_SPELLCAST_START")
settingsInterface:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
settingsInterface:RegisterEvent("CHAT_MSG_WHISPER")
settingsInterface:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
settingsInterface:RegisterEvent("CHAT_MSG_BN_WHISPER")
settingsInterface:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
settingsInterface:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
settingsInterface:RegisterEvent("INSPECT_READY")
settingsInterface:RegisterEvent("UNIT_INVENTORY_CHANGED")

settingsInterface:SetScript("OnEvent", function(self, event, arg1)
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
        UpgradeDefaultCastbar()
        HandlePlatesHook()
        HandleUnitFramePortraitClassColorsUpdate()
    elseif event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" then
        LFGDoubleClick()
    elseif settingsDB.enableCastTimerNameplate and (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START") then
        local nameplate = GetNameplateByID(arg1)
        if not nameplate then return end
        CastTimerNameplate(nameplate)
    elseif event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_WHISPER_INFORM" or event == "CHAT_MSG_BN_WHISPER" or event == "CHAT_MSG_BN_WHISPER_INFORM" then
        ChatWhispersMouseoverItemTooltip()
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(0, function() UpdateAllEquipmentSlots("player") end)
    elseif event == "PLAYER_EQUIPMENT_CHANGED" and arg1 ~= nil then
        UpdateEquipmentSlot("player", arg1)
    elseif event == "UNIT_INVENTORY_CHANGED" and arg1 ~= nil then
        if (UnitGUID(arg1) ~= UnitGUID("player") and settingsDB.m_currentInspec~= nil and settingsDB.m_currentInspec == UnitGUID(arg1)) or arg1 == "player" then
            UpdateAllEquipmentSlots(arg1)
        end
    elseif event == "INSPECT_READY" then
        local unit = nil
        if(_G.InspectFrame) then
            unit = _G.InspectFrame.unit
        else
            unit = "target"
        end
        settingsDB.m_currentInspec = UnitGUID(unit)
        UpdateAllEquipmentSlots(unit)
    else
        UpgradeRaidFrames()
    end

end)
hooksecurefunc('LFGListUtil_SetSearchEntryTooltip', HandleLFGTooltipHook)
hooksecurefunc("PaperDollFrame_SetItemLevel", HandleCharacterInfoILVLHook)
