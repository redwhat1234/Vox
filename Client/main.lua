local player = game.Players.LocalPlayer

local itemMod = require(game.ReplicatedStorage.modules.itemModule)
local keyMod = require(game.ReplicatedStorage.modules.keyCode)
local vectorMod = require(script.Parent.Placement.Mechanics)
local craftMod = require(game.ReplicatedStorage.modules.craftingModule)
local soundModule = require(game.ReplicatedStorage.modules.gameSound)

repeat wait(tick) until player:FindFirstChild("PlayerGui")
local load = game.ReplicatedStorage

game:GetService("StarterGui"):SetCore("TopbarEnabled", false)

for i,v in pairs(game.ReplicatedStorage.UIs.PlayerLoad:GetChildren()) do
	local newUI = v:Clone()
	newUI.Parent = player.PlayerGui
	print("Client UI Assigned.. "..newUI.Name)
end

repeat wait(tick) until player.PlayerGui:FindFirstChild("Load")
player.PlayerGui.Load.Enabled = true
local loadUI = player.PlayerGui:FindFirstChild("Load")
loadUI.loadBack.loadMain.Size = UDim2.new(workspace.genAmount.Value/100,0,1,0)
loadUI.label.Text = "Generating Terrain...".. math.floor(workspace.genAmount.Value) .."%"

if not workspace.hasFinishedGenerating.Value then 
	game.ReplicatedStorage.Events.initPlayer:FireServer() 
end

repeat wait(tick)
	game:GetService("StarterGui"):SetCore("TopbarEnabled", false)
	local loadUI = player.PlayerGui.Load
	loadUI.loadBack.loadMain.Size = UDim2.new(workspace.genAmount.Value/100,0,1,0)
	if workspace.genAmount.Value < 80 then
		loadUI.label.Text = "Generating Terrain...".. math.floor(workspace.genAmount.Value) .."%"
	elseif workspace.genAmount.Value < 90 then
		loadUI.label.Text = "Generating Caves..."
	else
		loadUI.label.Text = "Simulating the World for a bit..."
	end
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
local sound = {}

local settings = {}

settings.targetFilter = {}

settings.packTable = {
	[1] = "Detailed",
	[2] = "Low Poly"	
}

settings.renderTable = {
	[1] = "Very Low",
	[2] = "Low",
	[3] = "Medium",
	[4] = "High"	
}

settings.currentRenderDistance = 1.5
settings.Shadows = true
settings.Detail = true
settings.TexturePack = 2

character.hotbar = {}
character.inventory = {}
character.currentlyEquipped = nil
character.invOpen = false
character.craftOpen = false
character.currentFood = 20
character.maxFood = 20
character.isWalking = false
character.isMining = false
character.lastTarget = nil
character.rightUse = false

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
ui.isTyping = false

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

function world:roundMultiple(n, mult)
   local h = mult * 0.5
   return (n+h) - (n+h)%mult
end

function character:Init()
	repeat wait(tick) until player:FindFirstChild("PlayerGui"):FindFirstChild("Main")
	character:createHotbar(9)
	ui.selectionChanged(1)
	character:registerInventory()
	ui:createHealthBar(10)
	player.PlayerGui.Main.chatBox.Text = "Press / to start typing!"
	effects:registerArm()
	ui.createCraftButtons()
--	for i,v in pairs(player.Character.Head:GetChildren()) do
--		if v.ClassName == "Sound" then
--			v.SoundId = soundModule.stepIds[soundModule.stepNameId["blockGrass"]]
--		end
--	end
end

function character.onStepped()
	character.currentFood = character.currentFood - .0001
	for i,v in pairs(character.hotbar) do
		v:updateVPF()
	end
	for i,v in pairs(character.inventory) do
		v:updateVPF()
	end
end

function character:createHotbar(slots)
	for i = 1, slots do
		local newSlot = game.ReplicatedStorage.UIs.slot:Clone()
		newSlot.Name = i
		newSlot.num.Text = i
		newSlot.stack.Text = ""
		newSlot.Image.Image = ""
		newSlot.Parent = player.PlayerGui.Main.hotBar
		
		
		newSlot.moveButton.MouseButton1Click:Connect(function()
			character:switchHotbarToInv(character.hotbar[i])
		end)
		
		
		character.hotbar[i] = {
			["Id"] = 0,
			["Stack"] = 0,
			["Image"] = ""
		}
		
		local self = character.hotbar[i]
		
		function self:updateVPF()
			local vpf = newSlot.VF
			
			if not vpf:FindFirstChild("Camera") then
				local cam = Instance.new("Camera", vpf)
				vpf.CurrentCamera = cam
			end
			
			local function clear()
				if vpf:FindFirstChild("itm") then
					vpf:FindFirstChild("itm"):Destroy()
				end
			end
			
			if self.Id ~= nil and self.Id ~= 0 then
				local item = itemMod.Id[self.Id]
				print(item)
				local type = itemMod.itemTypes[self.Id]
				
				local folder, block
				
				if type == itemMod.Type.Block then
					folder = game.ReplicatedStorage.Blocks
					newSlot.Image.Visible = false
					vpf.Visible = true
				elseif type == itemMod.Type.Tool then
					folder = game.ReplicatedStorage.Items
					newSlot.Image.Visible = false
					vpf.Visible = true
					clear()
					return true
				elseif type == itemMod.Type.Entity.Bucket or type == itemMod.Type.Entity.Seed then
					folder = game.ReplicatedStorage.Items
					newSlot.Image.Visible = true
					vpf.Visible = false
					clear()
					return true
				else
					folder = game.ReplicatedStorage.Blocks
					newSlot.Image.Visible = false
					vpf.Visible = true
				end
			
			    if not vpf:FindFirstChild("itm") then
				   block = folder[item]:Clone()
				   block.Parent = vpf
			    end
				
				block.Name = "itm"
				
				local cam = vpf:FindFirstChild("Camera")
				
				cam.CFrame = CFrame.new(block.Position - Vector3.new(3.2,-3.2,3.2), block.Position)
				
			else
				if vpf:FindFirstChild("itm") then
					vpf:FindFirstChild("itm"):Destroy()
				end
			end
			
		end
	end
