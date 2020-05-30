local json = _G['json']
local mtd = CreateFrame("Frame")
local match = string.match
local strsplit = strsplit


local function GTTHook_OnTooltipSetItem(tooltip)
	local itemName, link = tooltip:GetItem()
	if not link then return; end
	if not MischiefToolsPriority then return; end

    local timeGenerated = MischiefToolsPriority.generated;
    local prio = MischiefToolsPriority.priority[itemName]
    
    if prio ~= nil then        
        tooltip:AddLine(" ")
        tooltip:AddLine("Mischief Tools Priority")
        tooltip:AddLine("Generated " .. date("%m/%d/%y %H:%M:%S", timeGenerated), .6, .6, .6)
        
        for _, record in ipairs(prio) do            
            tooltip:AddDoubleLine(record.character, record.points, 1, 1, 1)
        end
        tooltip:AddLine(" ")
    end
end

local function OnAddonLoaded(self, event, addon)
    if addon == "MischiefTools" then
        print("Hooking into tooltips")
        GameTooltip:HookScript("OnTooltipSetItem",GTTHook_OnTooltipSetItem);
    end
end

local function ShowImportFrame()    
    if not MM_ImportFrame then
        local f = CreateFrame("Frame", "MM_ImportFrame", UIParent, "DialogBoxFrame")
        f:SetPoint("CENTER")
        f:SetSize(600, 500)
        
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
            edgeSize = 16,
            insets = { left = 8, right = 6, top = 8, bottom = 8 },
        })
        f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
        
        -- Movable
        f:SetMovable(true)
        f:SetClampedToScreen(true)
        f:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self:StartMoving()
            end
        end)
        f:SetScript("OnMouseUp", f.StopMovingOrSizing)
        
        -- ScrollFrame
        local sf = CreateFrame("ScrollFrame", "MM_ImportFrameScrollFrame", MM_ImportFrame, "UIPanelScrollFrameTemplate")
        sf:SetPoint("LEFT", 16, 0)
        sf:SetPoint("RIGHT", -32, 0)
        sf:SetPoint("TOP", 0, -16)
        sf:SetPoint("BOTTOM", MM_ImportFrameButton, "TOP", 0, 0)
        MM_ImportFrameButton:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then                
                MischiefToolsData.ImportPriority(MM_ImportFrameEditBox:GetText())            
            end
        end)

        -- EditBox
        local eb = CreateFrame("EditBox", "MM_ImportFrameEditBox", MM_ImportFrameScrollFrame)
        eb:SetSize(sf:GetSize())
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false) -- dont automatically focus
        eb:SetFontObject("ChatFontNormal")
        eb:SetScript("OnEscapePressed", function() f:Hide() end)
        sf:SetScrollChild(eb)
        
        -- Resizable
        f:SetResizable(true)
        f:SetMinResize(150, 100)
        
        local rb = CreateFrame("Button", "MM_ImportFrameResizeButton", MM_ImportFrame)
        rb:SetPoint("BOTTOMRIGHT", -6, 7)
        rb:SetSize(16, 16)
        
        rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        
        rb:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then                
                f:StartSizing("BOTTOMRIGHT")
                self:GetHighlightTexture():Hide() -- more noticeable                
            end
        end)
        rb:SetScript("OnMouseUp", function(self, button)
            f:StopMovingOrSizing()
            self:GetHighlightTexture():Show()
            eb:SetWidth(sf:GetWidth())
        end)
        f:Show()
    end
    
    MM_ImportFrameEditBox:SetText("Import from http://mischief-tools.herokuapp.com/api/v1/addon/priority?format=json. Replace all text here with imported data.")    
    MM_ImportFrame:Show()
end

MischiefToolsData.ImportPriority = function(jsonData)
    print("Loading priority data")
    if (json ~= nil) then
        local obj, pos, err = json.decode(jsonData, 1, nil)
        if err then
            print ("Error:", err)
            return
        else
            MischiefToolsPriority = obj
            print("Priority data successfully loaded")
        end
    end
end

mtd:RegisterEvent("ADDON_LOADED")
mtd:SetScript("OnEvent", OnAddonLoaded)

local function MMDataSlashFunc(msg)
    print(msg)
end

SLASH_MMDATA1 = "/mm";
SlashCmdList["MMDATA"] = function(msg)
    if msg == 'import' then
        ShowImportFrame()
    else
        print("Command not recognized. Available commands are: import")
    end
end