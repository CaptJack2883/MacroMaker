-- Author      : CaptJack2883
-- Create Date : 08/28/2014
-- Modify Date : 07/22/2025
-- Version     : 2.0
	--[[ 
		To Do:				    
			In Progress: Add /petattack to all pet classes/specs			      
			Finish Settings Page. (Let users input custom macros.)
			Allow custom macros. (Probably requires a table.)
			Allow it to do /castsequence, with reset values and combat/target resets.			
						
		Bugs:
      		
			Truncating spellname inside of create macro. Need separate variable for truncated name.
			
			Priests seem to have issues with spell names. This was found to be based on Icon name, not Spell name.
			hopefully this is fixed, since we're using the spell ID now.
		
			Fixed: If you have a macro selected, it creates a new macro with that body with the new name.
					
        -->Modularize more, clear info and recreate before creating macro.
          
    Troubleshooting code:
      
    --local version, build, date, tocversion = GetBuildInfo();
    --print("MM: Version: ", version, " Build: ", build, " Date: ", date, " TOC Version: ", tocversion)
    
		--]]

-- Variable declarations (For All Files!)
MMMainHidden = nil
MMCustomString = nil

MMNumGlobalMacros = nil
MMNumCharMacros = nil
MMNumTotalMacros = nil
MMMacroNameIterator = nil
MMCharMacroIteratorStart = nil
MMCharMacroIteratorEnd = nil
MMMacroFound = 0
MMNumEmptyCharMacros = nil
MMFirstEmptyGlobalMacro = nil
MMFirstEmptyCharMacro = nil
MMMacroBodyString = nil
MMSpellName = nil
MMSpellNameTrunc = nil
MMSpellRank = nil
MMSpellIcon = nil
MMSpellCost = nil
MMInfo3 = nil
MMInfo4 = nil
MMInfo5 = nil
MMInfo6 = nil
MMInfoType = nil
MMInfo1 = nil
MMInfo2 = nil
MMSpellID = nil
MMCurrentSpell = nil
MMCurrentSpellName = nil
MMPlayerClass = nil
MMEnglishClass = nil
MMVerbose = nil
MMMinimapButtonShown = nil
-- variables for the LDB Icon
MM_LDBicon = LibStub("LibDBIcon-1.0")
-- Only require LibDataBroker for the minimap button
local macroMakerLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Macro Maker", {
    type = "data source",
    text = "Macro Maker",
    icon = "Interface\\AddOns\\MacroMaker\\MacroMakerIcon.tga",
    OnClick = function(clickedframe, button)
        if button == "RightButton" then
            MMConfigShow()
        else
            if MMMainHidden == 0 then      
                MacroMakerFrame:Raise()
                MacroMakerFrame:Show()
                MMMainHidden = 1
            elseif MMMainHidden == 1 then
                MacroMakerFrame:Hide()
                MMMainHidden = 0
            end
        end
    end,
})

-- Register the minimap icon if LibDBIcon is available
if MM_LDBicon and macroMakerLDB then
    MM_LDBicon:Register("Macro Maker", macroMakerLDB, {})
end


MMQuestionIcon = nil
MMCustomSpellName = nil
MMCustomMacroString = nil
MMEventFrame = CreateFrame("FRAME", nil, UIParent)
MMEventFrame:Hide()


if MMEventFrame ~= nil then
	--MMPrint("MMEventFrame has been created")
end

-- 	Register all events here
MMEventFrame:RegisterEvent("ADDON_LOADED")
MMEventFrame:RegisterEvent("PLAYER_LOGOUT")	--	Probably don't need/use this.

-- All Functions should be defined here.

