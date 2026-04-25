local function CastbarSetText(castingFrame)
  if not castingFrame.timer then return end
  if castingFrame.casting then
    castingFrame.timer:SetText(format("%2.1f/%1.1f", castingFrame.CastTimeText and castingFrame.CastTimeText:GetText():match("[%d%.]+") or castingFrame.value, castingFrame.maxValue))
  elseif castingFrame.channeling then
    castingFrame.timer:SetText(format("%.1f", castingFrame.value))
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
   frame.textureLeader:SetPoint("BOTTOM", frame.roleIcon, "TOP", 0, -6)
   frame.textureLeader:SetWidth(20)
   frame.textureLeader:SetHeight(20)
   frame.textureLeader:SetVertexColor(0.95, 0.85, 0.1)
end

local function PrepStatusIndicator(frame)
   frame.statusIndicator = frame:CreateTexture(nil, "OVERLAY")
   frame.statusIndicator:ClearAllPoints()
   frame.statusIndicator:SetPoint("BOTTOM", frame.roleIcon, "BOTTOM", 0, -13)
   frame.statusIndicator:SetWidth(15)
   frame.statusIndicator:SetHeight(15)
end

local function SetupStatusIndicator(unit, frame)
  if not GigaSettingsDB.statusIndicators and frame.statusIndicator ~= nil then
    frame.statusIndicator:Hide()
    return
  end

  if frame.statusIndicator ~= nil then
    frame.statusIndicator:Hide()
  end

  local isAFK = UnitIsAFK(unit)
  isAFK = issecretvalue and not issecretvalue(isAFK) and isAFK or false
  local isDND = UnitIsDND(unit)
  isDND = issecretvalue and not issecretvalue(isDND) and isDND or false
  local isOffline = not UnitIsConnected(unit)
  isOffline = issecretvalue and not issecretvalue(isOffline) and isOffline or false
  local isDead = UnitIsDeadOrGhost(unit)
  isDead = issecretvalue and not issecretvalue(isDead) and isDead or false
  local isInCombat = UnitAffectingCombat(unit)
  isInCombat = issecretvalue and not issecretvalue(isInCombat) and isInCombat or false
  
  if isAFK or isDND or isOffline or isDead or isInCombat then
    if not frame.statusIndicator then
      PrepStatusIndicator(frame)
    end
    frame.statusIndicator:SetAtlas(isAFK and "activities-clock-standard" or isDND and "activities-clock-ineligible" 
    or isOffline and "activities-clock-disabled" or isDead and "poi-soulspiritghost" or isInCombat and "questlog-questtypeicon-pvp")
    frame.statusIndicator:Show()
  end
end

local function SetupLeaderIcons(unit, frame)
  if not GigaSettingsDB.leaderIcons and frame.textureLeader ~= nil then
    frame.textureLeader:Hide()
    return
  end

  if frame.textureLeader ~= nil then
    frame.textureLeader:Hide()
  end

  local isGroupLeader = UnitIsGroupLeader(unit)
  local isGroupAssistant = UnitIsGroupAssistant(unit)
  if isGroupLeader or (isGroupAssistant and CompactRaidFrameContainer:IsShown()) then
    if not frame.textureLeader then
      PrepTextureLeader(frame)
    end
    frame.textureLeader:SetAtlas(isGroupLeader and "GO-icon-Lead-Applied" or "GO-icon-Header-Assist-Applied")
    frame.textureLeader:Show()
  end
end

local function SetupRaidMarks(unit, frame)
  local frameName = frame:GetName()
  local markId = GetRaidTargetIndex(unit)

  if not GigaSettingsDB.raidMarks and icons[frameName] ~= nil then
    icons[frameName].textureRM:Hide()
    return
  elseif icons[frameName] ~= nil then
    icons[frameName].textureRM:Hide()
  end

  if not icons[frameName] then
    icons[frameName] = frame
    icons[frameName].textureRM = frame:CreateTexture(nil, "OVERLAY")
    PrepTextureRaidMarker(frame)
  end

  if type(markId) ~= "nil" then
    SetRaidTargetIconTexture(icons[frameName].textureRM, markId)
    icons[frameName].textureRM:Show()
  end
end

local function UpdateIcons(frame)
   local unit = frame.unit
   if not unit or not GigaSettingsDB.upgradedRaidFrames then
      return
   end

   SetupRaidMarks(unit, frame)
   SetupLeaderIcons(unit, frame)
   SetupStatusIndicator(unit, frame)
end

function GigaSettingsInterface:UpgradeRaidFrames()
  if (CompactRaidFrameContainer:IsShown() and not CompactRaidFrameContainer:IsForbidden()) or (CompactPartyFrame:IsShown() and not CompactPartyFrame:IsForbidden()) then
		CompactRaidFrameContainer:ApplyToFrames("all", function(frame)
      C_Timer.After(0, function() UpdateIcons(frame) end)
    end)
	end
end

local function GetPlayerMapCoords()
  local uiMapId = C_Map.GetBestMapForUnit("player")
  if (uiMapId == nil) then
    return ""
  end
  local xy = C_Map.GetPlayerMapPosition(uiMapId, "player")
  if (xy == nil) then
    return ""
  else
    local x, y = xy:GetXY()
    return format("%.2f, %.2f",x*100, y*100)
  end
end

local playerMinimapCoordsTicker = nil
function GigaSettingsInterface:PlayerMinimapCoords()
  if not GigaSettingsDB.playerMinimapCoords or IsInInstance() then
    if playerMinimapCoordsTicker then playerMinimapCoordsTicker:Cancel() Minimap.GigaPlayerCoords:SetText("") end
    playerMinimapCoordsTicker = nil  
    return
  end

  if not Minimap.GigaPlayerCoords then
    Minimap.GigaPlayerCoords = Minimap:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    Minimap.GigaPlayerCoords:SetPoint("TOP", Minimap, "TOP", 0, -12)
  end
  playerMinimapCoordsTicker = C_Timer.NewTicker(0.3, function()
      Minimap.GigaPlayerCoords:SetText(GetPlayerMapCoords())
    end)
end

local cursorRingFrame = nil
function GigaSettingsInterface:CursorRing()
  if not GigaSettingsDB.cursorRing then
    if cursorRingFrame then
      cursorRingFrame:Hide()
      cursorRingFrame:SetScript("OnUpdate", nil)
    end
    return
  end

  if not cursorRingFrame then
    cursorRingFrame = CreateFrame("Frame", nil, UIParent)
    cursorRingFrame.texture = cursorRingFrame:CreateTexture(nil, "ARTWORK")
    cursorRingFrame.texture:SetAllPoints()
  end

  local size = GigaSettingsDB.cursorRingSize * 100
  cursorRingFrame:SetSize(size, size)
  cursorRingFrame.texture:SetAtlas(GigaSettingsDB.cursorRingTexture)
  cursorRingFrame:Show()
  local scale = UIParent:GetEffectiveScale()
    
  cursorRingFrame:SetScript("OnUpdate", function(self, elapsed)
    local x, y = GetCursorPosition()
    local s = self:GetEffectiveScale() 
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / s, y / s)
  end)
end
