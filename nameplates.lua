settingsDB = settingsDB or {}

-- Health percent text
-- TODO: split into multiple options for only %, hptext or all
function HPTextNameplate(frame)
  if frame.optionTable.colorNameBySelection and not frame:IsForbidden() then
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

    if not frame.health then
      frame.health = CreateFrame("Frame", nil, frame)
      frame.health:SetSize(170, 16)
      frame.health.text = frame.health.text or frame.health:CreateFontString(nil, "OVERLAY")
      frame.health.text:SetAllPoints(true)
      frame.health:SetFrameStrata("FULLSCREEN")
      frame.health:SetPoint("CENTER", frame.healthBar, 0, 0)
      frame.health.text:SetVertexColor(1, 1, 1)
      frame.health.text:SetFont(STANDARD_TEXT_FONT, 6, "OUTLINE")
    else
      frame.health.text:Show()
      frame.health.text:SetText(hpHealth .." ("..healthPercentage .. "%)")
    end
  end
end
-- Health percent text // END
