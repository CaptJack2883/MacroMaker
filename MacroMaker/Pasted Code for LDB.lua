local db; -- File-global handle to the Database
-- LibDBIcon storage
local defaults = {profile = {LDBIconStorage = {},},};

local ldbObject = {
 type = "launcher",
 icon = "Interface\\AddOns\\MacroMaker\\MacroMakerIcon",
--This is the icon used. Any .blp or .tga file is a valid icon.
--This path is ALWAYS relative to the World of Warcraft
--root (ie, "C:\Program Files\World of Warcraft" for
--Windows and "/Applications/World of Warcraft" for Mac)
 label = "MacroMaker",
 OnClick = function(self, button)
-- Add a click handler here

	if MMMainHidden == 0 then
		MacroMakerFrame:Show()
		MMMainHidden = 1
	elseif MMMainHidden == 1 then
		MacroMakerFrame:Hide()
		MMMainHidden = 0
	end

 end,
 OnTooltipShow = function(tooltip)
 tooltip:AddLine("MacroMakerTooltip");
--Add text here. The first line is ALWAYS a "header" type.
--It will appear slightly larger than subsequent lines of text
 end,
};

function updateDB(self, event, database)
 db = database.profile;
 LibStub("LibDBIcon-1.0"):Refresh("AddonLDBObjectName", db.LDBIconStorage);
end

local vars = LibStub("AceDB-3.0"):New("AddonSavedVarStorage", defaults);
vars:RegisterCallback("OnProfileChanged", updateDB);
vars:RegisterCallback("OnProfileCopied", updateDB);
vars:RegisterCallback("OnProfileReset", updateDB);
db = vars.profile;

LibStub("LibDataBroker-1.1"):NewDataObject("AddonLDBObjectName", ldbObject);
LibStub("LibDBIcon-1.0"):Register("AddonLDBObjectName", ldbObject, db.LDBIconStorage);