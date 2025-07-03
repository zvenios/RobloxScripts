local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerData = {} -- player -> { highlight = Highlight, beam = Beam, connections = { ... } }

-- Генератор случайных строк
function RandomString(length)
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local random = Random.new()

	if not (type(length) == "number") then
		length = random:NextInteger(10, 30)
	end

	local result = table.create(length)

	for i = 1, length do
		local randIndex = random:NextInteger(1, #chars)
		result[i] = string.sub(chars, randIndex, randIndex)
	end

	return table.concat(result)
end

-- Создаем папку для хранения лучей
local folder = Instance.new("Folder")
folder.Name = "PlayerBeams_" .. RandomString()
folder.Parent = workspace

-- Создаем Attachment для локального игрока
local localAttachment = Instance.new("Attachment")
localAttachment.Name = "LocalBeamAttachment"

-- Обновление Attachment при изменении персонажа
function updateLocalAttachment(character)
	if character then
		-- Ожидаем появление корневой части
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5) or
			character:FindFirstChild("Torso") or
			character.PrimaryPart

		if humanoidRootPart then
			localAttachment.Parent = humanoidRootPart
			return true
		end
	end
	localAttachment.Parent = nil
	return false
end

-- Обработчик изменений персонажа локального игрока
localPlayer.CharacterAdded:Connect(function(character)
	updateLocalAttachment(character)
end)

localPlayer.CharacterRemoving:Connect(function()
	localAttachment.Parent = nil
end)

if localPlayer.Character then
	updateLocalAttachment(localPlayer.Character)
end

-- Создание и обновление луча для игрока
function updatePlayerBeam(player)
	local data = playerData[player]
	if not data then return end

	-- Проверяем условия для создания луча
	if player == localPlayer then return end
	if not localPlayer.Character then return end
	if not player.Character then return end

	-- Ожидаем появление корневой части целевого игрока
	local humanoidRootPart = player.Character:WaitForChild("HumanoidRootPart", 2) or
		player.Character:FindFirstChild("Torso") or
		player.Character.PrimaryPart

	if not humanoidRootPart then return end

	-- Находим или создаем Attachment на целевом игроке
	local targetAttachment = humanoidRootPart:FindFirstChild("BeamAttachment")
	if not targetAttachment then
		targetAttachment = Instance.new("Attachment")
		targetAttachment.Name = "BeamAttachment"
		targetAttachment.Parent = humanoidRootPart
	end

	-- Проверяем локальный Attachment
	if not localAttachment.Parent then
		if not updateLocalAttachment(localPlayer.Character) then
			return
		end
	end

	-- Создаем луч если его еще нет
	if not data.beam then
		data.beam = Instance.new("Beam")
		data.beam.Name = "BeamTo_" .. player.Name
		data.beam.Parent = folder

		-- Настройка визуальных свойств
		data.beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
		data.beam.Width0 = 0.2
		data.beam.Width1 = 0.2
		data.beam.LightEmission = 1
		data.beam.LightInfluence = 0
		data.beam.FaceCamera = true
	end

	-- Обновляем привязки
	data.beam.Attachment0 = localAttachment
	data.beam.Attachment1 = targetAttachment
end

-- Функция обновления подсветки
function updatePlayerHighlight(player)
	if player == localPlayer then return end

	local data = playerData[player]
	if not data then return end

	-- Удаляем старую подсветку
	if data.highlight then
		data.highlight:Destroy()
		data.highlight = nil
	end

	-- Проверяем условия для подсветки
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		local humanoid = player.Character.Humanoid
		if humanoid.Health > 0 then
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 0
			highlight.FillColor = Color3.fromRGB(255, 0, 0)
			highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
			highlight.Parent = player.Character
			data.highlight = highlight
		end
	end
end

-- Управление отслеживанием игрока
function managePlayer(player)
	if player == localPlayer then return end

	local data = {
		highlight = nil,
		beam = nil,
		connections = {}
	}
	playerData[player] = data

	-- Обработчик персонажа
	local function handleCharacter(character)
		-- Отслеживание здоровья
		local humanoid = character:WaitForChild("Humanoid", 2)
		if humanoid then
			table.insert(data.connections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				updatePlayerHighlight(player)
				updatePlayerBeam(player)
			end))

			table.insert(data.connections, humanoid.Died:Connect(function()
				updatePlayerHighlight(player)
				updatePlayerBeam(player)
			end))
		end

		-- Обновляем визуальные эффекты
		updatePlayerHighlight(player)
		updatePlayerBeam(player)
	end

	table.insert(data.connections, player.CharacterAdded:Connect(handleCharacter))
	table.insert(data.connections, player.CharacterRemoving:Connect(function()
		if data.highlight then data.highlight:Destroy() end
		if data.beam then data.beam:Destroy() end
		data.highlight = nil
		data.beam = nil
	end))

	-- Обновление при изменении локального персонажа
	table.insert(data.connections, localPlayer.CharacterAdded:Connect(function()
		updatePlayerBeam(player)
	end))

	table.insert(data.connections, localPlayer.CharacterRemoving:Connect(function()
		if data.beam then data.beam:Destroy() end
		data.beam = nil
	end))

	-- Первоначальная настройка
	if player.Character then
		handleCharacter(player.Character)
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

		-- Удаляем визуальные элементы
		if data.highlight then
			data.highlight:Destroy()
		end

		if data.beam then
			data.beam:Destroy()
		end

		playerData[player] = nil
	end
end)

-- Инициализация существующих игроков
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= localPlayer then
		managePlayer(player)
	end
end

-- Обработка новых игроков
Players.PlayerAdded:Connect(function(player)
	if player ~= localPlayer then
		managePlayer(player)
	end
end)

-- Автоматическое обновление лучей
RunService.Heartbeat:Connect(function()
	for player, data in pairs(playerData) do
		if data.beam then
			-- Плавное изменение прозрачности
			local pulse = math.sin(tick() * 5) * 0.2 + 0.5
			data.beam.Transparency = NumberSequence.new(pulse)

			-- Проверяем актуальность привязок
			if not data.beam.Attachment0 or not data.beam.Attachment1 then
				updatePlayerBeam(player)
			end
		else
			-- Пытаемся восстановить луч если его нет
			if player.Character and localPlayer.Character then
				updatePlayerBeam(player)
			end
		end
	end
end)
