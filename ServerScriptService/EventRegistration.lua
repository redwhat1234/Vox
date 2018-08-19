
local itemModule = require(game.ReplicatedStorage.modules.itemModule)

function registerBlockDamage(player, target, toolType, Id, targetId)
	if toolType == "Hand" or itemModule.Type.Tool[toolType][targetId] then
		local newId = itemModule:itemLookUp(target.Name)
		target:Destroy()
		return "breakBlock", newId
	end
end



function registerBlockPlacement(player, Id, cframe, chunk)
local newBlock = game.ReplicatedStorage.Blocks[itemModule.Id[Id]]:Clone()
newBlock.Parent = workspace
newBlock.CFrame = cframe
print("Ant. Chunk: "..chunk)
newBlock.Parent = workspace.Blocks[chunk]
return true
end

local http = game:GetService("HttpService")

game:GetService("Players").PlayerAdded:Connect(function(player)
	if not game:GetService("RunService"):IsStudio() then
		local date = os.date("!*t")
		local Data = {
			["content"] = player.Name.." joined Vox on "..date.month.."/"..date.day.."/"..date.year
		}
		Data = http:JSONEncode(Data)
		http:PostAsync("https://discord.osyr.is/api/webhooks/433342270230757387/UJWRQJEzk2m84Z01gdUERn5pm9MSguinqJQT0XjZ4RZqTk-mP04GgP0lr5H7sjJfIh-D", Data)
	end
end)

game.ReplicatedStorage.Events.placeBlock.OnServerInvoke = registerBlockPlacement
game.ReplicatedStorage.Events.blockDamage.OnServerInvoke = registerBlockDamage