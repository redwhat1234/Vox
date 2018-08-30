local player = game.Players.LocalPlayer

local itemMod = require(game.ReplicatedStorage.modules.itemModule)
local keyMod = require(game.ReplicatedStorage.modules.keyCode)
local vectorMod = require(script.Parent.Placement.Mechanics)
local craftMod = require(game.ReplicatedStorage.modules.craftingModule)

repeat wait(tick) until player:FindFirstChild("PlayerGui")
repeat wait(tick) until player.PlayerGui:FindFirstChild("Load")
player.PlayerGui.Load.Enabled = true
repeat wait(tick)
	game:GetService("StarterGui"):SetCore("TopbarEnabled", false)
	local loadUI = player.PlayerGui.Load
	loadUI.loadBack.loadMain.Size = UDim2.new(workspace.genAmount.Value/100,0,1,0)
	loadUI.label.Text = "Generating Terrain..."..workspace.genAmount.Value .."%"
until workspace.hasFinishedGenerating.Value == true


local character = {}
local item = {}
local weather = {}
local network = {}
local chat = {}
local ui = {}
local effects = {}
local input = {}
local world = {}

character.hotbar = {}
character.inventory = {}
character.currentlyEquipped = nil
character.invOpen = false
character.craftOpen = false
character.currentFood = 20
character.maxFood = 20
character.isWalking = false

item.type = {}
item.type.tool = {}
item.type.block = {}
item.type.metaent = {}
item.type.ent = {}

weather.event = {}

chat.filter = {}
chat.event = {}
chat.tags = {}
chat.joinColor = Color3.fromRGB(160, 165, 65)
chat.firstJoinColor = Color3.fromRGB(148, 85, 165)
chat.leaveColor = Color3.fromRGB(160, 165, 65)
chat.systemColor = Color3.fromRGB(25, 183, 197)

ui.chunkLevel = 1
ui.scenic = true
ui.craft = {}
ui.craft.furnace = {}
ui.craft.x = 0

effects.currentBlock = nil
effects.currentBox = nil
effects.Arm = nil
effects.Offset = Vector3.new(0,0,0)
effects.cloudHeight = 150

ui.heartImage = "rbxgameasset://Images/Heart2"
ui.halfHeartImage = ""
ui.foodIcon = "rbxgameasset://Images/foodBar"
ui.cursorIcon = "rbxassetid://1776629404"

effects.blur = Instance.new("BlurEffect", workspace.CurrentCamera)
effects.blur.Enabled = false

function character:Init()
	repeat wait(tick) until player:FindFirstChild("PlayerGui"):FindFirstChild("Main")
	character:createHotbar(9)
	ui.selectionChanged(1)
	character:registerInventory()
	ui.craft:changeSelection()
	ui:createHealthBar(10)
	player.PlayerGui.Main.chatBox.Text = "Press / to start typing!"
	effects:registerArm()
end

function character.onStepped()
	character.currentFood = character.currentFood - .0001
end

function character:createHotbar(slots)
	for i = 1, slots do
		local newSlot = game.ReplicatedStorage.UIs.slot:Clone()
		newSlot.Name = i
		newSlot.num.Text = i
		newSlot.stack.Text = ""
		newSlot.Image.Image = ""
		newSlot.Parent = player.PlayerGui.Main.hotBar
		character.hotbar[i] = {
			["Id"] = 0,
			["Stack"] = 0,
			["Image"] = ""
		}
	end
end

function character:registerInventory()
	local x = 0
	for i,v in pairs(player.PlayerGui.Main.Inventory.SlotBag:GetChildren()) do
		x = x + 1
		if v.ClassName == "Frame" then
			v.Name = x
			character.inventory[x] = {
				["Id"] = 0,
				["Stack"] = 0,
				["Image"] = ""	
			}
		end
	end
end

