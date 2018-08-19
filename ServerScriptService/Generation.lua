
local genService = require(script.Parent.Generation.genBase)
local hasGenerated = false
spawn(function()
local amount = 0
for x = -50,50, 9 do
	amount = amount + 4
	for z = -50,50, 9 do
		wait(tick)
		genService.generateChunk(x,z,2,12)
		workspace.genAmount.Value = amount
		if x >= 42 and z >= 42 then
			print("Has Loaded!")
			hasGenerated = true
			workspace.hasFinishedGenerating.Value = true
		end 
	end
end	
script.Disabled = true
end)



game:GetService("RunService").Stepped:Connect(function()
	if hasGenerated then
		workspace.SpawnLocation.CanCollide = false
	end
end)