function MMEventHandler(self, event, ...)
	local arg1 = ...
	if event == "ADDON_LOADED" and arg1 == "MacroMaker" then
		--	Check for loaded SavedVariables
		if MMMainHidden == nil then
			MMMainHidden = 1
      --MacroMakerFrame:SetBackdrop(BACKDROP_DARK_DIALOG_32_32)
      MacroMakerFrame:Raise()
			MacroMakerFrame:Show()
		end
		if MMMainHidden == 0 then
			MacroMakerFrame:Hide()
		elseif MMMainHidden == 1 then
      --MacroMakerFrame:SetBackdrop(BACKDROP_DARK_DIALOG_32_32)
      MacroMakerFrame:Raise()
			MacroMakerFrame:Show()
		end
		if MMVerbose == nil then
			MMVerbose = 0
		end
		if MMMinimapButtonShown == nil then
			MMMinimapButtonShown = true
      MMMinimapButtonCheckbox:SetChecked(true)
      MM_LDBicon:Show("Macro Maker")
      MM_LDBaddon.db.profile.minimap.hide = true
      MacroMakerConfig_Refresh()
      MacroMakerConfig_Close()
    else      
      MMMinimapButtonCheckbox:SetChecked(MMMinimapButtonShown)
      MacroMakerConfig_Refresh()
      MacroMakerConfig_Close()
    end
		MMPrint("Macro Maker has been loaded.")
		MMResetInputButton()
		MMResetInputButton()
		MMBtnMacroInput:Click()
		--MMHelpString:Show()
		--MMHelpString:SetTextColor(1, 1, 1, 1)
		--MMTextString = CreateFontString(nil, "OVERLAY", "GameFontNormal")
		--MMTextString:SetPoint("CENTER")
		--MMTextString:SetText("HelloWorld!")
	elseif event == "PLAYER_LOGOUT" then
	--	Do something on logout.
	end	
end

function MMPrint(MMPrintString)
    MMVerbose = MMVerboseCheckbox:GetChecked();
    if MMVerbose then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFA471C6Macro Maker: |r"..MMPrintString)
    end
end

function MMBtnHide_OnClick()
	-- Hides the frame.
	MacroMakerFrame:Hide()
	MMMainHidden = 0
end

function MMBtnTest_OnClick()
	-- Make Test button print to chat, but not make the macro.
	-- MMTestMacro()
	-- Currently testing UnitClass
	MMPrint("Test Button was clicked.")
	local playerClass, englishClass = UnitClass("player");
	MMPlayerClass = playerClass
	MMEnglishClass = englishClass
	MMPrint("You are playing a "..MMPlayerClass)
	--MMSetMacroString();
	if MMVerbose then
		MMPrint("Verbose Test is true")
	else
		MMPrint("Verbose Test is false")
	end
end

function MMBtnCheck_OnClick()	
	-- This function tests macros to see if they are existing before overwriting.
	MMCheckMacro()
end

function MMBtnCreate_OnClick()
	-- Make this button actually create the macros from the BtnTest.
	-- Need to find out class of character to make better macros.
	MMCreateMacro()
end

function MMBtnOptions_OnClick()
	-- Make this button open the options dialog/config screen.
	MMConfigShow()
end

function MMTestMacro()
	-- This will test to see if macros already exist for the input ability.
	
	--MMPrint("This feature is not implemented yet.")
	--MMPrint("When implemented, this feature will Test the creation of macros without actually creating them.")
	if MMBtnMacroInput:GetText() == "QuestionMark" then
		MMPrint("You need to select a spell first.")
	elseif MMBtnMacroInput:GetText() ~= "QuestionMark" then
		MMPrint("You have selected: "..MMBtnMacroInput:GetText())
		--Iterate the macros to see if MMSpellName matches one of them.
		MMMacroFound = 0
		MMNumEmptyCharMacros = 0
		MMSpellName = MMBtnMacroInput:GetText()
		if MMSpellName ~= nil then
			-- Need to use Truncated name of spell for the Macro Name.
			MMSpellName = string.sub(MMSpellName, 1, 16)
			for i = 1,54 do
				MMMacroNameIterator = GetMacroInfo(i)
				if MMMacroNameIterator == MMSpellName then
					MMPrint("You already have a macro for "..MMSpellName)
					MMPrint(tostring(GetMacroInfo(MMSpellName)))
					MMMacroFound = 1
				elseif MMMacroNameIterator == nil then
					if i > 36 then	
						MMNumEmptyCharMacros = MMNumEmptyCharMacros + 1
					end
				else
					--Do Nothing
				end
			end
			if MMMacroFound == 0 then
				MMPrint("No macro found for "..MMSpellName)
			end
			if MMNumEmptyCharMacros == 0 then
				MMPrint("You have no empty Macros.")
			end
		end
	end
end

