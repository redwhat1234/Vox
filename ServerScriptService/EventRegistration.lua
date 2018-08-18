
local itemModule = require(game.ReplicatedStorage.modules.itemModule)

function registerBlockDamage(target, toolType, Id, targetId)
	if itemModule.Type.Tool[toolType][targetId] then
		return "breakBlock", target.Color, target.CFrame
	end
end



game.ReplicatedStorage.Events.blockDamage.OnServerInvoke = registerBlockDamage