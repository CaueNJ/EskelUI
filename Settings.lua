
local checkboxes = 0
local settings = {
    {
        settingText = "Enable tracking of Kills",
        settingKey = "enableKillTracking",
        settingTooltip = "While enabled, your kills will be tracked.",
    },
    {
        settingText = "Enable tracking of Currency",
        settingKey = "enableCurrencyTracking",
        settingTooltip = "While enabled, your currency gained will be tracked.",
    },
}

local settingsFrame = CreateFrame("Frame", "EskelUISettingsFrame", UIParent, "BasicFrameTemplateWithInset")
settingsFrame:SetSize(400, 300)
settingsFrame:SetPoint("CENTER")
settingsFrame.TitleBg:SetHeight(30)
settingsFrame.title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
settingsFrame.title:SetPoint("CENTER", settingsFrame.TitleBg, "CENTER", 0, -3)
settingsFrame.title:SetText("EskelUI Settings")
settingsFrame:Hide()
settingsFrame:EnableMouse(true)
settingsFrame:SetMovable(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)

settingsFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

local function CreateCheckbox(checkboxText, key, checkboxTooltip)
    local checkbox = CreateFrame("CheckButton", "MyAddonCheckboxID" .. checkboxes, settingsFrame, "UICheckButtonTemplate")
    checkbox.Text:SetText(checkboxText)
    checkbox:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 10, -30 + (checkboxes * -30))

    if EskelUIDB.settingsKeys[key] == nil then
        EskelUIDB.settingsKeys[key] = true
    end

    checkbox:SetChecked(EskelUIDB.settingsKeys[key])

    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(checkboxTooltip, nil, nil, nil, nil, true)
    end)

    checkbox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    checkbox:SetScript("OnClick", function(self)
        EskelUIDB.settingsKeys[key] = self:GetChecked()
    end)

    checkboxes = checkboxes + 1

    return checkbox
end

local eventListenerFrame = CreateFrame("Frame", "EskelUISettingsEventListenerFrame", UIParent)

eventListenerFrame:RegisterEvent("PLAYER_LOGIN")

eventListenerFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if not EskelUIDB.settingsKeys then
            EskelUIDB.settingsKeys = {}
        end

        for _, setting in pairs(settings) do
            CreateCheckbox(setting.settingText, setting.settingKey, setting.settingTooltip)
        end
    end
end)

local addon = LibStub("AceAddon-3.0"):NewAddon("EskelUI")
EskelUIMinimapButton = LibStub("LibDBIcon-1.0", true)

local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("EskelUI", {
	type = "data source",
	text = "EskelUI",
	icon = "Interface\\AddOns\\EskelUI\\minimap.tga",
	OnClick = function(self, btn)
        if btn == "LeftButton" then
		    EskelUI:ToggleMainFrame()
        elseif btn == "RightButton" then
            if settingsFrame:IsShown() then
                settingsFrame:Hide()
            else
                settingsFrame:Show()
            end
        end
	end,

	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then
			return
		end

		tooltip:AddLine("EskelUI\n\nLeft-click: Open EskelUI\nRight-click: Open EskelUI Settings", nil, nil, nil, nil)
	end,
})

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("EskelUI", {
		profile = {
			minimap = {
				hide = false,
			},
		},
	})

	EskelUIMinimapButton:Register("EskelUI", miniButton, self.db.profile.minimap)
end

EskelUIMinimapButton:Show("EskelUI")