function character:findOpenSlot(Id)
	for i,v in pairs(character.hotbar) do
		print("Slot Id: "..i.." Item Id: "..Id)
		if character.hotbar[i].Id == Id and character.hotbar[i].Stack < itemMod.maxStacks[Id] then
			character.hotbar[i].Stack = character.hotbar[i].Stack + 1
			print("Updated Current Stack! .. Slot: "..i)
			return true
		elseif character.hotbar[i].Id == 0 then
			character.hotbar[i].Id = Id
			character.hotbar[i].Stack = 1
			character.hotbar[i].Image = itemMod.itemImage[Id]
			print("Created New Stack! .. Slot: "..i)
			return true
		end
	end
	for i,v in pairs(character.inventory) do
		if character.inventory[i] ~= {} and character.inventory[i].Id == Id and character.inventory[i].Stack < itemMod.maxStacks[Id] then
			character.inventory[i].Stack = character.inventory[i].Stack + 1
			return true
		elseif character.inventory[i] == {} then
			character.inventory[i].Id = Id
			character.inventory[i].Stack = 1
			character.inventory[i].Image = itemMod.itemImage[Id]
			return true
		end
	end
end

function character:FindItemOnPlayer(Id)
	for i,v in pairs(character.inventory) do
		print(i.."::"..v.Id)
		if v.Id == Id then
			return v
		end
	end
	for i,v in pairs(character.hotbar) do
		print(i.."::"..v.Id)
		if v.Id == Id then
			return v
		end
	end
	return false
end

function character:FindItem(container)
	if container > 9 then
		return character.inventory[container]
	else
		return character.hotbar[container]
	end
end

function character:moveItem(currContainer, newContainer)
	if newContainer ~= {} then
		local newTable = newContainer
		newContainer = currContainer
		currContainer = newTable
		newTable = nil
	else
		newContainer = currContainer
		currContainer = {}
	end
end

function item:getType(id)
	return itemMod.itemTypes[id]
end

function item:getSubType(id)
	return itemMod.itemSubTypes[id]
end

function item:getLocale(id)
	local origText = itemMod.Id
	local locale = itemMod.Localization[origText]
	return locale
end

function item:getId(origText)
	return itemMod:itemLookUp(origText)
end

function item:getTexture(id)
	return itemMod.textureId[id]
end

function item:checkBlockState(Id)
	if itemMod.itemTypes[Id] == itemMod.Type.Block or itemMod.itemTypes[Id] == itemMod.Type.Block.Interactable then
		return true
	else
		return false
	end
end

function item:checkBlockStateModel(target)
	if itemMod:itemLookUp(target.Parent.Name) then
		return target.Parent
	else
		return false
	end
end

function item:checkHardness(Id)
	return itemMod.Type.Block.Hardness[Id]
end

function item.type.tool.onUse(target,toolType,Id)
	if toolType == itemMod.itemSubTypes.Pickaxe then
		if itemMod.Type.Tool.Pickaxe[item:getId(target.Name)] then
			local success, color, pos, itemId = network:FireEvent("blockDamage", target, toolType, Id, item:getId(target.Name))
			if success == "breakBlock" then
				effects:registerParticle(pos, color, 3, Vector3.new(0,-3,0), Vector3.new(3,3,3), .5)
				character:findOpenSlot(itemId)
			end
		end
	elseif toolType == itemMod.itemSubTypes.Shovel then
		if itemMod.Type.Tool.Shovel[item:getId(target.Name)] then
			local success, color, pos, itemId = network:FireEvent("blockDamage", target, toolType, Id, item:getId(target.Name))
			if success == "breakBlock" then
				effects:registerParticle(pos, color, 3, Vector3.new(0,-3,0), Vector3.new(3,3,3), .5)
				character:findOpenSlot(itemId)
			end
		end
	end
end

function item.type.tool.onBreak(Id)
	
end
	
function item.type.block.onBreak(toolType, Id)
	
end

function item.type.block.onUse(Id)
	
end

function item:placeBlock()
	print("Recieved Request!")
	local item = character.hotbar[character.currentlyEquipped]
	local Id = character.hotbar[character.currentlyEquipped].Id
	local stack = character.hotbar[character.currentlyEquipped].Stack
	print("Item: Id:"..Id.." Stack:"..stack)
	if stack > 0 then
		print("[Placement] Firing Request: Id: "..Id)
		local placed = network:FireEvent("placeBlock", Id, CFrame.new(player:GetMouse().Target.Position + vectorMod:returnVector(player:GetMouse().TargetSurface)), player:GetMouse().Target.Parent.Name)
		if placed then
			character.hotbar[character.currentlyEquipped].Stack = character.hotbar[character.currentlyEquipped].Stack - 1
			if character.hotbar[character.currentlyEquipped].Stack == 0 then
				character.hotbar[character.currentlyEquipped].Id = 0
				character.hotbar[character.currentlyEquipped].Image = ""
				ui:updateHotbar()
				effects:updateArm()
			end
		end
	end
