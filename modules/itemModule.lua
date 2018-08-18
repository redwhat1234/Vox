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
	[7] = 64
}

items.Type = {}

items.Type.Block = {}
items.Type.Tool = {}
items.Type.Entity = true

items.Type.Tool.Pickaxe = {3,7,10,11,12,13,14,15,16,17}
items.Type.Tool.Shovel = {1,2,3,6}

items.Type.Block.Hardness = {
	[1] = 4,
	[2] = 3,
	[3] = 6,	
	[6] = 1,
	[7] = 5,
	[8] = 5,
	[9] = 3,
	[10] = 8,
	[11] = 8,
	[12] = 12,
	[13] = 8,
	[14] = 12,
	[15] = 12,
	[16] = 16,
	[17] = 8
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
	[17] = items.Type.Block
}

items.Localization = {
	["blockGrass"] = "Grass Block",
	["blockDirt"] = "Dirt Block",
	["blockStone"] = "Stone Block",
	["Shovel"] = "Shovel",
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
	["oreCoal"] = "Coal Ore"
}

items.Id = {
	[1] = "blockGrass",
	[2] = "blockDirt",
	[3] = "blockStone",
	[4] = "Shovel",
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
	[17] = "oreCoal"
}

return items