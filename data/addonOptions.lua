local function InitDB(option)
    local key = option.key
    if GigaSettingsDB[key] ~=nil then return end

    GigaSettingsDB[key] = option.default
end

local function RegisterSetting(category, option)
    return Settings.RegisterAddOnSetting(
        category, option.key, option.key,
        GigaSettingsDB, type(option.default),
        option.name, option.default)
end

local function CreateOptionsBody()
    -- Addon Header
    GigaSettingsInterface.bigTitle = GigaSettingsInterface:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
    GigaSettingsInterface.bigTitle:SetJustifyH("LEFT")
    GigaSettingsInterface.bigTitle:SetText(GigaAddon.GigaData.addonName .. " v" .. C_AddOns.GetAddOnMetadata(GigaAddon.GigaData.addonName, "Version"))
	GigaSettingsInterface.bigTitle:SetPoint("TOPLEFT", 7, -22)
    GigaSettingsInterface.HorizontalDivider = GigaSettingsInterface:CreateTexture()
    GigaSettingsInterface.HorizontalDivider:SetAtlas("Options_HorizontalDivider", true)
    GigaSettingsInterface.HorizontalDivider:SetPoint("TOP", 0, -50)
    -- Reload button
    GigaSettingsInterface.reloadButton = CreateFrame("Button", nil, GigaSettingsInterface, "UIPanelButtonTemplate")
    GigaSettingsInterface.reloadButton:SetText("RELOAD")
    GigaSettingsInterface.reloadButton:SetWidth(96)
    GigaSettingsInterface.reloadButton:SetPoint("TOPRIGHT", -36, -16)
    GigaSettingsInterface.reloadButton:HookScript("OnClick", function()
        GigaSettingsDB["reopenOptions"] = true
        ReloadUI()
    end)
    GigaSettingsInterface.reloadButton:Hide()
    -- Helper reload button
    GigaSettingsInterface.HelpFrame = CreateFrame("Frame", nil, GigaSettingsInterface, "GlowBoxTemplate")
    GigaSettingsInterface.HelpFrame:SetPoint("RIGHT", GigaSettingsInterface.reloadButton, "LEFT", -15, 0)
    GigaSettingsInterface.HelpFrame:SetWidth(120)
    GigaSettingsInterface.HelpFrame:SetHeight(40)
    GigaSettingsInterface.HelpFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    GigaSettingsInterface.HelpFrame:SetParent(GigaSettingsInterface.reloadButton)
    GigaSettingsInterface.HelpFrame:Show()
    GigaSettingsInterface.HelpFrame.arrow = GigaSettingsInterface.HelpFrame:CreateTexture()
    GigaSettingsInterface.HelpFrame.arrow:ClearAllPoints()
	GigaSettingsInterface.HelpFrame.arrow:SetPoint("LEFT", GigaSettingsInterface.HelpFrame, "RIGHT", -10, 0)
	GigaSettingsInterface.HelpFrame.arrow:SetSize(40, 21)
	GigaSettingsInterface.HelpFrame.arrow:SetTexture("Interface\\TalentFrame\\TalentFrame-Parts")
    GigaSettingsInterface.HelpFrame.arrow:SetTexCoord(0.78515625, 0.99218750, 0.54687500, 0.58789063)
    GigaSettingsInterface.HelpFrame.arrow:SetRotation(math.pi/2)
    GigaSettingsInterface.HelpFrame.arrow:Show()
    GigaSettingsInterface.HelpFrame.text = GigaSettingsInterface.HelpFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightLeft")
    GigaSettingsInterface.HelpFrame.text:SetText("Reload required")
    GigaSettingsInterface.HelpFrame.text:ClearAllPoints()
	GigaSettingsInterface.HelpFrame.text:SetPoint("CENTER", GigaSettingsInterface.HelpFrame, "CENTER")
    -- Scroll
    GigaSettingsInterface.scrollFrame = CreateFrame("ScrollFrame", nil, GigaSettingsInterface, "ScrollFrameTemplate")
    GigaSettingsInterface.scrollFrame:SetPoint("TOPLEFT", GigaSettingsInterface.HorizontalDivider, "TOPLEFT", -20, -8)
	GigaSettingsInterface.scrollFrame:SetPoint("BOTTOMRIGHT", -26, 0)
	GigaSettingsInterface.scrollChild = CreateFrame("Frame")
	GigaSettingsInterface.scrollFrame:SetScrollChild(GigaSettingsInterface.scrollChild)
	GigaSettingsInterface.scrollChild:SetWidth(635)
	GigaSettingsInterface.scrollChild:SetHeight(1)
    -- Save the last element to position subsequent elements
    GigaAddon.GigaData.lastBuiltElement = GigaSettingsInterface.scrollChild
