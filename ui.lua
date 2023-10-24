settingsDB = settingsDB or {}
-- Castbar Timer
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

function UpgradeDefaultCastbar()
  if not settingsDB.enableUpgradedCastbar then return end -- it's not in the hook (which can give us realtime change just by checking the box in settings) because it takes CPU time even when it is disable
  PlayerCastingBarFrame.timer = PlayerCastingBarFrame:CreateFontString(nil)
  PlayerCastingBarFrame.timer:SetFont(STANDARD_TEXT_FONT,10,"OUTLINE")
  PlayerCastingBarFrame.timer:SetPoint("TOP", PlayerCastingBarFrame, "BOTTOM", 0, 12)
  PlayerCastingBarFrame.timer:SetText("")
  TargetFrameSpellBar.timer = TargetFrameSpellBar:CreateFontString(nil)
  TargetFrameSpellBar.timer:SetFont(STANDARD_TEXT_FONT,10,"OUTLINE")
  TargetFrameSpellBar.timer:SetPoint("TOP", TargetFrameSpellBar, "BOTTOM", 0, 12)
  TargetFrameSpellBar.timer:SetText("")
  FocusFrameSpellBar.timer = FocusFrameSpellBar:CreateFontString(nil)
  FocusFrameSpellBar.timer:SetFont(STANDARD_TEXT_FONT,10,"OUTLINE")
  FocusFrameSpellBar.timer:SetPoint("TOP", FocusFrameSpellBar, "BOTTOM", 0, 12)
  FocusFrameSpellBar.timer:SetText("")
  PlayerCastingBarFrame.Icon:AdjustPointsOffset(2, -4)
  PlayerCastingBarFrame.Icon:SetScale(1.5)
    
  PlayerCastingBarFrame:HookScript("OnValueChanged", function(self)
    PlayerCastingBarFrame.Icon:Show()
    CastbarSetText(self)
  end)
  TargetFrameSpellBar:HookScript("OnValueChanged", function(self)
    CastbarSetText(self)
  end)
  FocusFrameSpellBar:HookScript("OnValueChanged", function(self)
    CastbarSetText(self)
  end)
end
-- Castbar Timer // END

-- Class Frame colors
function UnitFramesClassColors(self)
	local healthBar = self.HealthBar

	if self.unit == "player" then
		if UnitInVehicle(self.unit) then
			healthBar = PetFrameHealthBar
		else
			healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea.HealthBar
		end
	elseif self.unit == "pet" then
		healthBar = PetFrameHealthBar
	elseif self.unit == "target" then
		healthBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBar
	elseif self.unit == "focus" then
		healthBar = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBar
	elseif self.unit == "vehicle" then
		healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea.HealthBar
	end

	if not healthBar then
		return
	end

	if UnitIsPlayer(self.unit) and UnitIsConnected(self.unit) then
		local _, const_class = UnitClass(self.unit);
		local r, g, b = GetClassColor(const_class)
		healthBar:SetStatusBarDesaturated(true)
		healthBar:SetStatusBarColor(r, g, b)
	elseif UnitIsPlayer(self.unit) and not UnitIsConnected(self.unit) then
		healthBar:SetStatusBarDesaturated(true)
		healthBar:SetStatusBarColor(1, 1, 1)
	elseif UnitIsConnected(self.unit) then
		healthBar:SetStatusBarDesaturated(true)
		healthBar:SetStatusBarColor(0, 1, 0)
	else
		healthBar:SetStatusBarDesaturated(false)
		healthBar:SetStatusBarColor(1, 1, 1)
	end
end
-- Class Frame colors // END

-- Raid Markers and Leader icons on Raid Frames
local icons = {}
local function PrepTextureRaidMarker(frame)
  local frameName = frame:GetName()
  if not icons[frameName] then
    return
  end
  icons[frameName].textureRM:ClearAllPoints()
  icons[frameName].textureRM:SetPoint("LEFT", 1, 0)
  icons[frameName].textureRM:SetWidth(20)
  icons[frameName].textureRM:SetHeight(20)
end

local function PrepTextureLeader(frame)
   frame.textureLeader = frame:CreateTexture(nil, "OVERLAY")
   frame.textureLeader:ClearAllPoints()
   frame.textureLeader:SetPoint("TOPLEFT", 1.5, 9)
   frame.textureLeader:SetWidth(15)
   frame.textureLeader:SetHeight(15)
end

local function SetupRaidMarks(unit, frame)
  local frameName = frame:GetName()
  local icon = GetRaidTargetIndex(unit)

  if not settingsDB.enableUpgradedRaidFrames and icons[frameName] ~= nil then
    icons[frameName].textureRM:Hide()
    return
  end

  if not icons[frameName] then
    icons[frameName] = {}
    icons[frameName].textureRM = frame:CreateTexture(nil, "OVERLAY")
    PrepTextureRaidMarker(frame)
  end
  if icon ~= icons[frameName].icon then
    icons[frameName].icon = icon
    if icon == nil then
      icons[frameName].textureRM:Hide()
    else
      icons[frameName].textureRM:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..icon)
      icons[frameName].textureRM:Show()
    end
  elseif icon == nil then
    icons[frameName].textureRM:Hide()
  else
    icons[frameName].textureRM:Show()
  end
end

local function SetupLeaderIcons(unit, frame)
  if not settingsDB.enableUpgradedRaidFrames and frame.textureLeader ~= nil then
    frame.textureLeader:Hide()
    return
  end

  if UnitIsGroupLeader(unit) then
    if frame.textureLeader == nil then
      PrepTextureLeader(frame)
    end
    frame.textureLeader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
    frame.textureLeader:Show()
  elseif UnitIsGroupAssistant(unit) then
    if frame.textureLeader == nil then
      PrepTextureLeader(frame)
    end
    frame.textureLeader:SetTexture("Interface\\GroupFrame\\UI-GROUP-ASSISTANTICON")
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

function UpgradeRaidFrames()
  if (CompactRaidFrameContainer:IsShown() and not CompactRaidFrameContainer:IsForbidden()) or (CompactPartyFrame:IsShown() and not CompactPartyFrame:IsForbidden()) then
		CompactRaidFrameContainer:ApplyToFrames("all", function(frame)
      UpdateIcons(frame)
    end)
	end
end
-- Raid Markers and Leader icons on Raid Frames // END