end

function network:FireEvent(event, ...)
	if game.ReplicatedStorage.Events[event].ClassName == "RemoteFunction" then
		local returnable = game.ReplicatedStorage.Events[event]:InvokeServer(...)
		if returnable then
			return returnable
		end
	else
		
	end
end

function chat:receiveMessage(p,m,tag)
	ui:createMessage(p,m,tag)
end

function chat:registerMessage(message)
	print("Attempting to send message!")
	network:FireEvent("playerSentMessage", message)
end

function ui:createBlockInfoContainer(item)
	local id, position = item.Name, item.Position
	player.PlayerGui.Main.blockHovered.Text = itemMod.Localization[id]
	player.PlayerGui.Main.blockHovered2.Text = "Block Height: "..math.floor(position.Y)
end

function ui.selectionChanged(slot)
	if character.currentlyEquipped ~= nil then
		player.PlayerGui.Main.hotBar[character.currentlyEquipped].BackgroundTransparency = .75
	end
	character.currentlyEquipped = slot
	player.PlayerGui.Main.hotBar[character.currentlyEquipped].BackgroundTransparency = 0
	print("Changed Selected Slot To: "..slot)
	effects.currentBlock = nil
	return true
end

function ui:cycleMessages()
	for i,v in pairs(player.PlayerGui.Main.chatFrame:GetChildren()) do
		v.Position = UDim2.new(0,0,0,v.Position.Y.Offset-v.Size.Y.Offset)
		if v.Position.Y.Offset <= 0 then
			v:Destroy()
		end
	end
end

function ui:createMessage(p, message, tag)
	repeat wait(tick) print("Received Message Request, waiting for GUI") until player:FindFirstChild("PlayerGui")
	ui:cycleMessages()
	local newMessage = Instance.new("TextLabel", player.PlayerGui.Main.chatFrame)
	newMessage.TextColor3 = Color3.new(255,255,255)
	newMessage.FontSize = Enum.FontSize.Size14
	newMessage.Font = Enum.Font.Arcade
	newMessage.TextXAlignment = Enum.TextXAlignment.Left
	newMessage.BackgroundTransparency = 1
	if tag then
		newMessage.Text = "["..tag.."]".."["..p.Name.."]"..message
	else
		newMessage.Text = "["..p.Name.."]"..message
	end
	newMessage.Size = UDim2.new(1,0,0,25)
	newMessage.Position = UDim2.new(0,0,0,newMessage.Parent.Size.Y.Offset-25)
end

function ui:registerSystemMessage(message, isJoin, isFirst, isLeave)
	ui:cycleMessages()
	local newMessage = Instance.new("TextLabel", player.PlayerGui.Main.chatFrame)
	if isJoin then
		newMessage.TextColor3 = chat.joinColor
	elseif isFirst then
		newMessage.TextColor3 = chat.firstJoinColor
	elseif isLeave then
		newMessage.TextColor3 = chat.leaveColor
	else
		newMessage.TextColor3 = chat.systemColor
	end
	newMessage.FontSize = Enum.FontSize.Size14
	newMessage.Font = Enum.Font.Arcade
	newMessage.TextXAlignment = Enum.TextXAlignment.Left
	newMessage.BackgroundTransparency = 1
	newMessage.Text = "[System]"..message
	newMessage.Size = UDim2.new(1,0,0,25)
	newMessage.Position = UDim2.new(0,0,0,newMessage.Parent.Size.Y.Offset-25)
end

function ui.updateHotbar()
	for i,v in pairs(character.hotbar) do
		if player.PlayerGui.Main.hotBar:FindFirstChild(i) then
			local slot = player.PlayerGui.Main.hotBar:FindFirstChild(i)
			if v.Id == 0 then
				slot.stack.Text = ""
			else
				slot.stack.Text = "x"..v.Stack
				slot.Image.Image = itemMod.itemImage[v.Id]
			end
		end
	end
