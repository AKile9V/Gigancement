local function CastbarSetText(castingFrame)
  if not castingFrame.timer then return end
  if castingFrame.casting then
    castingFrame.timer:SetText(format("%2.1f/%1.1f", max(castingFrame.maxValue - castingFrame.value, 0), castingFrame.maxValue))
  elseif castingFrame.channeling then
    castingFrame.timer:SetText(format("%.1f", max(castingFrame.value, 0)))
  else
    castingFrame.timer:SetText("")
  end
end

function GigaSettingsInterface:UpgradeDefaultCastbar(position)
  if not GigaSettingsDB.upgradedCastbar then return end
  if not PlayerCastingBarFrame.timer then
    PlayerCastingBarFrame.timer = PlayerCastingBarFrame:CreateFontString(nil)
    PlayerCastingBarFrame.timer:SetFont(STANDARD_TEXT_FONT,10,"OUTLINE")
    PlayerCastingBarFrame.timer:SetText("")
    PlayerCastingBarFrame.Icon:AdjustPointsOffset(2, -4)
    PlayerCastingBarFrame.Icon:SetScale(1.5)
    PlayerCastingBarFrame:HookScript("OnValueChanged", function(self)
      PlayerCastingBarFrame.Icon:Show()
      CastbarSetText(self)
    end)
  end
  PlayerCastingBarFrame.timer:ClearAllPoints()
  PlayerCastingBarFrame.timer:SetPoint(position, PlayerCastingBarFrame, position, 0, 1)
  if not TargetFrameSpellBar.timer then
    TargetFrameSpellBar.timer = TargetFrameSpellBar:CreateFontString(nil)
    TargetFrameSpellBar.timer:SetFont(STANDARD_TEXT_FONT,10,"OUTLINE")
    TargetFrameSpellBar.timer:SetText("")
    TargetFrameSpellBar:HookScript("OnValueChanged", function(self)
      CastbarSetText(self)
    end)
  end
  TargetFrameSpellBar.timer:ClearAllPoints()
  TargetFrameSpellBar.timer:SetPoint(position, TargetFrameSpellBar, position, 0, 1)
  if not FocusFrameSpellBar.timer then
    FocusFrameSpellBar.timer = FocusFrameSpellBar:CreateFontString(nil)
    FocusFrameSpellBar.timer:SetFont(STANDARD_TEXT_FONT,10,"OUTLINE")
    FocusFrameSpellBar.timer:SetText("")
    FocusFrameSpellBar:HookScript("OnValueChanged", function(self)
      CastbarSetText(self)
    end)
  end
  FocusFrameSpellBar.timer:ClearAllPoints()
  FocusFrameSpellBar.timer:SetPoint(position, FocusFrameSpellBar, position, 0, 1)
end

function GigaSettingsInterface:UnitFrameClassColor(unit, healthBar)
  if UnitIsPlayer(unit) and UnitIsConnected(unit) then
		local _, const_class = UnitClass(unit);
		local r, g, b = GetClassColor(const_class)
		healthBar:SetStatusBarDesaturated(true)
		healthBar:SetStatusBarColor(r, g, b)
	elseif UnitIsPlayer(unit) and not UnitIsConnected(unit) then
		healthBar:SetStatusBarDesaturated(true)
		healthBar:SetStatusBarColor(1, 1, 1)
	elseif UnitIsConnected(unit) then
		healthBar:SetStatusBarDesaturated(true)
		healthBar:SetStatusBarColor(0, 1, 0)
  elseif not UnitIsPlayer(unit) then
		healthBar:SetStatusBarDesaturated(false)
		healthBar:SetStatusBarColor(1, 1, 1)
	end
end

local icons = {}
local function PrepTextureRaidMarker(frame)
  local frameName = frame:GetName()
  if not icons[frameName] then
    return
  end
  icons[frameName].textureRM:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons")
  icons[frameName].textureRM:Hide()
  icons[frameName].textureRM:ClearAllPoints()
  icons[frameName].textureRM:SetPoint("LEFT", 1, 0)
  icons[frameName].textureRM:SetWidth(20)
  icons[frameName].textureRM:SetHeight(20)
end

local function PrepTextureLeader(frame)
   frame.textureLeader = frame:CreateTexture(nil, "OVERLAY")
   frame.textureLeader:ClearAllPoints()
   frame.textureLeader:SetPoint("TOPLEFT", -1, 12)
   frame.textureLeader:SetWidth(20)
   frame.textureLeader:SetHeight(20)
   frame.textureLeader:SetVertexColor(0.95, 0.85, 0.1)
end

local function SetupRaidMarks(unit, frame)
  local frameName = frame:GetName()
  local markId = GetRaidTargetIndex(unit)

  if not GigaSettingsDB.upgradedRaidFrames and icons[frameName] ~= nil then
    icons[frameName].textureRM:Hide()
    return
  end

  if not icons[frameName] then
    icons[frameName] = frame
    icons[frameName].textureRM = frame:CreateTexture(nil, "OVERLAY")
    PrepTextureRaidMarker(frame)
  end

  if type(markId) ~= "nil" then
    SetRaidTargetIconTexture(icons[frameName].textureRM, markId)
    icons[frameName].textureRM:Show()
  else
    icons[frameName].textureRM:Hide()
  end
end

local function SetupLeaderIcons(unit, frame)
  if not GigaSettingsDB.upgradedRaidFrames and frame.textureLeader ~= nil then
    frame.textureLeader:Hide()
    return
  end

  if UnitIsGroupLeader(unit) then
    if frame.textureLeader == nil then
      PrepTextureLeader(frame)
    end
    frame.textureLeader:SetAtlas("GO-icon-Lead-Applied")
    frame.textureLeader:Show()
  elseif UnitIsGroupAssistant(unit) and CompactRaidFrameContainer:IsShown() then
    if frame.textureLeader == nil then
      PrepTextureLeader(frame)
    end
    frame.textureLeader:SetAtlas("GO-icon-Header-Assist-Applied")
    frame.textureLeader:Show()
  else
    if frame.textureLeader ~= nil then
      frame.textureLeader:Hide()
    end
  end
end

local function UpdateIcons(frame)
   local unit = frame.unit
   if not unit then
      return
   end

   SetupRaidMarks(unit, frame)
   SetupLeaderIcons(unit, frame)
end

function GigaSettingsInterface:UpgradeRaidFrames()
  if (CompactRaidFrameContainer:IsShown() and not CompactRaidFrameContainer:IsForbidden()) or (CompactPartyFrame:IsShown() and not CompactPartyFrame:IsForbidden()) then
		CompactRaidFrameContainer:ApplyToFrames("all", function(frame)
      C_Timer.After(0, function() UpdateIcons(frame) end)
    end)
	end
end
