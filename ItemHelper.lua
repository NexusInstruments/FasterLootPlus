local PackageName, Major, Minor, Patch = "ItemHelper", 1, 0, 0
local PkgMajor, PkgMinor = PackageName, tonumber(string.format("%02d%02d%02d", Major, Minor, Patch))
local Pkg = Apollo.GetPackage(PkgMajor)
if Pkg and (Pkg.nVersion or 0) >= PkgMinor then
  return -- no upgrade needed
end


-- Set a reference to the actual package or create an empty table
local ItemHelper = Pkg and Pkg.tPackage or {}

ItemHelper.ItemTypeGroup = {
  Rune = -1,
  Token = -2,
  Element = -3,
  Housing = -4,
  Crafting = -5,
  Consumable = -6,
  Weapon = -7,
  Armor = -8,
  Costume = -9,
  Recipe = -10,
  Junk = -11,
  Quest = -12,
  Rewards = -13,
  PVP = -14,
  Vanity = -15,
  Attunement = -16,
  Upgrade = -17
}

ItemHelper.ItemTypeGroupNames = {
  [ItemHelper.ItemTypeGroup.Rune] = "Rune",
  [ItemHelper.ItemTypeGroup.Token] = "Token",
  [ItemHelper.ItemTypeGroup.Element] = "Element",
  [ItemHelper.ItemTypeGroup.Housing] = "Housing",
  [ItemHelper.ItemTypeGroup.Crafting] = "Crafting",
  [ItemHelper.ItemTypeGroup.Consumable] = "Consumable",
  [ItemHelper.ItemTypeGroup.Weapon] = "Weapon",
  [ItemHelper.ItemTypeGroup.Armor] = "Armor",
  [ItemHelper.ItemTypeGroup.Costume] = "Costume",
  [ItemHelper.ItemTypeGroup.Recipe] = "Recipe",
  [ItemHelper.ItemTypeGroup.Junk] = "Junk",
  [ItemHelper.ItemTypeGroup.Quest] = "Quest",
  [ItemHelper.ItemTypeGroup.Rewards] = "Rewards",
  [ItemHelper.ItemTypeGroup.PVP] = "PVP",
  [ItemHelper.ItemTypeGroup.Vanity] = "Vanity",
  [ItemHelper.ItemTypeGroup.Attunement] = "Attunement",
  [ItemHelper.ItemTypeGroup.Upgrade] = "Upgrade"
}

ItemHelper.ItemTypeGroupLookup = {
  [ItemHelper.ItemTypeGroup.Rune] = { 359, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 465 },
  [ItemHelper.ItemTypeGroup.Token] = { 467, 468, 469, 470, 471, 472, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494 },
  [ItemHelper.ItemTypeGroup.Element] = { 339, 340, 341, 342, 343, 344, 345 },
  [ItemHelper.ItemTypeGroup.Housing] = { 155, 164 },
  [ItemHelper.ItemTypeGroup.Crafting] = { 196, 197, 198, 201, 202, 206, 207, 208, 211, 213, 214, 219, 221, 266, 268, 269, 270, 271, 272, 273, 274, 275, 281, 282, 306, 307, 308, 309, 318, 320, 321, 322, 324, 325, 326, 327, 330, 331, 362, 363, 364, 365, 382, 383, 384, 385, 386, 387, 390, 391, 400, 401, 402, 403, 453 },  -- 302, 458, 459, 460
  [ItemHelper.ItemTypeGroup.Consumable] = { 74, 75, 90, 139, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 312, 313, 315, 316, 317, 328, 329, 336, 337, 338, 347, 361, 389, 452, 454, 455, 456, 457 }, -- 461
  [ItemHelper.ItemTypeGroup.Weapon] = { 45, 46, 48, 51, 79, 204 },  -- 49
  [ItemHelper.ItemTypeGroup.Armor] = { 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 53, 298, 299, 300, 301 },  -- 217
  [ItemHelper.ItemTypeGroup.Costume] = { 184, 185, 186, 187, 188, 189, 191, 332, 450 },
  [ItemHelper.ItemTypeGroup.Recipe] = { 154, 254, 255, 256, 257, 258, 259, 260 },
  [ItemHelper.ItemTypeGroup.Junk] = { 180, 199, 200, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 245, 246, 248, 249, 250, 251, 252, 283 },
  [ItemHelper.ItemTypeGroup.Quest] = { 153, 169, 170, 171, 172, 173, 174 },
  [ItemHelper.ItemTypeGroup.Rewards] = { 212, 349, 448, 449, 450, 451 },
  [ItemHelper.ItemTypeGroup.PVP] = { 366, 379, 380, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447 },
  [ItemHelper.ItemTypeGroup.Vanity] = { 136, 142, 143, 183, 332, 367, 368, 369, 370, 372, 373, 374, 482, 495, 496 },
  [ItemHelper.ItemTypeGroup.Attunement] = { 392, 393 },
  [ItemHelper.ItemTypeGroup.Upgrade] = { 394, 395, 396, 397, 398, 399, 462 }
}

