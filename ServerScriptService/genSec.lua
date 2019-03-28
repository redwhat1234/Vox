local self = {}

function RoundMultiple(n, mult)
   local h = mult * 0.5
   return (n+h) - (n+h)%mult
end

local waterTable = {}

function self:checkBlockSpace(pos, ignore)
	local a, b = Vector3.new(pos.X-1.5, pos.Y-1.5, pos.Z-1.5), Vector3.new(pos.X+1.5, pos.Y+1.5, pos.Z+1.5)
	local aabb = Region3.new(a,b)
	local val = workspace:IsRegion3Empty(aabb, ignore)
end

function self:registerWaterPhysics()
	
end

function self:makeDirt(x,y,z,c)
   if self:checkBlockSpace(Vector3.new(x,y,z), nil) == false then return end
   local Part = game.ReplicatedStorage.Blocks.blockDirt:Clone()
   Part.Parent = c
   Part.CFrame = CFrame.new(x*3,y,z*3)
end

function self:makeStone(x,y,z,c)
	if self:checkBlockSpace(Vector3.new(x,y,z), nil) == false then return end
   local Part = game.ReplicatedStorage.Blocks.blockStone:Clone()
   Part.Parent = c
   Part.CFrame = CFrame.new(x*3,y,z*3)
end

function self:makeGrass(x,y,z,c)
	if self:checkBlockSpace(Vector3.new(x,y,z), nil) == false then return end
   local Part = game.ReplicatedStorage.Blocks.blockGrass:Clone()
   Part.Parent = c
   Part.CFrame = CFrame.new(x*3,y,z*3)
end

function self:makeBedrock(x,y,z,c)
	if self:checkBlockSpace(Vector3.new(x,y,z), nil) == false then return end
   local Part = game.ReplicatedStorage.Blocks.blockBedrock:Clone()
   Part.Parent = c
   Part.CFrame = CFrame.new(x*3,y,z*3)
end

function self:makeLavaLayer(x,y,z,c)
	if self:checkBlockSpace(Vector3.new(x,y,z), nil) == false then return end
   local Part = game.ReplicatedStorage.Blocks.blockLava:Clone()
   Part.Parent = c
   Part.CFrame = CFrame.new(x*3,y,(z))
end

function self:makeWater(x,y,z,c)
	if self:checkBlockSpace(Vector3.new(x,y,z), nil) == false then return end
   local Part = game.ReplicatedStorage.Blocks.blockWater:Clone()
   Part.Parent = c
   Part.CFrame = CFrame.new(x*3,y,z*3)
end

function self:makeSand(x,y,z,c)
	if self:checkBlockSpace(Vector3.new(x,y,z), nil) == false then return end
   local Part = game.ReplicatedStorage.Blocks.blockSand:Clone()
   Part.Parent = c
   Part.CFrame = CFrame.new(x*3,y,z*3)
end

function self:makeLavaPocket(x,y,z,c)
	print("lPocket2")
	local x1 = math.random((3*4), (3*6))
	local x2 = math.random(-(3*8), -(3*5))
	
	local y1 = math.random((3*4), (3*8))
	local y2 = math.random((-3*3), -(3*1))
	
	local z1 = math.random((3*4), (3*6))
	local z2 = math.random(-(3*8), -(3*5))
	
	local v1 = Vector3.new((x*3-x2*3)-1.5, y-y2-1.5, (z*3-z2*3)-1.5)
	local v2 = Vector3.new((x*3+x1*3)+1.5, y+y1+1.5, (z*3+z1*3)+1.5)	
	
	local region = Region3.new(
		v1,
		v2	
	)
	
	for i,v in pairs(workspace:FindPartsInRegion3(region)) do
		print(v.Name)
		v:Destroy()
	end
	
	print("lPocket3")
	
	for x = v2.X, v1.X do
		for z = v2.Z, v1.Z do
			
