
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

local serverStats = {}
serverStats.currentAnimals = 0

shared.settings = {}

shared.settings.SERVER_WORLD_HEIGHT = 255
shared.settings.SERVER_WORLD_DEPTH = -64
shared.settings.SERVER_MAX_ANIMAL_COUNT_PER_GEN = 7
shared.settings.SERVER_MAX_ANIMAL_COUNT = 27
shared.settings.SERVER_CHUNKS = 64
shared.settings.SERVER_CHUNK_SIZE = 16

shared.settings.serverInfo = {
	["SERVER_WORLD_HEIGHT"] = shared.settings.SERVER_WORLD_HEIGHT,
	["SERVER_WORLD_DEPTH"] = shared.settings.SERVER_WORLD_DEPTH,
	["SERVER_MAX_ANIMAL_COUNT_PER_GEN"] = shared.settings.SERVER_MAX_ANIMAL_COUNT_PER_GEN,
	["SERVER_MAX_ANIMAL_COUNT"] = shared.settings.SERVER_MAX_ANIMAL_COUNT,
	["SERVER_CHUNKS"] = shared.settings.SERVER_CHUNKS,
	["SERVER_CHUNK_SIZE"] = shared.settings.SERVER_CHUNK_SIZE
}

shared.settings.commands = {
	["getServerInfo"] = {
		["desc"] = "Gets Information about the server, staff only."	
	},
	["help"] = {
		["desc"] = "Returns the Server Commands."	
	},
	["tp"] = {
		["desc"] = "Teleports to the specified player, if online, staff only."	
	},
	["tphere"] = {
		["desc"] = "Teleports specified player to you, if online, staff only."		
	},
	["lbright"] = {
		["desc"] = "Sets lighting to Maximum, staff only."	
	},
	["lnormal"] = {
		["desc"] = "Sets lighting to Normal, staff only."	
	}
}

local function getTopForRanXZ(X,Z)
	local newRay = Ray.new(Vector3.new(X,500,Z), Vector3.new(X,-500,Z))
	local part, pos, norm = workspace:FindPartOnRay(newRay)
	if part then
		return Vector3.new(part.Position.X, part.Position.Y + part.Size.Y*2, part.Position.Z)
	end
end

shared.settings.packTable = {
	[1] = "Detailed",
	[2] = "Low Poly"	
}

shared.settings.renderTable = {
	[1] = "Very Low",
	[2] = "Low",
	[3] = "Medium",
	[4] = "High"	
}

shared.settings.settingStore = game:GetService("DataStoreService")
shared.settings.DetailStore = shared.settings.settingStore:GetDataStore("Detail")
shared.settings.TexturePackStore = shared.settings.settingStore:GetDataStore("TexturePack")
shared.settings.ShadowStore = shared.settings.settingStore:GetDataStore("Shadows")
shared.settings.RenderStore = shared.settings.settingStore:GetDataStore("RenderDistance")

local Fall_Damage_Begin = 10
local Fall_Damage_Scale = .1

function onFreeFall(player, active, YPos)
	local Last_Y
    if (active) then
        Last_Y = player.Character.Torso.Position.Y
    else
        local y_diff = YPos - Last_Y
        if (y_diff > Fall_Damage_Begin) then
            local damage = (y_diff - Fall_Damage_Begin) * Fall_Damage_Scale 
            player.Character.Humanoid:TakeDamage(damage)
        end
    end
end

shared.settings.blockToolSize = Vector3.new(.5,.5,.5)
shared.settings.toolToolSize = Vector3.new(1.5,1.5,1.5)

function changeUserEqp(p,newEqp,type)
	if p.Character:FindFirstChild("EQP") then
		p.Character.EQP:Destroy()
	end
	local newEqp = game.ReplicatedStorage.Items[newEqp]:Clone()
	newEqp.Parent = p.Character
	newEqp.CFrame = p.Character["Right Arm"].CFrame
	newEqp.Anchored = false
	newEqp.CanCollide = false
	newEqp.Name = "EQP"
	
	if type == "Block" then
		newEqp.Size = shared.settings.blockToolSize
	else
		newEqp.Size = shared.settings.toolToolSize
	end
	
	local newWeld = Instance.new("Weld", newEqp)
	newWeld.Part0 = newEqp
	newWeld.Part1 = p.Character["Right Arm"]
	newWeld.C0 = CFrame.new() * CFrame.Angles(math.rad(90),0,0) - p.Character["Right Arm"].CFrame.upVector*p.Character["Right Arm"].Size.Y/2 + p.Character["Right Arm"].CFrame.lookVector*p.Character["Right Arm"].Size.Y/2
	return true
