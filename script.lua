
-- ============================================
-- AUTOPERFECT+ - 美化图形界面
-- ============================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local ACCENT = Color3.fromRGB(130, 150, 220)

-- ═══════════════════════════════════════════
-- 主脚本
-- ═══════════════════════════════════════════
function _G.Main()
	local CFG = {
		AutoPerfect = true,       -- 自动完美巴掌
		AutoDodge = true,         -- 自动闪避
		AutoGuess = true,         -- 自动猜打人者
		AutoSlapQueue = false,    -- 巴掌队列（测试版）
		PerfectValue = 0.999999,  -- 完美判定数值
		DodgeDelay = 0.1,         -- 自动闪避间隔
		LastSlapper = nil,        -- 记录最后打你的玩家
	}

	-- 查找远程事件
	local function findRemote(name)
		local events = RS:FindFirstChild("events")
		if events then
			local r = events:FindFirstChild(name)
			if r then return r end
		end
		for _, d in ipairs(RS:GetDescendants()) do
			if d:IsA("RemoteEvent") and d.Name == name then return d end
		end
	end

	local sendSlap = findRemote("SendSlap")
	local dodgeR = findRemote("Dodge")
	local guessR = findRemote("Guess")
	local queueR = findRemote("SlapQueue")
	print(("[自动完美+] SendSlap=%s 闪避=%s 猜人=%s 队列=%s"):format(
		sendSlap and "正常" or "未找到", dodgeR and "正常" or "未找到",
		guessR and "正常" or "未找到", queueR and "正常" or "未找到"
	))

	-- ═══════════════════════════════════════════
	-- 主图形界面 - 美化设计
	-- ═══════════════════════════════════════════
	local gui = Instance.new("ScreenGui")
	gui.Name = "AutoPerfect"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PG

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 320, 0, 400)
	main.Position = UDim2.new(0, 20, 0.5, -200)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	main.BorderSizePixel = 0
	main.Active = true
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

	-- 发光边框
	local mainStroke = Instance.new("UIStroke", main)
	mainStroke.Color = ACCENT
	mainStroke.Thickness = 1.2
	mainStroke.Transparency = 0.5

	-- 细微渐变背景
	local mainGrad = Instance.new("UIGradient", main)
	mainGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 30)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20)),
	}
	mainGrad.Rotation = 90

	-- ═══ 头部标题栏 ═══
	local hdr = Instance.new("Frame", main)
	hdr.Size = UDim2.new(1, 0, 0, 52)
	hdr.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	hdr.BorderSizePixel = 0
	hdr.Active = true
	hdr.Parent = main
	Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 14)

	local hdrFix = Instance.new("Frame", hdr)
	hdrFix.Size = UDim2.new(1, 0, 0, 16)
	hdrFix.Position = UDim2.new(0, 0, 1, -16)
	hdrFix.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
	hdrFix.BorderSizePixel = 0
	hdrFix.Active = false
	hdrFix.Parent = hdr

	-- 标题栏渐变
	local hdrGrad = Instance.new("UIGradient", hdr)
	hdrGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 30)),
	}
	hdrGrad.Rotation = 90

	-- 脉冲小圆点
	local hdrDot = Instance.new("Frame", hdr)
	hdrDot.Size = UDim2.new(0, 9, 0, 9)
	hdrDot.Position = UDim2.new(0, 18, 0.5, -4.5)
	hdrDot.BackgroundColor3 = ACCENT
	hdrDot.BorderSizePixel = 0
	hdrDot.Active = false
	hdrDot.Parent = hdr
	Instance.new("UICorner", hdrDot).CornerRadius = UDim.new(1, 0)

	-- 圆点光晕
	local dotHalo = Instance.new("Frame", hdr)
	dotHalo.Size = UDim2.new(0, 17, 0, 17)
	dotHalo.Position = UDim2.new(0, 14, 0.5, -8.5)
	dotHalo.BackgroundColor3 = ACCENT
	dotHalo.BackgroundTransparency = 0.7
	dotHalo.BorderSizePixel = 0
	dotHalo.Active = false
	dotHalo.Parent = hdr
	Instance.new("UICorner", dotHalo).CornerRadius = UDim.new(1, 0)

	-- 光晕脉冲动画
	task.spawn(function()
		while hdrDot.Parent do
			TweenService:Create(dotHalo, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Size = UDim2.new(0, 22, 0, 22),
				Position = UDim2.new(0, 11.5, 0.5, -11),
				BackgroundTransparency = 0.9
			}):Play()
			task.wait(1.5)
			TweenService:Create(dotHalo, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Size = UDim2.new(0, 17, 0, 17),
				Position = UDim2.new(0, 14, 0.5, -8.5),
				BackgroundTransparency = 0.7
			}):Play()
			task.wait(1.5)
		end
	end)

	-- 标题文字
	local hdrTitle = Instance.new("TextLabel", hdr)
	hdrTitle.Size = UDim2.new(1, -130, 1, 0)
	hdrTitle.Position = UDim2.new(0, 38, 0, 0)
	hdrTitle.BackgroundTransparency = 1
	hdrTitle.Text = "自动巴掌增强"
	hdrTitle.TextColor3 = Color3.fromRGB(235, 235, 245)
	hdrTitle.Font = Enum.Font.GothamBold
	hdrTitle.TextSize = 14
	hdrTitle.TextScaled = false
	hdrTitle.TextXAlignment = Enum.TextXAlignment.Left
	hdrTitle.Active = false

	-- 版本标签
	local verBadge = Instance.new("Frame", hdr)
	verBadge.Size = UDim2.new(0, 42, 0, 18)
	verBadge.Position = UDim2.new(1, -54, 0.5, -9)
	verBadge.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	verBadge.BorderSizePixel = 0
	verBadge.Active = false
	verBadge.Parent = hdr
	Instance.new("UICorner", verBadge).CornerRadius = UDim.new(0, 6)

	local verTxt = Instance.new("TextLabel", verBadge)
	verTxt.Size = UDim2.new(1, 0, 1, 0)
	verTxt.BackgroundTransparency = 1
	verTxt.Text = "v1.0"
	verTxt.TextColor3 = Color3.fromRGB(180, 180, 200)
	verTxt.Font = Enum.Font.GothamBold
	verTxt.TextSize = 9
	verTxt.TextScaled = false

	-- 标题栏下分隔线
	local sepLine = Instance.new("Frame", main)
	sepLine.Size = UDim2.new(1, -32, 0, 1)
	sepLine.Position = UDim2.new(0, 16, 0, 52)
	sepLine.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	sepLine.BorderSizePixel = 0

	-- ═══ 主题颜色选择区 ═══
	local colorTitle = Instance.new("TextLabel", main)
	colorTitle.Size = UDim2.new(1, -32, 0, 14)
	colorTitle.Position = UDim2.new(0, 16, 0, 66)
	colorTitle.BackgroundTransparency = 1
	colorTitle.Text = "主题颜色"
	colorTitle.TextColor3 = Color3.fromRGB(120, 120, 140)
	colorTitle.Font = Enum.Font.GothamBold
	colorTitle.TextSize = 9
	colorTitle.TextScaled = false
	colorTitle.TextXAlignment = Enum.TextXAlignment.Left
	colorTitle.Active = false

	local colorRow = Instance.new("Frame", main)
	colorRow.Size = UDim2.new(1, -32, 0, 32)
	colorRow.Position = UDim2.new(0, 16, 0, 86)
	colorRow.BackgroundTransparency = 1
	colorRow.Active = false
	colorRow.Parent = main

	local COLORS = {
		Color3.fromRGB(130, 150, 220),
		Color3.fromRGB(110, 200, 170),
		Color3.fromRGB(170, 130, 220),
		Color3.fromRGB(220, 130, 160),
		Color3.fromRGB(220, 180, 110),
		Color3.fromRGB(110, 200, 220),
	}
	local colorBtns = {}
	local toggleButtons = {}

	-- 更新界面强调色
	local function updateAccent(c)
		ACCENT = c
		mainStroke.Color = c
		hdrDot.BackgroundColor3 = c
		dotHalo.BackgroundColor3 = c
		for _, t in ipairs(toggleButtons) do
			if t:GetAttribute("on") then
				t.BackgroundColor3 = c
			end
		end
	end

	for i, c in ipairs(COLORS) do
		local b = Instance.new("TextButton", colorRow)
		b.Size = UDim2.new(1/#COLORS, -5, 1, 0)
		b.Position = UDim2.new((i-1)/#COLORS, 2.5, 0, 0)
		b.BackgroundColor3 = c
		b.Text = ""
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
		local bStroke = Instance.new("UIStroke", b)
		bStroke.Color = Color3.fromRGB(255, 255, 255)
		bStroke.Thickness = 2
		bStroke.Transparency = (c == ACCENT) and 0 or 1
		b.MouseButton1Click:Connect(function()
			for _, other in ipairs(colorBtns) do
				local os = other:FindFirstChildOfClass("UIStroke")
				if os then os.Transparency = 1 end
			end
			bStroke.Transparency = 0
			updateAccent(c)
		end)
		table.insert(colorBtns, b)
	end

	-- ═══ 功能开关区域 ═══
	local togglesTitle = Instance.new("TextLabel", main)
	togglesTitle.Size = UDim2.new(1, -32, 0, 14)
	togglesTitle.Position = UDim2.new(0, 16, 0, 134)
	togglesTitle.BackgroundTransparency = 1
	togglesTitle.Text = "功能选项"
	togglesTitle.TextColor3 = Color3.fromRGB(120, 120, 140)
	togglesTitle.Font = Enum.Font.GothamBold
	togglesTitle.TextSize = 9
	togglesTitle.TextScaled = false
	togglesTitle.TextXAlignment = Enum.TextXAlignment.Left
	togglesTitle.Active = false

	-- 创建开关组件函数
	local function makeToggle(yPos, name, initial, cb)
		local t = Instance.new("TextButton", main)
		t.Size = UDim2.new(1, -32, 0, 44)
		t.Position = UDim2.new(0, 16, 0, yPos)
		t.BackgroundColor3 = initial and ACCENT or Color3.fromRGB(35, 35, 45)
		t.Text = ""
		t.AutoButtonColor = false
		t.BorderSizePixel = 0
		t.Parent = main
		Instance.new("UICorner", t).CornerRadius = UDim.new(0, 10)
		t:SetAttribute("on", initial)

		-- 边框
		local tStroke = Instance.new("UIStroke", t)
		tStroke.Color = initial and ACCENT or Color3.fromRGB(55, 55, 70)
		tStroke.Thickness = 1
		tStroke.Transparency = initial and 0.5 or 0

		-- 开关文字
		local tLeft = Instance.new("TextLabel", t)
		tLeft.Size = UDim2.new(1, -90, 1, 0)
		tLeft.Position = UDim2.new(0, 16, 0, 0)
		tLeft.BackgroundTransparency = 1
		tLeft.Text = name
		tLeft.TextColor3 = Color3.fromRGB(235, 235, 245)
		tLeft.Font = Enum.Font.GothamMedium
		tLeft.TextSize = 12
		tLeft.TextScaled = false
		tLeft.TextXAlignment = Enum.TextXAlignment.Left
		tLeft.Active = false

		-- ON/OFF 滑块背景
		local badge = Instance.new("Frame", t)
		badge.Size = UDim2.new(0, 52, 0, 24)
		badge.Position = UDim2.new(1, -66, 0.5, -12)
		badge.BackgroundColor3 = initial and ACCENT or Color3.fromRGB(45, 45, 58)
		badge.BorderSizePixel = 0
		badge.Active = false
		badge.Parent = t
		Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 12)

		-- 滑块圆点
		local indicator = Instance.new("Frame", badge)
		indicator.Size = UDim2.new(0, 18, 0, 18)
		indicator.Position = initial and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		indicator.BorderSizePixel = 0
		indicator.Active = false
		Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

		t.MouseButton1Click:Connect(function()
			local state = not t:GetAttribute("on")
			t:SetAttribute("on", state)
			TweenService:Create(t, TweenInfo.new(0.2), {
				BackgroundColor3 = state and ACCENT or Color3.fromRGB(35, 35, 45)
			}):Play()
			TweenService:Create(tStroke, TweenInfo.new(0.2), {
				Color = state and ACCENT or Color3.fromRGB(55, 55, 70),
				Transparency = state and 0.5 or 0
			}):Play()
			TweenService:Create(badge, TweenInfo.new(0.2), {
				BackgroundColor3 = state and ACCENT or Color3.fromRGB(45, 45, 58)
			}):Play()
			TweenService:Create(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
			}):Play()
			cb(state)
		end)
		table.insert(toggleButtons, t)
	end

	-- 创建功能开关
	makeToggle(154, "自动完美巴掌", true, function(v) CFG.AutoPerfect = v end)
	makeToggle(206, "自动闪避", true, function(v) CFG.AutoDodge = v end)
	makeToggle(258, "自动猜测打人者", true, function(v) CFG.AutoGuess = v end)
	makeToggle(310, "巴掌队列", false, function(v) CFG.AutoSlapQueue = v end)

	-- BETA标记
	local betaLbl = Instance.new("TextLabel", main)
	betaLbl.Size = UDim2.new(1, -32, 0, 12)
	betaLbl.Position = UDim2.new(0, 16, 0, 358)
	betaLbl.BackgroundTransparency = 1
	betaLbl.Text = "测试功能"
	betaLbl.TextColor3 = Color3.fromRGB(90, 90, 110)
	betaLbl.Font = Enum.Font.Gotham
	betaLbl.TextSize = 9
	betaLbl.TextScaled = false
	betaLbl.TextXAlignment = Enum.TextXAlignment.Right
	betaLbl.Active = false

	-- 底部文字
	local footer = Instance.new("TextLabel", main)
	footer.Size = UDim2.new(1, -32, 0, 14)
	footer.Position = UDim2.new(0, 16, 1, -22)
	footer.BackgroundTransparency = 1
	footer.Text = "自动巴掌增强 • v1.0"
	footer.TextColor3 = Color3.fromRGB(80, 80, 100)
	footer.Font = Enum.Font.Gotham
	footer.TextSize = 9
	footer.TextScaled = false
	footer.TextXAlignment = Enum.TextXAlignment.Center
	footer.Active = false

	-- ═══ 窗口拖拽逻辑 ═══
	local dragging, dragStart, startPos
	local function startDrag(input)
		if input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end

	hdr.InputBegan:Connect(startDrag)
	hdrTitle.InputBegan:Connect(startDrag)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	-- ═══ 完美巴掌钩子 拦截SendSlap远程事件 ═══
	if hookmetamethod and getnamecallmethod and sendSlap then
		local oldNC
		oldNC = hookmetamethod(game, "__namecall", function(self, ...)
			if getnamecallmethod() == "FireServer" and self == sendSlap and CFG.AutoPerfect then
				local args = {...}
				if #args >= 1 and type(args[1]) == "number" then
					args[1] = CFG.PerfectValue -- 修改巴掌参数为完美值
					return oldNC(self, unpack(args))
				end
			end
			return oldNC(self, ...)
		end)
	end

	-- ═══ 永久循环自动闪避 ═══
	task.spawn(function()
		while true do
			task.wait(CFG.DodgeDelay)
			if CFG.AutoDodge and dodgeR then
				pcall(function() dodgeR:FireServer(true) end)
			end
		end
	end)

	-- ═══ 巴掌队列自动发送（slapbut按钮出现时触发） ═══
	local slapbutBtn = nil
	local function findSlapbut()
		for _, d in ipairs(PG:GetDescendants()) do
			if d:IsA("TextButton") and d.Name == "slapbut" then
				slapbutBtn = d
				return
			end
		end
		slapbutBtn = nil
	end
	findSlapbut()
	PG.DescendantAdded:Connect(function(d)
		if d.Name == "slapbut" then
			task.wait(0.1)
			findSlapbut()
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.1)
			if CFG.AutoSlapQueue and queueR then
				if not slapbutBtn or not slapbutBtn.Parent then
					findSlapbut()
				end
				if slapbutBtn and slapbutBtn.Parent and slapbutBtn.Visible then
					pcall(function() queueR:FireServer() end)
				end
			end
		end
	end)

	-- ═══ 自动猜打人者逻辑 ═══
	-- 获取离自己最近玩家
	local function closestPlayer()
		local char = LP.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
		local myPos = char.HumanoidRootPart.Position
		local best, bestDist = nil, math.huge
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
				if d < bestDist and d < 30 then best, bestDist = p, d end
			end
		end
		return best
	end

	-- 监听所有远程事件，记录打人玩家
	for _, r in ipairs(RS:GetDescendants()) do
		if r:IsA("RemoteEvent") then
			pcall(function()
				r.OnClientEvent:Connect(function(...)
					for _, v in ipairs({...}) do
						if type(v) == "string" then
							local p = Players:FindFirstChild(v)
							if p and p ~= LP then CFG.LastSlapper = v end
						elseif typeof(v) == "Instance" and v:IsA("Player") and v ~= LP then
							CFG.LastSlapper = v.Name
						end
					end
				end)
			end)
		end
	end

	-- 执行猜测
	local function doGuess()
		if not CFG.AutoGuess or not guessR then return end
		local s = CFG.LastSlapper
		if not s then
			local c = closestPlayer()
			if c then s = c.Name end
		end
		if s then
			if pcall(function() guessR:FireServer(s) end) then
				CFG.LastSlapper = nil
			end
		end
	end

	-- 检测猜人UI出现时自动提交答案
	PG.DescendantAdded:Connect(function(d)
		if not CFG.AutoGuess then return end
		local n = d.Name:lower()
		if n:find("guess") or n:find("who") or n:find("slapper") then
			task.wait(0.6)
			doGuess()
		end
	end)

	print("[自动巴掌增强] 加载完成")
end

-- 直接启动主程序，删除密钥验证部分
_G.Main()
