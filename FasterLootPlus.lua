------------------------------------------------------------------------------------------------
--  FasterLootPlus ver. @project-version@
--  Authored by Chimpy Evans, Chrono Syz -- Entity-US / Wildstar
--  Based on FasterLoot by Chimpy Evans -- Entity-US / Wildstar
--  Build @project-hash@
--  Copyright (c) Chronosis. All rights reserved
--
--  https://github.com/chronosis/FasterLootPlus
------------------------------------------------------------------------------------------------
-- FasterLoot.lua
------------------------------------------------------------------------------------------------

require "Window"
require "ChatSystemLib"

-----------------------------------------------------------------------------------------------
-- FasterLootPlus Module Definition
-----------------------------------------------------------------------------------------------
local FasterLootPlus = {}
local Utils = {}

local addonCRBML = Apollo.GetAddon("MasterLoot")

-----------------------------------------------------------------------------------------------
-- FasterLootPlus constants
-----------------------------------------------------------------------------------------------
local FASTERLOOTPLUS_CURRENT_VERSION = "1.0.0"

local tDefaultSettings = {
    user = {
      isEnabled = true,
      savedWndLoc = {}
    },
    debug = false,
    version = FASTERLOOTPLUS_CURRENT_VERSION,
    ruleSets = {
      [0] = {
        label = "Default",
        lootRules = {}
      }
    },
    currentRuleSet = 0
}

local tDefaultState = {
  isOpen = false,
  isRuleSetOpen = false,
  windows = {
    main = nil,
    ruleList = nil,
    editLootRule = nil,
    assigneeList = nil,
    editAssignee = nil,
    editRuleSets = nil,
    ruleSets = nil,
    ruleSetList = nil,
    confirmDeleteSet = nil,
    confirmClearRules = nil
  },
  ruleSetItems = {},     -- Rule Set List Items (Stores Windows)
  ruleItems = {},        -- Rule List Items (Stores Windows)
  assigneeItems = {},    -- Assignee List Items (Stores Windows)
  currentAssignees = {}  -- List of current Assignees for the item
}

-----------------------------------------------------------------------------------------------
-- FasterLootPlus Constructor
-----------------------------------------------------------------------------------------------
function FasterLootPlus:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  -- Saved and Restored values are stored here.
  o.settings = shallowcopy(tDefaultSettings)
  -- Volatile values are stored here. These are impermenant and not saved between sessions
  o.state = shallowcopy(tDefaultState)

  return o
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus Init
-----------------------------------------------------------------------------------------------
function FasterLootPlus:Init()
  local bHasConfigureFunction = false
  local strConfigureButtonText = ""
  local tDependencies = {
    -- "UnitOrPackageName",
  }
  Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)

  self.settings = shallowcopy(tDefaultSettings)
  -- Volatile values are stored here. These are impermenant and not saved between sessions
  self.state = shallowcopy(tDefaultState)

  self.tOldMasterLootList = {}
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus OnLoad
-----------------------------------------------------------------------------------------------
function FasterLootPlus:OnLoad()
  Apollo.LoadSprites("FasterLootPlusSprites.xml")

  self.xmlDoc = XmlDoc.CreateFromFile("FasterLootPlus.xml")
  self.xmlDoc:RegisterCallback("OnDocLoaded", self)

  Utils = Apollo.GetPackage("SimpleUtils-1.0").tPackage

  Apollo.RegisterEventHandler("Generic_ToggleFasterLootPlus", "OnToggleFasterLootPlus", self)
  Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus OnDocLoaded
