local items = {}

function items:itemLookUp(item)
	for i,v in pairs(items.Id) do
		if item == v then
			return i
		end
	end
end

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
	[21] = 64
}

items.Type = {}

items.Type.Block = {}
items.Type.Block.Interactable = {}
items.Type.Tool = {}
items.Type.Entity = {}

items.Type.Tool.Pickaxe = {3,7,10,11,12,13,14,15,16,17,18,20}
items.Type.Tool.Shovel = {1,2,3,6,19}

items.Type.Block.Hardness = {
	[1] = 3,
	[2] = 3,
	[3] = 6,	
	[6] = 1,
	[7] = 5,
	[8] = 5,
	[9] = 3,
	[10] = 6,
	[11] = 6,
	[12] = 6,
	[13] = 6,
	[14] = 6,
	[15] = 6,
	[16] = 6,
	[17] = 6,
	[18] = 6,
	[19] = 3,
	[20] = 6
}

items.itemSubTypes = {
	[4] = items.Type.Tool.Shovel,
	[5] = items.Type.Tool.Pickaxe	
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
	[21] = items.Type.Entity
}

items.itemImage = {
	[1] = "rbxgameasset://Images/grassIcon",
	[2] = "rbxgameasset://Images/dirtIcon",
	[3] = "rbxgameasset://Images/stoneIcon",
	[4] = "rbxgameasset://Images/toolStoneShovel",
	[5] = "rbxgameasset://Images/toolStonePickaxe",
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
	[21] = "rbxgameasset://Images/WoodenStick"
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
	["metaStick"] = "Wooden Stick"
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
	[21] = "metaStick"
}

return items