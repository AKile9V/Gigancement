settingsDB = settingsDB or {}

-- LFG Inspect Group Specializations
local function sortRoles(resultID, numMembers)
  local sortedMaps = {}
  for i = 1, numMembers do
    local role, class, classLocalized, specLocalized = C_LFGList.GetSearchResultMemberInfo(resultID, i)
    tinsert(sortedMaps, {
      index = tIndexOf(LFG_LIST_GROUP_DATA_ROLE_ORDER, role),
      class = class,
      classLocalized = classLocalized,
      specLocalized = specLocalized,
      role = role,
      isLeader = (i == 1),
    })
  end
  table.sort(sortedMaps, function(a, b)
    return a.index < b.index
  end)
  return sortedMaps
end

local function CheckIfTooltipContains(tooltip, searchText)
  for i = 1, 15 do
    local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
    local text
    if frame then
      text = frame:GetText()
    end
    if (text) then
      if type(searchText) == "table" then
        for _, v in ipairs(searchText) do
          local contains = string.gmatch(text, v)
          if (contains) then
            return true
          end
        end
      else
        local contains = string.gmatch(text, searchText)
        if (contains) then
          return true
        end
      end
    end
  end
  return false
end

function SetupLFGTooltip(tooltip, resultID, autoAcceptOption)
  local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
  local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID, nil, searchResultInfo.isWarMode)
  if activityInfo.isMythicPlusActivity == true or activityInfo.isMythicActivity == true then return end
  if activityInfo.displayType ~= Enum.LFGListDisplayType.ClassEnumerate then
    local found = CheckIfTooltipContains(tooltip, {LFG_LIST_TOOLTIP_MEMBERS, LFG_LIST_TOOLTIP_MEMBERS_SIMPLE})
    if (found) then
      tooltip:AddLine(" ")
      tooltip:AddLine(NORMAL_FONT_COLOR_CODE .. "Members Specialization:" .. FONT_COLOR_CODE_CLOSE)
    end

    local sortedMaps = sortRoles(resultID, searchResultInfo.numMembers)
    for i = 1, searchResultInfo.numMembers do
      local player = sortedMaps[i]
      local classColor = RAID_CLASS_COLORS[player.class] or NORMAL_FONT_COLOR
      local leaderArt = ""
      if player.isLeader then leaderArt = "|A:groupfinder-icon-leader:9:14|a" end
      tooltip:AddLine(getRoleTex(player.role) .. " |c".. classColor.colorStr .. player.classLocalized .. " - " .. player.specLocalized .."|r " .. leaderArt)
    end
  end
  tooltip:Show()
end
-- LFG Inspect Group Specializations // END

-- Double click to queue + Auto role check
local function OnDoubleClick(button, buttonName)
  local resultExists = not LFGListFrame.SearchPanel.SignUpButton.tooltip 
  if (settingsDB.enableDoubleClickLFG and resultExists and buttonName == "LeftButton" and (IsInGroup() ~= true or UnitIsGroupLeader("player") == true)) then
      LFGListSearchPanel_SignUp(button:GetParent():GetParent():GetParent())
  end
end

local function AddDoubleClickHook(scrollTarget)
  local buttons = {scrollTarget:GetChildren()}
  for _, button in ipairs(buttons) do
    button:SetScript("OnDoubleClick", OnDoubleClick)
  end
end

-- TODO: add as addon option?
LFGListApplicationDialog:HookScript("OnShow", function() 
  if LFGListApplicationDialog.SignUpButton:IsEnabled() and not IsShiftKeyDown() then 
    LFGListApplicationDialog.SignUpButton:Click() 
  end
end)

function LFGDoubleClick()
  local scrollTarget = LFGListFrame.SearchPanel.ScrollBox:GetScrollTarget()
  AddDoubleClickHook(scrollTarget)
end
-- Double click to queue + Auto role check // END

-- Silence application sound
local function DefaultApplicationSound()
  if ( not settingsDB.enableMuteApplicantSound and QueueStatusButton:OnGlowPulse(QueueStatusButton.EyeHighlightAnim) ) then
    PlaySound(SOUNDKIT.UI_GROUP_FINDER_RECEIVE_APPLICATION)
  end
end

function MuteApplicationSignupSound()
  local button = QueueStatusButton
  if button and button.EyeHighlightAnim then
      button.EyeHighlightAnim:SetScript('OnLoop', DefaultApplicationSound)
  end
end
-- Silence application sound // END