-----------------------------------------------------------------------------------------------
function FasterLootPlus:OnDocLoaded()
  if self.xmlDoc == nil then
    return
  end

  -- Delayed timer to fix Carbine's MasterLoot on /reloadui
  Apollo.RegisterTimerHandler("FixCRBML_Delay", "FixCRBML", self)

  Apollo.RegisterEventHandler("MasterLootUpdate", "OnMasterLootUpdate", self)

  self.state.windows.main = Apollo.LoadForm(self.xmlDoc, "FasterLootPlusWindow", nil, self)
  self.state.windows.ruleList = self.state.windows.main:FindChild("ItemList")
  self.state.windows.ruleSets = self.state.windows.main:FindChild("RuleSetsWindow")
  self.state.windows.ruleSetList = self.state.windows.ruleSets:FindChild("ItemList")
  self.state.isRuleSetOpen = false

  -- Initialize all the UI Items
  self:RebuildRuleSetItems()
  self:RebuildLootRuleItems()
  self.state.windows.main:Show(false)
  self.state.windows.ruleSets:Show(false)

  Apollo.RegisterSlashCommand("fasterloot", "OnSlashCommand", self)
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus OnSlashCommand
-----------------------------------------------------------------------------------------------
-- Handle slash commands
function FasterLootPlus:OnSlashCommand(cmd, params)
  args = params:lower():split("[ ]+")

  if args[1] == "debug" then
    if #args == 2 then
      if args[2] == "update" then
        self:OnMasterLootUpdate(true)
      end
    else
      self:ToggleDebug()
    end
  elseif args[1] == "show" then
    self.state.windows.main:Show(true)
  else
    cprint("FasterLootPlus v" .. self.settings.version)
    cprint("Usage:  /fasterloot <command>")
    cprint("====================================")
    cprint("   show           Open Filter Window")
    cprint("   debug          Toggle Debug")
    cprint("   debug update   Update the Window")
  end
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus OnInterfaceMenuListHasLoaded
-----------------------------------------------------------------------------------------------
function FasterLootPlus:OnInterfaceMenuListHasLoaded()
  Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "FasterLootPlus", {"Generic_ToggleFasterLootPlus", "", "FasterLootPlusSprites:FastCoins32"})
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus GatherMasterLoot
-----------------------------------------------------------------------------------------------
-- Returns a table of all Master Lootable items. Filters
-- out those items which are not supposed to go through MasterLoot
function FasterLootPlus:GatherMasterLoot()
  -- tLootList is a table
  -- index => {
  --   tLooters => Table of valid looters, used in AssignMasterLoot
  --   itemDrop => Actual item (e.g.: GetDetailedData())
  --   nLootId => Loot drop ID, used in AssignMasterLoot
  --   bIsMaster => If the item is valid master loot fodder
  -- }

  -- Get all loot
  local tLootList = GameLib.GetMasterLoot()

  -- Gather all the master lootable items
  local tMasterLootList = {}
  for idxNewItem, tCurMasterLoot in pairs(tLootList) do
    if tCurMasterLoot.bIsMaster then
      table.insert(tMasterLootList, tCurMasterLoot)
    end
  end

  return tMasterLootList
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus OnMasterLootUpdate
-----------------------------------------------------------------------------------------------
-- When Master Loot is updated, check each one for filtering, and random those
-- drops that fit the filter.
function FasterLootPlus:OnMasterLootUpdate(bForceOpen)
  local tMasterLootList = self:GatherMasterLoot()

  -- Check each item against the filter, and then random the ones that pass
  for idxMasterItem, tCurMasterLoot in pairs(tMasterLootList) do
    -- Prioritize designated looters first.
    tDesignatedLooter = self:DesignatedLooterForItemDrop(tCurMasterLoot)
    if tDesignatedLooter ~= nil then
      local strItemLink = tCurMasterLoot.itemDrop:GetChatLinkString()
      local strItemName = tCurMasterLoot.itemDrop:GetName()
      self:PrintDB("Assigning " .. strItemName .. " to designated " .. tDesignatedLooter:GetName())
      self:PrintParty("Assigning " .. strItemLink .. " to designated " .. tDesignatedLooter:GetName())
      GameLib.AssignMasterLoot(tCurMasterLoot.nLootId, tDesignatedLooter)
    -- Check to see if we can just random the item out
    elseif self:ItemDropShouldBeRandomed(tCurMasterLoot) then
      local strItemLink = tCurMasterLoot.itemDrop:GetChatLinkString()
      local strItemName = tCurMasterLoot.itemDrop:GetName()
      local randomLooter = tCurMasterLoot.tLooters[math.random(1, #tCurMasterLoot.tLooters)]
      self:PrintDB("Assigning " .. strItemName .. " to " .. randomLooter:GetName())
      self:PrintParty("Assigning " .. strItemLink .. " to " .. randomLooter:GetName())
      GameLib.AssignMasterLoot(tCurMasterLoot.nLootId, randomLooter)
    -- Otherwise, drop it to the master loot window
    else
      self:PrintDB("Not assigning " .. tCurMasterLoot.itemDrop:GetName())
    end
  end

  -- Update the old master loot list
  self.tOldMasterLootList = tMasterLootList
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus DesignatedLooterForItemDrop
-----------------------------------------------------------------------------------------------
-- Allow some items to go directly to some people
function FasterLootPlus:DesignatedLooterForItemDrop(tMasterLoot)
  strItemName = tMasterLoot.itemDrop:GetName()
  self:PrintDB("Entering to check designated loot for" .. strItemName)
  -- Iterate through the designated looter table, seeing if an entry exists for this item
  -- If we find a match, check to see if the looter we want is available.
  strDesignatedLooterName = self:GetDesignatedLooter(strItemName)
  if strDesignatedLooterName ~= nil then
    self:PrintDB("It is designated loot. Is the looter " .. strDesignatedLooterName .. " available?")
    for _, unitCurLooter in pairs(tMasterLoot.tLooters) do
      strCurLooterName = unitCurLooter:GetName()
      self:PrintDB("Checking " .. strCurLooterName)
      if strDesignatedLooterName == strCurLooterName then
        self:PrintDB("Yes! Give it out!")
        return unitCurLooter
      else
        self:PrintDB("No!")
      end
    end
    self:PrintDB("No designated looter available")
  else
    self:PrintDB("Not designated loot")
  end

  return nil
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus GetDesignatedLooter
-----------------------------------------------------------------------------------------------
-- Given an item name, check it against the matches in the designated looter list
-- Returns the looter's name if a match is found
-- TODO: Multiple designated looters for backups?
function FasterLootPlus:GetDesignatedLooter(strItemName)
  for strDesignatedMatch, strDesignatedLooter in pairs(tDesignatedLooters) do
    if string.match(strItemName, strDesignatedMatch) then
      return strDesignatedLooter
    end
  end
  return nil
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus GetDesignatedLooter
-----------------------------------------------------------------------------------------------
-- Filter oracle function used to determine if one particular item should
-- be randomed to a valid looter.
function FasterLootPlus:ItemDropShouldBeRandomed(tMasterLoot)
  -- Designated loot should never be randomed
  strItemName = tMasterLoot.itemDrop:GetName()
  if self:GetDesignatedLooter(strItemName) ~= nil then
    self:PrintDB("Designated loot should never be randomed")
    return false
  end

  tDetailedInfo = tMasterLoot.itemDrop:GetDetailedInfo().tPrimary
  enumItemQuality = tMasterLoot.itemDrop:GetItemQuality()
  strItemType = tMasterLoot.itemDrop:GetItemTypeName()

  --for key, val in pairs(tDetailedInfo) do
  --  self:PrintDB(key .. " => " .. tostring(val))
  --end

  -- White list items are ALWAYS randomed...
  if tWhiteList[strItemName] ~= nil then
    return true
  end

  -- Purples/Orange/Pinks are currently always interesting
  if enumItemQuality == Item.CodeEnumItemQuality.Superb or
     enumItemQuality == Item.CodeEnumItemQuality.Legendary or
     enumItemQuality == Item.CodeEnumItemQuality.Artifact then
    self:PrintDB("Can't random " .. strItemName .. " because of quality")
    return false
  end

  -- If the item level is below an item level threshold
  if tDetailedInfo.nEffectiveLevel > 55 then
    self:PrintDB("Can't random " .. strItemName .. " because of ilvl")
    return false
  end

  -- Various desirable items
  if strItemName == "Eldan Runic Module" or
     strItemName == "Suspended Biophage Cluster" or
     string.find(strItemName, "Archivos") or
     string.find(strItemName, "Warplot Boss") or
     string.match(strItemName, "Sign of %a+ - Eldan") or
     string.find(strItemName, "Ground Mount") or
     string.find(strItemName, "Hoverboard Mount") then
    self:PrintDB("Can't random " .. strItemName .. " because of name")
    return false
  end

  -- Why do people care about these?
  if strItemType == "Decor" or
     strItemType == "Improvement" then
    self:PrintDB("Can't random " .. strItemName .. " because of type")
    return false
  end

  return true
end

-----------------------------------------------------------------------------------------------
-- Save/Restore functionality
-----------------------------------------------------------------------------------------------
function FasterLootPlus:OnSave(eType)
  if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end

  return deepcopy(self.settings)
end

function FasterLootPlus:OnRestore(eType, tSavedData)
  if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end
  self.tOldMasterLootList = self:GatherMasterLoot()


  if tSavedData and tSavedData.user then
    -- Copy the settings wholesale
    self.settings = deepcopy(tSavedData)

    -- Fill in any missing values from the default options
    -- This Protects us from configuration additions in the future versions
    for key, value in pairs(tDefaultSettings) do
      if self.settings[key] == nil then
        self.settings[key] = deepcopy(tDefaultSettings[key])
      end
    end

    -- This section is for converting between versions that saved data differently

    -- Now that we've turned the save data into the most recent version, set it
    self.settings.user.version = FASTERLOOTPLUS_CURRENT_VERSION

  else
    self.tConfig = deepcopy(tDefaultOptions)
  end

  if #self.tOldMasterLootList > 0 and addonCRBML ~= nil then
    -- Try every second to bring the window back up...
    Apollo.CreateTimer("FixCRBML_Delay", 1, false)
    Apollo.StartTimer("FixCRBML_Delay")
  end
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus GetDesignatedLooter
-----------------------------------------------------------------------------------------------
-- This function is called on a timer from OnRestore to attempt to open Carbine's MasterLoot addon,
-- which doesn't automatically open if loot exists
function FasterLootPlus:FixCRBML()
  -- Hack, Carbine's ML OnLoad sets this field
  -- We use it to determine when Carbine is done loading
  if addonCRBML.tOld_MasterLootList ~= nil then
    self:PrintDB("Trying to open up MasterLoot!")
    addonCRBML:OnMasterLootUpdate(true)
    self:OnMasterLootUpdate(false)
  else
    self:PrintDB("MasterLoot not ready, trying again")
    Apollo.CreateTimer("FixCRBML_Delay", 1, false)
    Apollo.StartTimer("FixCRBML_Delay")
  end
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus Instance
-----------------------------------------------------------------------------------------------
local FasterLootPlusInst = FasterLootPlus:new()
FasterLootPlusInst:Init()