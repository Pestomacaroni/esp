local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local highlights = {}
local connections = {}

local espEnabled = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESP_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "ESP"
title.TextColor3 = Color3.fromRGB(0,255,0)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8,0,0.3,0)
toggleButton.Position = UDim2.new(0.1,0,0.4,0)
toggleButton.Text = "ESP ON"
toggleButton.BackgroundColor3 = Color3.fromRGB(0,150,0)
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextScaled = true
toggleButton.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.2,0,0.2,0)
closeButton.Position = UDim2.new(0.8,0,0,0)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(150,0,0)
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextScaled = true
closeButton.Parent = mainFrame

local function addESP(character)
	if not character then return end
	if highlights[character] then return end
	
	local highlight = Instance.new("Highlight")
	highlight.Name = "ESPHighlight"
	highlight.FillColor = Color3.fromRGB(255,0,0)
	highlight.OutlineColor = Color3.fromRGB(255,255,255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = character
	
	highlights[character] = highlight
end

local function removeESPFromCharacter(character)
	if highlights[character] then
		highlights[character]:Destroy()
		highlights[character] = nil
	end
end

local function removeAllESP()
	for character, highlight in pairs(highlights) do
		if highlight then
			highlight:Destroy()
		end
	end
	highlights = {}
end

local function setupPlayer(player)
	if player == LocalPlayer then return end 
	
	if player.Character and espEnabled then
		addESP(player.Character)
	end
	
	local charConnection = player.CharacterAdded:Connect(function(character)
		if espEnabled then
			addESP(character)
		end
	end)
	
	connections[player] = charConnection
end

local function cleanupPlayer(player)
	if connections[player] then
		connections[player]:Disconnect()
		connections[player] = nil
	end
	
	if player.Character then
		removeESPFromCharacter(player.Character)
	end
end

local function enableESP()
	espEnabled = true
	toggleButton.Text = "ESP OFF"
	
	for _, player in pairs(Players:GetPlayers()) do
		setupPlayer(player)
	end
	
	connections["PlayerAdded"] = Players.PlayerAdded:Connect(function(player)
		setupPlayer(player)
	end)
	
	connections["PlayerRemoving"] = Players.PlayerRemoving:Connect(function(player)
		cleanupPlayer(player)
	end)
end

local function disableESP()
	espEnabled = false
	toggleButton.Text = "ESP ON"
	
	removeAllESP()
	
	for _, conn in pairs(connections) do
		if typeof(conn) == "RBXScriptConnection" then
			conn:Disconnect()
		end
	end
	
	connections = {}
end

local function toggleESP()
	if espEnabled then
		disableESP()
	else
		enableESP()
	end
end

toggleButton.MouseButton1Click:Connect(toggleESP)

closeButton.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
end)

local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragInput, dragStartPos, startPos

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStartPos = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStartPos
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