end

function ui.updateInventory()
	for i,v in pairs(character.inventory) do
		if player.PlayerGui.Main.Inventory.SlotBag:FindFirstChild(i) then
			local slot = player.PlayerGui.Main.Inventory.SlotBag:FindFirstChild(i)
			if v.Id == 0 then
				slot.stack.Text = ""
			else
				slot.stack.Text = "x"..v.Stack
				slot.Image.Image = itemMod.itemImage[v.Id]
			end
		end
	end
end

function ui.onStepped()
	if effects.Arm ~= nil then
		effects:updateArm()
	end
	if not ui.scenic then
		game:GetService("UserInputService").MouseIconEnabled = false
		player.PlayerGui.Main.Enabled = false
	else
		game:GetService("UserInputService").MouseIconEnabled = true
		player.PlayerGui.Main.Enabled = true
	end
	player:GetMouse().TargetFilter = workspace.ignoreList
	player.PlayerGui.Main.Craft.Visible = character.craftOpen
	player.PlayerGui.Main.Inventory.Visible = character.invOpen
	world:updateChunks()
	ui.updateHotbar()
	ui.updateInventory()
	ui.updateHealthBar()
	local mouse = player:GetMouse()
	player:GetMouse().Icon = ui.cursorIcon
	game:GetService('Players').LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
	if mouse.Target == nil then
		return true
	end
	if item:getId(mouse.Target.Name) ~= nil then
		if itemMod.itemTypes[item:getId(mouse.Target.Name)] == itemMod.Type.Block and (player.Character.PrimaryPart.Position - mouse.Target.Position).Magnitude < 3*5 then
			if not mouse.Target:FindFirstChild("SelectionBox") then
				if effects.currentBox ~= nil then
					effects:destroyBox()
				end
				effects:registerBox(mouse.Target, Color3.new(0,0,0), .01)
				ui:createBlockInfoContainer(mouse.Target)
				player.PlayerGui.Main.blockHovered.Visible = true
				player.PlayerGui.Main.blockHovered2.Visible = true
			end
		elseif mouse.Target.Parent.ClassName == "Model" and not mouse.Target.Parent.Parent == workspace.Blocks and itemMod.itemTypes[item:getId(mouse.Target.Parent.Name)] == itemMod.Type.Block and (player.Character.PrimaryPart.Position - mouse.Target.Parent.PrimaryPart.Position).Magnitude < 3*5 then
			if not mouse.Target.Parent.PrimaryPart:FindFirstChild("SelectionBox") then
				if effects.currentBox ~= nil then
					effects:destroyBox()
				end
				effects:registerBox(mouse.Target.Parent.PrimaryPart, Color3.new(0,0,0), .01)
				ui:createBlockInfoContainer(mouse.Target.Parent.PrimaryPart)
				player.PlayerGui.Main.blockHovered.Visible = true
				player.PlayerGui.Main.blockHovered2.Visible = true
			end
		else
			player.PlayerGui.Main.blockHovered2.Visible = false
			player.PlayerGui.Main.blockHovered.Visible = false
			effects:destroyBox()
		end
	else
		player.PlayerGui.Main.blockHovered2.Visible = false
		player.PlayerGui.Main.blockHovered.Visible = false
		effects:destroyBox()
	end
	if game:GetService("Players").LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
		world:updateCurrentChunk()
	end
end

function ui.craft:changeSelection()
	ui.craft.x = ui.craft.x + 1
	if ui.craft.x > #craftMod.recipeList then
		ui.craft.x = 1
	end
	player.PlayerGui.Main.Craft.finishName.Text = itemMod.Localization[itemMod.Id[craftMod.recipeList[ui.craft.x][1][1]]].." x"..craftMod.recipeList[ui.craft.x][1][2]
	player.PlayerGui.Main.Craft.itemName.Text = itemMod.Localization[itemMod.Id[craftMod.recipeList[ui.craft.x][3][2]]].." x"..craftMod.recipeList[ui.craft.x][3][1]
	player.PlayerGui.Main.Craft.Item.Image = itemMod.itemImage[craftMod.recipeList[ui.craft.x][3][2]]
	player.PlayerGui.Main.Craft.Finish.Image = itemMod.itemImage[craftMod.recipeList[ui.craft.x][1][1]]