--			local x = RoundMultiple(x,3)
--			local z = RoundMultiple(z,3)
			local y = RoundMultiple(v1.Y, 3)
			
			
			self:makeLavaLayer(x,y,z,c)
		end
	end
end

function self:generateTree(tree,x,y,z,c, backupVector)
	x,y,z = backupVector.X, backupVector.Y, backupVector.Z
	local newTree = tree:Clone()
	newTree.Parent = c
	
	local rot = RoundMultiple(math.random(-180,180), 90)
	
	newTree:SetPrimaryPartCFrame(CFrame.new(x, y, z))
	newTree:SetPrimaryPartCFrame(newTree.PrimaryPart.CFrame * CFrame.Angles(0,math.rad(rot),0))
	for i,v in pairs(newTree:GetChildren()) do
		if v.Name == "blockLeave" then
			if self:checkBlockSpace(v.Position, v.Parent) == false then
				v:Destroy()
			end
		end
	end
	return true
end

function self:generateFern(tree,x,y,z,c)
	local newTree = tree:Clone()
	newTree.Parent = c
	if tree.Name == "blockPumpkin" then
		newTree.CFrame = CFrame.new(x, y, z)
	else
		newTree:SetPrimaryPartCFrame(CFrame.new(x, y, z))
		newTree.Mod:SetPrimaryPartCFrame(newTree.Mod.PrimaryPart.CFrame * CFrame.Angles(0,math.random(-180,180),0))
	end
	return true
end

local caves = 0

function self:genCaves(seed, power, res, worldHeight, freq)
	caves = caves + 1
	local x = math.noise(
		caves*res/freq,
		caves*res/freq,
		seed	
	)
	local z = math.noise(
		((caves*x)*res)/freq,
		((caves*x)*res)/freq,
		seed
	)
	
	local y1 = math.noise(
		((x)*freq)/res,
		((z)*freq)/res,
		seed
	)

	local y2 = math.noise(
		((x)*freq)*.55/res,
		((z)*freq)*.55/res,
		seed
	)
	
	local y3 = math.noise(
		((x)*freq)*8/res,
		((z)*freq)*8/res,
		seed
	)
	
	local y = (y1+y2*power*power)+y3
	
	y = RoundMultiple(y, 3)
	
	local x,z = x*500*(power/freq), z*500*(power/freq)
	
	local cf = CFrame.new(x,y,z)
	
	print(x..","..z)
	
	local distance = math.noise(x,z,seed)*(500)
	
	for i = 1, distance do
		
		game:GetService("RunService").Stepped:Wait()
		
		local wormx = math.noise(
			x*(i)*freq/res,
			z*(i)*freq/res,
			seed	
		)
		local wormz = math.noise(
			x*(i)+wormx*freq/res,
			z*(i)+wormx*freq/res,
			seed	
		)
		local wormy = math.noise(
			wormx+wormz*(x)*(i)*freq/res,
			wormx+wormz*(x)*(i)*freq/res,
			seed
		)
		
		local min, max = Vector3.new(
			x+(wormx-math.random(2,3))*3,
			y+(wormy-math.random(2,3))*3,
		    z+(wormz-math.random(2,3))*3
		), 
		                 Vector3.new(
			x+(wormx+math.random(2,3))*3,
			y+(wormy+math.random(2,3))*3,
		    z+(wormz+math.random(2,3))*3
		)
		
		cf = cf*CFrame.Angles(wormx*3,wormy,wormz*3)*CFrame.new(0,0,-3)
		
		local region = Region3.new(cf.p+min, cf.p+max)
		
		print("[Cave] Vec("..cf.X..","..cf.Y..","..cf.Z..")")
		
		for i,v in pairs(workspace:FindPartsInRegion3WithIgnoreList(region, game:GetService("CollectionService"):GetTagged("NotCaveMod"))) do
			if v.ClassName == "Part" or v.ClassName == "UnionOperation" then
				v:Destroy()
			end
		end
	end
end