end

local function CreateHeader(headerName)
    local headerOption = GigaAddon.GigaData["header_"..headerName]
    GigaSettingsInterface[headerOption.key] = GigaSettingsInterface.scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    GigaSettingsInterface[headerOption.key]:SetText(headerOption.name)
    GigaSettingsInterface[headerOption.key]:SetPoint("TOPLEFT", GigaAddon.GigaData.lastBuiltElement, "BOTTOMLEFT", headerOption.firstEle and 20 or 0, headerOption.firstEle and -19 or -20)
    
    GigaAddon.GigaData.lastBuiltElement = GigaSettingsInterface[headerOption.key]
end

local function SetupOptionTooltip(elements, option, bg)
    if option.tooltip then
        for index, ele in ipairs(elements) do
            ele:HookScript("OnEnter", function(self)
                local tooltip = GameTooltip:CreateFontString(nil, "ARTWORK", "GameFontNormal")
                tooltip:SetText(option.tooltip)

                GameTooltip:SetOwner(index == 1 and ele or bg, "ANCHOR_RIGHT", -10, 0)
                GameTooltip:AddLine(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(option.name), nil, nil, nil, true)
                GameTooltip:AddLine(tooltip:GetText(), nil, nil, nil, true)
                GameTooltip:Show()

                if ele.HoverBackground ~= nil then ele.HoverBackground:Hide() end
                if bg~= nil then bg.HoverBackground:Show() end
            end)
            ele:HookScript("OnLeave", function(self)
                GameTooltip:Hide()
                if bg~= nil then bg.HoverBackground:Hide() end
            end)
        end
    end
end

local function SetupCheckboxOnChangeScript(elements, checkbox, setting, option)
    checkbox:HookScript("OnClick", function(self)
        local checked = self:GetChecked()
        setting:SetValue(checked)

        if option.callback then
            option.callback()
        end
        if option.needReload then
            GigaSettingsInterface.reloadButton:Show()
        end
        PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    end)

    for _, ele in pairs(elements) do
        ele:HookScript("OnMouseUp", function(self)
            if checkbox:IsEnabled() then
                checkbox:Click()
            end
        end)
    end
end

local function CreateCheckbox(category, option)
    local setting = RegisterSetting(category, option)
    local checkbox = CreateFrame("Frame", nil, GigaSettingsInterface.scrollChild)
    checkbox:SetSize(230, 26)
    
    checkbox.checkboxControl = CreateFrame("CheckButton", nil, checkbox, "SettingsCheckboxTemplate")
    checkbox.checkboxControl:SetPoint("LEFT", checkbox, "RIGHT", 0, 0)
    -- TODO: probably not needed anymore
    -- checkbox:SetFrameLevel(checkbox.checkboxControl:GetFrameLevel()-1)
    checkbox.Label = checkbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    checkbox.Label:SetText(option.name)
    checkbox.Label:SetPoint("LEFT", checkbox, "LEFT", 30, 0)

    checkbox.HoverBackground = checkbox:CreateTexture(nil, "BACKGROUND")
    checkbox.HoverBackground:SetColorTexture(1, 1, 1, 0.1)
    checkbox.HoverBackground:SetPoint("TOPLEFT", checkbox, "TOPLEFT", -17, 0)
    checkbox.HoverBackground:SetSize(640, 26)
    checkbox.HoverBackground:Hide()

    if option.new then
        checkbox.NewFeature = CreateFrame("Frame", nil, checkbox, "NewFeatureLabelTemplate")
        checkbox.NewFeature:SetScale(0.8)
        checkbox.NewFeature:SetPoint("BOTTOMRIGHT", checkbox.Label, "LEFT", 16, -10)
        checkbox.NewFeature:Show()
    end

    SetupCheckboxOnChangeScript({checkbox.Label, checkbox}, checkbox.checkboxControl, setting, option)
    SetupOptionTooltip({checkbox.checkboxControl, checkbox.Label, checkbox}, option, checkbox)
    checkbox.checkboxControl:SetChecked(setting:GetValue())

    return checkbox