end

function ui.craft:createItem()
	print("Attempting Craft of: "..craftMod.recipeList[ui.craft.x][1][1])
	local itemToUse = character:FindItemOnPlayer(craftMod.recipeList[ui.craft.x][3][2])
	if not itemToUse then
		return false
	end
	if itemToUse then
		itemToUse.Stack = itemToUse.Stack - craftMod.recipeList[ui.craft.x][3][1]
		for i = 1, craftMod.recipeList[ui.craft.x][1][2] do
			character:findOpenSlot(craftMod.recipeList[ui.craft.x][1][1])
		end
		if itemToUse.Stack == 0 then
			itemToUse.Id = 0
		end
		return true 
	end
end

function ui:createHealthBar(slots)
	for i = 1, slots do
		local newImage = Instance.new("ImageLabel", player.PlayerGui.Main.Hp)
		newImage.Image = ui.heartImage
		newImage.BackgroundTransparency = 1
		newImage.Name = i
	end
	for i = 1, slots do
		local newImage = Instance.new("ImageLabel", player.PlayerGui.Main.Food)
		newImage.Image = ui.foodIcon
		newImage.BackgroundTransparency = 1
		newImage.Name = i
	end
end

function ui:updateHealthBar()
	for i,v in pairs(player.PlayerGui.Main.Hp:GetChildren()) do
		if v.ClassName == "ImageLabel" then
			if i-1 > math.floor(player.Character.Humanoid.Health/2) then
				v.Visible = false
			else
				v.Visible = true
			end
		end
	end
	for i,v in pairs(player.PlayerGui.Main.Food:GetChildren()) do
		if v.ClassName == "ImageLabel" then
			if i-1 > math.floor(character.currentFood/2) then
				v.Visible = false
			else
				v.Visible = true
			end
		end
	end
end

function effects:registerParticle(pos, color, time, accel, size, speed)
	local part = Instance.new("Part", workspace.ignoreList)
	local particle = Instance.new("ParticleEmitter", part)
	part.Size = size
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	particle.Color = color
	particle.Acceleration = accel
	particle.Speed = NumberRange.new(speed)
	part.CFrame = pos
	wait(time/16)
	part:Destroy()
end

function effects:registerBox(parent, color, size)
	local newBox = Instance.new("SelectionBox", parent)
	newBox.Adornee = parent
	newBox.Color3 = color
	newBox.LineThickness = size
	effects.currentBox = newBox
end

function effects:destroyBox()
	if effects.currentBox ~= nil then
		effects.currentBox:Destroy()
		effects.currentBox = nil
		return true
	else
		return false
	end
end

function effects:toggleBlur(val)
	effects.blur.Enabled = val
end

function effects:registerArm()
	if not workspace.CurrentCamera:FindFirstChild("armPart") then
		effects.Arm = game.ReplicatedStorage.Animations.armPart:Clone()
		effects.Arm.Parent = workspace.CurrentCamera
	end
end

function effects:updateArm()
	if workspace.CurrentCamera:FindFirstChild("armPart") then
		if not character.isWalking then
			effects.Arm.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position - workspace.CurrentCamera.CFrame.UpVector/1.25 + workspace.CurrentCamera.CFrame.RightVector/1.25, player:GetMouse().Hit.p)
		else
			effects.Arm.CFrame = CFrame.new((workspace.CurrentCamera.CFrame.Position - effects.Offset) - workspace.CurrentCamera.CFrame.upVector/1.25 + workspace.CurrentCamera.CFrame.RightVector/1.25, player:GetMouse().Hit.p)
		end
	end
end

function effects:createCloud()
	local h = effects.cloudHeight/4*4
    local cloud = game.ReplicatedStorage.Blocks.Cloud:Clone()
    cloud.Parent = workspace.Clouds
    cloud.Size = Vector3.new(math.random(3,10)*4,math.random(2,5)*4,math.random(3,10)*4)
    cloud.CFrame = CFrame.new(-190, h, math.random(-600,600))
    cloud.CanCollide = false
    game:GetService("RunService").Stepped:Connect(function()
        cloud.CFrame = cloud.CFrame*CFrame.new(.1, 0, 0)
    end)
