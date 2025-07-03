
EskelUI = EskelUI or {}

if not EskelUIDB then
    EskelUIDB = {}
end

-- Main frame code --
    local mainFrame = CreateFrame("Frame", "EskelUIMainFrame", UIParent, "BasicFrameTemplateWithInset")
    mainFrame:SetSize(500, 350)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    mainFrame.TitleBg:SetHeight(30)
    mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    mainFrame.title:SetPoint("TOPLEFT", mainFrame.TitleBg, "TOPLEFT", 5, -3)
    mainFrame.title:SetText("EskelUI")
    mainFrame:Hide()
    mainFrame:EnableMouse(true)
    mainFrame:SetMovable(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    mainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    mainFrame:SetScript("OnShow", function()
            PlaySound(808)
    end)

    mainFrame:SetScript("OnHide", function()
            PlaySound(808)
    end)

    table.insert(UISpecialFrames, "EskelUIMainFrame")
---------------------

-- Main frame content --
    -- Character name
    mainFrame.playerName = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.playerName:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -35)
    mainFrame.playerName:SetText("Character: " .. UnitName("player") .. " (Level " .. UnitLevel("player") .. ")")
    --

    -- Total Kills
    mainFrame.totalPlayerKills = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.totalPlayerKills:SetPoint("TOPLEFT", mainFrame.playerName, "BOTTOMLEFT", 0, -10)
    mainFrame.totalPlayerKills:SetText("Total Kills: " .. (EskelUIDB.kills or "0"))
    --

    -- Total Gold Gathered
    mainFrame.totalCurrency = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.totalCurrency:SetPoint("TOPLEFT", mainFrame.totalPlayerKills, "BOTTOMLEFT", 0, -10)
    mainFrame.totalCurrency:SetText("Gold: " .. (EskelUIDB.gold or "0") .. " Silver: " .. (EskelUIDB.silver or "0") .. " Copper: " .. (EskelUIDB.copper or "0"))
    --

    mainFrame:SetScript("OnShow", function()
        PlaySound(808)
        mainFrame.totalPlayerKills:SetText("Total Kills: " .. (EskelUIDB.kills or "0"))
        mainFrame.totalCurrency:SetText("Gold: " .. (EskelUIDB.gold or "0") .. " Silver: " .. (EskelUIDB.silver or "0") .. " Copper: " .. (EskelUIDB.copper or "0"))
    end)    

------------------------

-- Addon chat commands --
    SLASH_ESKEL1 = "/eskel"
    SlashCmdList["ESKEL"] = function()
        if mainFrame:IsShown() then
            mainFrame:Hide()
        else
            mainFrame:Show()
        end
    end
-------------------------

-- Event Listener eventListenerFrame --
    local eventListenerFrame = CreateFrame("Frame", "EskelUIEventListenerFrame", UIParent)
    
    local function eventHandler(self, event, ...)
        local _, eventType = CombatLogGetCurrentEventInfo()

        if event == "COMBAT_LOG_EVENT_UNFILTERED" and EskelUIDB.settingsKeys.enableKillTracking then
            if eventType and eventType == "PARTY_KILL" then
                if not EskelUIDB.kills then
                    EskelUIDB.kills = 1
                else
                    EskelUIDB.kills = EskelUIDB.kills + 1
                end
            end

        elseif event == "CHAT_MSG_MONEY" and EskelUIDB.settingsKeys.enableCurrencyTracking then
            local msg = ...
            local gold = tonumber(string.match(msg, "(%d+) Gold")) or 0
            local silver = tonumber(string.match(msg, "(%d+) Silver")) or 0
            local copper = tonumber(string.match(msg, "(%d+) Copper")) or 0

            EskelUIDB.gold = (EskelUIDB.gold or 0) + gold
            EskelUIDB.silver = (EskelUIDB.silver or 0) + silver
            EskelUIDB.copper = (EskelUIDB.copper or 0) + copper

            if EskelUIDB.copper >= 100 then
                EskelUIDB.silver = EskelUIDB.silver + math.floor(EskelUIDB.copper / 100)
                EskelUIDB.copper = EskelUIDB.copper % 100
            end

            if EskelUIDB.silver >= 100 then
                EskelUIDB.gold = EskelUIDB.gold + math.floor(EskelUIDB.silver / 100)
                EskelUIDB.silver = EskelUIDB.silver % 100
            end            
        end

        if mainFrame:IsShown() then
            mainFrame.totalPlayerKills:SetText("Total Kills: " .. (EskelUIDB.kills or "0"))
            mainFrame.totalCurrency:SetText("Gold: " .. (EskelUIDB.gold or "0") .. " Silver: " .. (EskelUIDB.silver or "0") .. " Copper: " .. (EskelUIDB.copper or "0"))
        end        
    end    

    eventListenerFrame:SetScript("OnEvent", eventHandler)
    eventListenerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    eventListenerFrame:RegisterEvent("CHAT_MSG_MONEY")
--------------------

function EskelUI:ToggleMainFrame()
    if not mainFrame:IsShown() then
        mainFrame:Show()
    else
        mainFrame:Hide()
    end
end