function MMCheckMacro()
	-- This will check how many of which macros we have, then list all macros by name.
	MMNumGlobalMacros,MMNumCharMacros = GetNumMacros()
	MMNumTotalMacros = MMNumCharMacros + MMNumGlobalMacros
	if MMNumGlobalMacros ~= nil then
		--MMPrint("MacroMaker: You have: ", MMNumGlobalMacros, "Global Macros.")
		--MMPrint("They are named:")
		-- Using literal Macro ID's. 1-36 is Global, 37-54 are Character.
		for i = 1,36 do
			MMMacroNameIterator = GetMacroInfo(i)
			if MMMacroNameIterator ~=nil then
				--MMPrint(MMMacroNameIterator)
			end
		end
	end
	
	if MMNumCharMacros ~= nil then
		--MMPrint("MacroMaker: You have: ", MMNumCharMacros, "Character Macros.")
		--MMPrint("They are named:")
		-- Using literal Macro ID's. 1-36 is Global, 37-54 are Character.
		for i = 37,54  do
			MMMacroNameIterator = GetMacroInfo(i)
			if MMMacroNameIterator ~= nil then
				--MMPrint(MMMacroNameIterator)
			end
		end	
	end
	
	if MMNumGlobalMacros == nil then
		MMPrint("You have no global macros yet!")
	end
	
	if MMNumCharMacros == nil then
		MMPrint("You have no character macros yet!")
	end
end

function MMCreateMacro()
	-- Tests to make sure we have empty slots, then creates a generic macro in one of the empty slots.
	MMNumEmptyCharMacros = 0
	MMNumNilMacros = 0
	-- Need to use Truncated spellname to check macros.
	MMSpellName = string.sub(MMBtnMacroInput:GetText(), 1, 16)
	--MMPrint("This feature is not implemented yet.")
	--MMPrint("When implemented, this feature will actually create the macros.")
	--Need to test for empty macro slots to make sure we have room for the new macro.
	for i = 1,54 do
		MMIsMacroEmpty = GetMacroInfo(i)
		if MMIsMacroEmpty == nil then --This is the correct test for an empty macro.
			--MMPrint(GetMacroInfo(i))
			--MMPrint("Nil Macro Found at Position:", i) --Use this to pick an empty spot, then break.
			if MMFirstEmptyGlobalMacro == nil then
				if i < 37 then
					MMFirstEmptyGlobalMacro = i
				end
			end
			if MMFirstEmptyCharMacro == nil then
				if i > 36 then
					MMFirstEmptyCharMacro = i					
				end
			end
			if i > 36 then
				MMNumEmptyCharMacros = MMNumEmptyCharMacros + 1
			end
			MMNumNilMacros = MMNumNilMacros + 1
		end
	end
	--MMPrint(MMNumNilMacros, "Nil Macros Found") --This is how many empty macros we have.
	--MMPrint("The first empty Global Macro is:", MMFirstEmptyGlobalMacro)
	--MMPrint("The first empty Character Macro is:", MMFirstEmptyCharMacro)
	
	-- This is where we actually create the macro.
	-- NOCOMBAT CreateMacro("name", "icon", "body", perCharacter)
	-- Need to make a "String" that we can concatenate beforehand, so we can include the ability name as part of the macro.
	if MMNumEmptyCharMacros ~= 0 then
		if MMCustomString ~= nil then
			MMCustomMacro(MMSpellName, MMCustomString)
		elseif MMSpellName ~= "QuestionMark" then
			MMCustomMacro(MMSpellName)
		end
	elseif MMNumEmptyCharMacros == 0 then
		MMPrint("You have no empty Character Macro slots. You need to delete a Character Macro to make room.")
	end
end

function MMResetAllVariables()
	MMNumGlobalMacros = nil
	MMNumCharMacros = nil
	MMNumTotalMacros = nil
	MMMacroNameIterator = nil
	MMCharMacroIteratorStart = nil
	MMCharMacroIteratorEnd = nil
	MMMacroFound = 0
	MMNumEmptyCharMacros = nil
	MMFirstEmptyGlobalMacro = nil
	MMFirstEmptyCharMacro = nil
	MMMacroBodyString = nil
	MMSpellName = nil
	MMSpellNameTrunc = nil
	MMSpellRank = nil
	MMSpellIcon = nil
	MMSpellCost = nil
	MMInfo3 = nil
	MMInfo4 = nil
	MMInfo5 = nil
	MMInfo6 = nil
	MMInfoType = nil
	MMInfo1 = nil
	MMInfo2 = nil
	MMSpellID = nil
	MMCurrentSpell = nil
	MMCurrentSpellName = nil
	
	--MMPrint("Resetting Variables.")