end

function effects.onStepped()
	if not effects.currentBlock then
		if workspace.CurrentCamera:FindFirstChild("DummyBlock") then
			workspace.CurrentCamera:FindFirstChild("DummyBlock"):Destroy()
		end
		if character.hotbar[character.currentlyEquipped].Id == 0 then
			return
		end
		if not itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block then
			return
		end
		local newBlock = game.ReplicatedStorage.Items[itemMod.Id[character.hotbar[character.currentlyEquipped].Id]]:Clone()
		newBlock.Parent = workspace.CurrentCamera
		newBlock.Name = "DummyBlock"
		if itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block or itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block.Interactable then
			print("[Effects] Block Size")
			newBlock.Size = Vector3.new(.5,.5,.5)
		else
			print("[Effects] Tool Size")
			newBlock.Size = Vector3.new(1.5,1.5,1.5)
		end
		newBlock.CanCollide = false
		effects.currentBlock = newBlock
	end
	effects.currentBlock.CFrame = effects.Arm.CFrame + effects.Arm.CFrame.lookVector*1.75
end

function input:registerInputEvent(inputE)
	local mouse = player:GetMouse()
	local target = mouse.Target
	if keyMod.keyList[inputE.KeyCode] then
		if keyMod.keyList[inputE.KeyCode] >= 1 and keyMod.keyList[inputE.KeyCode] <= 9 then
			print("Found Equipment Slot KeyCode!")
			ui.selectionChanged(keyMod.keyList[inputE.KeyCode])
		elseif keyMod.keyList[inputE.KeyCode] == 10 then
			if not character.invOpen then
				character.invOpen = true
				effects:toggleBlur(true)
			else
				character.invOpen = false
				effects:toggleBlur(false)
			end
		elseif keyMod.keyList[inputE.KeyCode] == 11 then
			if not character.craftOpen then
				character.craftOpen = true
				effects:toggleBlur(true)
			else
				character.craftOpen = false
				effects:toggleBlur(false)
			end
		elseif keyMod.keyList[inputE.KeyCode] == 12 then
			if ui.scenic then
				ui.scenic = not ui.scenic
			else
				ui.scenic = not ui.scenic
			end
		elseif keyMod.keyList[inputE.KeyCode] == 13 then
			if ui.chunkLevel < 3 then
				ui.chunkLevel = ui.chunkLevel + 1
			end
		elseif keyMod.keyList[inputE.KeyCode] == 14 then
			if ui.chunkLevel > 1 then
				ui.chunkLevel = ui.chunkLevel - 1
			end
		elseif keyMod.keyList[inputE.KeyCode] == 15 then
			player.PlayerGui.Main.chatBox:CaptureFocus()	
		elseif keyMod.keyList[inputE.KeyCode] == 16 then
			character.isWalking = true	
		end	
	end
	if character.invOpen or character.craftOpen then
		return false
	end
	if inputE.UserInputType == Enum.UserInputType.MouseButton1 then
		local isBlock = item:checkBlockState(item:getId(target.Name))
		if isBlock then
			if (player.Character.PrimaryPart.Position - target.Position).Magnitude > 3*5 then
				return
			end
			local canBreak = item:checkHardness(item:getId(target.Name))
			if canBreak <= 6 and character.currentlyEquipped == nil or canBreak <= 6 and itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block or canBreak <= 6 and character.hotbar[character.currentlyEquipped].Id == 0 then
				effects:registerParticle(target.CFrame, ColorSequence.new(target.Color), 3, Vector3.new(0,-3,0), Vector3.new(3,3,3), .5)
				local success, tempPart, itemId = network:FireEvent("blockDamage", target, "Hand", 0, item:getId(target.Name))
				if success == "breakBlock" then
					character:findOpenSlot(item:getId(target.Name))
				end
			elseif itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Tool then
				item.type.tool.onUse(target, itemMod.itemSubTypes[character.hotbar[character.currentlyEquipped].Id], character.hotbar[character.currentlyEquipped].Id)
			end
		elseif not isBlock then
			local isModelBlock = item:checkBlockStateModel(target)
			if isModelBlock then
				local canBreak = item:checkHardness(item:getId(target.Parent.Name))
				if canBreak <= 6 and character.currentlyEquipped == nil or canBreak <= 6 and itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block or canBreak <= 6 and character.hotbar[character.currentlyEquipped].Id == 0 then
					effects:registerParticle(target.CFrame, ColorSequence.new(target.Color), 3, Vector3.new(0,-3,0), Vector3.new(3,3,3), .5)
					local name = target.Parent.Name
					local success, tempPart, itemId = network:FireEvent("blockDamage", target.Parent, "Hand", 0, item:getId(target.Name))
					if success == "breakBlock" then
						character:findOpenSlot(item:getId(name))
					end
				end
			end
		end
	end
	if inputE.UserInputType == Enum.UserInputType.MouseButton2 then
		print("BlockPlace Attempt!")
		local isBlock = item:checkBlockState(item:getId(target.Name))
		if isBlock then
			if (player.Character.PrimaryPart.Position - target.Position).Magnitude > 3*5 then
				return
			end
			if character.currentlyEquipped ~= nil then
				if itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block or itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block.Interactable then
					item:placeBlock()
				end
			end
		end
	end
