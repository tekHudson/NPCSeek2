





--[[ reference
nameplateShowAll	0	Game	Character	
nameplateShowDebuffsOnFriendly	1	Game	Character	
nameplateShowEnemies	1	Game	Character	
nameplateShowEnemyGuardians	0	Game	Character	
nameplateShowEnemyMinions	0	Game	Character	
nameplateShowEnemyMinus	1	Game	Character	
nameplateShowEnemyPets	0	Game	Character	
nameplateShowEnemyTotems	0	Game	Character	
nameplateShowFriendlyGuardians	0	Game	Character	
nameplateShowFriendlyMinions	0	Game	Character	
nameplateShowFriendlyNPCs	0	Game	Character	
nameplateShowFriendlyPets	0	Game	Character	
nameplateShowFriendlyTotems	0	Game	Character	
nameplateShowFriends	0	Game	Character	
nameplateShowOnlyNames	0	Game	Character	Whether to hide the nameplate bars
nameplateShowSelf
]]--

_G.SetCVar("nameplateShowFriendlyNPCs",1)

local f = CreateFrame("Frame", nil, UIParent)
f:SetFrameStrata("BACKGROUND")
f:SetWidth(32)
f:SetHeight(32)

local t = f:CreateTexture(nil,"BACKGROUND")
-- t:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp")
t:SetTexture("Interface\\AddOns\\NpcSeek2\\Img\\detection.tga")
t:SetAllPoints(f)
f.texture = t

--f:SetPoint("CENTER",0,0)
f:SetPoint("TOPLEFT",40,-100)
f:Hide()


--print("Battlecruiser operational (npcseek2 loaded)")
local log=print
local AddOnFolderName, private = ...
local ace=LibStub("AceAddon-3.0")
local addon=ace:NewAddon(AddOnFolderName,
	"AceEvent-3.0", "AceConsole-3.0")






function addon:OnEnable()
--	print("OnEnable")
	
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
end

local ValidUnitTypeNames = {
	Creature = true,
	Vehicle = true,
}

local function GUIDToCreatureID(GUID)
	local unitTypeName, _, _, _, _, unitID = ("-"):split(GUID)
	if ValidUnitTypeNames[unitTypeName] then
		return tonumber(unitID)
	end
end

local function getUnitData(unitToken)
	local guid = _G.UnitGUID(unitToken)
	
	-- log("guid: "..tostring(guid))
	local npcId = GUIDToCreatureID(guid)
	
	if not npcId then
		-- log("No npcId:"..unitToken)
		return
	end
	
	-- log("npc id:"..npcId)
	
	local sourceText=UNIT_NAMEPLATES
	
	--local unitIsDead = _G.UnitIsDead(unitToken)
	local detectionData = {
		--isDead = unitIsDead,
		npcID = npcId,
		npcName = _G.UnitName(unitToken),
		sourceText = sourceText,
		unitClassification = _G.UnitClassification(unitToken),
		unitCreatureType = _G.UnitCreatureType(unitToken),
		unitLevel = _G.UnitLevel(unitToken),
		unitToken = unitToken,
	}
	
	--log("npc name:"..detectionData.npcName)
	
	return detectionData
end

local _countByName={}

local _isSee=false
local updateUi=function()
	local hasAny=false
	for name,count in pairs(_countByName) do
--		log(name..":"..tostring(count))
		hasAny=true
		break
	end
	
	if hasAny then
--		log("show")
		f:Show()
	else
--		log("hide")
		f:Hide()
		
	end
end



local noticedUnit=function(unitData, name)
--	log("noticed:"..name)
	local curr=_countByName[name]
	if curr==nil then curr=1 else curr=curr+1 end
	_countByName[name]=curr
	
	updateUi()
end

local unNoticedUnit=function(unitData, name)
--	log("unnoticed:"..name)
	local curr=_countByName[name]
	if curr==nil then return end
	curr=curr-1
	if curr<=0 then 
		_countByName[name]=nil
	else
		_countByName[name]=curr
	end
	
	updateUi()
end


-- _ contains fn name
function addon:NAME_PLATE_UNIT_ADDED(_, unitToken)
	-- print("see")
	-- print("see unit: "..tostring(_))
	
	-- log("token: "..tostring(unitToken))
	local unitData=getUnitData(unitToken)
	if unitData==nil then return end
	local name=unitData.npcName
	
	for k,listName in pairs(DetectionList) do
		if name==listName then
			noticedUnit(unitData, listName)
			break
		end
	end
end

function addon:NAME_PLATE_UNIT_REMOVED(_, unitToken)
	local unitData=getUnitData(unitToken)
	if unitData==nil then return end
	local name=unitData.npcName
	
	for k,listName in pairs(DetectionList) do
		if name==listName then
			unNoticedUnit(unitData, listName)
			break
		end
	end
end


local showDetectionList=function()
	log("detection list:")
	for k,name in pairs(DetectionList) do
		log(name)
	end
end


-- detectionList["test_pers"]="hello"

-- Chat

addon:RegisterChatCommand("seekadd", "SeekAdd")
addon:RegisterChatCommand("seekdel", "SeekDel")
addon:RegisterChatCommand("seeklist", "SeekList")


function addon:SeekList(str)
	showDetectionList()
end

local isEmptyString=function(str)
	return str==nil or str==""
end


local clearName=function(name)
	local result=string.gsub(name,'"','')
	return result
end


function addon:SeekAdd(name)
	if isEmptyString(name) then
		log("seekadd NpcName")
		return
	end
	name=clearName(name)
	
	table.insert(DetectionList, name)
	
	showDetectionList()
	updateUi()
	log("success")
end

function addon:SeekDel(name)
	if isEmptyString(name) then
		log("seekdel NpcName")
		return
	end
	
	name=clearName(name)
	
	for k,currName in pairs(DetectionList) do
		if name==currName then
			DetectionList[k]=nil
		end
	end
	
	showDetectionList()
	_countByName[name]=nil
	updateUi()
	log("success")
end



function addon:OnInitialize()
--	print("OnInitialize")
	if DetectionList==nil then 
		DetectionList={
--			"Bristleback Invader",
--			"Plainstrider",
--			"Marjak Keenblade",
		}
	end
	
	print("addon:"..tostring(addon).." initialized")
	showDetectionList()
end