end

function MMCustomMacro(MMCustomSpellName, MMCustomMacroString)
	
	if MMCustomMacroString ~= nil then		
		MMTestMacro()
		if MMMacroFound ~= 1 then
			if MMCustomMacroString ~= nil then
				CreateMacro(MMCustomSpellName, "INV_MISC_QUESTIONMARK", MMCustomMacroString)				
			elseif MMCustomSpellName ~= nil then
				-- Need to test here and make separate strings for pet classes
				MMSetMacroString()
				-- MMMacroBodyString = "#showtooltip " .. MMCustomSpellName .. "\n/cleartarget [dead][noharm]\n/startattack\n/cast " .. MMCustomSpellName
				CreateMacro(MMCustomSpellName, "INV_MISC_QUESTIONMARK", MMMacroBodyString, 1)
				MMPrint("Creating macro for ", MMCustomSpellName)
				return
			end
		end
	end
	if MMBtnMacroInput:GetText() ~= "QuestionMark" then
		-- Need to use Truncated spellname to check macros.
		MMSpellNameTrunc = string.sub(MMBtnMacroInput:GetText(), 1, 16)
		MMSpellName = MMBtnMacroInput:GetText()
		MMSetMacroString()
		--MMMacroBodyString = "#showtooltip " .. MMSpellName .. "\n/cleartarget [dead][noharm]\n/startattack\n/cast " .. MMSpellName
		MMTestMacro()
		if MMMacroFound ~= 1 then
			if MMSpellName ~= nil then
				MacroFrame_SaveMacro()
				HideUIPanel(MacroFrame)
				CreateMacro(MMSpellNameTrunc, "INV_MISC_QUESTIONMARK", MMMacroBodyString, 1)
				MMPrint("Creating macro for ", MMSpellName)
				-- ShowMacroFrame() -- No longer open the macro panel automatically
				return
			end
		end
	end
end

function MMBtnShowMacroPanel_OnClick()
	-- This should open (and possibly close) the Macro Panel
	--MMPrint("This feature is not net implemented.")
	--MMPrint("When implemented, this button will open the Macro Panel.")
	-- The following code is "PROTECTED" and is not usable.
	--RunMacroText("/macro")
	--RunMacro("MacroPanel")
	--ShowUIPanel(MacroFrame)
  
  local version, build, date, tocversion = GetBuildInfo();
  if tocversion < 90000 then
    -- We are in classic/tbc/wrath. Don't use new code for closing the Macro Panel.
    if ( MacroFrame and MacroFrame:IsShown() ) then
      HideUIPanel(MacroFrame)
    else
      ShowMacroFrame()
      --ShowUIPanel(MacroFrame) This one doesn't work in classic
    end
  else
    -- We are in retail and we can use the new code.    
    if ( MacroFrame and MacroFrame:IsShown() ) then
      --MacroFrame:Hide()
      HideUIPanel(MacroFrame)
    else
      if not (MacroFrame) then
      ShowMacroFrame()
      --ShowUIPanel(MacroFrame) Doesn't work in retail either.
      else
        MacroFrame:Show()
        tinsert(UISpecialFrames, MacroFrame:GetName())
      end
    end    
  end
end

function MMBtnMacroInput_OnDrag()
	--Drags the Macro Back out of the Input Button.
	-- Need to use Truncated name of ability to get correct macro.
	PickupMacro(string.sub(MMBtnMacroInput:GetText(), 1, 16))	
end

function MMResetInputButton()
    MMResetAllVariables()
    MMBtnMacroInput:SetNormalTexture("Interface\\Icons\\INV_MISC_QUESTIONMARK")
    MMBtnMacroInput:SetText("QuestionMark")
    MMBtnMacroInput:SetAttribute("type", nil)
    MMBtnMacroInput:SetAttribute("spell", nil)
    MMBtnMacroInput:SetAttribute("macro", nil)
    -- Tooltip for empty state
    MMBtnMacroInput:SetScript("OnEnter", function(self)
        if MMBtnMacroInput:GetText() == "QuestionMark" then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Drop a spell or macro here!")
            GameTooltip:Show()
        end
    end)
    MMBtnMacroInput:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end


	--  Need to make separate Functions. First check Icon of MMBtnMacroInput, then use that to determine if you need to get spell from Cursor, or Use CurrentSpell.
