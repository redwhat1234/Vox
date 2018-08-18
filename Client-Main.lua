local player = game.Players.LocalPlayer

local itemMod = require(game.ReplicatedStorage.modules.itemModule)

local character = {}
local item = {}
local weather = {}
local network = {}
local chat = {}
local ui = {}
local effects = {}
local input = {}

character.hotbar = {}
character.inventory = {}
character.currentlyEquipped = nil

item.type = {}
item.type.tool = {}
item.type.block = {}
item.type.metaent = {}
item.type.ent = {}

weather.event = {}

chat.filter = {}
chat.event = {}
chat.tags = {}

effects.currentBox = nil

ui.cursorIcon = "rbxassetid://1776629404"

function character:Init()
	repeat wait(tick) until player:FindFirstChild("PlayerGui"):FindFirstChild("Main")
	character:createHotbar(8)
end

function character:createHotbar(slots)
	for i = 1, slots do
		local newSlot = game.ReplicatedStorage.UIs.slot:Clone()
		newSlot.Name = i
		newSlot.num.Text = i
		newSlot.stack.Text = ""
		newSlot.Image.Image = ""
		newSlot.Parent = player.PlayerGui.Main.hotBar
	end
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

function item.type.tool.onUse(target,toolType,Id)
	if toolType == itemMod.itemSubTypes.Pickaxe then
		if itemMod.Type.Tool.Pickaxe[item:getId(target.Name)] then
			local success, color, pos = network:FireEvent("blockDamage", target, toolType, Id, item:getId(target.Name))
			if success == "breakBlock" then
				effects:registerParticle(pos, color, 3, Vector3.new(0,-3,0), Vector3.new(3,3,3), .5)
			end
		end
	elseif toolType == itemMod.itemSubTypes.Shovel then
		if itemMod.Type.Tool.Shovel[item:getId(target.Name)] then
			local success, color, pos = network:FireEvent("blockDamage", target, toolType, Id, item:getId(target.Name))
			if success == "breakBlock" then
				effects:registerParticle(pos, color, 3, Vector3.new(0,-3,0), Vector3.new(3,3,3), .5)
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

function ui:createBlockInfoContainer(id)
	player.PlayerGui.Main.blockHovered.Text = itemMod.Localization[id]
end

function ui.selectionChanged(container)
	
end

function ui.onStepped()
	local mouse = player:GetMouse()
	player:GetMouse().Icon = ui.cursorIcon
	game:GetService('Players').LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
	if mouse.Target == nil then
		return true
	end
	if item:getId(mouse.Target.Name) ~= nil then
		if itemMod.itemTypes[item:getId(mouse.Target.Name)] == itemMod.Type.Block then
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

function input:registerInputEvent(input)
	print(input.KeyCode)
end

character:Init()

game:GetService("UserInputService").InputBegan:Connect(function(i)
	input:registerInputEvent(i)
end)
game:GetService("RunService").RenderStepped:Connect(function()
	ui.onStepped()	
end)