end

function character:registerInventory()
	for i = 1, 27 do
		local newSlot = game.ReplicatedStorage.UIs.InvSlot:Clone()
		newSlot.Parent = player.PlayerGui.Main.Inventory.SlotBag
		newSlot.Name = "Slot_"..i
		newSlot.moveButton.MouseButton1Click:Connect(function()
			character:switchInvToHotbar(character.inventory[i])	
		end)
		character.inventory[i] = {
			["Id"] = 0,
			["Stack"] = 0,
			["Image"] = ""	
		}
		local self = character.inventory[i]
		
		function self:updateVPF()
			local vpf = newSlot.VF
			
			if not vpf:FindFirstChild("Camera") then
				local cam = Instance.new("Camera", vpf)
				vpf.CurrentCamera = cam
			end
			
			local function clear()
				if vpf:FindFirstChild("itm") then
					vpf:FindFirstChild("itm"):Destroy()
				end
			end
			
			if self.Id ~= nil and self.Id ~= 0 then
				local item = itemMod.Id[self.Id]
				print(item)
				local type = itemMod.itemTypes[self.Id]
				
				local folder, block
				
				if type == itemMod.Type.Block then
					folder = game.ReplicatedStorage.Blocks
					newSlot.Image.Visible = false
					vpf.Visible = true
				elseif type == itemMod.Type.Tool then
					folder = game.ReplicatedStorage.Items
					newSlot.Image.Visible = false
					vpf.Visible = true
					clear()
					return true
				elseif type == itemMod.Type.Entity.Bucket or type == itemMod.Type.Entity.Seed then
					folder = game.ReplicatedStorage.Items
					newSlot.Image.Visible = true
					vpf.Visible = false
					clear()
					return true
				else
					folder = game.ReplicatedStorage.Blocks
					newSlot.Image.Visible = false
					vpf.Visible = true
				end
				
			    if not vpf:FindFirstChild("itm") then
				   block = folder[item]:Clone()
				   block.Parent = vpf
			    end
				
				block.Name = "itm"
				
				local cam = vpf:FindFirstChild("Camera")
				
				cam.CFrame = CFrame.new(block.Position - Vector3.new(3.2,-3.2,3.2), block.Position)
				
			else
				if vpf:FindFirstChild("itm") then
					vpf:FindFirstChild("itm"):Destroy()
				end
			end
		end
	end
end

function checkHotbar(Id)
	for i,v in pairs(character.hotbar) do
		if v.Id == Id and v.Stack < itemMod.maxStacks[Id] then
			return v
		elseif v.Id == 0 then
			return v
		end
	end
	return false
end
	
function checkInv(Id)
	for i,v in pairs(character.inventory) do
		if v.Id == Id and v.Stack < itemMod.maxStacks[Id] then
			return v
		elseif v.Id == 0 then
			return v
		end
	end
	return false
end

function getFirstIdFromId(Id, type)
	if type == "h" then
		local check = checkHotbar(Id)
		if check then
			return check
		else
			return false
		end
	else
		local check = checkInv(Id)
		if check then
			return check
		else
			return false
		end
	end
end

function character:switchHotbarToInv(Slot)
	local Id, Stack, Image = Slot.Id, Slot.Stack, Slot.Image
	if checkInv(Id) then
		print("Found Inventory Slot!")
		if checkInv(Id).Id == 0 then
			print("New Slot")
			local slot = checkInv(Id)
			slot.Id = Id
			slot.Stack = Stack
			slot.Image = Image
			Slot.Id = 0
			Slot.Stack = 0
			Slot.Image = 0
			return true
		else
			print("Current Slot")
			if checkInv(Id).Stack + Stack < itemMod.maxStacks[Id] then
				print("Less Than")
				local slot = checkInv(Id)
				slot.Stack = slot.Stack + Stack
				Slot.Stack = 0
				Slot.Id = 0
				Slot.Image = 0
				return true
			else
				print("More Than...")
				local slot = checkInv(Id)
				if slot.Stack + Stack > itemMod.maxStacks[Id] then
					local difference = itemMod.maxStacks[Id] - slot.Stack
					slot.Stack = slot.Stack + difference
					slot.Id = Id
					slot.Image = Image
					Slot.Stack = Slot.Stack - difference
					return true
				end
			end
		end
	end
end

function character:switchInvToHotbar(Slot)
	local Id, Stack, Image = Slot.Id, Slot.Stack, Slot.Image
	if checkHotbar(Id) then
		print("Found Inventory Slot!")
		if checkHotbar(Id).Id == 0 then
			print("New Slot")
			local slot = checkHotbar(Id)
			slot.Id = Id
			slot.Stack = Stack
			slot.Image = Image
			Slot.Id = 0
			Slot.Stack = 0
			Slot.Image = 0
			return true
		else
			print("Current Slot")
			if checkHotbar(Id).Stack + Stack < itemMod.maxStacks[Id] then
				print("Less Than")
				local slot = checkHotbar(Id)
				slot.Stack = slot.Stack + Stack
				Slot.Stack = 0
				Slot.Id = 0
				Slot.Image = 0
				return true
			else
				print("More Than...")
				local slot = checkHotbar(Id)
				if slot.Stack + Stack > itemMod.maxStacks[Id] then
					local difference = itemMod.maxStacks[Id] - slot.Stack
					slot.Stack = slot.Stack + difference
					slot.Id = Id
					slot.Image = Image
					Slot.Stack = Slot.Stack - difference
					return true
				end
			end
		end
	end
end

function character:findOpenSlot(Id)
	local hotbar = checkHotbar(Id)
	if hotbar then
		hotbar.Id = Id
		if hotbar.Stack < 1 then
			hotbar.Stack = 1
		else
			hotbar.Stack = hotbar.Stack+1
		end
		hotbar.Image = itemMod.itemImage[Id]
	else
		local inv = checkInv(Id)
		if inv then
			inv.Id = Id
			if inv.Stack < 1 then
				inv.Stack = 1
			else
				inv.Stack = inv.Stack + 1
			end
			inv.Image = itemMod.itemImage[Id]
		end
	end
end