end

local function RegisterCheckbox(checkboxName, category, firstEle)
    local checkboxOption = GigaAddon.GigaData["checkbox_"..checkboxName]
    GigaSettingsInterface[checkboxOption.key] = CreateCheckbox(category, checkboxOption)
    GigaSettingsInterface[checkboxOption.key]:SetPoint("TOPLEFT",  GigaAddon.GigaData.lastBuiltElement, "BOTTOMLEFT", 0, checkboxOption.firstEle and -21 or -10)

    -- TODO: Probably not neccessary on the release, should remove option.disable from each element in addonData.lua
    if checkboxOption.disable then
        GigaSettingsInterface[checkboxOption.key].checkboxControl:Disable()
        GigaSettingsInterface[checkboxOption.key].Label:SetFontObject("GameFontDisable")
    end

    if checkboxOption.dependency~=nil then
        GigaSettingsInterface[checkboxOption.key].checkboxControl:SetEnabled(GigaSettingsDB[checkboxOption.dependency])
        GigaSettingsInterface[checkboxOption.key].Label:SetFontObject(GigaSettingsDB[checkboxOption.dependency] and "GameFontNormalSmall" or "GameFontDisableSmall")
        GigaSettingsInterface[checkboxOption.key].Label:SetPoint("LEFT", 45, 0)
    end
    -- Save the last element to position subsequent elements
    GigaAddon.GigaData.lastBuiltElement = GigaSettingsInterface[checkboxOption.key]
end

local function CreateColorSwatch(parent, option)
    local colorswatch = CreateFrame("Button", nil, parent, "ColorSwatchTemplate")
    colorswatch:SetColor(CreateColorFromHexString(GigaSettingsDB[option.key]))

    local function openColorPicker(swatch, button, isDown)
        local info = {}
        info.swatch = swatch

        local healthColor = CreateColorFromHexString(GigaSettingsDB[option.key])
        info.r, info.g, info.b = healthColor:GetRGB()

        local currentColor = CreateColor(0, 0, 0, 0)
        info.swatchFunc = function()
            local r,g,b = ColorPickerFrame:GetColorRGB()
            currentColor:SetRGB(r, g, b, 1)
            GigaSettingsDB[option.key] = currentColor:GenerateHexColor()
        end;

        info.cancelFunc = function()
            local r,g,b = ColorPickerFrame:GetPreviousValues()
            currentColor:SetRGB(r, g, b, 1)
            GigaSettingsDB[option.key] = currentColor:GenerateHexColor()
            ColorPickerFrame:SetupColorPickerAndShow(info)
        end;

        ColorPickerFrame:SetupColorPickerAndShow(info)
    end
    colorswatch:HookScript("OnClick", openColorPicker)
    SetupOptionTooltip({colorswatch}, option)

    return colorswatch
end

local function RegisterCheckboxWithColorSwatch(checkboxName, colorswatchName, category, firstEle)
    RegisterCheckbox(checkboxName, category, firstEle)
    local checkbox = GigaSettingsInterface[checkboxName].checkboxControl
    local colorswatchOption = GigaAddon.GigaData["colorswatch_"..colorswatchName]
    checkbox.colorswatch = CreateColorSwatch(checkbox, colorswatchOption)
    checkbox.colorswatch:SetPoint("LEFT", checkbox, "RIGHT", 12, -2)

    if colorswatchOption.dependency~=nil then
        checkbox.colorswatch:SetEnabled(GigaSettingsDB[colorswatchOption.dependency])
    end