end

game.ReplicatedStorage.Events.eqpChange.OnServerEvent:Connect(changeUserEqp)

function createDrop(block, pos)
	if block.Name == "blockFarmland" then
		block = game.ReplicatedStorage.Blocks.blockDirt
	elseif block.Name == "blockGrass" then
		block = game.ReplicatedStorage.Blocks.blockDirt
	elseif block.Name == "blockLeave" then
		print("LEAF")
		local chance = math.random(1,10)
		if chance > 2 and chance < 5 then
			print("SUCCESSFUL LEAVE YAY")
			block = game.ReplicatedStorage.Items.blockOakSappling
		else
			return
		end
	elseif block.Name == "blockFern" then
		
		return
	elseif block.Name == "blockMetaGrass" then
		local chance = math.random(1,10)
		if chance > 2 and chance < 7.5 then
			print("SUCCESSFUL SEED YAY")
			block = game.ReplicatedStorage.Items.blockWheatSeed
		else
			return
		end
	elseif block.Name == "blockGravel" then
		local chance = math.random(1,10)
		if chance > 2 and chance < 7.5 then
			block = game.ReplicatedStorage.Items.blockFlint
		else
			return
		end	
	elseif block.Name == "oreDiamond" then
		block = game.ReplicatedStorage.Items.metaDiamond
	elseif block.Name == "oreCoal" then
		block = game.ReplicatedStorage.Items.metaCoal
	end		
    local drop = block:Clone()
    drop.Parent = workspace.ignoreList
    drop.Size = Vector3.new(.5,.5,.5)
    drop.CFrame = CFrame.new(pos)
    drop.CanCollide = false
    drop.Anchored = true
    
    local angle = 0
    
    local desiredpos = CFrame.new(pos)
    drop.CFrame = drop.CFrame:lerp(desiredpos*CFrame.new(0,.2+(math.sin(tick())*.5),0)*CFrame.Angles(0,math.rad(angle),0), .2)
    game:GetService("RunService").Stepped:Connect(function(dt)
        if drop.Parent == nil or drop.Parent ~= workspace.ignoreList then
	       return false
        end
        
        angle = angle+2
        if angle >= 360 then angle = 0 end
        local ray = Ray.new(desiredpos.Position, Vector3.new(0, -.5, 0))
        local hit,pos = workspace:FindPartOnRayWithIgnoreList(ray, drop.Parent:GetChildren())
        desiredpos = CFrame.new(pos)*CFrame.new(0,.2,0)
        drop.CFrame = drop.CFrame:lerp(desiredpos*CFrame.new(0,.2+(math.sin(tick())*.5),0)*CFrame.Angles(0,math.rad(angle),0), .2)
    end)
spawn(function()
	local x = 1
	while wait(tick) do
		if x == 600 then
			drop:Destroy()
			break
		end
		if drop.Parent == nil or drop.Parent ~= workspace.ignoreList then
			break
		end
		for i,v in pairs(game.Players:GetChildren()) do
		   if (v.Character.PrimaryPart.Position - drop.Position).Magnitude < 6 then
			  repeat drop.CFrame = drop.CFrame:lerp(v.Character.PrimaryPart.CFrame,.075) until (v.Character.PrimaryPart.Position - drop.Position).Magnitude < .1
			  game.ReplicatedStorage.Events.pickupBlock:InvokeClient(v, drop.Name)
			  drop:Destroy()
			  break
		   end
		end
	end	
end)
    return drop
end
	
