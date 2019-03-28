
local items = {}

function items:itemLookUp(item)
	for i,v in pairs(items.Id) do
		if item == v then
			return i
		end
	end
end

items.breakId = {
	[1] = "rbxgameasset://Images/destroy_stage_0",
	[2] = "rbxgameasset://Images/destroy_stage_1",
	[3] = "rbxgameasset://Images/destroy_stage_2",
	[4] = "rbxgameasset://Images/destroy_stage_3",
	[5] = "rbxgameasset://Images/destroy_stage_4",
	[6] = "rbxgameasset://Images/destroy_stage_5",
	[7] = "rbxgameasset://Images/destroy_stage_6",
	[8] = "rbxgameasset://Images/destroy_stage_7",
	[9] = "rbxgameasset://Images/destroy_stage_8",
	[10] = "rbxgameasset://Images/destroy_stage_9"
}

items.faceIds = {
	[1] = "Back",
	[2] = "Front",
	[3] = "Left",
	[4] = "Right",
	[5] = "Bottom",
	[6] = "Top"
}

items.maxStacks = {
	[1] = 64,
	[2] = 64,
	[3] = 64,
	[4] = 1,
	[5] = 1,
	[6] = 64,
	[7] = 64,
	[8] = 64,
	[9] = 64,
	[10] = 64,
	[11] = 64,
	[12] = 64,
	[13] = 64,
	[14] = 64,
	[15] = 64,
	[16] = 64,
	[17] = 64,
	[18] = 64,
	[19] = 64,
	[20] = 64,
	[21] = 64,
	[22] = 1,
	[23] = 1,
	[24] = 64,
	[25] = 64,
	[26] = 64,
	[27] = 64,
	[28] = 64,
	[29] = 64,
	[30] = 64,
	[31] = 64,
	[32] = 1,
	[33] = 1,
	[34] = 1,
	[35] = 1,
	[36] = 16,
	[37] = 64,
	[38] = 64,
	[39] = 64,
	[40] = 1,
	[44] = 64,
	[45] = 16,
	[46] = 64,
	[47] = 64,
	[48] = 64,
	[49] = 64,
	[50] = 16,
	[51] = 1,
	[52] = 1,
	[53] = 64,
	[54] = 1,
	[55] = 16,
	[56] = 64,
	[57] = 64,
}

items.Type = {}

items.Type.Block = {}
items.Type.Block.Interactable = {}
items.Type.Tool = {}
items.Type.Entity = {}

items.Type.Entity.Seed = {}
items.Type.Entity.Bucket = {}

items.Type.Entity.Seed.GrowTable = {
	[48] = {
		["Images"] = {
			[1] = "rbxgameasset://Images/wheat_stage2",
			[2] = "rbxgameasset://Images/wheat_stage3",
			[3] = "rbxgameasset://Images/wheat_stage4",
			[4] = "rbxgameasset://Images/wheat_stage5",
			[5] = "rbxgameasset://Images/wheat_stage6",
			[6] = "rbxgameasset://Images/wheat_stage7"
		},
		["TotalTime"] = 64,
		["InitImage"] = "rbxgameasset://Images/wheat_stage1",
		["returnId"] = 49,
	}	
}

items.Type.Tool.Axe = {}
items.Type.Tool.Pickaxe = {3,10,11,12,13,14,15,16,17,18,20,29}
items.Type.Tool.Shovel = {1,2,6,19,44}
items.Type.Tool.Hand = {1,2,8,9,19,24,25,26,27,28,29,37,38,39,44,45,46,47}
items.Type.Tool.Hoe = {}

items.Type.Tool.toolLevel = {
	[0] = 1,
	[4] = 4,
	[5] = 4,
	[22] = 2,
	[23] = 2,
	[32] = 6,
	[33] = 6,
	[34] = 12,
	[35] = 12,
	[40] = 4,
}

items.Type.Tool.Durability = {}

items.Type.Block.Interactable.onUse = {
	[20] = function()
		
	end,
	[36] = function(door)
		if door.isOpen.Value == false then
			for i = 1, 90, 2 do
				wait(tick)
				door.door:setPrimaryPartCFrame(door.door.PrimaryPart.CFrame * CFrame.Angles(0,2,0))
			end
		else
			for i = 1, 90, 2 do
				wait(tick)
				door.door:setPrimaryPartCFrame(door.door.PrimaryPart.CFrame * CFrame.Angles(0,-2,0))
			end
		end
		door.isOpen.Value = not door.isOpen.Value
		return true
	end	
}

items.Type.Block.Hardness = {
	[1] = 2,
	[2] = 2,
	[3] = 6,	
	[6] = 1,
	[7] = 2,
	[8] = 2,
	[9] = .5,
	[10] = 8,
	[11] = 7,
	[12] = 7,
	[13] = 7,
	[14] = 10,
	[15] = 10,
	[16] = 14,
	[17] = 7,
	[18] = 6,
	[19] = 3,
	[20] = 6,
	[24] = 2,
	[25] = 2,
	[26] = 2,
	[27] = .5,
	[28] = 2,
	[29] = .25,
	[36] = 2,
	[37] = 2,
	[38] = 2,
	[39] = 2,
	[44] = 2,
	[45] = .1,
	[46] = .1,
	[47] = .1,
	[53] = 20,
	[56] = .1,
}

