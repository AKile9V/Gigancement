local GetNameplateByID = C_NamePlate.GetNamePlateForUnit

function GigaSettingsInterface:CastTimerNameplate(nameplate)
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