end

local function SetupDropdownOnChangeScript(dropdown, setting, option)
    local function getOptionData()
        local container = Settings.CreateControlTextContainer()
        for _, data in ipairs(option.data) do
            container:Add(data.value, data.name)
        end
        return container:GetData();
    end
    dropdown.dropdownControl.Dropdown.SetTooltipFunc = function() end
    dropdown.dropdownControl.Dropdown.SetDefaultTooltipAnchors = function() end
    local inserter = Settings.CreateDropdownOptionInserter(setting, getOptionData)
    Settings.InitDropdown(dropdown.dropdownControl.Dropdown, setting, inserter)
    -- SetupOptionTooltip({dropdown.dropdownControl.Dropdown, dropdown.Label, dropdown}, option, dropdown)

    local function isSelected(value)
		return GigaSettingsDB[option.key] == value
	end
    local function setSelected(value)
        GigaSettingsDB[option.key] = value
        option.callback()
        dropdown.dropdownControl.Dropdown:GenerateMenu()
		return MenuResponse.Close
	end
    dropdown.dropdownControl.Dropdown:SetupMenu(function(dropdown, rootDescription)
		for _, option in ipairs(option.data) do
            local radioDescription = rootDescription:CreateHighlightRadio(option.text, isSelected, setSelected, option.value)
        end
	end)
end

local function CreateDropdown(category, option)
    local setting = RegisterSetting(category, option)
    local dropdown = CreateFrame("Frame", nil, GigaSettingsInterface.scrollChild)
    dropdown:SetSize(250, 26)

    dropdown.dropdownControl = CreateFrame("Frame", nil, dropdown, "SettingsDropdownWithButtonsTemplate")
    dropdown.dropdownControl:SetPoint("LEFT", dropdown, "RIGHT", 12, 0)
    dropdown.dropdownControl.Dropdown:SetWidth(220)
    -- TODO: probably not needed anymore
    -- dropdown:SetFrameLevel(dropdown.dropdownControl.Dropdown:GetFrameLevel()-1)
    dropdown.Label = dropdown:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropdown.Label:SetText(option.name)
    dropdown.Label:SetPoint("LEFT", dropdown, "LEFT", 30, 0)

    dropdown.HoverBackground = dropdown:CreateTexture(nil, "BACKGROUND")
    dropdown.HoverBackground:SetColorTexture(1, 1, 1, 0.1)
    dropdown.HoverBackground:SetPoint("TOPLEFT", dropdown, "TOPLEFT", -17, 0)
    dropdown.HoverBackground:SetSize(640, 26)
    dropdown.HoverBackground:Hide()

    -- TODO: attach it to the label?
    -- if new == 1 then
    --     local NewFeature = CreateFrame("Frame", nil, dropdownControl, "NewFeatureLabelTemplate")
    --     NewFeature:SetScale(0.8)
    --     NewFeature:SetPoint("RIGHT", dropdownControl, "LEFT", -261, -3)
    --     NewFeature:Show()
    -- end

    SetupDropdownOnChangeScript(dropdown, setting, option)
    SetupOptionTooltip({dropdown.dropdownControl.Dropdown, dropdown.Label, dropdown}, option, dropdown)

    return dropdown
end

local function RegisterDropdown(dropdownName, category, firstEle)
    local dropdownOption = GigaAddon.GigaData["dropdown_"..dropdownName]
    GigaSettingsInterface[dropdownOption.key] = CreateDropdown(category, dropdownOption)
    GigaSettingsInterface[dropdownOption.key]:SetPoint("TOPLEFT",  GigaAddon.GigaData.lastBuiltElement, "BOTTOMLEFT", 0, dropdownOption.firstEle and -21 or -10)

    if dropdownOption.dependency ~= nil then
        GigaSettingsInterface[dropdownOption.key].dropdownControl:SetEnabled(GigaSettingsDB[dropdownOption.dependency])
        GigaSettingsInterface[dropdownOption.key].Label:SetFontObject(GigaSettingsDB[dropdownOption.dependency] and "GameFontNormalSmall" or "GameFontDisableSmall")
        GigaSettingsInterface[dropdownOption.key].Label:SetPoint("LEFT", 45, 0)
    end

    GigaAddon.GigaData.lastBuiltElement = GigaSettingsInterface[dropdownOption.key]