--function character:findOpenSlot(Id)
--	for i,v in pairs(character.hotbar) do
--		print("Slot Id: "..i.." Item Id: "..Id)
--		if character.hotbar[i].Id == Id and character.hotbar[i].Stack < itemMod.maxStacks[Id] then
--			character.hotbar[i].Stack = character.hotbar[i].Stack + 1
--			print("Updated Current Stack! .. Slot: "..i)
--			return true
--		elseif character.hotbar[i].Id == 0 then
--			character.hotbar[i].Id = Id
--			character.hotbar[i].Stack = 1
--			character.hotbar[i].Image = itemMod.itemImage[Id]
--			print("Created New Stack! .. Slot: "..i)
--			return true
--		end
--	end
--		print("[Character :: Slot Locate] Couldn't Find Slot In Hotbar, Checking Inventory")
--	for i,v in pairs(character.inventory) do
--		if character.inventory[i].Id == Id and character.inventory[i].Stack < itemMod.maxStacks[Id] then
--			character.inventory[i].Stack = character.inventory[i].Stack + 1
--			print("Updated Current Stack! .. Slot: "..i)
--			return true
--		elseif character.inventory[i] == 0 then
--			character.inventory[i].Id = Id
--			character.inventory[i].Stack = 1
--			character.inventory[i].Image = itemMod.itemImage[Id]
--			print("Created New Stack! .. Slot: "..i)
--			return true
--		end
--	end
--end

function character:FindItemOnPlayer(Id)
	for i,v in pairs(character.inventory) do
		if v.Id == Id then
			return v
		end
	end
	for i,v in pairs(character.hotbar) do
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

function item.type.tool.resetLastBlock()
	if character.lastTarget ~= nil then
		for i,v in pairs(character.lastTarget:GetDescendants()) do
			if v.ClassName == "Decal" then
				v:Destroy()
			end
		end
	end
end
--
--function item.type.tool.onUse(toolId, target)
--	while character.isMining and target~= nil do
--	if character.isMining and target~= nil and target == character.lastTarget then
--		wait(tick)
--		print("[Tool Use :: Block Hardness] "..itemMod.Type.Block.Hardness[item:getId(target.Name)])
--		local mineTime
--		local correctTool = false
--		for i,v in pairs(itemMod.itemSubTypes[toolId]) do
--			print("[Tool Use :: itemSubType Accepted List] Id: "..v)
--			if v == item:getId(target.Name) then
--				correctTool = true
--			end
--		end
--		if correctTool then
--			warn("[Tool Use :: Block Break Type Determination] True")
--		else
--			warn("[Tool Use :: Block Break Type Determination] False")
--		end
--		if itemMod.itemTypes[toolId] ~= itemMod.Type.Block and correctTool then
--			print("[Tool Use :: Break Type] Correct Tool-Type")
--			mineTime = itemMod.Type.Block.Hardness[item:getId(target.Name)]*1.5
--		else
--			print("[Tool Use :: Break Type] Not Correct Tool-Type")
--			mineTime = itemMod.Type.Block.Hardness[item:getId(target.Name)]*5
--		end
--		if itemMod.itemTypes[toolId] == itemMod.Type.Block then
--			print("[Tool Use :: Tool Level] "..itemMod.Type.Tool.toolLevel[0])
--			mineTime = mineTime/(itemMod.Type.Tool.toolLevel[0])
--		else
--			print("[Tool Use :: Tool Level] "..itemMod.Type.Tool.toolLevel[toolId])
--			mineTime = mineTime/(itemMod.Type.Tool.toolLevel[toolId])
--		end
--	elseif character.isMining and target~= nil and target ~= character.lastTarget then
--		item.type.tool.resetLastBlock()
--		character.lastTarget = target
--		wait(tick)
--		print("[Tool Use :: Block Hardness] "..itemMod.Type.Block.Hardness[item:getId(target.Name)])
--		local mineTime
--		local correctTool = false
--		for i,v in pairs(itemMod.itemSubTypes[toolId]) do
--			print("[Tool Use :: itemSubType Accepted List] Id: "..v)
--			if v == item:getId(target.Name) then
--				correctTool = true
--			end
--		end
--		if correctTool then
--			warn("[Tool Use :: Block Break Type Determination] True")
--		else
--			warn("[Tool Use :: Block Break Type Determination] False")
--		end
--		if itemMod.itemTypes[toolId] ~= itemMod.Type.Block and correctTool then
--			print("[Tool Use :: Break Type] Correct Tool-Type")
--			mineTime = itemMod.Type.Block.Hardness[item:getId(target.Name)]*1.5
--		else
--			print("[Tool Use :: Break Type] Not Correct Tool-Type")
--			mineTime = itemMod.Type.Block.Hardness[item:getId(target.Name)]*5
--		end
--		if itemMod.itemTypes[toolId] == itemMod.Type.Block then
--			print("[Tool Use :: Tool Level] "..itemMod.Type.Tool.toolLevel[0])
--			mineTime = mineTime/(itemMod.Type.Tool.toolLevel[0])
--		else
--			print("[Tool Use :: Tool Level] "..itemMod.Type.Tool.toolLevel[toolId])
--			mineTime = mineTime/(itemMod.Type.Tool.toolLevel[toolId])
--		end
--	end
--	end
--end

function item.type.tool.onRightUse(toolId, target)
	print("[Tool Use :: Block Unlocalized Name] "..target.Name)
	print("[Tool Use :: Tool Id] "..toolId)
	if target ~= nil then
		if itemMod.itemSubTypes[toolId] == itemMod.Type.Tool.Hoe then
			if item:getId(target.Name) == 1 or item:getId(target.Name) == 2 then
				game.ReplicatedStorage.Events.convertToFarmland:FireServer(target)
				return true
			end
		elseif itemMod.itemTypes[toolId] == itemMod.Type.Entity.Seed then
			if target.Name == "blockFarmland" or target.Name == "blockNourishedFarmland" or target.Parent.Name == "blockFarmland" then
				print("Firing Plant Event")
				if target:FindFirstChild("OnPlant") then
					target.OnPlant:FireServer(toolId)
				elseif target.Parent:FindFirstChild("OnPlant") then
					target.Parent.OnPlant:FireServer(toolId)
				end
			end
			return true
		elseif itemMod.itemTypes[toolId] == itemMod.Type.Entity.Bucket then
			if toolId == 50 then
				local item = character.hotbar[character.currentlyEquipped]
				if target.Name == "blockWater" then
					if item.Stack > 1 then
						character:findOpenSlot(51)
						item.Stack = item.Stack - 1
					else
						item.Id = 51
						item.Image = itemMod.itemImage[51]
					end	
					ui:updateHotbar()
					effects:updateArm()
				elseif target.Name == "blockLava" then
					if item.Stack > 1 then
						character:findOpenSlot(52)
						item.Stack = item.Stack - 1
					else
						item.Id = 52
						item.Image = itemMod.itemImage[52]
					end	
					ui:updateHotbar()
					effects:updateArm()
				end 
			end	
		end
	end
