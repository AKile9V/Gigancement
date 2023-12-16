settingsDB = settingsDB or {}

-- Actionbar button texts
local mapKeybinds = {
	["Middle Mouse"] = "M3",
	["Mouse Wheel Down"] = "DWN",
	["Mouse Wheel Up"] = "UP",
	["Home"] = "Hm",
	["Insert"] = "Ins",
	["Page Down"] = "PD",
	["Page Up"] = "PU",
	["Spacebar"] = "SB",
}

local modPatterns = {
	["Mouse Button "] = "M", -- M4, M5
	["Num Pad "] = "N",
	["a%-"] = "A", -- alt
	["c%-"] = "C", -- ctrl
	["s%-"] = "S", -- shift
	["Mouse Wheel Down"] = "MD",
	["Mouse Wheel Up"] = "MU",
}

local function ShortenKeybinds(self, actionButtonType)
	local hotkey = self.HotKey
	local text = hotkey:GetText()
	for k, v in pairs(modPatterns) do
		text = text:gsub(k, v)
	end
	hotkey:SetText(mapKeybinds[text] or text)
end

function HandleShortenKeybinds()
	if not settingsDB.enableShorterKeybinds then
		return
	end
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		hooksecurefunc(_G["ActionButton"..i], "UpdateHotkeys", ShortenKeybinds)
		hooksecurefunc(_G["MultiBarBottomLeftButton"..i], "UpdateHotkeys", ShortenKeybinds)
		hooksecurefunc(_G["MultiBarBottomRightButton"..i], "UpdateHotkeys", ShortenKeybinds)
		hooksecurefunc(_G["MultiBarLeftButton"..i], "UpdateHotkeys", ShortenKeybinds)
		hooksecurefunc(_G["MultiBarRightButton"..i], "UpdateHotkeys", ShortenKeybinds)
		hooksecurefunc(_G["MultiBar5Button"..i], "UpdateHotkeys", ShortenKeybinds)
		hooksecurefunc(_G["MultiBar6Button"..i], "UpdateHotkeys", ShortenKeybinds)
		hooksecurefunc(_G["MultiBar7Button"..i], "UpdateHotkeys", ShortenKeybinds)
		hooksecurefunc(_G["PetActionButton"..((i <= 10) and i or 2)], "SetHotkeys", ShortenKeybinds)
	end
end

function ShouldHideActionbarButtonsText()
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		_G["ActionButton"..i.."HotKey"]:SetAlpha(settingsDB.enableHideKeybindText and 0 or 1)
		_G["MultiBarBottomLeftButton"..i.."HotKey"]:SetAlpha(settingsDB.enableHideKeybindText and 0 or 1)
		_G["MultiBarBottomRightButton"..i.."HotKey"]:SetAlpha(settingsDB.enableHideKeybindText and 0 or 1)
		_G["MultiBarLeftButton"..i.."HotKey"]:SetAlpha(settingsDB.enableHideKeybindText and 0 or 1)
		_G["MultiBarRightButton"..i.."HotKey"]:SetAlpha(settingsDB.enableHideKeybindText and 0 or 1)
		_G["MultiBar5Button"..i.."HotKey"]:SetAlpha(settingsDB.enableHideKeybindText and 0 or 1)
		_G["MultiBar6Button"..i.."HotKey"]:SetAlpha(settingsDB.enableHideKeybindText and 0 or 1)
		_G["MultiBar7Button"..i.."HotKey"]:SetAlpha(settingsDB.enableHideKeybindText and 0 or 1)
		_G["PetActionButton"..((i <= 10) and i or 2).."HotKey"]:SetAlpha(settingsDB.enableHideKeybindText and 0 or 1)

		_G["ActionButton"..i.."Name"]:SetAlpha(settingsDB.enableHideMacroText and 0 or 1)
		_G["MultiBarBottomLeftButton"..i.."Name"]:SetAlpha(settingsDB.enableHideMacroText and 0 or 1)
		_G["MultiBarBottomRightButton"..i.."Name"]:SetAlpha(settingsDB.enableHideMacroText and 0 or 1)
		_G["MultiBarLeftButton"..i.."Name"]:SetAlpha(settingsDB.enableHideMacroText and 0 or 1)
		_G["MultiBarRightButton"..i.."Name"]:SetAlpha(settingsDB.enableHideMacroText and 0 or 1)
		_G["MultiBar5Button"..i.."Name"]:SetAlpha(settingsDB.enableHideMacroText and 0 or 1)
		_G["MultiBar6Button"..i.."Name"]:SetAlpha(settingsDB.enableHideMacroText and 0 or 1)
		_G["MultiBar7Button"..i.."Name"]:SetAlpha(settingsDB.enableHideMacroText and 0 or 1)
		-- _G["PetActionButton"..((i <= 10) and i or 2).."Name"]:SetAlpha(settingsDB.enableHideMacroText and 0 or 1) -- cannot macro petactionbar
	end
end
-- Actionbar button texts // END
