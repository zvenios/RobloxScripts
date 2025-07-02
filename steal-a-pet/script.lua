local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local DefaultSpeed = 50
local TeleportDistance = 10
local TeleportBackDelay = 0.25
local TargetHoldDuration = 0.01

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "6ug5enufsfeig8e7g6f5d76n849-09ujhse"
screenGui.Parent = Player.PlayerGui
screenGui.ResetOnSpawn = false

-- Сохраняем позицию для возврата
local savedPosition = nil

-- Создаем три кнопки
local saveButton = Instance.new("TextButton")
saveButton.Size = UDim2.new(0, 120, 0, 40)
saveButton.Position = UDim2.new(0.8, 0, 0.4, 0)  -- Верхняя кнопка
saveButton.Text = "SAVE POSITION"
saveButton.TextScaled = true
saveButton.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveButton.Font = Enum.Font.SourceSansBold
saveButton.Parent = screenGui

local teleportForwardButton = Instance.new("TextButton")
teleportForwardButton.Size = UDim2.new(0, 120, 0, 40)
teleportForwardButton.Position = UDim2.new(0.8, 0, 0.5, 0)  -- Средняя кнопка
teleportForwardButton.Text = "TELEPORT FORWARD"
teleportForwardButton.TextScaled = true
teleportForwardButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
teleportForwardButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportForwardButton.Font = Enum.Font.SourceSansBold
teleportForwardButton.Parent = screenGui

local teleportToSavedButton = Instance.new("TextButton")
teleportToSavedButton.Size = UDim2.new(0, 120, 0, 40)
teleportToSavedButton.Position = UDim2.new(0.8, 0, 0.5, 0)  -- Средняя кнопка
teleportToSavedButton.Text = "TELEPORT TO SAVED"
teleportToSavedButton.TextScaled = true
teleportToSavedButton.BackgroundColor3 = Color3.fromRGB(200, 120, 80)
teleportToSavedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportToSavedButton.Font = Enum.Font.SourceSansBold
teleportToSavedButton.Parent = screenGui

local teleportForwardButton = Instance.new("TextButton")
teleportForwardButton.Size = UDim2.new(0, 120, 0, 40)
teleportForwardButton.Position = UDim2.new(0.8, 0, 0.6, 0)  -- Нижняя кнопка
teleportForwardButton.Text = "TELEPORT FORWARD"
teleportForwardButton.TextScaled = true
teleportForwardButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
teleportForwardButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportForwardButton.Font = Enum.Font.SourceSansBold
teleportForwardButton.Parent = screenGui

-- Функция сохранения позиции
saveButton.MouseButton1Click:Connect(function()
	if Player.Character then
		local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			savedPosition = humanoidRootPart.Position
		end
	end
end)

-- Функция телепортации вперед
local function TeleportForward()
	local character = Player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local lookDirection = humanoidRootPart.CFrame.LookVector
	local newPosition = humanoidRootPart.Position + (lookDirection * TeleportDistance)
	humanoidRootPart.CFrame = CFrame.new(newPosition, newPosition + lookDirection)
end

teleportForwardButton.MouseButton1Click:Connect(TeleportForward)

-- Функция телепортации к сохраненной позиции и возврата
teleportToSavedButton.MouseButton1Click:Connect(function()
	if not savedPosition then return end

	local character = Player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Сохраняем точку возврата
	local returnPosition = humanoidRootPart.Position

	-- Телепортируем к сохраненной позиции
	humanoidRootPart.CFrame = CFrame.new(savedPosition)

	-- Ждем и возвращаем обратно
	task.wait(TeleportBackDelay)

	-- Проверяем актуальность ссылок
	if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
		Player.Character.HumanoidRootPart.CFrame = CFrame.new(returnPosition)
	end
end)

-- Контроль скорости игрока
local function HandleCharacter(Character)
	local Humanoid = Character:WaitForChild("Humanoid")
	Humanoid.WalkSpeed = DefaultSpeed

	Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if Humanoid.WalkSpeed ~= DefaultSpeed then
			Humanoid.WalkSpeed = DefaultSpeed
		end
	end)
end

if Player.Character then
	HandleCharacter(Player.Character)
end

Player.CharacterAdded:Connect(HandleCharacter)

-- Ускорение ProximityPrompt
local function ConfigurePrompt(prompt)
	if prompt:IsA("ProximityPrompt") then
		prompt.HoldDuration = TargetHoldDuration

		if not prompt:GetAttribute("tkeyj642kiebuuki38rknyfuk") then
			prompt:SetAttribute("tkeyj642kiebuuki38rknyfuk", true)

			prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
				if prompt.HoldDuration ~= TargetHoldDuration then
					prompt.HoldDuration = TargetHoldDuration
				end
			end)
		end
	end
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
	ConfigurePrompt(descendant)
end

Workspace.DescendantAdded:Connect(ConfigurePrompt)