end

function item.type.tool.onUse(toolId, target)
	print("[Tool Use :: Block Unlocalized Name] "..target.Name)
	print("[Tool Use :: Tool Id] "..toolId)
	if target.Name == "blockFarmland" and target.itemId.Value ~= 0 or target.Name == "blockNourishedFarmland" or target.Parent.Name == "blockFarmland" and target.Parent.itemId.Value ~= 0 then
		print("Firing Harvest Event")
		if target:FindFirstChild("Harvest") then
			target.Harvest:FireServer(toolId)
		elseif target.Parent:FindFirstChild("Harvest") then
			target.Parent.Harvest:FireServer(toolId)
		end
		return true
	end
	if itemMod.itemSubTypes[toolId] == itemMod.Type.Tool.Sword then
		if target.Parent:FindFirstChild("Humanoid") then
			local damage = game.ReplicatedStorage.Events.entityDamage:InvokeServer(target.Parent.Humanoid, itemMod.Type.Tool.Sword.Damage[toolId])
			if damage then
				print("Entity was a Damaged for: "..damage)
				return true
			end
		end
	end
	while character.isMining and target ~= nil do
		wait(tick)
		print("[Tool Use :: Block Hardness] "..itemMod.Type.Block.Hardness[item:getId(target.Name)])
		local mineTime
		local correctTool = false
		for i,v in pairs(itemMod.itemSubTypes[toolId]) do
			print("[Tool Use :: itemSubType Accepted List] Id: "..v)
			if v == item:getId(target.Name) then
				correctTool = true
			end
		end
		if correctTool then
			warn("[Tool Use :: Block Break Type Determination] True")
		else
			warn("[Tool Use :: Block Break Type Determination] False")
		end
		if itemMod.itemTypes[toolId] ~= itemMod.Type.Block and correctTool then
			print("[Tool Use :: Break Type] Correct Tool-Type")
			mineTime = itemMod.Type.Block.Hardness[item:getId(target.Name)]*1.5
		else
			print("[Tool Use :: Break Type] Not Correct Tool-Type")
			mineTime = itemMod.Type.Block.Hardness[item:getId(target.Name)]*5
		end
		if itemMod.itemTypes[toolId] == itemMod.Type.Block then
			print("[Tool Use :: Tool Level] "..itemMod.Type.Tool.toolLevel[0])
			mineTime = mineTime/(itemMod.Type.Tool.toolLevel[0])
		else
			print("[Tool Use :: Tool Level] "..itemMod.Type.Tool.toolLevel[toolId])
			mineTime = mineTime/(itemMod.Type.Tool.toolLevel[toolId])
		end
		print("[Tool Use :: Mining Time] "..mineTime)
		for i = 1, 10 do
			if character.isMining then
				if target.ClassName == "Part" or target.ClassName == "UnionOperation" then
					if not target:FindFirstChild("breakDecal1") then
						print("[Tool Use :: Decal Creation] Creating New Break Effect.")
						for a = 1, 6 do
							local newDecal = Instance.new("Decal", target)
							newDecal.Face = itemMod.faceIds[a]
							newDecal.Texture = itemMod.breakId[i]
							newDecal.Name = "breakDecal"..a
						end
					else
						print("[Tool Use :: Decal Creation] Updating Break Effect.")
						for a = 1,6 do
							target:FindFirstChild("breakDecal"..a).Texture = itemMod.breakId[i]
						end
					end
			if target.Name == "blockStone" or string.find(target.Name, "ore", 1, 1) then
				game.SoundService.Stone.PlaybackSpeed = math.random(.7,1.2)
				game.SoundService.Stone:Play()
			elseif target.Name == "blockDirt" or target.Name == "blockGrass" then
				game.SoundService.Dirt.PlaybackSpeed = math.random(.7,1.2)
				game.SoundService.Dirt:Play()
			elseif target.Name == "blockLog" or target.Name == "blockPlank"	then
				game.SoundService.Wood.PlaybackSpeed = math.random(.7,1.2)
				game.SoundService.Wood:Play()
			elseif target.Name == "blockSand" then
				game.SoundService.Sand.PlaybackSpeed = math.random(.7,1.2)
				game.SoundService.Sand:Play()
			end
					if i == 10 then
						print("[Tool Use :: Fire Event] Firing Break Event.")
						network:FireEvent("blockDamage", target, mineTime)
					end
				end
			else
				print("[Tool Use :: Action Broken] Action was Ended Returning with Remaining Time of: "..mineTime-(mineTime/i))
				for i,v in pairs(target:GetChildren()) do
					if v.ClassName == "Decal" then
						v:Destroy()
					end
				end
				break
			end
			wait(mineTime/10)
		end
	end
	if not target == nil then
		for i,v in pairs(target:GetChildren()) do
			if v.ClassName == "Decal" then
				v:Destroy()
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
		
		local targ = player:GetMouse().Target.Parent.Parent
		
		if targ.Parent ~= workspace.Blocks then
			targ = targ.Parent
		end
		
		local placed = network:FireEvent("placeBlock", Id, CFrame.new(player:GetMouse().Target.Position + vectorMod:returnVector(player:GetMouse().TargetSurface)), targ.Name)
		if placed then
			character.hotbar[character.currentlyEquipped].Stack = character.hotbar[character.currentlyEquipped].Stack - 1
			if itemMod.Id[Id] == "blockStone" or string.find(itemMod.Id[Id], "ore", 1, 1) then
				game.SoundService.Stone.PlaybackSpeed = math.random(.7,1.2)
				game.SoundService.Stone:Play()
			elseif itemMod.Id[Id] == "blockLog" or itemMod.Id[Id] == "blockPlank" then
				game.SoundService.Wood.PlaybackSpeed = math.random(.7,1.2)
				game.SoundService.Wood:Play()
			elseif itemMod.Id[Id] == "blockSand" then
				game.SoundService.Sand.PlaybackSpeed = math.random(.7,1.2)
				game.SoundService.Sand:Play()
			elseif itemMod.Id[Id] == "blockDirt" or itemMod.Id[Id] == "blockGrass" then
				game.SoundService.Dirt.PlaybackSpeed = math.random(.7,1.2)
				game.SoundService.Dirt:Play()
			end
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
	if message == "" or message == "Press / to start typing!" then
		return
	end
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
				slot.Image.Image = ""
			else
				slot.stack.Text = "x"..v.Stack
				slot.Image.Image = itemMod.itemImage[v.Id]
			end
		end
	end
