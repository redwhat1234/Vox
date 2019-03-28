local seed = math.random(1, 10e6)
local frequency = 12
local power = 8
local resolution = 200
local maxWorldDepth = -(24*3)

local worldVec1 = Vector3.new((-288), maxWorldDepth+(5*3), (-288))
local worldVec2 = Vector3.new((288), maxWorldDepth+(20*3), (288))

local gen = require(script.genSec)

function RoundMultiple(n, mult)
   local h = mult * 0.5
   return (n+h) - (n+h)%mult
end

function makeTopLayer(x,y,z,c)
	
	local function runWaterGen()
		for i = y+3, -6, 3 do
			gen:makeWater(x,i,z,c)
		end
	end
	
	if y > 10 then
		
		gen:makeStone(x,y,z,c)
		
	elseif y < -6 then
		
		runWaterGen()
		
		if y < -12 then
			gen:makeDirt(x,y,z,c)
		else
			gen:makeSand(x,y,z,c)
		end
		
	else
		
		gen:makeGrass(x,y,z,c)
		
		local chance = math.random(1,10)
		
		if chance == 5 then
			print(x..y..z.." :: "..c.Name)
			local bVec = Vector3.new(x*3,y+3,z*3)
			gen:generateFoliage(x*3,y+3,z*3,c, bVec)
		end
	end
end

function generateCaves(amt)
	for i = 1, amt do
		gen:genCaves(seed, power, resolution, maxWorldDepth, frequency)
	end
end

function makeChunk(a,b,chunk, c2)
local stone, top = Instance.new("Model", chunk),Instance.new("Model", chunk)
--local stonec, topc = Instance.new("Model", c2),Instance.new("Model", c2)
stone.Name = "stone"
top.Name = "top"
--stonec.Name = "stone"
--topc.Name = "top"
for x = a, a+8 do
	game:GetService("RunService").Stepped:Wait()
	for z = b, b+8 do
        local y1 = math.noise(
            ((x)*frequency)/resolution,
            ((z)*frequency)/resolution,
            seed
        )

		local y2 = math.noise(
            ((x)*frequency*.55)/resolution,
            ((z)*frequency*.55)/resolution,
            seed
		)
		
		local y3 = math.noise(
            ((x)*frequency*8)/resolution,
            ((z)*frequency*8)/resolution,
            seed
        )
		
		local y4 = math.noise(
            ((x)*frequency*16)/resolution,
            ((z)*frequency*16)/resolution,
            seed
        )
        
		local y = (y1*y2*power*power)+(y3+y4)
		local y = RoundMultiple(y,3)
		
		if y <= maxWorldDepth then
			y = maxWorldDepth + 12 -- redundancy phhbbbbpppp
		end
		
		makeTopLayer(x,y,z,top)
		
		for i = maxWorldDepth, y-3, 3 do
			if i < y-(9) then
--				if i < y-(20*3) and i > maxWorldDepth then
--					if i < y-(23*2) and i > maxWorldDepth then
--						gen:makeLavaLayer(x,maxWorldDepth+3,z,stone)
--					else
--						
--					end
				if i == maxWorldDepth then
					gen:makeBedrock(x,i,z,stone)
				else
					local isOre = gen:checkOreChance(y)
					
					if isOre then
						gen:makeOre(x,i,z,stone)
					else
						gen:makeStone(x,i,z,stone)
					end
					
				end
			else
				if y > 10 then
					gen:makeStone(x,i,z,top)
				else
					gen:makeDirt(x,i,z,top)
				end
			end
		end
	end
end
end

function generateRandomLavaPockets(amt)
	for i = 1, amt do
		local x = math.random(-3*16, 3*16)
		local y = math.random(maxWorldDepth+(5*3), maxWorldDepth+(20*3))
		local z = math.random(3*16, 9*16)
		
		local function getChunk()
			local ray = Ray.new(Vector3.new(x,y,z), Vector3.new(x,y-3,z))
			
			local part, norm = workspace:FindPartOnRay(ray)
			
			if part then
				if part.Parent.Parent.Parent == workspace.Blocks then
					return part.Parent.Parent
				end
			end
		end
		
		local c = getChunk()
		
		if c~= nil then
			gen:makeLavaPocket(x,y,z,c)
		end
	end
end

function generatePlains(x, z)
for x = x, x+(16*6), 9 do
	for z = z, z+(16*6), 9 do
		if not workspace.hasFinishedGenerating.Value then
			workspace.genAmount.Value = workspace.genAmount.Value + 1.11
		end
		game:GetService("RunService").Stepped:Wait()
--		power = power + .125
--		frequency = frequency - (.125*1.5)
		local chunk = Instance.new("Model", workspace.Blocks)
		chunk.Name = "chunk_"..x..z
		local c2 = Instance.new("Model", game.ReplicatedStorage.blockCache)
		c2.Name = "chunk_"..x..z
		makeChunk(x,z, chunk, c2)
		local newBase = Instance.new("Part", chunk)
		newBase.Size = Vector3.new(8*3,256*3,8*3)
		newBase.CFrame = CFrame.new((x+4)*3,256*3/2,(z+4)*3)
		newBase.Anchored = true
		newBase.CanCollide = false
		newBase.Transparency = 1
		chunk.PrimaryPart = newBase
		game:GetService("CollectionService"):AddTag(newBase, "NotCaveMod")
	end
end
end

function generateMountains(x, z)
for x = x, x+16*6, 9 do
	power = 8
	for z = z, z+16*6, 9 do
		game:GetService("RunService").Stepped:Wait()
		power = power + 1
		frequency = 24
		local chunk = Instance.new("Model", workspace.Blocks)
		chunk.Name = "chunk_"..x..z
		makeChunk(x,z, chunk)
	end
end
end

generatePlains(-3*16,3*16)
workspace.genAmount.Value = 80
generateCaves(5)
generateRandomLavaPockets(8, worldVec1, worldVec2)
workspace.genAmount.Value = 90
workspace.hasFinishedGenerating.Value = true

--for i,v in pairs(workspace.Blocks:GetChildren()) do Still working on this
--	if v:FindFirstChild("stone") then
--		game:GetService("RunService").Stepped:Wait()
--		for a, b in pairs(v.stone:GetChildren()) do
--			b.Parent = game.ReplicatedStorage.blockCache[v.Name].stone
--		end
--	end
--end
for i,v in pairs(workspace.Blocks:GetChildren()) do
	if v:FindFirstChild("stone") then
		game:GetService("RunService").Stepped:Wait()
		v.stone.Parent = game.ReplicatedStorage.blockCache[v.Name]
	end
end

workspace.genAmount.Value = 100
--generatePlains(3*16,3*16)
--generatePlains(-3*16,-3*16)
--generatePlains(3*16,-3*16)