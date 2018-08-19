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
player.PlayerGui.Load.Enabled = false

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

item.type = {}
item.type.tool = {}
item.type.block = {}
item.type.metaent = {}
item.type.ent = {}

weather.event = {}

chat.filter = {}
chat.event = {}
chat.tags = {}

ui.craft = {}
ui.craft.x = 0

effects.currentBox = nil

ui.cursorIcon = "rbxassetid://1776629404"

function character:Init()
	repeat wait(tick) until player:FindFirstChild("PlayerGui"):FindFirstChild("Main")
	character:createHotbar(9)
	ui.selectionChanged(1)
	character:registerInventory()
	ui.craft:changeSelection()
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
	if itemMod.itemTypes[Id] == itemMod.Type.Block then
		return true
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
	if stack > 0 then
		local placed = network:FireEvent("placeBlock", Id, CFrame.new(player:GetMouse().Target.Position + vectorMod:returnVector(player:GetMouse().TargetSurface)), player:GetMouse().Target.Parent.Name)
		if placed then
			character.hotbar[character.currentlyEquipped].Stack = character.hotbar[character.currentlyEquipped].Stack - 1
			if character.hotbar[character.currentlyEquipped].Stack == 0 then
				character.hotbar[character.currentlyEquipped].Id = 0
				character.hotbar[character.currentlyEquipped].Image = ""
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

function ui:createBlockInfoContainer(id)
	player.PlayerGui.Main.blockHovered.Text = itemMod.Localization[id]
end

function ui.selectionChanged(slot)
	if character.currentlyEquipped ~= nil then
		player.PlayerGui.Main.hotBar[character.currentlyEquipped].BackgroundTransparency = .75
	end
	character.currentlyEquipped = slot
	player.PlayerGui.Main.hotBar[character.currentlyEquipped].BackgroundTransparency = 0
	print("Changed Selected Slot To: "..slot)
	return true
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

function ui.onStepped()
	player.PlayerGui.Main.Craft.Visible = character.craftOpen
	player.PlayerGui.Main.Inventory.Visible = character.invOpen
	world:updateCurrentChunk()
	world:updateChunks()
	ui.updateHotbar()
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
				ui:createBlockInfoContainer(mouse.Target.Name)
				player.PlayerGui.Main.blockHovered.Visible = true
			end
		else
			player.PlayerGui.Main.blockHovered.Visible = false
			effects:destroyBox()
		end
	else
		player.PlayerGui.Main.blockHovered.Visible = false
		effects:destroyBox()
	end
end

function ui.craft:changeSelection()
	ui.craft.x = ui.craft.x + 1
	if ui.craft.x > #craftMod.recipeList then
		ui.craft.x = 1
	end
	player.PlayerGui.Main.Craft.finishName.Text = itemMod.Localization[itemMod.Id[craftMod.recipeList[ui.craft.x][1][1]]].." x"..craftMod.recipeList[ui.craft.x][1][2]
	player.PlayerGui.Main.Craft.itemName.Text = itemMod.Localization[itemMod.Id[craftMod.recipeList[ui.craft.x][3][2]]].." x"..craftMod.recipeList[ui.craft.x][3][1]
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

function effects:registerParticle(pos, color, time, accel, size, speed)
	local part = Instance.new("Part", workspace)
	local particle = Instance.new("ParticleEmitter", part)
	part.Size = size
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	particle.Color = color
	particle.Acceleration = accel
	particle.Speed = speed
	part.CFrame = pos
	wait(time)
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
			else
				character.invOpen = false
			end
		elseif keyMod.keyList[inputE.KeyCode] == 11 then
			if not character.craftOpen then
				character.craftOpen = true
			else
				character.craftOpen = false
			end
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
				local success, tempPart, itemId = network:FireEvent("blockDamage", target, "Hand", 0, item:getId(target.Name))
				if success == "breakBlock" then
					--effects:registerParticle(CFrame.new(tempPart.Position), ColorSequence.new(tempPart.Color), 3, Vector3.new(0,-3,0), Vector3.new(3,3,3), .5)
					character:findOpenSlot(item:getId(target.Name))
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
				if itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block then
					item:placeBlock()
				end
			end
		end
	end
end

function world:updateCurrentChunk()
	for i,v in pairs(workspace.Blocks:GetChildren()) do
		if math.sqrt((v.PrimaryPart.Position.X - player.Character.PrimaryPart.Position.X)^2 + (v.PrimaryPart.Position.Z - player.Character.PrimaryPart.Position.Z)^2) > 24 then
			player.PlayerGui.Main.currChunk.Text = v.Name
		end
	end
end

function world:updateChunks()
	for i,v in pairs(workspace.Blocks:GetChildren()) do
		if math.sqrt((v.PrimaryPart.Position.X - player.Character.PrimaryPart.Position.X)^2 + (v.PrimaryPart.Position.Z - player.Character.PrimaryPart.Position.Z)^2) > 48 then
			v.Parent = game.ReplicatedStorage.blockCache
		end
	end
	for i,v in pairs(game.ReplicatedStorage.blockCache:GetChildren()) do
		if math.sqrt((v.PrimaryPart.Position.X - player.Character.PrimaryPart.Position.X)^2 + (v.PrimaryPart.Position.Z - player.Character.PrimaryPart.Position.Z)^2) < 48 then
			v.Parent = workspace.Blocks
		end
	end
end

character:Init()


player.PlayerGui.Main.Craft.Craft.MouseButton1Click:Connect(function()
	ui.craft:createItem()	
end)
player.PlayerGui.Main.Craft.Right.MouseButton1Click:Connect(function()
	ui.craft:changeSelection()	
end)

game:GetService("UserInputService").InputBegan:Connect(function(i)
	input:registerInputEvent(i)
end)
game:GetService("RunService").RenderStepped:Connect(function()
	ui.onStepped()	
end)