end

function ui.updateInventory()
	for i,v in pairs(character.inventory) do
		if player.PlayerGui.Main.Inventory.SlotBag:FindFirstChild("Slot_"..i) then
			local slot = player.PlayerGui.Main.Inventory.SlotBag:FindFirstChild("Slot_"..i)
			if v.Id == 0 then
				slot.stack.Text = ""
				slot.Image.Image = ""
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
		if workspace.CurrentCamera:FindFirstChild("armPart") then
			workspace.CurrentCamera:FindFirstChild("armPart").Transparency = 1
			if workspace.CurrentCamera:FindFirstChild("DummyBlock") then
				workspace.CurrentCamera:FindFirstChild("DummyBlock").Transparency = 1
			end
		end
	else
		game:GetService("UserInputService").MouseIconEnabled = true
		player.PlayerGui.Main.Enabled = true
		if workspace.CurrentCamera:FindFirstChild("armPart") then
			workspace.CurrentCamera:FindFirstChild("armPart").Transparency = 0
			if workspace.CurrentCamera:FindFirstChild("DummyBlock") then
				if not workspace.CurrentCamera:FindFirstChild("DummyBlock"):FindFirstChild("Decal") then
					workspace.CurrentCamera:FindFirstChild("DummyBlock").Transparency = 0
				end
			end
		end
	end
	player:GetMouse().TargetFilter = workspace.ignoreList
	player.PlayerGui.Main.Craft.Visible = character.craftOpen
	player.PlayerGui.Main.Inventory.Visible = character.invOpen
	ui.updateHotbar()
	ui.updateInventory()
	ui.updateHealthBar()
	ui:updatePosition()
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
		--world:updateCurrentChunk()
	end
	if not player.PlayerGui.Load.Enabled then
		world:updateChunks()
	end
end

--function ui.craft:changeSelection(direction)
--	if direction == "Plus" then
--		ui.craft.x = ui.craft.x + 1
--		if ui.craft.x > #craftMod.recipeList then
--			ui.craft.x = 1
--		end
--	else
--		ui.craft.x = ui.craft.x - 1
--		if ui.craft.x < 1 then
--			ui.craft.x = #craftMod.recipeList
--		end
--	end
--	player.PlayerGui.Main.Craft.finishName.Text = itemMod.Localization[itemMod.Id[craftMod.recipeList[ui.craft.x][1][1]]].." x"..craftMod.recipeList[ui.craft.x][1][2]
--	player.PlayerGui.Main.Craft.itemName.Text = itemMod.Localization[itemMod.Id[craftMod.recipeList[ui.craft.x][3][2]]].." x"..craftMod.recipeList[ui.craft.x][3][1]
--	player.PlayerGui.Main.Craft.Item.Image = itemMod.itemImage[craftMod.recipeList[ui.craft.x][3][2]]
--	player.PlayerGui.Main.Craft.Finish.Image = itemMod.itemImage[craftMod.recipeList[ui.craft.x][1][1]]
--end

--function ui.craft:createItem()
--	print("Attempting Craft of: "..craftMod.recipeList[ui.craft.x][1][1])
--	local itemToUse = character:FindItemOnPlayer(craftMod.recipeList[ui.craft.x][3][2])
--	if not itemToUse then
--		return false
--	end
--	if itemToUse then
--		itemToUse.Stack = itemToUse.Stack - craftMod.recipeList[ui.craft.x][3][1]
--		for i = 1, craftMod.recipeList[ui.craft.x][1][2] do
--			character:findOpenSlot(craftMod.recipeList[ui.craft.x][1][1])
--		end
--		if itemToUse.Stack <= 0 then
--			itemToUse.Id = 0
--			itemToUse.Image = ""
--		end
--		return true 
--	end
--end

function ui.craft:createItem()
	print("Attempting Craft of: "..craftMod.recipeList[ui.craft.x].newItem[1])
	local canCraft = false
	for i,v in pairs(craftMod.recipeList[ui.craft.x].recipeTree) do
		if v ~= nil then
			if v[1] ~= nil and v[2] ~= nil then
				print("Running Item Check...")
				local item = character:FindItemOnPlayer(v[1], v[2])
				if not item then
					return false
				else
					print("Found Item: "..v[1])
					canCraft = true
				end
			end
		else
			print("v == nil")
		end
	end
	print("Craft Requirements Met...")
	if canCraft then
		for i,v in pairs(craftMod.recipeList[ui.craft.x].recipeTree) do
			if v[1] ~= nil then
				local item = character:FindItemOnPlayer(v[1], v[2])
				item.Stack = item.Stack - v[2]
				print("Subtracted "..v[2])
				if item.Stack <= 0 then
					item.Id = 0
					item.Image = ""
				end
			end
		end
	end
	if canCraft then
		for i = 1, craftMod.recipeList[ui.craft.x].newItem[2] do
			character:findOpenSlot(craftMod.recipeList[ui.craft.x].newItem[1])
		end
	end
	return false
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