items.itemSubTypes = {
	[0] = items.Type.Tool.Hand,
	[4] = items.Type.Tool.Shovel,
	[5] = items.Type.Tool.Pickaxe,
	[22] = items.Type.Tool.Shovel,
	[23] = items.Type.Tool.Pickaxe,
	[32] = items.Type.Tool.Pickaxe,
	[33] = items.Type.Tool.Shovel,
	[34] = items.Type.Tool.Pickaxe,
	[35] = items.Type.Tool.Shovel,
	[40] = items.Type.Tool.Hoe,
}

items.itemTypes = {
	[1] = items.Type.Block,
	[2] = items.Type.Block,
	[3] = items.Type.Block,
	[4] = items.Type.Tool,
	[5] = items.Type.Tool,
	[6] = items.Type.Block,
	[7] = items.Type.Block,
	[8] = items.Type.Block,
	[9] = items.Type.Block,
	[10] = items.Type.Block,
	[11] = items.Type.Block,
	[12] = items.Type.Block,
	[13] = items.Type.Block,
	[14] = items.Type.Block,
	[15] = items.Type.Block,
	[16] = items.Type.Block,
	[17] = items.Type.Block,
	[18] = items.Type.Block,
	[19] = items.Type.Block,
	[20] = items.Type.Block.Interactable,
	[21] = items.Type.Entity,
	[22] = items.Type.Tool,
	[23] = items.Type.Tool,
	[24] = items.Type.Block,
	[25] = items.Type.Block,
	[26] = items.Type.Block,
	[27] = items.Type.Block,
	[28] = items.Type.Block,
	[29] = items.Type.Block,
	[30] = items.Type.Entity,
	[31] = items.Type.Entity,
	[32] = items.Type.Tool,
	[33] = items.Type.Tool,
	[34] = items.Type.Tool,
	[35] = items.Type.Tool,
	[36] = items.Type.Block.Interactable,
	[37] = items.Type.Block,
	[38] = items.Type.Block,
	[39] = items.Type.Block,
	[40] = items.Type.Tool,
	[44] = items.Type.Block,
	[45] = items.Type.Block,
	[46] = items.Type.Block,
	[47] = items.Type.Block,
	[48] = items.Type.Entity.Seed,
	[49] = items.Type.Entity,
	[50] = items.Type.Entity.Bucket,
	[51] = items.Type.Entity.Bucket,
	[52] = items.Type.Entity.Bucket,
	[53] = items.Type.Block,
	[54] = items.Type.Entity.FS,
	[55] = items.Type.Entity,
	[56] = items.Type.Block,
	[57] = items.Type.Entity
}

items.itemImage = {
	[1] = "rbxgameasset://Images/grassIcon",
	[2] = "rbxgameasset://Images/dirtIcon",
	[3] = "rbxgameasset://Images/stoneIcon",
	[4] = "rbxgameasset://Images/stone_shovel",
	[5] = "rbxgameasset://Images/stone_pickaxe",
	[6] = "",
	[7] = "rbxgameasset://Images/plankIcon",
	[8] = "",
	[9] = "",
	[10] = "",
	[11] = "",
	[12] = "",
	[13] = "",
	[14] = "",
	[15] = "",
	[16] = "",
	[17] = "",
	[18] = "",
	[19] = "",
	[20] = "",
	[21] = "rbxgameasset://Images/stick",
	[22] = "rbxgameasset://Images/wooden_shovel",
	[23] = "rbxgameasset://Images/wooden_pickaxe",
	[24] = "",
	[25] = "",
	[26] = "",
	[27] = "",
	[28] = "",
	[29] = "",
	[30] = "rbxgameasset://Images/ironIngot",
	[31] = "rbxgameasset://Images/metaDiamond",
	[32] = "rbxgameasset://Images/iron_pickaxe",
	[33] = "rbxgameasset://Images/iron_shovel",
	[34] = "rbxgameasset://Images/diamond_pickaxe",
	[35] = "rbxgameasset://Images/diamond_shovel",
	[36] = "",
	[37] = "",
	[38] = "",
	[39] = "",
	[40] = "",
	[44] = "",
	[45] = "rbxgameasset://Images/oak_sappling",
	[46] = "rbxgameasset://Images/fern",
	[47] = "rbxgameasset://Images/grass",
	[48] = "rbxgameasset://Images/wheat_seeds",
	[49] = "rbxgameasset://Images/wheat",
	[50] = "rbxgameasset://Images/bucket",
	[51] = "rbxgameasset://Images/wwater_bucket",
	[52] = "rbxgameasset://Images/lava_bucket",
	[53] = "",
	[54] = "rbxgameasset://Images/flint_and_steel",
	[55] = "rbxgameasset://Images/flint",
	[56] = "",
	[57] = "rbxgameasset://Images/coal(1)"
}

