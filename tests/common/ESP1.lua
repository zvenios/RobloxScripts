local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerData = {} -- player -> { highlight = Highlight, connections = { ... } }

-- Функция обновления подсветки для конкретного игрока
function updatePlayerHighlight(player)
	if player == localPlayer then return end -- Игнорируем себя

	local data = playerData[player]
	if not data then return end

	-- Удаляем старую подсветку
	if data.highlight then
		data.highlight:Destroy()
		data.highlight = nil
	end

	-- Проверяем условия для подсветки
	if 
		player.Character and
		player.Character:FindFirstChild("Humanoid") and
		player.Character.Humanoid.Health > 0
	then
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		
		local fillColor = Color3.fromRGB(1, 0, 0)
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineColor = Color3.fromRGB(0, 255, 0)

		highlight.Parent = player.Character
		data.highlight = highlight
	end
end

-- Управление отслеживанием игрока
function managePlayer(player)
	if player == localPlayer then return end -- Игнорируем себя

	local data = {
		highlight = nil,
		connections = {}
	}
	playerData[player] = data

	-- Обработчики изменений игрока
	table.insert(data.connections, player:GetPropertyChangedSignal("Team"):Connect(function()
		updatePlayerHighlight(player)
	end))

	table.insert(data.connections, player:GetPropertyChangedSignal("TeamColor"):Connect(function()
		updatePlayerHighlight(player)
	end))

	-- Обработчик появления персонажа
	table.insert(data.connections, player.CharacterAdded:Connect(function(character)
		-- Обработчик здоровья персонажа
		local function setupHealthTracking()
			local humanoid = character:WaitForChild("Humanoid")
			table.insert(data.connections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				updatePlayerHighlight(player)
			end))
			table.insert(data.connections, humanoid.Died:Connect(function()
				updatePlayerHighlight(player)
			end))
		end

		pcall(setupHealthTracking) -- Защита на случай отсутствия Humanoid
		updatePlayerHighlight(player)
	end))

	-- Первоначальная настройка
	if player.Character then
		updatePlayerHighlight(player)
	end
end

-- Обработчик удаления игрока
Players.PlayerRemoving:Connect(function(player)
	local data = playerData[player]
	if data then
		-- Отключаем все соединения
		for _, conn in ipairs(data.connections) do
			conn:Disconnect()
		end

		-- Удаляем подсветку
		if data.highlight then
			data.highlight:Destroy()
		end

		playerData[player] = nil
	end
end)

-- Обновляем всех при смене команды локального игрока
localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
	for player in pairs(playerData) do
		updatePlayerHighlight(player)
	end
end)

-- Инициализация существующих игроков
for _, player in ipairs(Players:GetPlayers()) do
	managePlayer(player)
end

-- Обработка новых игроков
Players.PlayerAdded:Connect(managePlayer)