function ui:updatePosition()
	player.PlayerGui.Main.playerPosition.Text = "X:"..world:roundMultiple(math.floor(player.Character.PrimaryPart.Position.X),3)/3 .." Y:"..world:roundMultiple(math.floor(player.Character.PrimaryPart.Position.Y),3)/3 .." Z:"..world:roundMultiple(math.floor(player.Character.PrimaryPart.Position.Z),3)/3
	player.PlayerGui.Main.fpsTracker.Text = "Frames Per Second: "..math.floor(workspace:GetRealPhysicsFPS())
	player.PlayerGui.Main.currentChunk.Text = "Chunk : X:"..(world:roundMultiple(math.floor(player.Character.PrimaryPart.Position.X),(3*16))/16)/3 .." Z:"..(world:roundMultiple(math.floor(player.Character.PrimaryPart.Position.Z),(3*16))/16)/3
end

--function ui:createCraftButtons()
--	for i = 1, #craftMod.recipeList do
--		local newThing = game.ReplicatedStorage.UIs.CraftTab:Clone()
--		repeat wait(tick) until newThing:FindFirstChild("finishName")
--		print("[Item :: Crafting] Creating New Button: Item Used: "..craftMod.recipeList[i][3][2].." "..itemMod.Id[craftMod.recipeList[i][3][2]].." Finished Item: "..craftMod.recipeList[i][1][1])
--		newThing.itemName.Text = itemMod.Localization[itemMod.Id[craftMod.recipeList[i][3][2]]]
--		newThing.finishName.Text = itemMod.Localization[itemMod.Id[craftMod.recipeList[i][1][1]]]
--		newThing.Finish.number.Text = "x"..craftMod.recipeList[i][1][2]
--		newThing.Item.number.Text = "x"..craftMod.recipeList[i][3][1]
--		newThing.Item.Image = itemMod.itemImage[craftMod.recipeList[i][3][2]]
--		newThing.Finish.Image = itemMod.itemImage[craftMod.recipeList[i][1][1]]
--		newThing.CraftId.Value = i
--		newThing.Parent = player.PlayerGui.Main.Craft
--		newThing.Craft.MouseButton1Click:Connect(function()
--			ui.craft.x = newThing.CraftId.Value
--			ui.craft.createItem()
--		end)
--	end
--end

function ui:createCraftButtons()
	for i = 1, #craftMod.recipeList do
		local recipe = craftMod.recipeList[i]
		if recipe.Type == "MultiItem" then
			local newThing = game.ReplicatedStorage.UIs.CraftTab:Clone()
			repeat wait(tick) until newThing:FindFirstChild("finishName")
			newThing.Multi.Visible = true
			for a,v in pairs(recipe.recipeTree) do
				if v[1] == nil then
				newThing.Multi[a].Image = ""
				newThing.Multi[a].Amount.Text = ""
				else
			    newThing.Multi[a].Image = itemMod.itemImage[v[1]]
			    newThing.Multi[a].Amount.Text = "x".. v[2] 
			    newThing.Parent = player.PlayerGui.Main.Craft
			    newThing.Multi[a].Name = itemMod.Localization[itemMod.Id[recipe.newItem[1]]]
			    newThing.Multi:GetChildren()[a].MouseEnter:Connect(function()
				   if not player.PlayerGui.Misc:FindFirstChild("ToolTip") then
					  local toolTip = Instance.new("TextLabel", player.PlayerGui.Misc)
					  toolTip.Size = UDim2.new(0,125,0,15)
					  toolTip.BackgroundColor3 = Color3.fromRGB(4, 10, 48)
					  toolTip.Position = UDim2.new(0,player:GetMouse().X, 0, player:GetMouse().Y)
					  toolTip.Text = newThing.Multi:GetChildren()[a].Name
					  toolTip.TextColor3 = Color3.fromRGB(255,255,255)
					  player:GetMouse().Move:Connect(function()
						  toolTip.Position = UDim2.new(0,player:GetMouse().X, 0, player:GetMouse().Y)
					  end)
					  newThing.MouseLeave:Connect(function()
						 toolTip:Destroy()
					  end)
				   end
			    end)
			end
        end
		newThing.Craft.MouseButton1Click:Connect(function()
		     ui.craft.x = newThing.CraftId.Value
			 ui.craft.createItem()
		end)
	    newThing.Finish.Image = itemMod.itemImage[recipe.newItem[1]]
	    newThing.Finish.number.Text = "x".. recipe.newItem[2]
	    newThing.CraftId.Value = i
	    newThing.finishName.Text = itemMod.Localization[itemMod.Id[recipe.newItem[1]]]
		elseif recipe[2] == "OneItem" then
			-- Do nothing these don't exist...
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
	local walkSpeed = 8
	if workspace.CurrentCamera:FindFirstChild("armPart") then
		player:GetMouse().TargetFilter = workspace
		if character.isWalking then
			local walkSpeed = math.clamp(player.Character.Humanoid.MoveDirection.Magnitude,0,1)*player.Character.Humanoid.WalkSpeed/3
			effects.Offset = Vector3.new(-(math.sin(time() * math.pi * walkSpeed)*.1)/2, -(math.sin(time() * math.pi * walkSpeed)*.1)/4, 0)
			player.Character.Humanoid.CameraOffset = Vector3.new(0, math.sin(time() * math.pi * walkSpeed)*.1, 0)
			effects.Arm.CFrame = CFrame.new((workspace.CurrentCamera.CFrame.Position - effects.Offset) - workspace.CurrentCamera.CFrame.upVector/1.25 + workspace.CurrentCamera.CFrame.RightVector/1.25, player:GetMouse().Hit.p)
		elseif character.isMining then
			effects.Offset = Vector3.new(-(math.sin(time() * math.pi * walkSpeed)*.1)/2, 0, 0)
			effects.Arm.CFrame = CFrame.new((workspace.CurrentCamera.CFrame.Position - effects.Offset) - workspace.CurrentCamera.CFrame.upVector/1.25 + workspace.CurrentCamera.CFrame.RightVector/1.25, player:GetMouse().Hit.p) * CFrame.Angles(-(math.sin(time() * math.pi * walkSpeed)*.5), 0, 0)
		elseif not character.isWalking then
			effects.Arm.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position - workspace.CurrentCamera.CFrame.UpVector/1.25 + workspace.CurrentCamera.CFrame.RightVector/1.25, player:GetMouse().Hit.p)
			player.Character.Humanoid.CameraOffset = Vector3.new(0,0,0)
		end
	end