items.Localization = {
	["blockGrass"] = "Grass Block",
	["blockDirt"] = "Dirt Block",
	["blockStone"] = "Stone Block",
	["toolStoneShovel"] = "Stone Shovel",
	["toolStonePick"] = "Stone Pickaxe",
	["metaTorch"] = "Torch",
	["blockPlank"] = "Wooden Plank",
	["blockLog"] = "Log",
	["blockLeave"] = "Leaves",
	["oreIron"] = "Iron Ore",
	["oreTin"] = "Tin Ore",
	["oreSilver"] = "Silver Ore",
	["oreCopper"] = "Copper Ore",
	["oreGold"] = "Gold Ore",
	["oreRedstone"] = "Redstone Ore",
	["oreDiamond"] = "Diamond Ore",
	["oreCoal"] = "Coal Ore",
	["blockStoneBrick"] = "Stone Brick",
	["blockSand"] = "Sand",
	["blockFurnace"] = "Furnace",
	["metaStick"] = "Wooden Stick",
	["toolWoodenPick"] = "Wooden Pickaxe",
	["toolWoodenShovel"] = "Wooden Shovel",
	["blockSprucePlank"] = "Spruce Plank",
	["blockSpruceLeave"] = "Spruce Leaves",
	["blockSpruceLog"] = "Spruce Log",
	["blockBirchLog"] = "Birch Log",
	["blockBirchPlank"] = "Birch Plank",
	["blockGlass"] = "Glass",
	["metaIronIngot"] = "Iron Ingot",
	["metaDiamond"] = "Diamond",
	["toolIronPick"] = "Iron Pickaxe",
	["toolIronShovel"] = "Iron Shovel",
	["toolDiamondPick"] = "Diamond Pickaxe",
	["toolDiamondShovel"] = "Diamond Shovel",
	["blockDoor"] = "Wooden Door",
	["blockPumpkin"] = "Pumpkin",
	["blockLantern"] = "Jack O' Lantern",
	["blockLanternUnlit"] = "Jack O' Lantern",
	["toolWoodenHoe"] = "Wooden Hoe",
	["blockFarmland"] = "Farmland",
	["blockOakSappling"] = "Oak Sappling",
	["blockFern"] = "Fern",
	["blockMetaGrass"] = "Grass",
	["blockWheatSeed"] = "Wheat Seeds",
	["blockWheat"] = "Wheat",
	["blockBucket"] = "Bucket",
	["blockWaterBucket"] = "Water Bucket",
	["blockLavaBucket"] = "Lava Bucket",
	["blockObsidian"] = "Obsidian",
	["blockFlintSteel"] = "Flint and Steel",
	["blockFlint"] = "Flint",
	["blockGravel"] = "Gravel",
	["metaCoal"] = "Coal"
}

items.Id = {
	[1] = "blockGrass",
	[2] = "blockDirt",
	[3] = "blockStone",
	[4] = "toolStoneShovel",
	[5] = "toolStonePick",	
	[6] = "metaTorch",
	[7] = "blockPlank",
	[8] = "blockLog",
	[9] = "blockLeave",
	[10] = "oreIron",
	[11] = "oreTin",
	[12] = "oreSilver",
	[13] = "oreCopper",
	[14] = "oreGold",
	[15] = "oreRedstone",
	[16] = "oreDiamond",
	[17] = "oreCoal",
	[18] = "blockStoneBrick",
	[19] = "blockSand",
	[20] = "blockFurnace",
	[21] = "metaStick",
	[22] = "toolWoodenShovel",
	[23] = "toolWoodenPick",
	[24] = "blockBirchPlank",
	[25] = "blockBirchLog",
	[26] = "blockSpruceLog",
	[27] = "blockSpruceLeave",
	[28] = "blockSprucePlank",
	[29] = "blockGlass",
	[30] = "metaIronIngot",
	[31] = "metaDiamond",
	[32] = "toolIronPick",
	[33] = "toolIronShovel",
	[34] = "toolDiamondPick",
	[35] = "toolDiamondShovel",
	[36] = "blockDoor",
	[37] = "blockPumpkin",
	[38] = "blockLantern",
	[39] = "blockLanternUnlit",
	[40] = "toolWoodenHoe",
	[41] = "toolStoneHoe",
	[42] = "toolIronHoe",
	[43] = "toolDiamondHoe",
	[44] = "blockFarmland",
	[45] = "blockOakSappling",
	[46] = "blockFern",
	[47] = "blockMetaGrass",
	[48] = "blockWheatSeed",
	[49] = "blockWheat",
	[50] = "blockBucket",
	[51] = "blockWaterBucket",
	[52] = "blockLavaBucket",
	[53] = "blockObsidian",
	[54] = "blockFlintSteel",
	[55] = "blockFlint",
	[56] = "blockGravel",
	[57] = "metaCoal"
}

return items