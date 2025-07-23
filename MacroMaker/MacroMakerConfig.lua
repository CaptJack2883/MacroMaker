-- Author      : CaptJack2883
-- Create Date : 08/24/2017
-- Modify Date : 11/27/2022

-- Put Variables in MacroMaker.lua (unless they're function-local)


function MacroMakerConfig_OnLoad(panel)	
	panel.name = "Macro Maker"
	panel.okay = function (self) MacroMakerConfig_Close() end
	panel.cancel = function (self) MacroMakerConfig_CancelOrLoad() end
	panel.refresh = function (self) MacroMakerConfig_Refresh() end
	panel.default = function (self) MacroMakerConfig_Default() end	
	if Settings and Settings.OpenToCategory then
		local category = Settings.RegisterCanvasLayoutCategory(panel, "MacroMaker")
		Settings.RegisterAddOnCategory(category)
		MacroMakerSettingsCategory = category -- Store globally for later use
	elseif InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(panel)
	end
end

function MMConfigShow()	
	if InterfaceOptionsFrame_OpenToCategory then
		InterfaceOptionsFrame_OpenToCategory("MacroMaker")
		InterfaceOptionsFrame_OpenToCategory("MacroMaker")
	else
		if MacroMakerSettingsCategory then
			Settings.OpenToCategory(MacroMakerSettingsCategory.ID)
		end
	end
end

function MacroMakerConfig_Close()
  MMPrint("The Config screen was closed.")
  MMMinimapButtonShown = MMMinimapButtonCheckbox:GetChecked()
  if MMMinimapButtonShown then
    MM_LDBicon:Show("Macro Maker")
  else
    MM_LDBicon:Hide("Macro Maker")
  end
end

function MacroMakerConfig_Refresh()  
  MMPrint("The Config screen was refreshed.")
  MMMinimapButtonCheckbox:SetChecked(MMMinimapButtonShown)
  if MMMinimapButtonShown then
    MM_LDBicon:Show("Macro Maker")
  else
    MM_LDBicon:Hide("Macro Maker")
  end
end

function MMOptionsButtonHide_OnClick()
	MacroMakerFrame:Hide()
	MMMainHidden = 0
end

function MMOptionsButtonShowMM_OnClick()
	MacroMakerFrame:Show()
	MMMainHidden = 1
	MMBtnMacroInput:SetNormalTexture("Interface\\Icons\\INV_MISC_QUESTIONMARK")
end

function MMCreateDropDowns()
	if not MMDropMacroSelect then
		CreateFrame("Button", "MMDropMacroSelect", UIParent, "UIDropDownMenuTemplate")
	end
	 
	MMDropMacroSelect:ClearAllPoints()
	MMDropMacroSelect:SetPoint("CENTER", 0, 0)
	MMDropMacroSelect:Show()
	 
	local MMDropMacroSelectItems = {"Alpha", "Beta", "Gamma", "Delta",}
	 
	local function MMDropMacroSelect_OnClick(self)
	   UIDropDownMenu_SetSelectedID(MMDropMacroSelect, self:GetID())
	end
	 
	local function MMDropMacroSelect_Initialize(self, level)
	   local MMDDMSinfo = UIDropDownMenu_CreateInfo()
	   for k,v in pairs(MMDropMacroSelectItems) do
		  info = UIDropDownMenu_CreateInfo()
		  info.text = v
		  info.value = v
		  info.func = OnClick
		  UIDropDownMenu_AddButton(MMDDMSinfo, level)
	   end
	end
	 
	 
	UIDropDownMenu_Initialize(MMDropMacroSelect, MMDropMacroSelect_Initialize)
	UIDropDownMenu_SetWidth(MMDropMacroSelect, 100);
	UIDropDownMenu_SetButtonWidth(MMDropMacroSelect, 124)
	UIDropDownMenu_SetSelectedID(MMDropMacroSelect, 1)
	UIDropDownMenu_JustifyText(MMDropMacroSelect, "LEFT")
end

function MMMinimapButtonCheckbox_OnClick()
  MMMinimapButtonShown = MMMinimapButtonCheckbox:GetChecked()
  if MMMinimapButtonShown then
    MM_LDBicon:Show("Macro Maker")
  else
    MM_LDBicon:Hide("Macro Maker")
  end
end

function MMConfigHide()
    if Settings and SettingsPanel and SettingsPanel:IsShown() then
        SettingsPanel:Hide()
    elseif InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown() then
        InterfaceOptionsFrame:Hide()
    elseif MacroMakerConfig and MacroMakerConfig:IsShown() then
        MacroMakerConfig:Hide()
    end
end