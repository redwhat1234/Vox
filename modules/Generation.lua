local models = {}
local module = {}

local topBlockList = {
	["Hills"] = "blockGrass",
	["Desert"] = "blockSand"	
}

local heightMult1 = 38

function RoundMultiple(n, mult)
   local h = mult * 0.5
   return (n+h) - (n+h)%mult
end

function determineBlock()
	local chance = math.random(1,100) 
	if chance == 25 then
		return game.ReplicatedStorage.Blocks.oreIron:Clone()
	elseif chance == 20 then
		return game.ReplicatedStorage.Blocks.oreCopper:Clone()
	elseif chance == 15 then
		return game.ReplicatedStorage.Blocks.oreCoal:Clone()
	elseif chance == 10 then
		return game.ReplicatedStorage.Blocks.oreGold:Clone()
	elseif chance == 5 then
		return game.ReplicatedStorage.Blocks.oreDiamond:Clone()
	elseif chance == 30 then
		return game.ReplicatedStorage.Blocks.oreRedstone:Clone()
	else
		return game.ReplicatedStorage.Blocks.blockStone:Clone()
	end
end

function module.generateChunk(a,b,y1,y2,biome, face)
	local YWaitTime, ZWaitTime = false, false
	local topBlock = topBlockList[biome]
	local chunk = Instance.new("Model", workspace.Blocks)
	chunk.Name = "Chunk_"..#workspace.Blocks:GetChildren()
	local chunkPart = Instance.new("Part", chunk)
	chunk.PrimaryPart = chunkPart
	chunkPart.Size = Vector3.new(9*3,3,9*3)
	chunkPart.Anchored = true
	chunkPart.CFrame = CFrame.new(a*3,-65,b*3)
	chunkPart.Material = Enum.Material.Granite
	chunkPart.Color = Color3.fromRGB(0,0,0)
	for x = a,a+8 do
		for z = b,b+8 do
		local antHeight = math.floor(math.noise(x/heightMult1,z/heightMult1)*51)
		if antHeight <= -24 then
			biome = "Desert"
		else
			biome = "Hills"
		end
			local height = RoundMultiple(math.floor(math.noise(x/heightMult1,z/heightMult1)*51),3)
			local topBlock = topBlockList[biome]
			local clone = game.ReplicatedStorage.Blocks[topBlock]:Clone()
			clone.Parent = chunk
			clone.CFrame = CFrame.new(x*3,height,z*3)
			if height <= -27 then
				for i = height, -24, 3 do
					local newBlock = game.ReplicatedStorage.Blocks.blockWater:Clone()
					newBlock.Parent = chunk
					newBlock.CFrame = CFrame.new(x*3,i,z*3) 
				end
			end
		end
	end
	for x = a,a+8 do
		for z = b,b+8 do
			local height = RoundMultiple(math.floor(math.noise(x/heightMult1,z/heightMult1)*51),3)
			local clone = game.ReplicatedStorage.Blocks.blockDirt:Clone()
			clone.Parent = chunk
			clone.CFrame = CFrame.new(x*3,height - 3,z*3)
		end
	end
	print(math.floor((Vector3.new(0,y1,0)-chunkPart.Position).Magnitude)/4)
	for y = y1, math.floor((Vector3.new(0,y1,0)-chunkPart.Position).Magnitude)/4 do
		if YWaitTime then
			wait(tick)
		end
	for x = a,a+8 do
		for z = b,b+8 do
			if ZWaitTime then
				wait(tick)
			end
			local height = RoundMultiple(math.floor(math.noise(x/heightMult1,z/heightMult1)*51),3)
			local clone = determineBlock()
			clone.Parent = chunk
			clone.CFrame = CFrame.new(x*3,height - (3*y),z*3)
			if clone.CFrame.Y <= -65 then
				clone:Destroy()
			end
		end
	end
	end
	for x = a,a+8 do
		for z = b,b+8 do
			local chance = math.random(1,100)
			if chance <= 15 and chance >= 5 then
			local height = RoundMultiple(math.floor(math.noise(x/heightMult1,z/heightMult1)*51),3)
			if height <= -24 then
				
			else
			local clone = game.ReplicatedStorage.Foliage.Tree:Clone()
			clone.Parent = chunk
			clone:SetPrimaryPartCFrame(CFrame.new(x*3,height + (3),z*3))
			end
			elseif chance <= 25 and chance >= 16 then
			local height = RoundMultiple(math.floor(math.noise(x/heightMult1,z/heightMult1)*51),3)
			if height <= -24 then
				
			else
			local clone = game.ReplicatedStorage.Foliage.Fern:Clone()
			clone.Parent = chunk
			clone:SetPrimaryPartCFrame(CFrame.new(x*3,height + (3),z*3))
			end
			else
				return
			end
		end
	end
end 

module.UpdateGen = function(player)
	for index, child in pairs(workspace.Blocks:GetChildren()) do
		for i, c in pairs(child:GetChildren()) do
			if (player.Character.Torso.Position - c.Position).Magnitude > 125 then
				child.Parent = game.ReplicatedStorage.blockCache
			else
				child.Parent = workspace.Blocks
			end
		end
	end
	for index, child in pairs(game.ReplicatedStorage.blockCache:GetChildren()) do
		for i, c in pairs(child:GetChildren()) do
			if (player.Character.Torso.Position - c.Position).Magnitude > 125 then
				child.Parent = game.ReplicatedStorage.blockCache
			else
				child.Parent = workspace.Blocks
			end
		end
	end
end
return module