function createUserDrop(player, block, pos)
    local drop = game.ReplicatedStorage.Items[block]:Clone()
    drop.Parent = workspace.ignoreList
    drop.Size = Vector3.new(.5,.5,.5)
    drop.CFrame = CFrame.new(pos)
    drop.CanCollide = false
    drop.Anchored = true
    
    local angle = 0
    
    local desiredpos = CFrame.new(pos)
    drop.CFrame = drop.CFrame:lerp(desiredpos*CFrame.new(0,.2+(math.sin(tick())*.5),0)*CFrame.Angles(0,math.rad(angle),0), .2)
    game:GetService("RunService").Stepped:Connect(function(dt)
        if drop.Parent == nil or drop.Parent ~= workspace.ignoreList then
	       return false
        end
        
        angle = angle+2
        if angle >= 360 then angle = 0 end
        local ray = Ray.new(desiredpos.Position, Vector3.new(0, -.5, 0))
        local hit,pos = workspace:FindPartOnRayWithIgnoreList(ray, drop.Parent:GetChildren())
        desiredpos = CFrame.new(pos)*CFrame.new(0,.2,0)
        drop.CFrame = drop.CFrame:lerp(desiredpos*CFrame.new(0,.2+(math.sin(tick())*.5),0)*CFrame.Angles(0,math.rad(angle),0), .2)
    end)
spawn(function()
	local x = 1
	while wait(tick) do
		if x == 120 then
			drop:Destroy()
			break
		end
		x = x + .5
		if drop.Parent == nil or drop.Parent ~= workspace.ignoreList then
			break
		end
		for i,v in pairs(game.Players:GetChildren()) do
		   if (v.Character.PrimaryPart.Position - drop.Position).Magnitude < 6 and x >= 60 and v == player or (v.Character.PrimaryPart.Position - drop.Position).Magnitude < 6 and x <= 60 and v ~= player or (v.Character.PrimaryPart.Position - drop.Position).Magnitude < 6 and x >= 60 and v ~= player then
			  repeat drop.CFrame = drop.CFrame:lerp(v.Character.PrimaryPart.CFrame,.075) until (v.Character.PrimaryPart.Position - drop.Position).Magnitude < .1
			  game.ReplicatedStorage.Events.pickupBlock:InvokeClient(v, drop.Name)
			  drop:Destroy()
			  break
		   end
		end
	end	
end)
    return drop
end

game.ReplicatedStorage.Events.dropItem.OnServerInvoke = createUserDrop

function registerBlockDamage(player, target, timeToMine)
	if timeToMine < 9 then
		createDrop(target, target.Position)
	end
	if target.Name ~= "blockFern" and target.Name ~= "blockMetaGrass" then
		target:Destroy()
	else
		target.Parent:Destroy()
	end
	return true
end

function convertToFarmland(p, target)
	local newFarmland = game.ReplicatedStorage.Blocks.blockFarmland:Clone()
	newFarmland.Parent = target.Parent
	newFarmland:SetPrimaryPartCFrame(target.CFrame - Vector3.new(0,.25,0))
	target:Destroy()
	return true
end

game.ReplicatedStorage.Events.convertToFarmland.OnServerEvent:Connect(convertToFarmland)

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

local admin = {
	34929389,
	123867010
}

local function rankCheck(player)
	if player:GetRankInGroup(1228910) >= 3 or admin[player.UserId] then
		return true
	else
		return false
	end
end

function commandCheck(player, message)
	for i,v in pairs(shared.settings.commands) do
		if string.find(message, i, 2, 1) then
			return i
		end
	end
end