function self:generateFoliage(x,y,z,chunk, backupVector)
	local chance = math.random(1,3)
	if chance == 1 then
		local c2 = math.random(1,3)
		
		if c2 > 3 then
			c2 = math.floor(c2)
		else
			c2 = math.ceil(c2)
		end
		
		local a = 0
		local object
--		for i,v in pairs(game.ReplicatedStorage.Foliage.Trees:GetChildren()) do
--			a = a + 1
--			if a == c2 then
--				object = v
--			end
--		end
		
		if object == nil then
			local thing = math.random(1,2.5)
			if thing < 2 then
				object = game.ReplicatedStorage.Foliage.Trees.oakTree
			else
				object = game.ReplicatedStorage.Foliage.Trees.oakTreeBig
			end
		end
		
		x,y,z = backupVector.X, backupVector.Y, backupVector.Z
		
		self:generateTree(object,x,y,z,chunk, backupVector)
	else
		
		if chance > 3 then
			chance = math.floor(chance)
		else
			chance = math.ceil(chance)
			if chance == 1 then
				chance = 2
			end
		end
		
		local a = 0
		local object
		
		
		for i,v in pairs(game.ReplicatedStorage.Foliage:GetChildren()) do
			a = a + 1
			if a == chance then
				object = v
			end
		end
		
		if object == game.ReplicatedStorage.Foliage.Trees then
			local c3 = math.random(1,20)
			if c3 > 10 then
				object = game.ReplicatedStorage.Foliage.Grass
			else
				if chance > .5 then
					object = game.ReplicatedStorage.Foliage.Fern
				elseif chance < 1.2 then
					object = game.ReplicatedStorage.Blocks.blockPumpkin
				end
			end
		end
		
		self:generateFern(object,x,y,z,chunk, backupVector)
	end
end

function self:checkOreChance(y)
	local chance = math.random(1,10)
	if chance == 5 then
		return true
	else
		return false
	end
end

function self:makeOre(x,y,z,c)
	
	local oreHeightTable = {
		["oreiron"]={
			height=Vector2.new(-(3*3),-(24*3)),	
		},
		["orecoal"]={
			height=Vector2.new(-(4*3),-(24*3)),
		},
		["oregold"]={
			height=Vector2.new(-(15*3),-(24*3)),
		},
		["oreredstone"]={
			height=Vector2.new(-(16*3),-(24*3)),
		},
		["orediamond"]={
			height=Vector2.new(-(18*3),-(24*3)),
		},
		["oresapphire"]={
			height=Vector2.new(-(18*3),-(24*3)),
		},
	}
	
	local function returnRandomOre(y)
		local ranValue = math.random(1,6)
		
		local x = 0
		
		for i,v in pairs(oreHeightTable) do
			x = x + 1
			if x == ranValue then
				return v
			end
		end
	end
	
	local function getOreName(ore)
		for name, height in pairs(oreHeightTable) do
			if height == ore then
				return name
			end
		end
	end
	
	local function runHeightReqCheck(ore, y)
		if ore.height.X > y then
			return true
		else
			return false
		end
	end
	
	local function makeNewOre(oreName)
		local newOre
		
		for i,v in pairs(game.ReplicatedStorage.Blocks:GetChildren()) do
			if string.lower(v.Name) == oreName then
				newOre = v:Clone()
			end
		end
		
		if newOre ~= nil then
			newOre.Parent = c
			newOre.CFrame = CFrame.new(x*3, y, z*3)
		else
			return self:makeStone(x,y,z,c)
		end
	end
	
	local function generateOre()
		local newOreTable = returnRandomOre()
		
		if runHeightReqCheck(newOreTable, y) then
			
			local oreName = getOreName(newOreTable)
			makeNewOre(oreName) 
			
			return true
		else
			newOreTable = returnRandomOre()
			
			if runHeightReqCheck(newOreTable, y) then
				
				local oreName = getOreName(newOreTable)
				makeNewOre(oreName) 
				
				return true
			else
				return self:makeStone(x,y,z,c)
			end
		end
	end
	
	generateOre()
	
end

return self