end

function effects:createCloud()
	local h = effects.cloudHeight/4*4
    local cloud = game.ReplicatedStorage.Blocks.Cloud:Clone()
    cloud.Parent = workspace.Clouds
    cloud.Size = Vector3.new(math.random(10,30)*4,5*4,math.random(10,30)*4)
    cloud.CFrame = CFrame.new(-190, h, math.random(-600,600))
    cloud.CanCollide = false
    game:GetService("RunService").Stepped:Connect(function()
        cloud.CFrame = cloud.CFrame*CFrame.new(.1, 0, 0)
        if cloud.CFrame.X >= 1000 then
	       cloud:Destroy()
        end
    end)
end

function effects:updateDepthFog()
--	local pos
--	if player.Character.PrimaryPart.Position.Y == 0 then
--		pos = 3
--	else
--		pos = player.Character.PrimaryPart.Position.Y
--	end
--	game.Lighting.FogStart = (400/(math.abs(world:roundMultiple(pos, 3)))/2.5)
--	game.Lighting.FogEnd = (800/(math.abs(world:roundMultiple(pos, 3)))/2.5)
end

function effects:weatherStep()
	if workspace.IsRaining then
		for i,v in pairs(workspace.Clouds:GetChildren()) do
			v.Color = Color3.fromRGB(65,65,65)
		end
		for i,v in pairs(player.Character.HumanoidRootPart:GetChildren()) do
			if v.ClassName == "Beam" then
				v.Enabled = true
			end
		end
		game.Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
	else
		for i,v in pairs(workspace.Clouds:GetChildren()) do
			v.Color = game.ReplicatedStorage.Blocks.Cloud.Color
		end
		for i,v in pairs(player.Character.HumanoidRootPart:GetChildren()) do
			if v.ClassName == "Beam" then
				v.Enabled = false
			end
		end
		game.Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)
	end
end

function effects.onStepped()
	effects:weatherStep()
	world:updateCurrentChunk()
	if not effects.currentBlock then
		if workspace.CurrentCamera:FindFirstChild("DummyBlock") then
			workspace.CurrentCamera:FindFirstChild("DummyBlock"):Destroy()
		end
		local currType
		if itemMod.itemTypes[character.currentlyEquipped] == itemMod.Type.Tool then
			currType = "Tool"
		else
			currType = "Block"
		end
		if character.hotbar[character.currentlyEquipped].Id == 0 then
			return
		end
		game.ReplicatedStorage.Events.eqpChange:FireServer(itemMod.Id[character.hotbar[character.currentlyEquipped].Id], currType)
		if not itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block then
			return
		end
		local newBlock = game.ReplicatedStorage.Items[itemMod.Id[character.hotbar[character.currentlyEquipped].Id]]:Clone()
		newBlock.Parent = workspace.CurrentCamera
		newBlock.Name = "DummyBlock"
		if itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block or itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block.Interactable then
			print("[Effects] Block Size")
			newBlock.Size = Vector3.new(.5,.5,.5)
		elseif itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Tool then
			print("[Effects] Tool Size")
			newBlock.Size = Vector3.new(1.5,1.5,1.5)
		else
			newBlock.Size = game.ReplicatedStorage.Items[itemMod.Id[character.hotbar[character.currentlyEquipped].Id]].Size/2
		end
		newBlock.CanCollide = false
		effects.currentBlock = newBlock
	elseif effects.currentBlock and character.hotbar[character.currentlyEquipped].Id == 0 then
		if workspace.CurrentCamera:FindFirstChild("DummyBlock") then
			workspace.CurrentCamera:FindFirstChild("DummyBlock"):Destroy()
		end	
	end	
	effects.currentBlock.CFrame = effects.Arm.CFrame + effects.Arm.CFrame.lookVector*1.75
	effects:updateDepthFog()
end

