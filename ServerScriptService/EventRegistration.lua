
local itemModule = require(game.ReplicatedStorage.modules.itemModule)

local chatTagStore = game:GetService("DataStoreService"):GetDataStore("Tags")
local playerHasJoined = game:GetService("DataStoreService"):GetDataStore("hasJoined")

local http = game:GetService("HttpService")

local systemMessages = {
	"Be Sure to check out our Social Media Links in the game description! e.g. Discord, Twitter.",
	"You can Press 'C' to craft more complex objects!",
	"Some things can only be broken using specific Tools!",
	"This game is currently in alpha, so be sure to report bugs to us on Discord!",
	"Thank you for supporting Vox!",
	"You can Support us by donating on the main menu, under settings!",
	"Chat Tags are 100 Robux, they can be purchased and customized in the settings!",
	"If you would like to donate a custom amount, message one of the Admins on Discord!"
}

function registerBlockDamage(player, target, toolType, Id, targetId)
	if toolType == "Hand" or itemModule.Type.Tool[toolType][targetId] then
		local newId = itemModule:itemLookUp(target.Name)
		target:Destroy()
		return "breakBlock", newId
	end
end

function registerBlockPlacement(player, Id, cframe, chunk)
	print("[Server Placement] Recieved Request: Id: "..Id)
local newBlock = game.ReplicatedStorage.Blocks[itemModule.Id[Id]]:Clone()
newBlock.Parent = workspace
if newBlock.ClassName == "Model" then
	newBlock:SetPrimaryPartCFrame(cframe)
else
	newBlock.CFrame = cframe
end
print("Ant. Chunk: "..chunk)
newBlock.Parent = workspace.Blocks[chunk]
return true
end

function fireToDiscord(p,m)
	if not game:GetService("RunService"):IsStudio() then
		local date = os.date("!*t")
		local Data = {
			["content"] = "```["..p.Name.."]"..m.."```"
		}
		Data = http:JSONEncode(Data)
		http:PostAsync("https://discord.osyr.is/api/webhooks/433342270230757387/UJWRQJEzk2m84Z01gdUERn5pm9MSguinqJQT0XjZ4RZqTk-mP04GgP0lr5H7sjJfIh-D", Data)
	end
end

function sendSystemMessage(global, player, message, isJoinMessage, isFirstJoinMessage, isLeaveMessage)
	if global then
		for i,v in pairs(game.Players:GetChildren()) do
			game.ReplicatedStorage.Events.systemMessage:InvokeClient(v,message, isJoinMessage, isFirstJoinMessage, isLeaveMessage)
		end
	else
		game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, message)
	end
end

function registerChatMessage(player, message)
	print("Received Message Request")
	local tagTrue = false
--	if chatTagStore:GetAsync(player.userId) ~= nil then
--		tagTrue = true
--	end
	local canSend = game:GetService("Chat"):FilterStringForBroadcast(message, player)
	if not string.find(canSend, "#", 1, 1) then
--		if tagTrue then
--			print("Tag Message")
--			for i,v in pairs(game.Players:GetChildren()) do
--				game.ReplicatedStorage.Events.playerSentMessage:InvokeClient(v, player, canSend, chatTagStore:GetAsync(player.userId))
--			end
		if player.Name == "redwhat1234" then
			print("Owner Message")
			for i,v in pairs(game.Players:GetChildren()) do
				game.ReplicatedStorage.Events.playerSentMessage:InvokeClient(v, player, canSend, "Owner")
			end
		else
			print("No-Tag Message")
			for i,v in pairs(game.Players:GetChildren()) do
				game.ReplicatedStorage.Events.playerSentMessage:InvokeClient(v, player, canSend, false)
			end
		end
	else
		sendSystemMessage(false, player, "Cannot Send Message, Roblox Registered Profranity.")
	end
	if canSend then
		fireToDiscord(player, message)
	end
end

game:GetService("Players").PlayerAdded:Connect(function(player)
	if not playerHasJoined:GetAsync(player.userId) then
		sendSystemMessage(true, nil, "Welcome "..player.Name.." to Vox!", false, true, false)
		playerHasJoined:SetAsync(player.userId, true)
	else
		sendSystemMessage(true, nil, player.Name.." has joined the game!", true, false, false)
	end
	player.CharacterAdded:Connect(function(c)
		c.Humanoid.Health = 20
		c.Humanoid.MaxHealth = 20
		c.Humanoid.JumpPower = 17
		c.Humanoid.WalkSpeed = 18
	end)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
	sendSystemMessage(true, nil, player.Name.." has left the game!", false, false, true)
end)

game.ReplicatedStorage.Events.playerSentMessage.OnServerInvoke = registerChatMessage
game.ReplicatedStorage.Events.placeBlock.OnServerInvoke = registerBlockPlacement
game.ReplicatedStorage.Events.blockDamage.OnServerInvoke = registerBlockDamage

spawn(function()
	local x = 1
	while wait(65) do
		sendSystemMessage(true, nil, systemMessages[x])
		x = x + 1
		if x >= #systemMessages then
			x = 1
		end
	end	
end)