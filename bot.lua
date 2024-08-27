-- services

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local tweenService = game:GetService("TweenService")
local currentTween = false
local HttpService = game:GetService("HttpService")

-- values

local aiCooldown = 10  -- Adjust cooldown as needed
local lastAICall = 0
local aiActive = false
local controllerName = "habibihadoodoo21"
local followerName = "ilovecheezburber"
local habibi = "habibihadoodoo21"
local whitelist = {habibi}  -- habibi is automatically whitelisted
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")
local speaker = Players.LocalPlayer
local bangLoop 
local aiAPIKey = "51c55c2983mshde73f44bb6cccd5p13c19djsn6dab69383652"
local aiAPIHost = "chatgpt-42.p.rapidapi.com"
local aiBotID = "OEXJ8qFp5E5AwRwymfPts90vrHnmr8yZgNE171101852010w2S0bCtN3THp448W7kDSfyTf3OpW5TUVefz"

wait(0.5)

local screenGui = Instance.new("ScreenGui")
local titleLabel = Instance.new("TextLabel")
local frame = Instance.new("Frame")
local footerLabel = Instance.new("TextLabel")
local statusLabel = Instance.new("TextLabel")

screenGui.Parent = game.CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

titleLabel.Parent = screenGui
titleLabel.Active = true
titleLabel.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
titleLabel.Draggable = true
titleLabel.Position = UDim2.new(0.698610067, 0, 0.098096624, 0)
titleLabel.Size = UDim2.new(0, 370, 0, 52)
titleLabel.Font = Enum.Font.SourceSansSemibold
titleLabel.Text = "Anti Afk"
titleLabel.TextColor3 = Color3.new(0, 1, 1)
titleLabel.TextSize = 22

frame.Parent = titleLabel
frame.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
frame.Position = UDim2.new(0, 0, 1.0192306, 0)
frame.Size = UDim2.new(0, 370, 0, 107)

footerLabel.Parent = frame
footerLabel.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
footerLabel.Position = UDim2.new(0, 0, 0.800455689, 0)
footerLabel.Size = UDim2.new(0, 370, 0, 21)
footerLabel.Font = Enum.Font.Arial
footerLabel.Text = "verzoni made this bih"
footerLabel.TextColor3 = Color3.new(0, 1, 1)
footerLabel.TextSize = 20

statusLabel.Parent = frame
statusLabel.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
statusLabel.Position = UDim2.new(0, 0, 0.158377, 0)
statusLabel.Size = UDim2.new(0, 370, 0, 44)
statusLabel.Font = Enum.Font.ArialBold
statusLabel.Text = "Status: Active"
statusLabel.TextColor3 = Color3.new(0, 1, 1)
statusLabel.TextSize = 20

local virtualUser = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
	virtualUser:CaptureController()
	virtualUser:ClickButton2(Vector2.new())
	statusLabel.Text = "Roblox tried kicking you but I didn't let them!"
	wait(2)
	statusLabel.Text = "Status: Active"
end)

local isFollowing = false
local isHeadSitting = false
local isStalkMode = false
local isLookingAt = false
local stalkTarget = nil
local lookAtTarget = nil
local isTweenFlying = false

local defaultEmotes = {
	"/e dance", "/e wave", "/e laugh", "/e cheer", "/e point",
	"/e salute", "/e sit", "/e dance2", "/e dance3"
}

local function checkAndJump()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Ensure the character is not sitting or in freefall
	if humanoid.Sit or humanoid:GetState() == Enum.HumanoidStateType.Seated then
		humanoid.Jump = true
		return
	end

	if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
		-- Raycast parameters to exclude the character's parts
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {character}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = true

		-- Perform raycast in the direction the character is facing
		local rayDirection = character.HumanoidRootPart.CFrame.LookVector * 5  -- Extend the ray length as needed
		local raycastResult = workspace:Raycast(
			character.HumanoidRootPart.Position,
			rayDirection,
			raycastParams
		)

		-- Check if the raycast hit an object
		if raycastResult and raycastResult.Instance then
			-- If an object is detected in front, make the character jump
			humanoid.Jump = true
		end
	end
end

local function getTorso(character)
	if character:FindFirstChild("HumanoidRootPart") then
		return character.HumanoidRootPart
	elseif character:FindFirstChild("Torso") then
		return character.Torso
	end
end

local function getRoot(character)
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
end

local function getPlayer(name, speaker)
	local players = {}
	if name:lower() == "all" then
		players = Players:GetPlayers()
	else
		local player = Players:FindFirstChild(name)
		if player then
			table.insert(players, player)
		end
	end
	return players
end

