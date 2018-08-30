
local genService = require(script.Parent.Generation.genBase)
local hasGenerated = false
local biome = "Hills"
spawn(function()
local amount = 0
for x = -50,50, 9 do
	wait(tick)
	amount = amount + 8
	for z = -50,50, 9 do
		local antHeight = math.floor(math.noise(x/14,z/14)*51)
		if antHeight <= -24 then
			biome = "Desert"
		else
			biome = "Hills"
		end
		genService.generateChunk(x,z,2,12, biome)
		workspace.genAmount.Value = amount
		if amount >= 96 then
			print("Has Loaded!")
			hasGenerated = true
			workspace.hasFinishedGenerating.Value = true
		end 
	end
end		
workspace.SpawnLocation.CanCollide = false
script.Disabled = true
end)


