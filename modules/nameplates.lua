function GigaSettingsInterface:CastTimerNameplate(nameplate)
  if not nameplate:IsForbidden() and not nameplate.UnitFrame.CastBarsContainer.castBar.timer then
    nameplate.UnitFrame.CastBarsContainer.castBar.timer = nameplate.UnitFrame.CastBarsContainer.castBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    local fontPath = nameplate.UnitFrame.CastBarsContainer.castBar.timer:GetFont()
    nameplate.UnitFrame.CastBarsContainer.castBar.timer:SetFont(fontPath, 13, "OUTLINE, SLUG")
    nameplate.UnitFrame.CastBarsContainer.castBar.timer:SetPoint("RIGHT", nameplate.UnitFrame.CastBarsContainer.castBar, "RIGHT", 0, 0)
    nameplate.UnitFrame.CastBarsContainer.castBar.timer:SetText("")
    nameplate.UnitFrame.CastBarsContainer.castBar:HookScript("OnValueChanged", function(self)
      if self.casting then
        self.timer:SetText(format("%2.1f/%1.1f", self:GetValue(), select(2, self:GetMinMaxValues())))
      elseif self.channeling then
        self.timer:SetText(format("%.1f", self:GetValue()))
      else
        self.timer:SetText("")
      end
    end)
  end
end

function GigaSettingsInterface:UpgradeFriendlyNameplates()
  if GigaSettingsDB.upgradedFriendlyNameplates then 
    local font, size, flags = SystemFont_NamePlate_Outlined:GetFont()
    SystemFont_NamePlate:SetFont(font, size, flags)
    SystemFont_NamePlateFixed:SetFont(font, size, flags)
    SystemFont_LargeNamePlate:SetFont(font, size, flags)
    SystemFont_LargeNamePlateFixed:SetFont(font, size, flags)
  end
end
