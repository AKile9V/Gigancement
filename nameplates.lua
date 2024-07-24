settingsDB = settingsDB or {}
local GetNameplateByID = C_NamePlate.GetNamePlateForUnit

-- Health percent text
-- TODO: split into multiple options for only %, hptext or all
function HPTextNameplate(unit)
  local nameplate = GetNameplateByID(unit, issecure())
  local frame = nil
  if not nameplate or not nameplate.UnitFrame then
      nameplate = nil
      return
  end
  frame = nameplate.UnitFrame

  if frame and not frame.health then
    frame.health = CreateFrame("Frame", nil, frame)
    frame.health:SetSize(170, 16)
    frame.health.text = frame.health.text or frame.health:CreateFontString(nil, "OVERLAY")
    frame.health.text:SetAllPoints(true)
    frame.health:SetFrameStrata("FULLSCREEN")
    frame.health:SetPoint("CENTER", frame.healthBar, 0, 0)
    frame.health.text:SetVertexColor(1, 1, 1)
    frame.health.text:SetFont(STANDARD_TEXT_FONT, 6, "OUTLINE")
    frame.health.text:Show()
  end

  if frame and frame.optionTable.colorNameBySelection then
    if not settingsDB.enableHPTextFriendlyNameplate and UnitIsFriend("player", frame.unit) then
      frame.health.text:SetText(" ")
      frame.health.text:Hide()
      return
    end
    local healthPercentage = ("%.02f"):format(((UnitHealth(frame.displayedUnit) / UnitHealthMax(frame.displayedUnit) * 100)))
    local hpHealth = UnitHealth(frame.displayedUnit)
    if hpHealth >= 1e9 then
      hpHealth = string.format("%.1fB", hpHealth / 1e9)
    elseif hpHealth >= 1e6 then
      hpHealth = string.format("%.1fM", hpHealth / 1e6)
    elseif hpHealth >= 1e3 then
      hpHealth = string.format("%.1fK", hpHealth / 1e3)
    else
      hpHealth = UnitHealth(frame.displayedUnit)
    end
    local hpText = (settingsDB.formatHPText[3].value and (hpHealth .." ("..healthPercentage .. "%)")) or
                   (settingsDB.formatHPText[1].value and hpHealth) or
                   (settingsDB.formatHPText[2].value and (healthPercentage.."%"))
    frame.health.text:SetText(hpText)
    frame.health.text:Show()
  end
end
-- Health percent text // END

-- Cast time on Nameplate
function CastTimerNameplate(nameplate)
  if not nameplate:IsForbidden() and not nameplate.UnitFrame.castBar.timer then
    nameplate.UnitFrame.castBar.timer = nameplate.UnitFrame.castBar:CreateFontString(nil, "OVERLAY")
    nameplate.UnitFrame.castBar.timer:SetFont(STANDARD_TEXT_FONT,8,"OUTLINE")
    nameplate.UnitFrame.castBar.timer:SetPoint("LEFT", nameplate.UnitFrame.castBar, "RIGHT", -10, 0)
    nameplate.UnitFrame.castBar.timer:SetText("")
    nameplate.UnitFrame.castBar:HookScript("OnValueChanged", function(self)
      if self.casting then
        self.timer:SetText(format("%.1f", max(nameplate.UnitFrame.castBar.maxValue - nameplate.UnitFrame.castBar.value, 0)))
      elseif self.channeling then
        self.timer:SetText(format("%.1f", max(nameplate.UnitFrame.castBar.value, 0)))
      else
        self.timer:SetText("")
      end
    end)
  end
end
-- Cast time on Nameplate // END