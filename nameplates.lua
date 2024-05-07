settingsDB = settingsDB or {}

local C_Timer = C_Timer


-- Health percent text
-- TODO: split into multiple options for only %, hptext or all
function HPTextNameplate(frame)
  if not frame:IsForbidden() and not frame.health then
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
  
  if not frame:IsForbidden() and frame.optionTable.colorNameBySelection then
    if(UnitIsFriend("player", frame.unit)) then
      frame.health.text:SetText(" ")
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
    frame.health.text:SetText(hpHealth .." ("..healthPercentage .. "%)")
  end
end
-- Health percent text // END

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