local function bang(args)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	local bangAnim = Instance.new("Animation")

	-- Check if the character is R15 or R6 and set the appropriate animation
	if humanoid.RigType == Enum.HumanoidRigType.R15 then
		bangAnim.AnimationId = "rbxassetid://5918726674" -- R15 animation
	else
		bangAnim.AnimationId = "rbxassetid://148840371" -- R6 animation
	end

	local bang = humanoid:LoadAnimation(bangAnim)
	bang:Play(0.1, 1, 1)
	bang:AdjustSpeed(3)

	local bangDied
	bangDied = humanoid.Died:Connect(function()
		bang:Stop()
		bangAnim:Destroy()
		bangDied:Disconnect()
		bangLoop:Disconnect()
	end)

	if args[1] then
		local players = getPlayer(args[1], speaker)
		for _, v in pairs(players) do
			local bangplr = Players[v].Name
			local bangOffset = CFrame.new(0, 0, 1.1)
			bangLoop = RunService.Stepped:Connect(function()
				pcall(function()
					local otherRoot = getTorso(Players[bangplr].Character)
					getRoot(speaker.Character).CFrame = otherRoot.CFrame * bangOffset
				end)
			end)
		end
	end
end


local function getControllerPlayer()
	return Players:FindFirstChild(controllerName)
end

local function followController()
	local controller = getControllerPlayer()
	if not controller or not controller.Character then return end

	local targetRoot = controller.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	humanoid:MoveTo(targetRoot.Position)
end

local function isWhitelisted(username)
	for _, user in ipairs(whitelist) do
		if user == username then
			return true
		end
	end
	return false
end

local function addToWhitelist(username)
	if not isWhitelisted(username) then
		table.insert(whitelist, username)
	end
end

local function removeFromWhitelist(username)
	for i, user in ipairs(whitelist) do
		if user == username then
			table.remove(whitelist, i)
			break
		end
	end
end

local function stalkTargetPlayer()
	print("Stalking function called")
	if not stalkTarget then
		print("stalkTarget is nil")
		return
	end
	if not stalkTarget.Character then
		print("stalkTarget.Character is nil")
		return
	end

	local targetRoot = stalkTarget.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		print("targetRoot not found")
		return
	end

	local targetPosition = targetRoot.Position
	local direction = (targetPosition - root.Position).Unit
	local stalkPosition = targetPosition - direction * 30

	humanoid:MoveTo(stalkPosition)
end



local function headSit()
	local controller = getControllerPlayer()
	if not controller or not controller.Character then return end

	local targetHead = controller.Character:FindFirstChild("Head")
	if not targetHead then return end

	root.CFrame = targetHead.CFrame * CFrame.new(0, 1, 0)
end

local function leave()
	humanoid:Destroy()
end





local function sayInChat(message)
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		local textChannel = TextChatService.TextChannels.RBXGeneral
		-- Directly call SendAsync without spawning a new task
		textChannel:SendAsync(message)
	else
		game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
	end
end

local function tweenfly(lowerMsg)
	local player = Players.LocalPlayer

	-- Make sure lowerMsg is provided
	if not lowerMsg then
		warn("No message provided")
		return
	end

	-- Convert lowerMsg to lowercase and extract the speed
	lowerMsg = lowerMsg:lower()
	local speed = tonumber(lowerMsg:sub(11)) or 1 -- default speed is 1 if not specified
	isTweenFlying = true

	spawn(function()
		while isTweenFlying do
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hrp = char.HumanoidRootPart
				local front = hrp.CFrame.LookVector
				local goal = hrp.CFrame + (front * 10)

				local tweenInfo = TweenInfo.new(10 / speed, Enum.EasingStyle.Linear)
				local tween = tweenService:Create(hrp, tweenInfo, {CFrame = goal})
				tween:Play()
				tween.Completed:Wait()
			end
			wait()
		end
	end)

	print("Tween")
end


sayInChat("StarBot Started. made by gepoooo")
task.wait(1)
sayInChat(",gg\]bMzMsXyZ")



-- Define onChatted function
local function onChatted(player, message)
	if player.Name ~= controllerName then 
		sayInChat(player.Name .. ", you are not permitted to use this command.")
		return
	end


	local lowerMsg = message:lower()
	
	

	if lowerMsg == "!cmds" then
		sayInChat("All Commands are restricted to " .. controllerName)
		task.wait(1)
		sayInChat("Commands are: !stop, !follow, !headsit, !startai, !tweenfly, !tweenstop, !killscript, !emote (1-9), !stalk [username], !lookat [username], !bang [username], fling [username] (only useable in games with player collision.)")
		print("Displayed commands")
		return
	end
	if isWhitelisted(player.Name) then
		if lowerMsg:sub(1, 10) == "!e" then
			sayInChat("You are not allowed to use this command.")
			return