-- Item Types were data-mined with github.com/chronosis/FSDataMiner
ItemHelper.ItemTypes = {
  [1] = "Armor - Light - Chest",
  [2] = "Armor - Light - Legs",
  [3] = "Armor - Light - Head",
  [4] = "Armor - Light - Shoulder",
  [5] = "Armor - Light - Feet",
  [6] = "Armor - Light - Hands",
  [8] = "Armor - Medium - Chest",
  [9] = "Armor - Medium - Legs",
  [10] = "Armor - Medium - Head",
  [11] = "Armor - Medium - Shoulder",
  [12] = "Armor - Medium - Feet",
  [13] = "Armor - Medium - Hands",
  [15] = "Armor - Heavy - Chest",
  [16] = "Armor - Heavy - Legs",
  [17] = "Armor - Heavy - Head",
  [18] = "Armor - Heavy - Shoulder",
  [19] = "Armor - Heavy - Feet",
  [20] = "Armor - Heavy - Hands",
  --[28] = "",                              -- Deprecated (Literal Item with this name)
  --[30] = "",                               -- Test Scientist Build Item
  [45] = "Pistols",
  [46] = "Psyblade",
  [48] = "Claws",
  --[49] = "Plasma Rifle",                   -- Deprecated (Again Literal Item name)
  [51] = "Greatsword",
  [53] = "Energy Shield",
  [74] = "Food",
  [75] = "Potion",
  [79] = "Resonators",
  [90] = "Bandage",
  --[92] = "(Unidentified Item)",            -- Mysterious Weapon (Items that need to be IDed)
  --[116] = "(Recipe)",                       -- Recipe Halon Ring Pasta (Other Recipes from zones not in game)
  [134] = "Bag",
  [136] = "Vanity Pet",
  [139] = "Elixir",
  --[141] = "(Item Enhancement)",            -- Not Yet Implemented
  [142] = "(Vanity)",                    -- Deed to Piglet House
  [143] = "(Vanity)",                    -- Title: The Anniverserator
  --[144] = "(Charged Item)",                -- Sun Healer, Laser Pickaxe 2.0 (not implemented)
  [146] = "(Charged Item-Path)",            -- Path Usable Items
  --[147] = "(Unidentified Item)",          -- Unidentified Gloves (Items that need to be IDed -- not implemented)
  --[150] = "(Group Reagent)",              -- Summon Spell Reagent (Required to be Summoned -- not implemented)
  --[151] = "Tradeskill Reagent",              -- Drop 5 Tradeskill Reagents
  [153] = "(Quest)",                        -- Quest Item
  [154] = "(Recipe)",                        -- Recipes and Formula
  [155] = "Decor",
  [164] = "Improvement",
  [169] = "(Quest Start Item)",              -- Starts a Quest
  [170] = "(Quest Turn-in)",                -- Quest Turn-in Items
  [171] = "(Quest Turn-in)",                -- Quest Turn-in Items
  [172] = "(Quest Activated Item)",          -- Quest Usable Items
  [173] = "(Quest Activated Item)",          -- Quest Usable Items
  [174] = "(Quest Consumable)",              -- Quest Consumable Items
  [180] = "Junk",                            -- Bag of Useless Junk
  [181] = "(Novelty)",                      -- Dangerous Creatures of Nexus, DRED Experimental Pocket Teleporter
  --[182] = "(Book)",                        -- Path Ability Unlock IOU (not implemented)
  [183] = "Ground Mounts",
  [184] = "Costume - Chest",
  [185] = "Costume - Legs",
  [186] = "Costume - Head",
  [187] = "Costume - Shoulder",
  [188] = "Costume - Feet",
  [189] = "Costume - Hands",
  [191] = "(Costume)",                      -- Misc Costume Piece
  [192] = "Costume - Weapon",
  --[193] = "(Tradeskill Reagent)",          -- Drop 5 Tradeskill Reagents
  --[195] = "(Discovery Relic)",            -- Deprecated Datacube
  [196] = "(Hobby)",                        -- Cooking Ingredient / Hunter Data (not implemented)
  [197] = "Ore",
  [198] = "Herb",
  [199] = "Scrap - Weapon Parts",            -- Salvagable Containers
  [200] = "Treasure",                        -- Junk
  [201] = "Tool - Mining",
  [202] = "Omni-Plasm",
  [204] = "Heavy Gun",
  --[205] = "Locked Stat",                  -- Crafting Slot - Last seen Drop 5
  [206] = "Power Core",
  [207] = "Leather",
  [208] = "Meat",
  [210] = "Settler Resource",
  [211] = "Cloth",
  [212] = "Salvageable Container",
  [213] = "Seeds",
  [214] = "Relic Parts",
  [215] = "Gadget",
  --[217] = "Augment",                      -- Augment Slot item (not implemented)
  [219] = "Wood",
  --[220] = "Mushroom",												-- Large Renewshroom (not implemented)
  [221] = "Produce",
  [222] = "Beak - Junk",
  [223] = "Blood - Junk",
  [224] = "Bone - Junk",
  [225] = "Claw - Junk",
  [226] = "Cloth Scraps - Junk",
  [227] = "Essence - Junk",
  [228] = "Eyeball - Junk",
  [229] = "Feather - Junk",
  [230] = "Fin - Junk",
  [231] = "Fur - Junk",
  [232] = "Gland - Junk",
  [233] = "Heart - Junk",
  [234] = "Insignia - Junk",
  [235] = "Intestines - Junk",
  [236] = "Knick-Knacks - Junk",
  [237] = "Metal Scraps - Junk",
  [238] = "Oil - Junk",
  [239] = "Papers - Junk",
  [240] = "Pincher - Junk",
  [241] = "Powercell - Junk",
  [242] = "Rock - Junk",
  [243] = "Scale - Junk",
  [245] = "Slime - Junk",
  [246] = "Spores - Junk",
  [248] = "Talon - Junk",
  [249] = "Tooth - Junk",
  [250] = "Totem - Junk",
  [251] = "Tusk - Junk",
  [252] = "Venom - Junk",
  [254] = "Tailor Pattern",
  [255] = "Outfitter Guide",
  [256] = "Armorer Design",
  [257] = "Weaponsmith Schematic",
  [258] = "Technologist Formula",
  [259] = "Cook Recipe",
  [260] = "Architect Blueprint",
  [266] = "Fish",
  [268] = "Bug Meat",
  [269] = "Poultry",
  [270] = "Gem",
  [271] = "Crystal",
  [272] = "Tool - Survivalist",
  [273] = "Tool - Relic Hunter",
  [274] = "Pelt",
  [275] = "Bone",
  [281] = "Cooking - Ingredient",
  [282] = "Architect - Hardware",
  [283] = "Junk",
  [285] = "Meat Meal",
  [286] = "Poultry Meal",
  [287] = "Bug Meat Meal",
  [288] = "Vegetarian Option",
  [289] = "Seafood",
  [290] = "Algoroc Eats",
  [291] = "Deradune Victuals",
  [292] = "Celestion Comestibles",
  [293] = "Ellevar Edibles",
  [294] = "Galeras Grub",
  [295] = "Auroria Chow",
  [296] = "Whitevale Vittles",
  [298] = "Weapon Attachment",
  [299] = "Support System",
  [300] = "Key",
  [301] = "Implant",
  --[302] = "Lodestone",                              -- Lodestone (mining -- not implemented)
  [306] = "Emberine Acceleron",                        -- Weaponsmithing
  [307] = "Corium Acceleron",                          -- Weaponsmithing
  [308] = "Cyclonite Acceleron",                      -- Weaponsmithing
  [309] = "Marinax Acceleron",                        -- Weaponsmithing
  [312] = "Farside Foods",
  [313] = "Wilderrun Provisions",
  [315] = "Halon Ring Entrees",
  [316] = "Malgrave Sustenance",
  [317] = "Grimvault Meals",
  [318] = "Additive - Technologist",
  --[319] = "Locked Special",                          -- Drop 5 Tradeskill Reagent
  [320] = "Architect Catalyst",
  [321] = "Technologist Catalyst",
  [322] = "Cooking Catalyst",
  [324] = "Mining - No Commodity",
  [325] = "Meat - No Commodity",
  [326] = "Farming - No Commodity",
  [327] = "Relics - No Commodity",
  [328] = "Medishot",
  [329] = "Boost",
  [330] = "Cloth - No Commodity",
  [331] = "Modification - No Commodity",
  [332] = "Dye",
  --[334] = "Rune",																			-- Deprecated (Old Runes)
  [336] = "Elder Meals",
  [337] = "Hybrid Meals",
  [338] = "Datascape Meals",
  [339] = "Water Element",
  [340] = "Life Element",
  [341] = "Earth Element",
  [342] = "Fusion Element",
  [343] = "Fire Element",
  [344] = "Logic Element",
  [345] = "Air Element",
  [347] = "Special Diet",
  [349] = "Dye Collection",
  [359] = "Rune Fragment",
  [361] = "Field Tech",
  [362] = "Red Capacitor",                       -- Crafting
  [363] = "Blue Resonator",                      -- Crafting
  [364] = "Green Inductor",                      -- Crafting
  [365] = "Gadget Reagent",                      -- Technologist
  [366] = "Warplot Improvement",
  [367] = "Hoverboard Mounts",
  [368] = "Hoverboard Mount Flair - Front",
  [369] = "Hoverboard Mount Flair - Rear",
  [370] = "Hoverboard Mount Flair - Side",
  [372] = "Ground Mount Flair - Front",
  [373] = "Ground Mount Flair - Rear",
  [374] = "Ground Mount Flair - Side",
  --[377] = "Eldan Artifact",                    -- Old attunment turn-ins
  --[378] = "Master Schematic",                  -- Recipes not yet implemented
  [379] = "Warplot Deployable Weapon",
  [380] = "Warplot Deployable Trap",
  --[381] = "Rune Fragment Set",                 -- Old Rune Fragments (Not Implemented)
  [382] = "Smart Cloth",
  [383] = "Glamer Cloth",
  [384] = "Neurocite Ingot",
  [385] = "Vitalium Ingot",
  [386] = "Tech Leather",
  [387] = "Sacred Leather",
  [389] = "Meal - No Commodity",
  [390] = "Power Core",
  [391] = "Tradeskill Reagent",                  -- Carnage Jack
  [392] = "Imbuement Material",
  [393] = "Security Key Material",
  [394] = "Warrior AMP",
  [395] = "Engineer AMP",
  [396] = "Medic AMP",
  [397] = "Stalker AMP",
  [398] = "Esper AMP",
  [399] = "Spellslinger AMP",
  [400] = "Carcass - Beast",
  [401] = "Carcass - Bird",
  [402] = "Carcass - Bug",
  [403] = "Carcass - Fish",
  [404] = "Attributes",                          -- Rune (Fire)
  [405] = "General Rune Sets",
  [406] = "Class Rune Sets",
  [407] = "Elder Rune Sets",
  [408] = "Attributes",                          -- Rune (Water)
  [409] = "General Rune Sets",
  [410] = "Class Rune Sets",
  [411] = "Elder Rune Sets",
  [412] = "Attributes",                          -- Rune (Earth)
  [413] = "General Rune Sets",
  [414] = "Class Rune Sets",
  [415] = "Elder Rune Sets",
  [416] = "Attributes",                          -- Rune (Air)
  [417] = "General Rune Sets",
  [418] = "Class Rune Sets",
  [419] = "Elder Rune Sets",
  [420] = "Attributes",                          -- Rune (Life)
  [421] = "General Rune Sets",
  [422] = "Class Rune Sets",
  [423] = "Elder Rune Sets",
  [424] = "Attributes",                          -- Rune (Logic)
  [425] = "General Rune Sets",
  [426] = "Class Rune Sets",
  [427] = "Elder Rune Sets",
  [428] = "Attributes",                          -- Rune (Fusion)
  [429] = "General Rune Sets",
  [430] = "Class Rune Sets",
  [431] = "Elder Rune Sets",
  [433] = "PvP Attributes",                      -- Rune (Fire)
  [434] = "PvP Attributes",                      -- Rune (Water)
  [435] = "PvP Attributes",                      -- Rune (Earth)
  [436] = "PvP Attributes",                      -- Rune (Air)
  [437] = "PvP Attributes",                      -- Rune (Life)
  [438] = "PvP Attributes",                      -- Rune (Logic)
  [439] = "PvP Attributes",                      -- Rune (Fusion)
  [440] = "PvP Rune Sets",                       -- Rune (Fire)
  [441] = "PvP Rune Sets",                       -- Rune (Water)
  [442] = "PvP Rune Sets",                       -- Rune (Earth)
  [443] = "PvP Rune Sets",                       -- Rune (Air)
  [444] = "PvP Rune Sets",                       -- Rune (Life)
  [445] = "PvP Rune Sets",                       -- Rune (Logic)
  [446] = "PvP Rune Sets",                       -- Rune (Fusion)
  [447] = "PvP Loot Chest",
  [448] = "Tradeskill Loot Bag",
  [449] = "Loot Bag",
  [450] = "Dye Loot Bag",
  [451] = "Housing Decor Loot Chest",
  [452] = "Blighthaven Bites",
  [453] = "Cloth Salvageables",
  [454] = "The Defile Delicacies",
  [455] = "Nexus Nourishments",
  [456] = "Star-Comm Snacks",
  [457] = "Ultimate Protogames Beverages",
  [458] = "Carnageknit Cloth",                   -- Mastercraft (Not implemented)
  [459] = "Phagesilk Cloth",                     -- Mastercraft (Not implemented)
  [460] = "Eldanweave Cloth",                    -- Mastercraft (Not implemented)
  [461] = "Skeech Soup",                         -- Food
  [462] = "Unlocks and Upgrades",                -- AMP/Ability Points
  --[463] = "Runecrafting Inscription",          -- Runecrafting Recipe (Not implemented)
  [465] = "Runic Flux",
  --[466] = "Novelty Weapons",                   -- Gourd of War (Not implemented -- event)
  [467] = "Token - Heavy Armor - Head",
  [468] = "Token - Heavy Armor - Shoulder",
  [469] = "Token - Heavy Armor - Chest",
  [470] = "Token - Heavy Armor - Legs",
  [471] = "Token - Heavy Armor - Hands",
  [472] = "Token - Heavy Armor - Feet",
  [482] = "???",                                 -- Lucky Lopp Leg
  [483] = "Token - Medium Armor - Head",
  [484] = "Token - Medium Armor - Shoulder",
  [485] = "Token - Medium Armor - Chest",
  [486] = "Token - Medium Armor - Legs",
  [487] = "Token - Medium Armor - Hands",
  [488] = "Token - Medium Armor - Feet",
  [489] = "Token - Light Armor - Head",
  [490] = "Token - Light Armor - Shoulder",
  [491] = "Token - Light Armor - Chest",
  [492] = "Token - Light Armor - Legs",
  [493] = "Token - Light Armor - Hands",
  [494] = "Token - Light Armor - Feet",
  [495] = "(Vanity)",                            -- Appearance Modification Token
  [496] = "Toy",                                 -- Official Anniversary Party-Starter
  [499] = "(Malfunctioning Item)"                -- When item needs a /ticket
}

function ItemHelper:IsItemTypeOfGroup(typeID, groupID)
  local test = false
  local group = ItemHelper.ItemTypeGroupLookup[groupID]
  if group then
    for k,v in pairs(group) do
      if v == typeID then
        test = true
      end
    end
  end
  return test
end

function ItemHelper:IsItemOfType(item, typeID)
  return item.type == typeID
end

function ItemHelper:IsItemOfGroup(item, groupID)
  return ItemHelper:IsItemTypeOfGroup(item.type, groupID)
end

Apollo.RegisterPackage(ItemHelper, PkgMajor, PkgMinor, {})
