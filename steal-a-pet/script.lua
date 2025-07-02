local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "6ug5enufsfeig8e7g6f5d76n849-09ujhse"
screenGui.Parent = Player.PlayerGui
screenGui.ResetOnSpawn = false

local savedPosition = nil

local saveButton = Instance.new("TextButton")
saveButton.Size = UDim2.new(0, 120, 0, 40)
saveButton.Position = UDim2.new(0.8, 0, 0.6, 0)
saveButton.Text = "SAVE POSITION"
saveButton.TextScaled = true
saveButton.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveButton.Font = Enum.Font.SourceSansBold
saveButton.Parent = screenGui

local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0, 120, 0, 40)
teleportButton.Position = UDim2.new(0.8, 0, 0.7, 0)
teleportButton.Text = "TELEPORT"
teleportButton.TextScaled = true
teleportButton.BackgroundColor3 = Color3.fromRGB(200, 120, 80)
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.Font = Enum.Font.SourceSansBold
teleportButton.Parent = screenGui

saveButton.MouseButton1Click:Connect(function()
	if Player.Character then
		local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			savedPosition = humanoidRootPart.Position
		end
	end
end)

teleportButton.MouseButton1Click:Connect(function()
	if not savedPosition then return end

	local character = Player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local returnPosition = humanoidRootPart.Position

	humanoidRootPart.CFrame = CFrame.new(savedPosition)

	task.wait(1)

	if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
		Player.Character.HumanoidRootPart.CFrame = CFrame.new(returnPosition)
	end
end)

local function HandleCharacter(Character)
	local Humanoid = Character:WaitForChild("Humanoid")
	Humanoid.WalkSpeed = 50

	Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if Humanoid.WalkSpeed ~= 50 then
			Humanoid.WalkSpeed = 50
		end
	end)
end

if Player.Character then
	HandleCharacter(Player.Character)
end

Player.CharacterAdded:Connect(HandleCharacter)

local function ConfigurePrompt(prompt)
	if prompt:IsA("ProximityPrompt") then
		prompt.HoldDuration = 0.01

		if not prompt:GetAttribute("tkeyj642kiebuuki38rknyfuk") then
			prompt:SetAttribute("tkeyj642kiebuuki38rknyfuk", true)

			prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
				if prompt.HoldDuration ~= 0.01 then
					prompt.HoldDuration = 0.01
				end
			end)
		end
	end
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
	ConfigurePrompt(descendant)
end

Workspace.DescendantAdded:Connect(ConfigurePrompt)
