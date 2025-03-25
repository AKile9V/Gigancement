settingsDB = settingsDB or {}

-- LFG Inspect Group Specializations
local function sortRoles(resultID, numMembers)
  local sortedMaps = {}
  for i = 1, numMembers do
    local role, class, classLocalized, specLocalized, isLeader = C_LFGList.GetSearchResultMemberInfo(resultID, i)
    tinsert(sortedMaps, {
      index = tIndexOf(LFG_LIST_GROUP_DATA_ROLE_ORDER, role),
      class = class,
      classLocalized = classLocalized,
      specLocalized = specLocalized,
      role = role,
      isLeader = isLeader,
    })
  end
  table.sort(sortedMaps, function(a, b)
    return a.index < b.index
  end)
  return sortedMaps
end

function SetupLFGTooltip(tooltip, resultID, autoAcceptOption)
  local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
  local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1], nil, searchResultInfo.isWarMode)
  if activityInfo.displayType ~= Enum.LFGListDisplayType.ClassEnumerate and activityInfo.displayType ~= Enum.LFGListDisplayType.RoleEnumerate then
    for i=1, tooltip:NumLines() do 
      local line = _G[tooltip:GetName().."TextLeft"..i]
      local text = line:GetText()
      if text and text:match("Members:") then
        local sortedMaps = sortRoles(resultID, searchResultInfo.numMembers)
        for i = 1, searchResultInfo.numMembers do
          local player = sortedMaps[i]
          local classColor = RAID_CLASS_COLORS[player.class] or NORMAL_FONT_COLOR:GenerateHexColor()
          local leaderArt = player.isLeader and "|A:groupfinder-icon-leader:9:14|a" or ""
          text = text .. "\n" .. getRoleTex(player.role, 13, 13) .. " |c".. classColor.colorStr .. player.classLocalized .. " - " .. player.specLocalized .."|r " .. leaderArt
        end
        line:SetText(text)
        line:SetSpacing(2)
        line:Show()
        break
      end
    end
  end
  tooltip:Show()
end
-- LFG Inspect Group Specializations // END

-- Double click to queue
local function OnDoubleClick(button, buttonName)
  local resultExists = not LFGListFrame.SearchPanel.SignUpButton.tooltip 
  if (settingsDB.enableDoubleClickLFG and resultExists and buttonName == "LeftButton" and (IsInGroup() ~= true or UnitIsGroupLeader("player") == true)) then
      LFGListSearchPanel_SignUp(button:GetParent():GetParent():GetParent())
  end
end

local function AddDoubleClickHook(scrollTarget)
  local buttons = {scrollTarget:GetChildren()}
  for _, button in ipairs(buttons) do
    if button.resultID then
      button:SetScript("OnDoubleClick", OnDoubleClick)
    end
  end
end

function LFGDoubleClick()
  local scrollTarget = LFGListFrame.SearchPanel.ScrollBox:GetScrollTarget()
  AddDoubleClickHook(scrollTarget)
end
-- Double click to queue // END

-- Auto role check
LFGListApplicationDialog:HookScript("OnShow", function() 
  if settingsDB.enableSkipRoleCheck and LFGListApplicationDialog.SignUpButton:IsEnabled() and not IsShiftKeyDown() then 
    LFGListApplicationDialog.SignUpButton:Click()
  end
end)
LFDRoleCheckPopupAcceptButton:HookScript("OnShow", function()
  if settingsDB.enableSkipRoleCheck then
    LFDRoleCheckPopupAcceptButton:Click()
  end
end)
-- Auto role check // END

-- Silence application sound
local origEyeOnLoop = QueueStatusButton.EyeHighlightAnim:GetScript("OnLoop")
function MuteApplicationSignupSound()
  if QueueStatusButton and QueueStatusButton.EyeHighlightAnim and origEyeOnLoop then
    QueueStatusButton.EyeHighlightAnim:SetScript("OnLoop", (not settingsDB.enableMuteApplicantSound and origEyeOnLoop) or (function() return end))
  end
end
-- Silence application sound // END

-- Applicant Race in tooltip
function AddApplicantRaceInTooltip(self)
  local race = C_CreatureInfo.GetRaceInfo(select(15, C_LFGList.GetApplicantMemberInfo(self:GetParent().applicantID, self.memberIdx))).raceName
  for i=1, GameTooltip:NumLines() do 
    local line = _G["GameTooltipTextLeft"..i]
    local text = line:GetText()
    if text and text:match("Level %d+") and race then
      line:SetText("|c"..NORMAL_FONT_COLOR:GenerateHexColor()..race.."|r" .. "\n" ..text)
      line:Show()
      GameTooltip:Show()
      return
    end
  end
end
-- Applicant Race in tooltip // END

-- Sort Applicants by RIO score
local function SortApplicantsCB(applicantID1, applicantID2)
  local applicantInfo1 = C_LFGList.GetApplicantInfo(applicantID1)
  local applicantInfo2 = C_LFGList.GetApplicantInfo(applicantID2)
  
  if not applicantInfo1 then
    return false
  end
  
  if not applicantInfo2 then
    return true
  end
  
  local applicant1Score = select(12, C_LFGList.GetApplicantMemberInfo(applicantInfo1.applicantID, 1)) or 0
  local applicant2Score = select(12, C_LFGList.GetApplicantMemberInfo(applicantInfo2.applicantID, 1)) or 0
  
  return applicant1Score>applicant2Score
end

function SortApplicantsByRating(applicants)
  table.sort(applicants, SortApplicantsCB)
end
-- Sort Applicants by RIO score // END