end

function world:updateCurrentChunk()
	for i,v in pairs(workspace.Blocks:GetChildren()) do
		if v.PrimaryPart ~= nil then
			if math.sqrt((v.PrimaryPart.Position.X - player.Character.PrimaryPart.Position.X)^2 + (v.PrimaryPart.Position.Z - player.Character.PrimaryPart.Position.Z)^2) > 24 then
				player.PlayerGui.Main.currChunk.Text = v.Name
			end
		end
	end
end

function world:updateChunks()
	--game.Lighting.FogStart = 15*ui.chunkLevel
	--game.Lighting.FogEnd = 40*ui.chunkLevel
	for i,v in pairs(workspace.Blocks:GetChildren()) do
		if math.sqrt((v.PrimaryPart.Position.X - player.Character.PrimaryPart.Position.X)^2 + (v.PrimaryPart.Position.Z - player.Character.PrimaryPart.Position.Z)^2) > 48*ui.chunkLevel then
			v.Parent = game.ReplicatedStorage.blockCache
		end
	end
	for i,v in pairs(game.ReplicatedStorage.blockCache:GetChildren()) do
		if math.sqrt((v.PrimaryPart.Position.X - player.Character.PrimaryPart.Position.X)^2 + (v.PrimaryPart.Position.Z - player.Character.PrimaryPart.Position.Z)^2) < 48*ui.chunkLevel then
			v.Parent = workspace.Blocks
		end
	end
end

character:Init()


game.ReplicatedStorage.Events.playerSentMessage.OnClientInvoke = function(p, m, tag)
	chat:receiveMessage(p,m,tag)	
end

game.ReplicatedStorage.Events.systemMessage.OnClientInvoke = function(m, i, f, l)
	ui:registerSystemMessage(m, i, f, l)
end

player.PlayerGui.Main.chatBox.FocusLost:Connect(function(e)
	if e then
		chat:registerMessage(player.PlayerGui.Main.chatBox.Text)
	end	
	player.PlayerGui.Main.chatBox.Text = "Press / to start typing!"
end)

player.PlayerGui.Main.Craft.Craft.MouseButton1Click:Connect(function()
	ui.craft:createItem()	
end)
player.PlayerGui.Main.Craft.Right.MouseButton1Click:Connect(function()
	ui.craft:changeSelection()	
end)

game:GetService("UserInputService").InputBegan:Connect(function(i)
	input:registerInputEvent(i)
end)

game:GetService("UserInputService").InputEnded:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.W then
		character.isWalking = false
	end	
end)

spawn(function()
	repeat wait(tick) 
		player.PlayerGui.Load.label.Text = "Loading... [This may take a while!]"
	until
	game:GetService('Players').LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson
	player.PlayerGui.Load.Enabled = false	
end)

spawn(function()
	while wait(math.random(3)) do
		effects:createCloud()
	end	
end)

game:GetService("RunService").RenderStepped:Connect(function()
	ui.onStepped()	
	character.onStepped()
	effects.onStepped()
end)