function executeCommand(player, command, originalMessage)
	if command == "getServerInfo" then
		game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, "-----------------[Server Info]-----------------", true, false, false)
		for i,v in pairs(shared.settings.serverInfo) do
			game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, i.." >> "..v, false, true, false)
		end
		return true
	elseif command == "help" then
		game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, "-----------------[Commands]-----------------", true, false, false)
		for i,v in pairs(shared.settings.commands) do
			game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, "/"..i.." - "..v.desc, false, true, false)
		end
		return true
	elseif command == "tp" then
		for i,v in pairs(game.Players:GetChildren()) do
			if string.find(originalMessage, v.Name, 1, 1) and v ~= player then
				if v.Character ~= nil then
					player.Character:SetPrimaryPartCFrame(v.Character.PrimaryPart.CFrame)
					return true
				else
					game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, v.Name.." is not alive.", false, true, false)
					return true
				end
			elseif string.find(originalMessage, v.Name, 1, 1) and v == player then
				game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, "You cannot teleport to yourself, silly. :3", false, true, false)
				return true
			end
		end
		game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, "The player you requested is not online.", false, true, false)
	elseif command == "tphere" then
		for i,v in pairs(game.Players:GetChildren()) do
			if string.find(originalMessage, v.Name, 1, 1) and v ~= player then
				if v.Character ~= nil then
					v.Character:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
					return true
				else
					game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, v.Name.." is not alive.", false, true, false)
					return true
				end
			elseif string.find(originalMessage, v.Name, 1, 1) and v == player then
				game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, "You cannot teleport to yourself, silly. :3", false, true, false)
				return true
			end
		end
		game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, "The player you requested is not online.", false, true, false)
	elseif command == "lbright" then
		game.Lighting.Ambient = Color3.fromRGB(255,255,255)
		return true
	elseif command == "lnormal" then
		game.Lighting.Ambient = Color3.fromRGB(0,0,0)
		return true
	end	
end

function registerChatMessage(player, message)
	print("Received Message Request")
	local tagTrue = false
--	if chatTagStore:GetAsync(player.userId) ~= nil then
--		tagTrue = true
--	end
    if message == "" then
	   return false
    end
    if string.find(message, "/", 1, 1) then
	   local isRank = rankCheck(player)
	   if isRank then
		  local commandCheckBool = commandCheck(player, message)
		  if commandCheckBool then
			 executeCommand(player, commandCheckBool, message)
			 return true
		  else
			 game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, "Unknown Command, please use '/help' for command help.")
			 return true
		  end
		  game.ReplicatedStorage.Events.systemMessage:InvokeClient(player, "You don't have permission to use commands, if you think this is in error, please contact an admin.")
		  return true
	   end
    end
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
		elseif player.Name == "TheGrimDeathZombie" then
			print("Contributor Message")
			for i,v in pairs(game.Players:GetChildren()) do
				game.ReplicatedStorage.Events.playerSentMessage:InvokeClient(v, player, canSend, "Contributor")
			end
		elseif player:GetRankInGroup(1228910) == 3 then
			print("Moderator Message")
			for i,v in pairs(game.Players:GetChildren()) do
				game.ReplicatedStorage.Events.playerSentMessage:InvokeClient(v, player, canSend, "Moderator")
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
		
local function spawnChar(player)
	local newChar = game.ReplicatedStorage.characterModel:Clone()
	newChar.Name = player.Name
	newChar.Parent = workspace
	repeat wait(tick) player.Character = newChar until player.Character == newChar
	newChar:SetPrimaryPartCFrame(CFrame.new(1, 23, 200))
	player.Character.Humanoid.Died:Connect(function()
		spawnChar(player)	
	end)
end

game:GetService("Players").PlayerAdded:Connect(function(player)
	if not playerHasJoined:GetAsync(player.userId) then
		sendSystemMessage(true, nil, "Welcome "..player.Name.." to Vox!", false, true, false)
		playerHasJoined:SetAsync(player.userId, true)
	else
		sendSystemMessage(true, nil, player.Name.." has joined the game!", true, false, false)
	end
	repeat wait(tick) until workspace.hasFinishedGenerating.Value and workspace.genAmount.Value >= 100
	spawnChar(player)
--	player.Character.Humanoid.FreeFalling:connect(function()
--		onFreeFall(player, true)	
--	end)
	player.CharacterAdded:Connect(function(c)
		c.Humanoid.Health = 20
		c.Humanoid.MaxHealth = 20
		repeat wait(tick) print("[Character Statistics :: Jump Power] Setting Player Jump Power...") c.Humanoid.JumpPower = 32 until c.Humanoid.JumpPower == 32
		repeat wait(tick) print("[Character Statistics :: Walk Speed] Setting Player Walk Speed...") c.Humanoid.WalkSpeed = 14 until c.Humanoid.WalkSpeed == 14
	end)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
	sendSystemMessage(true, nil, player.Name.." has left the game!", false, false, true)
end)

