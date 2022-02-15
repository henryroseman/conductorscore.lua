function plugindef()
   -- This function and the 'finaleplugin' namespace
   -- are both reserved for the plug-in definition.
   finaleplugin.RequireScore = true
   finaleplugin.Author = "Nick Mazuk"
   finaleplugin.Version = "1.00"
   finaleplugin.AuthorURL = "https://nickmazuk.com"
   return "Create Conductor Score", "Create Conductor Score", "Makes the score more condusive with conducting through several options"
end

--displays the availible settings
local options = finenv.UserValueInput()
options.Title = "Conductor Score Options"
options:SetTypes("Boolean", "Boolean","Boolean","Boolean")
options:SetDescriptions("Change name to conductor", "Large time signatures", "Measure numbers below each measure", "Get rid of whole rests in empty measures")--, "Cutout Score")
options:SetInitValues(true,true,true,true)
local chosenoptions = options:Execute()
if not chosenoptions then return end

--Makes the score text say conductor
if chosenoptions[1] == true then
    local parts = finale.FCParts()
    parts:LoadAll()
    local p = parts:GetCurrent()

    local args = finale.FCString()
    args.LuaString = "Conductor"
    local hasCustomText = p:HasCustomText()

    if p:SaveCustomTextString(args) then
        if not hasCustomText then p:Save() end
    end
end

--makes large Time Signatures
if chosenoptions[2] == true then
	--choose which staves have the time signature on
	local staveswithtime = finenv.UserValueInput()
	local staffnames = {}
	local stafftypes = {}
	local defaultvalues = {}
	for staff in loadall(finale.FCStaves()) do
		local name = staff:CreateFullNameString()
		name:GetLuaString()
		name:TrimEnigmaFontTags()
		table.insert(staffnames, name:GetLuaString())
		table.insert(stafftypes, "Boolean")
		table.insert(defaultvalues, false)
	end
	for group in loadall(finale.FCGroups()) do
		if group:GetBracketStyle() == 6 then
			defaultvalues[group:GetStartStaff()] = true
		end
	end
	staveswithtime.Title = "Which Staves with Large Time Signatures?"
	staveswithtime:SetTypes(stafftypes)
	staveswithtime:SetDescriptions(staffnames)
	staveswithtime:SetInitValues(defaultvalues)
	local timesigoptions = staveswithtime:Execute()
	if not timesigoptions then return end
	for staff in loadall(finale.FCStaves()) do
		staff:SetShowTimeSignatures(timesigoptions[staff:GetItemNo()])
		staff:Save()
	end

	--actually change the font to a large font
	local fontprefs=finale.FCFontPrefs()
	fontprefs:Load(finale.FONTPREF_TIMESIG)
	local fontinfo=fontprefs:CreateFontInfo()
	--print(fontinfo:CreateEnigmaStyleString():GetLuaString())
	fontinfo:SetSize(40)
	fontinfo.Name="EngraverTime"
	fontprefs:SetFontInfo(fontinfo)
	fontprefs:Save()
	local distanceprefs = finale.FCDistancePrefs()
-- Load preference data that don't use multiple records with 1:
	distanceprefs:Load(1)
	distanceprefs:SetTimeSigBottomVertical(-290)
	distanceprefs:Save()
end

--puts the measure numbers in the bottom
if chosenoptions[3] == true then
    local systems = finale.FCStaffSystem()
    systems:Load(1)

	for m in loadall(finale.FCMeasureNumberRegions()) do
        -- Sets the measure numbers correctly
		m:SetUseScoreInfoForParts(false)
		font = finale.FCFontInfo()
		font:SetSize('14')
        font:SetAbsolute(true)
		m:SetMultipleFontInfo(font,false)
		m:SetShowOnTopStaff(false,false)
		m:SetShowOnSystemStart(false,false)
		m:SetShowOnBottomStaff(true,false)
		m:SetExcludeOtherStaves(true,false)
		m:SetShowMultiples(true,false)
		m:SetHideFirstNumber(false,false)
		m:SetMultipleAlignment(finale.MNALIGN_CENTER ,false)
		m:SetMultipleJustification(finale.MNJUSTIFY_CENTER ,false)

        -- Sets the position in accordance to the system scaling
        local startMeasure = m.StartMeasure
        local endMeasure = m.EndMeasure
        local systemScaling = systems.Resize
        local position = -3873 * (systemScaling ^ -.568)
		m:SetMultipleVerticalPosition(position,false)
		m:Save()
	end
end

--gets rid of whole rests in empty measures
if chosenoptions[4] == true then
	for staff in loadall(finale.FCStaves()) do
		staff:SetDisplayEmptyRests()
		staff:Save()
	end
end
