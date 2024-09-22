settingsDB = settingsDB or {}
local chatEvents = {
    CHAT_MSG_BN_CONVERSATION = 0, CHAT_MSG_BN_WHISPER = 0,
    CHAT_MSG_BN_WHISPER_INFORM = 0, 
    CHAT_MSG_SAY = 1, CHAT_MSG_YELL = 1, 
    CHAT_MSG_WHISPER = 1, CHAT_MSG_WHISPER_INFORM = 1,
    CHAT_MSG_PARTY = 1, CHAT_MSG_PARTY_LEADER = 1,
    CHAT_MSG_INSTANCE_CHAT = 1, CHAT_MSG_INSTANCE_CHAT_LEADER = 1,
    CHAT_MSG_RAID = 1, CHAT_MSG_RAID_LEADER = 1, CHAT_MSG_RAID_WARNING = 1,
    CHAT_MSG_GUILD = 1, CHAT_MSG_OFFICER = 1, CHAT_MSG_CHANNEL = 1, 
    CHAT_MSG_COMMUNITIES_CHANNEL = 1, CHAT_MSG_TEXT_EMOTE = 1, 
    CHAT_MSG_SYSTEM = 2, CHAT_MSG_TARGETICONS = 2, CHAT_MSG_EMOTE = 2,
}

-- Open addon settings
SLASH_GSETTINGS1 = "/giga"
SlashCmdList["GSETTINGS"] = function()
    Settings.OpenToCategory("Gigancement")
end