function shared.settings:updatePlayerSetting(player, setting, value)
	if setting == "Render" then
		shared.settings.RenderStore:SetAsync(player.userId, value)
	elseif setting == "Detail" then
		shared.settings.DetailStore:SetAsync(player.userId, value)
	elseif setting == "Shadow" then
		shared.settings.ShadowStore:SetAsync(player.userId, value)
	elseif setting == "Texture" then
		shared.settings.TexturePackStore:SetAsync(player.userId, value)
	end
end
	
function shared.settings:returnPlayerSetting(player, setting)
	if setting == "Render" then
		return shared.settings.RenderStore:GetAsync(player.userId)
	elseif setting == "Detail" then
		if shared.settings.DetailStore:GetAsync(player.userId) == true then
			return "True"
		else
			return "False"
		end
		return 
	elseif setting == "Shadow" then
		if shared.settings.ShadowStore:GetAsync(player.userId) == true then
			return "True"
		else
			return "False"
		end
		return 
	elseif setting == "Texture" then
		return shared.settings.TexturePackStore:GetAsync(player.userId)
	end
end

local function spawnAnimals(animal)
	local function getRandomGrassBlockInChunk()
		local chunk = workspace.Blocks:GetChildren()[math.random(1,#workspace.Blocks:GetChildren())]
		local grassTable = {}
		for i,v in pairs(chunk:GetDescendants()) do
			if v.Name == "blockGrass" then
				table.insert(grassTable, v)
			end
		end
		local selected = grassTable[math.random(1, #grassTable)]
		return selected
	end
	local selectedBlock = getRandomGrassBlockInChunk()
	for i = 1, math.random(3, shared.settings.SERVER_MAX_ANIMAL_COUNT_PER_GEN) do
		if serverStats.currentAnimals < shared.settings.SERVER_MAX_ANIMAL_COUNT then
			local newAnimal = game.ReplicatedStorage.Animals[animal]:Clone()
			newAnimal.Parent = workspace.Animals
			newAnimal:SetPrimaryPartCFrame(selectedBlock.CFrame + Vector3.new(math.random(-3*4,3*4),5,math.random(-3*4,3*4)))
			serverStats.currentAnimals = serverStats.currentAnimals + 1
		end
	end
	return true
end

game.ReplicatedStorage.Events.getPlayerSetting.OnServerInvoke = function(p, s)
	return shared.settings:returnPlayerSetting(p, s)
end
game.ReplicatedStorage.Events.updatePlayerSetting.OnServerEvent:Connect(function(p,s,v)
	shared.settings:updatePlayerSetting(p,s,v)	
end)
game.ReplicatedStorage.Events.playerSentMessage.OnServerInvoke = registerChatMessage
game.ReplicatedStorage.Events.placeBlock.OnServerInvoke = registerBlockPlacement
game.ReplicatedStorage.Events.blockDamage.OnServerInvoke = registerBlockDamage
game.ReplicatedStorage.Events.jumpActive.OnServerInvoke = onFreeFall

spawn(function()
	local x = 1
	while wait(60*5) do
		sendSystemMessage(true, nil, systemMessages[x])
		x = x + 1
		if x >= #systemMessages then
			x = 1
		end
	end	
end)

repeat wait(tick) until workspace.hasFinishedGenerating.Value == true

spawn(function()
	spawnAnimals("Sheep")
	while wait(60) do
		spawnAnimals("Sheep")
	end	
end)

function playerPosUpdate()
	for i,v in pairs(game.Players:GetChildren()) do
		if v:FindFirstChild("Character") then
			if v.Character.PrimaryPart.Position.Y < -100 then
				local newPos = getTopForRanXZ(v.Character.PrimaryPart.Position.X, v.Character.PrimaryPart.Position.Z)
				v.Character:SetPrimaryPartCFrame(CFrame.new() + newPos)
			end
		end
	end
end


function RoundMultiple(n, mult)
   local h = mult * 0.5
   return (n+h) - (n+h)%mult
end

function stoneRenderUpdate()
	local sides = {
		Enum.NormalId.Back,
		Enum.NormalId.Bottom,
		Enum.NormalId.Top,
		Enum.NormalId.Left,
		Enum.NormalId.Right,
		Enum.NormalId.Front,	
	}
	
	for i,v in pairs(game:GetService("CollectionService"):GetTagged("Stone")) do
		game:GetService("RunService").Stepped:Wait()
		
		local function revealBlock(block)
			if block.Parent.Parent.Parent == game.ReplicatedStorage.blockCache then
				if block.Parent.Name == "stone" then
					block.Parent = game.Workspace.Blocks[block.Parent.Parent.Name].stone
				elseif block.Parent.Name == "top" then
					block.Parent = game.Workspace.Blocks[block.Parent.Parent.Name].top
				end
			elseif block.Parent.Parent.Parent == game.Workspace.Blocks then
				if block.Parent.Name == "stone" then
					block.Parent = game.ReplicatedStorage.blockCache[block.Parent.Parent.Name].stone
				elseif block.Parent.Name == "top" then
					block.Parent = game.ReplicatedStorage.blockCache[block.Parent.Parent.Name].top
				end
			end
		end
		
		local function checkBlockSpace(vec, dir)
			local ray = Ray.new(vec, dir)
			local part, hit = workspace:FindPartOnRay(ray, v, false, false)
			if part then
				return false
			else
				return true
			end
		end
		
		local left, right, top, bottom, front, back = false, false, false, false, false, false
		
		for a, side in pairs(sides) do
			if side == Enum.NormalId.Back then
				local isExposed = checkBlockSpace(
					v.Position,
					-v.CFrame.lookVector*3	
				)
				back = isExposed
			elseif side == Enum.NormalId.Bottom then
				local isExposed = checkBlockSpace(
					v.Position,
					-v.CFrame.upVector*3	
				)
				bottom = isExposed
			elseif side == Enum.NormalId.Top then
				local isExposed = checkBlockSpace(
					v.Position,
					v.CFrame.upVector*3	
				)
				top = isExposed
			elseif side == Enum.NormalId.Left then
				local isExposed = checkBlockSpace(
					v.Position,
					-v.CFrame.rightVector*3	
				)
				left = isExposed
			elseif side == Enum.NormalId.Right then
				local isExposed = checkBlockSpace(
					v.Position,
					v.CFrame.rightVector*3	
				)
				right = isExposed
			elseif side == Enum.NormalId.Front then
				local isExposed = checkBlockSpace(
					v.Position,
					v.CFrame.lookVector*3	
				)
				front = isExposed
			end
		end
		if left or right or top or bottom or front or back then
			print("Revealing!")
			revealBlock(v)
		end
	end
end

function waterUpdate()
	for i,v in pairs(game:GetService("CollectionService"):GetTagged("Water")) do
		
		local ray = Ray.new(v.Position, v.CFrame.upVector*3)
		local part, hit = workspace:FindPartOnRay(ray, v, false, false)
		
		if part then
			if part.Name == "blockWater" then
				v.SurfaceGui.ImageLabel.ImageTransparency = 1
			end
			if v.Size.Y < 3 and part.Name == "blockWater" then
				v.Size = Vector3.new(3,3,3)
				v.CFrame = v.CFrame + Vector3.new(0,.375,0)
			end
		else
			v.SurfaceGui.ImageLabel.ImageTransparency = 0
			local x,y,z = RoundMultiple(v.CFrame.X, 3),RoundMultiple(v.CFrame.Y, 3),RoundMultiple(v.CFrame.Z, 3)
			v.Size = Vector3.new(3,3-.375,3)
			v.CFrame = CFrame.new(x,y-.375,z)
		end
	end	
end

function weatherUpdate()
	local ran = math.random(1,100)
	if ran < 1 and ran > 16 then
		workspace.IsRaining.Value = true
	else
		workspace.IsRaining.Value = false
	end
end


--spawn(
--	function()
--		while true do
--			game:GetService("RunService").Stepped:Wait()
--			stoneRenderUpdate()
--		end
--	end	
--)

local rainTick = 0

local function checkTicks()
	if rainTick > 10*60 then
		weatherUpdate()
	end
end

local function addTick()
	rainTick = rainTick+1
	checkTicks()
end

game:GetService("RunService").Stepped:Connect(function()
	playerPosUpdate()
	waterUpdate()
	addTick()
end)