end

function GigaSettingsInterface:BuildAddonOptionsMenu()
    -- Register Gigancement in Addon options
    local category = Settings.RegisterCanvasLayoutCategory(self, GigaAddon.GigaData.addonName)
    category.ID = GigaAddon.GigaData.addonName
    Settings.RegisterAddOnCategory(category)

    -- Populate DB if there are empty/missing values
    for _, key in pairs(GigaAddon.GigaData) do
        if key.default~=nil then InitDB(key) end
    end

    -- Build Addon Options menu
    CreateOptionsBody()
    -- Character Info module
    CreateHeader("characterInfoTitle")
    RegisterCheckbox("decimalILVL", category)
    RegisterCheckbox("classColorILVL", category)
    RegisterCheckbox("characterILVLInfo", category)
    RegisterCheckbox("characterEnchantsInfo", category)
    RegisterCheckbox("characterGemsInfo", category)
    -- UI module
    CreateHeader("uiModuleTitle")
    RegisterCheckbox("upgradedCastbar", category)
    RegisterDropdown("castTimePosition", category)
    RegisterCheckbox("upgradedRaidFrames", category)
    RegisterCheckbox("classColorsUnitFrames", category)
    RegisterCheckbox("playerMinimapCoords", category)
    RegisterCheckbox("cursorRing", category)
    RegisterDropdown("cursorRingTexture", category)
    -- Chat module
    CreateHeader("chatModuleTitle")
    RegisterCheckboxWithColorSwatch("linksInChat", "linksInChatColor", category)
    RegisterCheckbox("rolesInChat", category)
    RegisterCheckbox("shorterChannelNames", category)
    RegisterCheckbox("chatMouseoverItemTooltip", category)
    -- Actionbar Module
    CreateHeader("actionbarModuleTitle")
    RegisterCheckbox("shorterKeybinds", category)
    RegisterCheckbox("hideKeybindText", category)
    RegisterCheckbox("hideMacroText", category)
    -- LFG Module
    CreateHeader("lfgModuleTitle")
    RegisterCheckbox("inspectLFG", category)
    RegisterCheckbox("doubleClickLFG", category)
    RegisterCheckbox("skipRoleCheck", category)
    RegisterCheckbox("muteApplicantSound", category)
    RegisterCheckbox("applicantRaceTooltip", category)
    RegisterCheckbox("sortApplicants", category)
    -- Nameplate Module
    CreateHeader("nameplateModuleTitle")
    RegisterCheckbox("castTimerNameplate", category)

    -- Reopen addon options if a reload is required
    if GigaSettingsDB["reopenOptions"] == true then
        C_Timer.After(0, function()
            Settings.OpenToCategory("Gigancement")
        end)
        GigaSettingsDB["reopenOptions"] = false
    end
end

-- Stop processing events for disabled options
function GigaSettingsInterface:ToggleEventRegister(event, flag)
    if flag==true then
        GigaSettingsInterface:RegisterEvent(event)
    else
        GigaSettingsInterface:UnregisterEvent(event)
    end
end

-- Get role icon texture
local roleTex = {
    ["DAMAGER"]     = "|A:groupfinder-icon-role-micro-dps:",
    ["HEALER"]      = "|A:groupfinder-icon-role-micro-heal:",
    ["TANK"]        = "|A:groupfinder-icon-role-micro-tank:",
    ["DAMAGERCHAT"] = "|A:GM-icon-role-dps:",
    ["HEALERCHAT"] = "|A:GM-icon-role-healer:",
    ["TANKCHAT"]    = "|A:GM-icon-role-tank:",
    ["NONE"]        = ""
}
function GigaSettingsInterface:GetRoleTex(role, height, width)
    local str = roleTex[role]
    if str == nil or not str then
        return roleTex["NONE"]
    end
    return str .. tostring(height) .. ":" .. tostring(width) .. "|a"
end