function MMBtnMacroInput_LeftButton()
    -- If the button is not empty, clear it first
    if MMBtnMacroInput:GetText() ~= "QuestionMark" then
        MMResetInputButton()
    end

    -- Now proceed as before
    MMPrint("I have no spell or macro yet. Please give me a spell or macro to process.")
    MMInfoType, MMInfo1, MMInfo2, MMSpellID = GetCursorInfo()
    MMPrint(tostring(MMInfoType).." "..tostring(MMSpellID))
    ClearCursor()
    if not MMInfoType then
        MMPrint("No spell or macro was found on the cursor.")
        return
    end
    if MMInfoType == "spell" and MMSpellID ~= nil then
        if GetSpellInfo then
            local spellName, _, spellIcon = GetSpellInfo(MMSpellID)
            MMSpellName = spellName
            MMSpellIcon = spellIcon
            MMPrint("Icon path:", MMSpellIcon)
            if not MMSpellIcon or MMSpellIcon == "" then
                MMSpellIcon = "Interface\\Icons\\INV_MISC_QUESTIONMARK"
            end
            MMBtnMacroInput:SetNormalTexture(MMSpellIcon)
            MMBtnMacroInput:SetText(MMSpellName)
            MMPrint("You have selected the Spell: ".. MMSpellName)
            MMBtnMacroInput:SetAttribute("type", "spell")
            MMBtnMacroInput:SetAttribute("spell", MMSpellName)
            MMBtnMacroInput:SetAttribute("macro", nil)
        else
            local spell = Spell:CreateFromSpellID(MMSpellID)
            spell:ContinueOnSpellLoad(function()
                MMSpellName = spell:GetSpellName()
                MMSpellIcon = spell:GetSpellTexture()
                MMPrint("Icon path:", MMSpellIcon)
                if not MMSpellIcon or MMSpellIcon == "" then
                    MMSpellIcon = "Interface\\Icons\\INV_MISC_QUESTIONMARK"
                end
                MMBtnMacroInput:SetNormalTexture(MMSpellIcon)
                MMBtnMacroInput:SetText(MMSpellName)
                MMPrint("You have selected the Spell: ".. MMSpellName)
                MMBtnMacroInput:SetAttribute("type", "spell")
                MMBtnMacroInput:SetAttribute("spell", MMSpellName)
                MMBtnMacroInput:SetAttribute("macro", nil)
            end)
        end
    elseif MMInfoType == "macro" and MMInfo1 ~= nil then        
        MMPrint("You can't use Macros, you need a spell.")
        ClearCursor()
		MMResetInputButton()
    end
    
    if MMBtnMacroInput:GetText() ~= "QuestionMark" then
        MMPrint(MMBtnMacroInput:GetText())
    end
end

function MMBtnMacroInput_RightButton()
	MMResetInputButton()
end

function MMSetMacroString()
	-- This will check class, and make the macrostring accordingly.
	
	local playerClass, englishClass = UnitClass("player");
	MMPlayerClass = playerClass
	MMEnglishClass = englishClass
	
	if MMPlayerClass == "Hunter" then
		-- use petclass macro
		MMMacroBodyString = "#showtooltip " .. MMSpellName .. "\n/cleartarget [dead][noharm]\n/targetenemy [dead][noharm]\n/startattack\n/petattack\n/cast " .. MMSpellName
	elseif MMPlayerClass == "Warlock" then
		-- use petclass macro
		MMMacroBodyString = "#showtooltip " .. MMSpellName .. "\n/cleartarget [dead][noharm]\n/targetenemy [dead][noharm]\n/startattack\n/petattack\n/cast " .. MMSpellName
	else
		-- use standard macro
		MMMacroBodyString = "#showtooltip " .. MMSpellName .. "\n/cleartarget [dead][noharm]\n/targetenemy [dead][noharm]\n/startattack\n/cast " .. MMSpellName
	end
	MMPrint(MMMacroBodyString)
	
end







--SetScripts MUST be AFTER the function they call.
MMEventFrame:SetScript("OnEvent", MMEventHandler)