end
	
	if player.Name == habibi then
		if lowerMsg:sub(1, 10) == "!whitelist" then
			local targetUsername = message:sub(12)
			if targetUsername and targetUsername ~= "" then
				addToWhitelist(targetUsername)
				sayInChat(targetUsername .. " has been whitelisted.")
			end
			return
		elseif lowerMsg:sub(1, 12) == "!unwhitelist" then
			local targetUsername = message:sub(14)
			if targetUsername and targetUsername ~= "" then
				removeFromWhitelist(targetUsername)
				sayInChat(targetUsername .. " has been removed from the whitelist.")
			end
			return
		end
	end
	
   if isWhitelisted(player.Name) then
        if lowerMsg:sub(1, 10) == "!whitelist" then
            sayInChat("You are not allowed to use this command.")
            return
        end

    else
        sayInChat(player.Name .. ", you are not permitted to use this command.")
    end
end
	
	if lowerMsg == "!ver" then
		sayInChat("Version/Build 0.19")
		return
	end

	if lowerMsg == "!leave" then
		sayInChat("Leaving in 5 seconds.")
		task.wait(5)
		sayInChat("Goodbye!")
		leave()
	end

	if lowerMsg == "!follow" then
		isFollowing = true
		isHeadSitting = false
		isStalkMode = false
		isLookingAt = false
		print("Now following " .. controllerName)
		return
	end

	if lowerMsg == "!stop" then
		isFollowing = false
		isHeadSitting = false
		isStalkMode = false
		isLookingAt = false
		isTweenFlying = false
		if currentTween then
			currentTween:Cancel()
		end
		humanoid:MoveTo(root.Position)
		sayInChat("Stopped all actions")
		print("Stopped all actions")
		return
	end
	


	if lowerMsg == "!killscript" then
		script:Destroy()
		print("Script Terminated")
		sayInChat("Script Terminated")
		return
	end

	if lowerMsg == "!AntiAFK" then
		sayInChat("ANTIAFK Active")
		print("AntiAFK Active")
		return
	end

	if lowerMsg == "!headsit" then
		isFollowing = false
		isHeadSitting = true
		isStalkMode = false
		isLookingAt = false
		print("Now headsitting on " .. controllerName)
		return
	end

	if lowerMsg:sub(1, 6) == "!emote" then
		local emoteNumber = tonumber(lowerMsg:sub(7))
		if emoteNumber and emoteNumber >= 1 and emoteNumber <= #defaultEmotes then
			local emoteCommand = defaultEmotes[emoteNumber]
			sayInChat(emoteCommand)
			print("Saying emote in chat: " .. emoteCommand)
		end
		return
	end

	if lowerMsg:sub(1, 5) == "!chat" then
		local chatMessage = message:sub(7)
		print("Attempting to say: " .. tostring(chatMessage))
		task.spawn(function()
			sayInChat(chatMessage)
		end)
		print("Saying in chat: " .. chatMessage)
		return
	end

	if lowerMsg:sub(1, 6) == "!stalk" then
		local targetName = message:sub(8)
		stalkTarget = Players:FindFirstChild(targetName)
		if stalkTarget then
			isStalkMode = true
			isFollowing = false
			isHeadSitting = false
			isLookingAt = false
			print("Now stalking " .. targetName)
			sayInChat("Now stalking " .. targetName)
		else
			print("Target not found")
			sayInChat("Target not found")
		end
		return
	end

	if lowerMsg:sub(1, 7) == "!lookat" then
		local targetName = message:sub(9)
		lookAtTarget = Players:FindFirstChild(targetName)
		if lookAtTarget then
			isLookingAt = true
			isFollowing = false
			isHeadSitting = false
			isStalkMode = false
			print("Now constantly looking at " .. targetName)
			sayInChat("I lowkey finna fart on " .. targetName)
		else
			print("Target player not found")
			sayInChat("Target player not found")
		end
		return
	end


	RunService.Heartbeat:Connect(function()
		if isFollowing then
			followController()
		elseif isHeadSitting then
			headSit()
		elseif isStalkMode then
			stalkTargetPlayer()
		elseif isLookingAt and lookAtTarget and lookAtTarget.Character then
			local targetRoot = lookAtTarget.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				root.CFrame = CFrame.new(root.Position, Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
			end
		end
	end)

	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		print("Using TextChatService")
		TextChatService.OnIncomingMessage = function(message)
			local player = Players:GetPlayerByUserId(message.TextSource.UserId)
			onChatted(player, message.Text)
		end
	else
		print("Using LegacyChatService")
		Players.PlayerChatted:Connect(onChatted)
	end

	RunService.Heartbeat:Connect(checkAndJump)

	print("Script loaded for " .. followerName .. ". Waiting for commands from " .. controllerName)
end
