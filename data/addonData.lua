GigaSettingsInterface = CreateFrame("Frame")
GigaSettingsDB = GigaSettingsDB or {}
GigaAddon = {
    GigaData = {
        addonName = "Gigancement",
        categoryID = nil,
        reopenOptions = {
            key = "reopenOptions",
            default = false,
        },
        disableLGMessage = {
            key = "disableLGMessage",
            default = false,
        },
        currentInspec = {
            key = "currentInspec",
            default = nil,
        },
        characterInfoFlag = {
            key = "characterInfoFlag",
            default = false,
            callback = function()
                local flag = GigaSettingsDB.characterILVLInfo or GigaSettingsDB.characterEnchantsInfo or GigaSettingsDB.characterGemsInfo
                GigaSettingsInterface:ToggleEventRegister("INSPECT_READY", flag)
                GigaSettingsInterface:ToggleEventRegister("UNIT_INVENTORY_CHANGED", flag)
                GigaSettingsInterface:ToggleEventRegister("PLAYER_EQUIPMENT_CHANGED", flag)
                GigaSettingsInterface:ToggleEventRegister("ENCHANT_SPELL_COMPLETED", flag)
                GigaSettingsInterface:ToggleEventRegister("SOCKET_INFO_UPDATE", flag)
                GigaSettingsDB.characterInfoFlag = GigaSettingsDB.characterInfoFlag or flag
                GigaSettingsInterface:UpdateAllEquipmentSlots("player")
                GigaSettingsDB.characterInfoFlag = flag
                if not GigaSettingsDB.characterInfoFlag then
                    GigaAddon.GigaData.checkbox_characterILVLInfo.needReload = true
                    GigaAddon.GigaData.checkbox_characterEnchantsInfo.needReload = true
                    GigaAddon.GigaData.checkbox_characterGemsInfo.needReload = true
                end
            end,
        },
        lastBuiltElement = nil,
        header_nameplateModuleTitle = {
            key = "nameplateModuleTitle",
            name = "Nameplate",
        },
        checkbox_castTimerNameplate = {
            key = "castTimerNameplate",
            default = false,
            disable = false,
            needReload = true,
            name = "Cast Time on Nameplates",
            tooltip = "Show cast bar timer on all nameplates.\n|cffFF0000Reload|r required.",
            firstEle = true,
        },
        header_actionbarModuleTitle = {
            key = "actionbarModuleTitle",
            name = "Action Bar",
        },
        checkbox_shorterKeybinds = {
            key = "shorterKeybinds",
            default = false,
            disable = false,
            needReload = true,
            name = "Shorter Keybind Names",
            tooltip = "Show keybinds like S1, A1, M1 instead of s-1, a-1, Mouse...\n|cffFF0000Reload|r required.",
            firstEle = true,
        },
        checkbox_hideKeybindText = {
            key = "hideKeybindText",
            default = false,
            disable = false,
            callback = function() GigaSettingsInterface:ShouldHideActionbarButtonsText() end,
            name = "Hide Keybind Text",
            tooltip = "Hide keybind text from all action bar buttons.",
        },
        checkbox_hideMacroText = {
            key = "hideMacroText",
            default = false,
            disable = false,
            callback = function() GigaSettingsInterface:ShouldHideActionbarButtonsText() end,
            name = "Hide Macro Text",
            tooltip = "Hide macro text from all action bar buttons.",
        },
        header_chatModuleTitle = {
            key = "chatModuleTitle",
            name = "Chat",
        },
        checkbox_linksInChat = {
            key = "linksInChat",
            default = false,
            disable = false,
            callback = function() GigaSettingsInterface["linksInChat"].checkboxControl.colorswatch:SetEnabled(GigaSettingsDB.linksInChat) end,
            name = "Links in Chat",
            tooltip = "Make chat links clickable for copy.",
            firstEle = true,
        },
        colorswatch_linksInChatColor = {
            key = "linksInChatColor",
            default = "ff00b3ff",
            dependency = "linksInChat",
            name = "Link Color",
            tooltip = "Choose the link color.",
        },
        checkbox_rolesInChat = {
            key = "rolesInChat",
            default = false,
            disable = false,
            name = "Roles in Chat",
            tooltip = "Show |A:GM-icon-role-tank:20:20|a, |A:GM-icon-role-healer:20:20|a or |A:GM-icon-role-dps:20:20|a roles next to player names in chat.",
        },
        checkbox_shorterChannelNames = {
            key = "shorterChannelNames",
            default = false,
            disable = false,
            name = "Shorter Default Channel Names",
            tooltip = "[R] for [Raid], [P] for [Party], etc.",
        },
        checkbox_chatMouseoverItemTooltip = {
            key = "chatMouseoverItemTooltip",
            default = false,
            disable = false,
            name = "Chat Mouseover Tooltips",
            tooltip = "Hover over items/mounts/pets/achievements in chat to show tooltip.",
        },
        header_lfgModuleTitle = {
            key = "lfgModuleTitle",
            name = "LFG",
        },
        checkbox_inspectLFG = {
            key = "inspectLFG",
            default = false,
            disable = true,
            needReload = true,
            name = "Inspect Groups in Tooltip",
            tooltip = "Mouseover premade groups to view leader and all roles/specs. Ignores M+ groups (Blizzard added in 10.2.7).\n|cffFF0000Reload|r required.",
            firstEle = true,
        },
        checkbox_doubleClickLFG = {
            key = "doubleClickLFG",
            default = false,
            disable = false,
            callback = function() GigaSettingsInterface:ToggleEventRegister("LFG_LIST_SEARCH_RESULTS_RECEIVED", GigaSettingsDB.doubleClickLFG) end,
            name = "Double-click Sign Up",
            tooltip = "Double left click to sign up for a premade group.",
        },
        checkbox_skipRoleCheck = {
            key = "skipRoleCheck",
            default = false,
            disable = false,
            name = "Auto Role Check and\nSkip the Note Popup",
            tooltip = "Auto-accept role check for group sign-ups and skip notes. Hold |cff00FF00Shift|r to include a note.",
        },
        checkbox_muteApplicantSound = {
            key = "muteApplicantSound",
            default = false,
            disable = false,
            callback = function() GigaSettingsInterface:MuteApplicationSignupSound() end,
            name = "Silence Application Sound",
            tooltip = "Turn off sign-up alert sound when creating a group.",
        },
        checkbox_applicantRaceTooltip = {
            key = "applicantRaceTooltip",
            default = false,
            disable = false,
            needReload = true,
            name = "Show Applicant Race",
            tooltip = "Show applicant race in LFG tooltip under applicant name.\n|cffFF0000Reload|r required.",
        },
        checkbox_sortApplicants = {
            key = "sortApplicants",
            default = false,
            disable = false,
            needReload = true,
            name = "Sort Applicants by Rating",
            tooltip = "Sort applicants by Mythic+ score.\n|cffFF0000Reload|r required.",
        },
        header_uiModuleTitle = {
            key = "uiModuleTitle",
            name = "UI",
        },
        checkbox_upgradedCastbar = {
            key = "upgradedCastbar",
            default = false,
            disable = false,
            needReload = true,
            callback = function()
                GigaSettingsInterface["castTimePosition"].dropdownControl:SetEnabled(GigaSettingsDB["upgradedCastbar"])
                GigaSettingsInterface["castTimePosition"].Label:SetFontObject(GigaSettingsDB["upgradedCastbar"] and "GameFontNormalSmall" or "GameFontDisableSmall")
            end,
            name = "Upgrade Default Castbar",
            tooltip = "Show spell icon and remaining/total cast time on Player, Target and Focus casting bars.\n|cffFF0000Reload|r required.",
            firstEle = true,
        },
        dropdown_castTimePosition = {
            key = "castTimePosition",
            default = "BOTTOM",
            dependency = "upgradedCastbar",
            disable = false,
            callback = function() GigaSettingsInterface:UpgradeDefaultCastbar(GigaSettingsDB.castTimePosition) end,
            data = {
                [1] = {
                    value = "BOTTOMLEFT",
                    text = "Left",
                },
                [2] = {
                    value = "BOTTOM",
                    text = "Center",
                },
                [3] = {
                    value = "BOTTOMRIGHT",
                    text = "Right",
                },
            },
            name = "Castbar Text Position",
            tooltip = "Set cast time text position.",
        },
        checkbox_classColorsUnitFrames = {
            key = "classColorsUnitFrames",
            default = false,
            disable = false,
            needReload = true,
            name = "Class Color Unit Frames",
            tooltip = "Apply class colors to Blizzard Unit Frames (Player, Pet, Target, Focus).\n|cffFF0000Reload|r required.",
        },
        header_characterInfoTitle = {
            key = "characterInfoTitle",
            name = "Character Info",
            firstEle = true,
        },
        checkbox_decimalILVL = {
            key = "decimalILVL",
            default = false,
            disable = false,
            name = "Equipped/Max Item Level",
            tooltip = "Show |cffa335eeequipped/maximum|r item level with two decimals.",
            firstEle = true,
        },
        checkbox_classColorILVL = {
            key = "classColorILVL",
            default = false,
            disable = false,
            name = "Class Color Equipped Item Level",
            tooltip = "Show |c"..RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr.."ilvl|r in class color.",
        },

        checkbox_characterILVLInfo = {
            key = "characterILVLInfo",
            default = false,
            disable = false,
            needReload = false,
            callback = function() GigaAddon.GigaData["characterInfoFlag"].callback() end,
            name = "Show Item Level",
            tooltip = "Show item level for each equipment slot in Character and Inspect frames.",
        },
        checkbox_characterEnchantsInfo = {
            key = "characterEnchantsInfo",
            default = false,
            disable = false,
            needReload = false,
            callback = function() GigaAddon.GigaData["characterInfoFlag"].callback() end,
            name = "Show Enchants",
            tooltip = "Show enchants for each equipment slot in Character and Inspect frames.",
        },
        checkbox_characterGemsInfo = {
            key = "characterGemsInfo",
            default = false,
            disable = false,
            needReload = false,
            callback = function() GigaAddon.GigaData["characterInfoFlag"].callback() end,
            name = "Show Gems",
            tooltip = "Show gems for each equipment slot in Character and Inspect frames.",
        },
        checkbox_playerMinimapCoords = {
            key = "playerMinimapCoords",
            default = false,
            disable = false,
            callback = function() GigaSettingsInterface:PlayerMinimapCoords() end,
            name = "Minimap X-Y coordinates",
            tooltip = "Show the player's current coordinates on the Minimap frame. Automatically disabled inside instances.",
        },
        checkbox_cursorRing = {
            key = "cursorRing",
            default = false,
            disable = false,
            callback = function()
                GigaSettingsInterface:CursorRing()
                GigaSettingsInterface["cursorRingTexture"].dropdownControl:SetEnabled(GigaSettingsDB["cursorRing"])
                GigaSettingsInterface["cursorRingTexture"].Label:SetFontObject(GigaSettingsDB["cursorRing"] and "GameFontNormalSmall" or "GameFontDisableSmall")
            end,
            name = "Ring Cursor",
            tooltip = "Highlight the mouse cursor with a ring.",
        },
        dropdown_cursorRingTexture = {
            key = "cursorRingTexture",
            default = "talents-animations-mask-heroclass-ring",
            dependency = "cursorRing",
            disable = false,
            callback = function() GigaSettingsInterface:CursorRing() end,
            data = {
                [1] = {
                    value = "talents-animations-mask-heroclass-ring",
                    text = "Simple White",
                },
                [2] = {
                    value = "Adventures-Buff-Heal-Ring",
                    text = "Soft Neon White",
                },
                [3] = {
                    value = "ItemUpgrade_FX_FrameDecor_Ring",
                    text = "Bright Neon White",
                },
            },
            name = "Ring Texture",
            tooltip = "Select the ring appearance.",
        },
        checkbox_groupFormingText = {
            key = "groupFormingText",
            default = false,
            disable = false,
            callback = function()
                GigaSettingsInterface:ToggleEventRegister("LFG_LIST_APPLICANT_UPDATED", GigaSettingsDB.groupFormingText)
                GigaSettingsInterface:ToggleGroupFormingText()
            end,
            name = "Hide Group Forming Text",
            tooltip = "Hide the \"Your group is currently forming.\" message so you can mouseover the applicants when you are not the group leader.",
        },
        dropdown_upgradedRaidFrames = {
            key = "upgradedRaidFrames",
            default = false,
            disable = false,
            needReload = false,
            new = true,
            callback = function()
                local flag = GigaSettingsDB.leaderIcons or GigaSettingsDB.raidMarks or GigaSettingsDB.statusIndicators or false
                GigaSettingsInterface:ToggleEventRegister("DISPLAY_SIZE_CHANGED", flag)
                GigaSettingsInterface:ToggleEventRegister("UI_SCALE_CHANGED", flag)
                GigaSettingsInterface:ToggleEventRegister("GROUP_ROSTER_UPDATE", flag)
                GigaSettingsInterface:ToggleEventRegister("UPDATE_ACTIVE_BATTLEFIELD", flag)
                GigaSettingsInterface:ToggleEventRegister("UNIT_FLAGS", flag)
                GigaSettingsInterface:ToggleEventRegister("PLAYER_FLAGS_CHANGED", flag)
                GigaSettingsInterface:ToggleEventRegister("PARTY_LEADER_CHANGED", flag)
                GigaSettingsInterface:ToggleEventRegister("RAID_TARGET_UPDATE", flag)
                GigaSettingsInterface:ToggleEventRegister("PLAYER_DIFFICULTY_CHANGED", flag)
                GigaSettingsInterface:ToggleEventRegister("PLAYER_ROLES_ASSIGNED", flag)
                GigaSettingsDB.upgradedRaidFrames = GigaSettingsDB.upgradedRaidFrames or flag
                GigaSettingsInterface:UpgradeRaidFrames()
                GigaSettingsDB.upgradedRaidFrames = flag
                if not GigaSettingsDB.upgradedRaidFrames then
                    GigaAddon.GigaData.dropdown_upgradedRaidFrames.needReload = true
                end
            end,
            data = {
                [1] = {
                    value = "leaderIcons",
                    text = "Leader & Co-Leader",
                },
                [2] = {
                    value = "raidMarks",
                    text = "Raid Marks",
                },
                [3] = {
                    value = "statusIndicators",
                    text = "Status Indicators",
                },
            },
            name = "Upgrade Default Raid Frames",
            tooltip = "Enhance default Blizzard Raid Frames with additional icon indicators to improve information visibility.\n\n"
            ..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Leader & Co-Leader:").." |A:GO-icon-Lead-Applied:20:20|a|A:GO-icon-Header-Assist-Applied:20:20|a\n\n"
            ..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Raid Marks:").." |A:GM-raidMarker1:20:20|a|A:GM-raidMarker2:20:20|a |A:GM-raidMarker3:20:20|a|A:GM-raidMarker4:20:20|a|A:GM-raidMarker5:20:20|a|A:GM-raidMarker6:20:20|a |A:GM-raidMarker7:20:20|a|A:GM-raidMarker8:20:20|a\n\n"
            ..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Status Indicators:").."\nAFK: |A:activities-clock-standard:15:15|a\nDND: |A:activities-clock-ineligible:15:15|a\nOffline: |A:activities-clock-disabled:15:15|a\nDead: |A:poi-soulspiritghost:15:15|a\nIn Combat: |A:questlog-questtypeicon-pvp:20:20|a",
        },
    }
}