-- Clear chat windows
SLASH_CHATCLEAR1 = "/clear"
SlashCmdList["CHATCLEAR"] = function()
    -- ChatFrame1
    local chatFrameName
    local cF = _G["ChatFrame1"]
    cF:Clear()
    -- ChatFrame3,4,5,6...10 skipping ChatFrame2(combatlog)
    for i=3, NUM_CHAT_WINDOWS do
        chatFrameName = ("%s%d"):format("ChatFrame", i)
        cF = _G[chatFrameName]
        cF:Clear()
    end
    -- Any other Whisper ChatFrame (don't expect more then 15 whispers opened at the same time)
    for i=11, 25 do
        chatFrameName = ("%s%d"):format("ChatFrame", i)
        cF = _G[chatFrameName]
        if(cF) then
            cF:Clear()
        end
    end
end

--Leave Group
SLASH_LEAVEGROUP1 = "/lg"
SlashCmdList["LEAVEGROUP"] = function(arg1)
    if arg1~="" then
        if arg1 == "msg off" then
            settingsDB.c_disableLGMessage = true
            print("|cffFF0000/lg FAREWELL MESSAGE DISABLED|r")
        elseif arg1 == "msg on" then
            settingsDB.c_disableLGMessage = false
            print("|cff00FF00/lg FAREWELL MESSAGE ENABLED|r")
        end
        return
    end
    SendChatMessage(settingsDB.c_disableLGMessage and "" or "Thanks for the group", "PARTY")
    C_Timer.After(settingsDB.c_disableLGMessage and 0 or 1.7, function() C_PartyInfo.LeaveParty() end)
end

--Secondary Stats Distribution
local function ssdround(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
SLASH_SDP1 = "/ssd"
local function GetStatsDistrib()
    local critValue = GetCombatRating(CR_CRIT_MELEE)
    local hasteValue = GetCombatRating(CR_HASTE_MELEE)
    local masteryValue = GetCombatRating(CR_MASTERY)
    local verValue = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
    local statTotal = critValue + hasteValue + masteryValue + verValue
    
    print("---- Secondary Stats Distribution -----")
    print("## Total: ".. statTotal .. " → 100%")
    print("|cff00FF00Crit:|r ".. critValue .." → " .. ssdround(((critValue / statTotal) * 100),2) .. "%")
    print("|cffFFFF00Haste|r: ".. hasteValue .." → " .. ssdround(((hasteValue / statTotal) * 100),2) .. "%")
    print("|cff0000FFMastery:|r ".. masteryValue .." → " .. ssdround(((masteryValue / statTotal) * 100),2) .. "%")
    print("|cffFF0000Versatility:|r ".. verValue .." → " .. ssdround(((verValue / statTotal) * 100),2) .. "%")
    print("-------------------------------------------------")
end
SlashCmdList["SDP"] = GetStatsDistrib

--MRT Ready Check
SLASH_READYCHECKME1 = "/rcme"
SlashCmdList["READYCHECKME"] = function()
    if not C_AddOns.IsAddOnLoaded("MRT") then 
        print("|cffFF0000MRT ISN'T ENABLED|r")
        return
    end
    MRTConsumables:Enable()
    MRTConsumables.Test(true)
end

-- Quick Keybind Mode
SLASH_QUICKKEYBINDMODE1 = "/kb"
SlashCmdList["QUICKKEYBINDMODE"] = function()
    if UnitAffectingCombat("player") then 
        print("|cffFF0000PLEASE LEAVE THE COMBAT TO OPEN THE QUICK KEYBIND MODE|r")
        return
    end
    if QuickKeybindFrame then ShowUIPanel(QuickKeybindFrame) end
end

-- LinksInChat
local function doColor(url)
    local color = string.format("%02x%02x%02x", 
                                math.floor(settingsDB.colorLinkRed*255),
                                math.floor(settingsDB.colorLinkGreen*255),
                                math.floor(settingsDB.colorLinkBlue*255))
    url = "|cff"..color.."|Hurl:"..url.."|h["..url.."|h]|r "
    return url
end

local function urlFilter(self, event, msg, author, ...)
    if not settingsDB.enableLinksInChat then return end
    if strfind(msg, "(%a+)://(%S+)%s?") then
        return false, string.gsub(msg, "(%a+)://(%S+)%s?", doColor("%1://%2")), author, ...
    end
    if strfind(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?") then
        return false, string.gsub(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", doColor("www.%1.%2")), author, ...
    end
    if strfind(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?") then
        return false, string.gsub(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", doColor("%1@%2%3%4")), author, ...
    end
    if strfind(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?):(%d%d?%d?%d?%d?)%s?") then
        return false, string.gsub(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?):(%d%d?%d?%d?%d?)%s?", doColor("%1.%2.%3.%4:%5")), author, ...
    end
    if strfind(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?") then
        return false, string.gsub(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", doColor("%1.%2.%3.%4")), author, ...
    end
    if strfind(msg, "[wWhH][wWtT][wWtT][\46pP]%S+[^%p%s]") then
        return false, string.gsub(msg, "[wWhH][wWtT][wWtT][\46pP]%S+[^%p%s]", doColor("%1")), author, ...
    end
end

function LinksInChat()
    StaticPopupDialogs["LINKWINDOW"] = {
        text = "Use \"CTRL+C\" to copy URL",
        button2 = CANCEL,
        hasEditBox = true,
        hasWideEditBox = true,
        timeout = 0,
        exclusive = 1,
        hideOnEscape = 1,
        EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
        whileDead = 1,
        maxLetters = 255,
    }

    local SetHyperlink = _G.ItemRefTooltip.SetHyperlink
    function _G.ItemRefTooltip:SetHyperlink(link, ...)
        if not settingsDB.enableLinksInChat then return end
        if link and (strsub(link, 1, 3) == "url") then
            local url = strsub(link, 5)
            local dialog = StaticPopup_Show("LINKWINDOW")
            local editbox = _G[dialog:GetName().."EditBox"]

            editbox:SetText(url)
            editbox:SetFocus()
            editbox:HighlightText()
            editbox:SetScript("OnKeyDown", function(self, key)
                if IsControlKeyDown() and (key == "C" or key == "X") then
                    -- Have to delay popup closing, because that operation can be faster then copying to clipboard
                    C_Timer.After(0, function()
                        self:GetParent():Hide()
                        ActionStatus:DisplayMessage(doColor(url) .. " copied to clipboard.")
                    end)
                end
            end)

            local button = _G[dialog:GetName().."Button2"]
            button:ClearAllPoints()
            button:SetPoint("CENTER", editbox, "CENTER", 0, -30)

            return
        end

        SetHyperlink(self, link, ...)
    end

    for k,v in pairs(chatEvents) do
        if v == 0 or v == 1 then
            ChatFrame_AddMessageEventFilter(k, urlFilter)
        end
    end
end
-- LinksInChat // END

-- Roles in chat
local GetColoredName_orig
local function GetColoredName_hook(event, arg1, arg2, ...)
    local ret = GetColoredName_orig(event, arg1, arg2, ...) 
    if chatEvents[event] and settingsDB.enableRolesInChat then
        local player, realm = strsplit( "-", arg2, 2 )
        local role = UnitGroupRolesAssigned(player)
        if not UnitInParty(player) and not UnitInRaid(player) then
            role = "NONE"
            return ret
        end
        if role and role ~= "NONE" then
            ret = getRoleTex(role.."CHAT", 18, 18) .. ret
        end
    end
    return ret
end

if GetColoredName then
    GetColoredName_orig = _G.GetColoredName
    _G.GetColoredName = GetColoredName_hook
end
-- Roles in chat // END

local shortChnNames = {
    "[G", --General
    "[T(S)]", --Trade (Services)
    "[T]", --Trade
    "[WD", --WorldDefense
    "[LD", --LocalDefense
    "[LFG]", --LookingForGroup
    "[G]", --Guild
    "[I]", --Instance
    "[IL|A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:14:14|a]", --Instance Leader
    "[P]", --Party
    "[PL|A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:14:14|a]", --Party Leader
    "[PG|A:UI-HUD-UnitFrame-Player-Group-GuideIcon:14:14|a]", --Party Guide
    "[O]", --Officer
    "[R]", --Raid
    "[RL|A:UI-HUD-UnitFrame-Player-Group-LeaderIcon:14:14|a]", --Raid Leader
    "[RW|TInterface\\GroupFrame\\UI-GROUP-MAINASSISTICON:0|t]", --Raid Warning
    "[%1]", --Custom Channels
}
local fullChnNames = {
    "%[%d%d?%. General",
    "%[%d%d?%. Trade %([^%]]*%]",
    "%[%d%d?%. Trade[^%]]*%]",
    "%[%d%d?%. WorldDefense",
    "%[%d%d?%. LocalDefense",
    "%[%d%d?%. LookingForGroup[^%]]*%]",
    string.gsub(CHAT_GUILD_GET, ".*%[(.*)%].*", "%%[%1%%]"),
    string.gsub(CHAT_INSTANCE_CHAT_GET, ".*%[(.*)%].*", "%%[%1%%]"),
    string.gsub(CHAT_INSTANCE_CHAT_LEADER_GET, ".*%[(.*)%].*", "%%[%1%%]"),
    string.gsub(CHAT_PARTY_GET, ".*%[(.*)%].*", "%%[%1%%]"),
    string.gsub(CHAT_PARTY_LEADER_GET, ".*%[(.*)%].*", "%%[%1%%]"),
    string.gsub(CHAT_PARTY_GUIDE_GET, ".*%[(.*)%].*", "%%[%1%%]"),
    string.gsub(CHAT_OFFICER_GET, ".*%[(.*)%].*", "%%[%1%%]"),
    string.gsub(CHAT_RAID_GET, ".*%[(.*)%].*", "%%[%1%%]"),
    string.gsub(CHAT_RAID_LEADER_GET, ".*%[(.*)%].*", "%%[%1%%]"),
    string.gsub(CHAT_RAID_WARNING_GET, ".*%[(.*)%].*", "%%[%1%%]"),
    "%[(%d%d?)%. ([^%]]+)%]",
}

local function ReplaceChannelNames(text)
    local size = #fullChnNames
    for i=1, size do
        text = string.gsub(text, fullChnNames[i], shortChnNames[i])
    end
    return text
end

local EditMessage = function(self)
    if not settingsDB.enableShorterChannelNames then return end

	local num = self.headIndex
	if num == 0 then
		num = self.maxElements
	end
	local tbl = self.elements[num]
	local text = tbl and tbl.message
	if text then
		text = ReplaceChannelNames(text)
		self.elements[num].message = text
	end
end

local function ChatMouseoverItemTooltip(chatFrame, link, text)
    if not settingsDB.enableChatMouseoverItemTooltip then return end

    local linkType = LinkUtil.SplitLinkData(link)
    if linkType == "battlepet" then
        GameTooltip:SetOwner(chatFrame, "ANCHOR_CURSOR_RIGHT", 4, 2)
        BattlePetToolTip_ShowLink(text)
    elseif linkType ~= "trade" then
        GameTooltip:SetOwner(chatFrame, "ANCHOR_CURSOR_RIGHT", 4, 2)
        local retOK = pcall(GameTooltip.SetHyperlink, GameTooltip, link)
        if not retOK then
            GameTooltip:Hide()
        else
            GameTooltip:Show()
        end
    end
end
  
local function ChatCloseMouseoverItemTooltip()
    if not settingsDB.enableChatMouseoverItemTooltip then return end
    
    BattlePetTooltip:Hide()
    GameTooltip:Hide()
end

function ChatWhispersMouseoverItemTooltip()
    if not settingsDB.enableChatMouseoverItemTooltip then return end
    
    local chatFrameName
    local cF
    -- 15 whisper chatframes
    for i=11, 25 do
        chatFrameName = ("%s%d"):format("ChatFrame", i)
        cF = _G[chatFrameName]
        if(cF and cF:GetScript("OnHyperlinkEnter")==nil) then
            cF:SetScript("OnHyperlinkEnter", ChatMouseoverItemTooltip)
            cF:SetScript("OnHyperlinkLeave", ChatCloseMouseoverItemTooltip)
        end
    end
end

function ChatFramesModifications()
    -- ChatFrame1
    local chatFrameName
    local cF = _G["ChatFrame1"]

    hooksecurefunc(cF.historyBuffer, "PushFront", EditMessage)

    cF:SetScript("OnHyperlinkEnter", ChatMouseoverItemTooltip)
    cF:SetScript("OnHyperlinkLeave", ChatCloseMouseoverItemTooltip)
    -- ChatFrame3,4,5,6...10 skipping ChatFrame2(combatlog)
    for i=3, NUM_CHAT_WINDOWS do
        chatFrameName = ("%s%d"):format("ChatFrame", i)
        cF = _G[chatFrameName]

        hooksecurefunc(cF.historyBuffer, "PushFront", EditMessage)
        
        cF:SetScript("OnHyperlinkEnter", ChatMouseoverItemTooltip)
        cF:SetScript("OnHyperlinkLeave", ChatCloseMouseoverItemTooltip)
    end
    -- Any other Whisper ChatFrame (don't expect more then 15 whispers opened at the same time)
    ChatWhispersMouseoverItemTooltip()
end
