local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Основная функция обновления характеристик
local function updateStats()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    humanoid.WalkSpeed = 75
    humanoid.JumpPower = 200
end

-- Обработчик появления персонажа
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    updateStats()
end)

-- Бесконечный цикл с интервалом 1 секунда
while true do
    updateStats()
    task.wait(1)
end
