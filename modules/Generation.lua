local models = {}
local module = {}

function RoundMultiple(n, mult)
   local h = mult * 0.5
   return (n+h) - (n+h)%mult
end

module.GeneratePlains = function(a,b, player)
	local model = Instance.new("Model")
	model.Parent = workspace.Blocks
	model.Name = math.random()
	for x = a,a+8 do
		for z = b,b+8 do
			local height = RoundMultiple(math.floor(math.noise(x/24,z/24)*51),3)
			local clone = game.ReplicatedStorage.Blocks.blockGrass:Clone()
			clone.Parent = model
			clone.CFrame = CFrame.new(x*3,height,z*3)
		end
	end
end

module.GenerateDirt = function(a,b,player)
	local model = Instance.new("Model")
	model.Parent = workspace.Blocks
	model.Name = math.random()
	for x = a,a+8 do
		for z = b,b+8 do
			local height = RoundMultiple(math.floor(math.noise(x/24,z/24)*51),3)
			local clone = game.ReplicatedStorage.Blocks.blockDirt:Clone()
			clone.Parent = model
			clone.CFrame = CFrame.new(x*3,height - 3,z*3)
		end
	end
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

module.GenerateStone = function(a,b,player)
	local model = Instance.new("Model")
	model.Parent = workspace.Blocks
	model.Name = math.random()
	for y = 2, 12 do
	for x = a,a+8 do
		for z = b,b+8 do
			local height = RoundMultiple(math.floor(math.noise(x/24,z/24)*51),3)
			local clone = determineBlock()
			clone.Parent = model
			clone.CFrame = CFrame.new(x*3,height - (3*y),z*3)
		end
	end
	end
end 

function module.generateTrees(a,b)
	for x = a,a+8 do
		for z = b,b+8 do
			local chance = math.random(1,100)
			if chance <= 15 and chance >= 5 then
			local height = RoundMultiple(math.floor(math.noise(x/24,z/24)*51),3)
			local clone = game.ReplicatedStorage.Foliage.Tree:Clone()
			clone.Parent = workspace
			clone:SetPrimaryPartCFrame(CFrame.new(x*3,height + (3),z*3))
			elseif chance <= 25 and chance >= 16 then
			local height = RoundMultiple(math.floor(math.noise(x/24,z/24)*51),3)
			local clone = game.ReplicatedStorage.Foliage.Fern:Clone()
			clone.Parent = workspace
			clone:SetPrimaryPartCFrame(CFrame.new(x*3,height + (3),z*3))
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
