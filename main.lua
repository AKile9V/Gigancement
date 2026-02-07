local GetNameplateByID = C_NamePlate.GetNamePlateForUnit

local function HandleLFGHooks()
    if GigaSettingsDB.inspectLFG then
        hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", GigaSettingsInterface.SetupLFGTooltip)
    end
    if GigaSettingsDB.applicantRaceTooltip then
        hooksecurefunc("LFGListApplicantMember_OnEnter", GigaSettingsInterface.AddApplicantRaceInTooltip)
    end
    if GigaSettingsDB.sortApplicants then
        LFGListUtil_SortApplicants = GigaSettingsInterface.SortApplicantsByRating
    end
end

local function UntriggerDisabledEvents()
    if not GigaSettingsDB.castTimerNameplate then
        GigaSettingsInterface:UnregisterEvent("UNIT_SPELLCAST_START")
        GigaSettingsInterface:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    end
    if not GigaSettingsDB.classColorsUnitFrames then
        GigaSettingsInterface:UnregisterEvent("PLAYER_TARGET_CHANGED")
        GigaSettingsInterface:UnregisterEvent("PLAYER_FOCUS_CHANGED")
    end
    if not GigaSettingsDB.characterInfoFlag then
        GigaSettingsInterface:UnregisterEvent("INSPECT_READY")
        GigaSettingsInterface:UnregisterEvent("UNIT_INVENTORY_CHANGED")
        GigaSettingsInterface:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
        GigaSettingsInterface:UnregisterEvent("ENCHANT_SPELL_COMPLETED")
        GigaSettingsInterface:UnregisterEvent("SOCKET_INFO_UPDATE")
    end
end

GigaSettingsInterface:RegisterEvent("ADDON_LOADED")
GigaSettingsInterface:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
GigaSettingsInterface:RegisterEvent("DISPLAY_SIZE_CHANGED")
GigaSettingsInterface:RegisterEvent("UI_SCALE_CHANGED")
GigaSettingsInterface:RegisterEvent("GROUP_ROSTER_UPDATE")
GigaSettingsInterface:RegisterEvent("UPDATE_ACTIVE_BATTLEFIELD")
GigaSettingsInterface:RegisterEvent("UNIT_FLAGS")
GigaSettingsInterface:RegisterEvent("PLAYER_FLAGS_CHANGED")
GigaSettingsInterface:RegisterEvent("PARTY_LEADER_CHANGED") 
GigaSettingsInterface:RegisterEvent("RAID_TARGET_UPDATE")
GigaSettingsInterface:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
GigaSettingsInterface:RegisterEvent("PLAYER_ROLES_ASSIGNED")
GigaSettingsInterface:RegisterEvent("PLAYER_ENTERING_WORLD")
GigaSettingsInterface:RegisterEvent("UNIT_SPELLCAST_START")
GigaSettingsInterface:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
GigaSettingsInterface:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
GigaSettingsInterface:RegisterEvent("INSPECT_READY")
GigaSettingsInterface:RegisterEvent("UNIT_INVENTORY_CHANGED")
GigaSettingsInterface:RegisterEvent("PLAYER_TARGET_CHANGED")
GigaSettingsInterface:RegisterEvent("PLAYER_FOCUS_CHANGED")
GigaSettingsInterface:RegisterEvent("ENCHANT_SPELL_COMPLETED")
GigaSettingsInterface:RegisterEvent("SOCKET_INFO_UPDATE")
GigaSettingsInterface:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "Gigancement" then
        GigaSettingsInterface:BuildAddonOptionsMenu()
        -- Enable modules
        GigaSettingsInterface:HandleShortenKeybinds()
        GigaSettingsInterface:ShouldHideActionbarButtonsText()
        GigaSettingsInterface:LinksInChat()
        GigaSettingsInterface:ChatFramesModifications() -- ShortChannelNames & MouseoverItemTooltip
        GigaSettingsInterface:UpgradeDefaultCastbar(GigaSettingsDB.castTimePosition)
        GigaSettingsInterface:MuteApplicationSignupSound()
        GigaSettingsInterface:CursorRing()
        HandleLFGHooks()
        UntriggerDisabledEvents()
        EventRegistry:RegisterCallback("CharacterFrame.Show", function()
            C_Timer.After(0, function() GigaSettingsInterface:UpdateAllEquipmentSlots("player") end)
        end)
    elseif event == "PLAYER_ENTERING_WORLD" then
        GigaSettingsInterface:PlayerMinimapCoords()
        if GigaSettingsDB.classColorsUnitFrames then
            GigaSettingsInterface:UnitFrameClassColor("player", PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar)
            GigaSettingsInterface:UnitFrameClassColor("player", PetFrameHealthBar)
        end
        if arg1==true then
            C_Timer.After(0, function() GigaSettingsInterface:UpdateAllEquipmentSlots("player") end)
    end
    elseif event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" then
        GigaSettingsInterface:LFGDoubleClick()
    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        local nameplate = GetNameplateByID(arg1)
        if not nameplate then return end
        GigaSettingsInterface:CastTimerNameplate(nameplate)
    elseif event == "PLAYER_EQUIPMENT_CHANGED" and arg1 ~= nil then
        GigaSettingsInterface:UpdateEquipmentSlot("player", arg1)
    elseif event == "UNIT_INVENTORY_CHANGED" and arg1 ~= nil then
        if (UnitGUID(arg1) ~= UnitGUID("player") and GigaSettingsDB.currentInspec~= nil and GigaSettingsDB.currentInspec == UnitGUID(arg1)) then
            C_Timer.After(0, function() GigaSettingsInterface:UpdateAllEquipmentSlots(arg1) end)
        end
    elseif event == "ENCHANT_SPELL_COMPLETED" and arg1==true and arg2 and arg2.equipmentSlotIndex then
        C_Timer.After(0.5, function() GigaSettingsInterface:UpdateEquipmentSlot("player", arg2.equipmentSlotIndex) end)
    elseif event == "SOCKET_INFO_UPDATE" then
        GigaSettingsInterface:UpdateEquipmentSlot("player", 1)
        GigaSettingsInterface:UpdateEquipmentSlot("player", 2)
        GigaSettingsInterface:UpdateEquipmentSlot("player", 6)
        GigaSettingsInterface:UpdateEquipmentSlot("player", 9)
        GigaSettingsInterface:UpdateEquipmentSlot("player", 11)
        GigaSettingsInterface:UpdateEquipmentSlot("player", 12)
    elseif event == "INSPECT_READY" then
        if not _G.InspectFrame or not _G.InspectFrame.unit then return end
        local unit = _G.InspectFrame.unit
        GigaSettingsDB.currentInspec = UnitGUID(unit or "target")
        C_Timer.After(0, function() GigaSettingsInterface:UpdateAllEquipmentSlots(unit or "target") end)
    elseif event == "PLAYER_TARGET_CHANGED" then
        GigaSettingsInterface:UnitFrameClassColor("target", TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar)
    elseif event == "PLAYER_FOCUS_CHANGED" then
        GigaSettingsInterface:UnitFrameClassColor("focus", FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar)
    else
        GigaSettingsInterface:UpgradeRaidFrames()
    end

end)