function input:registerInputEvent(inputE)
	local mouse = player:GetMouse()
	local target = mouse.Target
	if ui.isTyping then
		return
	end
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
				for i, v in pairs(player.PlayerGui.Main.Craft:GetChildren()) do
					if v.ClassName == "Frame" then
						if v.Craft then
							if v.Craft.ClassName == "TextButton" then
								v.Craft.Modal = true
							end
						end
						v.Visible = true
					end
				end
				effects:toggleBlur(true)
			else
				character.craftOpen = false
				for i, v in pairs(player.PlayerGui.Main.Craft:GetChildren()) do
					if v.ClassName == "Frame" then
						if v.Craft then
							if v.Craft.ClassName == "TextButton" then
								v.Craft.Modal = false
							end
						end
						v.Visible = false
					end
				end
				effects:toggleBlur(false)
			end
		elseif keyMod.keyList[inputE.KeyCode] == 12 then
			if ui.scenic then
				ui.scenic = not ui.scenic
			else
				ui.scenic = not ui.scenic
			end
		elseif keyMod.keyList[inputE.KeyCode] == 13 then
			if ui.chunkLevel < 6 then
				ui.chunkLevel = ui.chunkLevel + 1
			end
		elseif keyMod.keyList[inputE.KeyCode] == 14 then
			if ui.chunkLevel > 1 then
				ui.chunkLevel = ui.chunkLevel - 1
			end
		elseif keyMod.keyList[inputE.KeyCode] == 15 then
			player.PlayerGui.Main.chatBox:CaptureFocus()
			ui.isTyping = true
				
		elseif keyMod.keyList[inputE.KeyCode] == 16 then
			character.isWalking = true	
		elseif keyMod.keyList[inputE.KeyCode] == 17 then
			network:FireEvent("jumpActive", true, player.Character.PrimaryPart.Position.Y)
		elseif keyMod.keyList[inputE.KeyCode] == 18 then
			print("Changing Settings.Detail")
			settings.Detail = not settings.Detail	
			settings.Stepped()
		elseif keyMod.keyList[inputE.KeyCode] == 19 then
			settings.Shadows = not settings.Shadows
			print("Changing Settings.Shadows")
			settings.Stepped()
		elseif keyMod.keyList[inputE.KeyCode] == 20 then
			settings.TexturePack = settings.TexturePack + 1		
			print("Changing Settings.TexturePack")
			if settings.TexturePack > 2 then
				settings.TexturePack = 1
			end
			settings.Stepped()
			print("TextureP: "..settings.TexturePack)
		elseif keyMod.keyList[inputE.KeyCode] == 21 then
			local dropped = game.ReplicatedStorage.Events.dropItem:InvokeServer(itemMod.Id[character.hotbar[character.currentlyEquipped].Id], player.Character.PrimaryPart.Position + player.Character.PrimaryPart.CFrame.lookVector*1.2 - player.Character.PrimaryPart.CFrame.upVector*player.Character.Humanoid.HipHeight)
			if dropped then
				character.hotbar[character.currentlyEquipped].Stack = character.hotbar[character.currentlyEquipped].Stack - 1
				if character.hotbar[character.currentlyEquipped].Stack <= 0 then
					character.hotbar[character.currentlyEquipped].Id = 0
					character.hotbar[character.currentlyEquipped].Image = ""
				end
				return true
			end
		end
	end
	if character.invOpen or character.craftOpen then
		return false
	end
	if inputE.UserInputType == Enum.UserInputType.MouseButton1 then
		item.type.tool.onUse(character.hotbar[character.currentlyEquipped].Id, target)
	end
	if inputE.UserInputType == Enum.UserInputType.MouseButton2 then
		local isBlock = item:checkBlockState(item:getId(target.Name))
		if itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Tool or itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Entity.Seed or itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Entity.Bucket then
			print("ToolUse Attempt!")
			item.type.tool.onRightUse(character.hotbar[character.currentlyEquipped].Id, target)
		elseif isBlock then
			print("BlockPlace Attempt!")
			if (player.Character.PrimaryPart.Position - target.Position).Magnitude > 3*5 then
				return
			end
			if character.currentlyEquipped ~= nil then
				if itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block or itemMod.itemTypes[character.hotbar[character.currentlyEquipped].Id] == itemMod.Type.Block.Interactable then
					item:placeBlock()
				end
			end
		else

		end
	end
end

function world:updateCurrentChunk()
	player.PlayerGui.Main.currChunk.Text = "Chunks Loaded: "..#workspace.Blocks:GetChildren().." Chunks Cached: "..#game.ReplicatedStorage.blockCache:GetChildren()
end

function world:updateChunks()
	for i,v in pairs(workspace.Blocks:GetChildren()) do
		if math.sqrt((v.PrimaryPart.Position.X - player.Character.PrimaryPart.Position.X)^2 + (v.PrimaryPart.Position.Z - player.Character.PrimaryPart.Position.Z)^2) > (12*3)*1 then
			if v:FindFirstChild("stone") then
				v.stone.Parent = game.ReplicatedStorage.blockCache[v.Name]
			end
		end
	end
	for i,v in pairs(game.ReplicatedStorage.blockCache:GetChildren()) do
		if math.sqrt((workspace.Blocks:FindFirstChild(v.Name).PrimaryPart.Position.X - player.Character.PrimaryPart.Position.X)^2 + (workspace.Blocks:FindFirstChild(v.Name).PrimaryPart.Position.Z - player.Character.PrimaryPart.Position.Z)^2) < (12*3)*1 then
			if v:FindFirstChild("stone") then
				v.stone.Parent = workspace.Blocks[v.Name]
			end
		end
	end
end

function sound:PlaySound(soundName)
local Id = soundModule.stepIds[soundModule.stepNameId[soundName]]
print("[Sound :: Sound ID] "..Id)
local newsound = Instance.new("Sound", game.SoundService)
newsound.SoundId = Id
newsound:Play()
print("[Sound :: Playing Sound] Playing Requested Sound")
return true
end

character:Init()


game.ReplicatedStorage.Events.playerSentMessage.OnClientInvoke = function(p, m, tag)
	chat:receiveMessage(p,m,tag)	
end

game.ReplicatedStorage.Events.systemMessage.OnClientInvoke = function(m, i, f, l)
	ui:registerSystemMessage(m, i, f, l)
end

game.ReplicatedStorage.Events.pickupBlock.OnClientInvoke = function(d)
	character:findOpenSlot(item:getId(d))
end

player.PlayerGui.Main.chatBox.FocusLost:Connect(function(e)
	ui.isTyping = false
	if e then
		chat:registerMessage(player.PlayerGui.Main.chatBox.Text)
	end	
	player.PlayerGui.Main.chatBox.Text = "Press / to start typing!"
end)

game:GetService("UserInputService").InputBegan:Connect(function(i)
	input:registerInputEvent(i)
end)

player:GetMouse().WheelForward:Connect(function()
	if character.currentlyEquipped == 9 then
		ui.selectionChanged(1)
	else
		ui.selectionChanged(character.currentlyEquipped + 1)
	end
end)

player:GetMouse().WheelBackward:Connect(function()
	if character.currentlyEquipped == 1 then
		ui.selectionChanged(9)
	else
		ui.selectionChanged(character.currentlyEquipped - 1)
	end
end)

player:GetMouse().Button1Down:Connect(function()
	character.isMining = true	
end)

player:GetMouse().Button1Up:Connect(function()
	character.isMining = false	
end)

player:GetMouse().Button2Down:Connect(function()
	character.rightUse = true
end)

player:GetMouse().Button2Up:Connect(function()
	character.rightUse = false	
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
	while wait(math.random(9)) do
		effects:createCloud()
	end	
end)

spawn(function()
	while wait(.35) do
		if character.isWalking and not player.Character.Humanoid.Jumping then
			game.SoundService.Dirt.PlaybackSpeed = math.random(.7,1.2)
			game.SoundService.Dirt:Play()
		end
	end	
end)

game:GetService("RunService").RenderStepped:Connect(function()
	if player.Character then
		ui.onStepped()	
		character.onStepped()
		effects.onStepped()
	end
end)