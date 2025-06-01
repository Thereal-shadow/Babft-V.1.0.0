local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local lastInputTime = tick()

-- Use the actual current place ID dynamically
local PLACE_ID = game.PlaceId

-- Remote function to send AFK notification
local function notifyAFK()
	local url = "https://yourusername.pythonanywhere.com/afk"

	local data = {
		player = player.Name,
		status = "afk",
		place_id = PLACE_ID
	}

	local jsonData = HttpService:JSONEncode(data)

	local success, response = pcall(function()
		return HttpService:PostAsync(url, jsonData, Enum.HttpContentType.ApplicationJson)
	end)

	if success then
		print("AFK reported. Server response:", response)
	else
		warn("Failed to notify AFK:", response)
	end
end

-- Track player input
UserInputService.InputBegan:Connect(function()
	lastInputTime = tick()
end)

-- Monitor idle time and act after 1180 seconds (19 min 40 sec)
while true do
	wait(10)
	if tick() - lastInputTime >= 1180 then
		notifyAFK()
		wait(1)

		-- Teleport to another instance of the same place
		local success, result = pcall(function()
			TeleportService:Teleport(PLACE_ID, player)
		end)

		if not success then
			warn("Teleport failed:", result)
		end

		break
	end
end
