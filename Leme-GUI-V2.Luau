local g = typeof(getgenv) == "function" and getgenv() or _G

local function Start()
    if g.LemeGUIV2 and type(g.LemeGUIV2) == "table" and type(g.LemeGUIV2.D) == "function" then
        pcall(g.LemeGUIV2.D)
    end

    local C = {}
    g.LemeGUIV2 = C

    local function S(o, n)
        return o:GetService(n)
    end

    local P = S(game, "Players")
    local U = S(game, "UserInputService")
    local R = S(game, "RunService")
    local T = S(game, "TeleportService")
    local SG = S(game, "StarterGui")
    local ST = S(game, "Stats")
    local L = S(game, "Lighting")
    local ws = workspace
    local lp = P.LocalPlayer
    if not lp then
        return
    end

    local uiParent do
        local ok, res = pcall(function()
            if typeof(gethui) == "function" then
                return gethui()
            end
        end)
        if ok and res then
            uiParent = res
        else
            local ok2, res2 = pcall(function()
                if typeof(get_hidden_gui) == "function" then
                    return get_hidden_gui()
                end
            end)
            if ok2 and res2 then
                uiParent = res2
            else
                local ok3, res3 = pcall(function()
                    return game:GetService("CoreGui")
                end)
                if ok3 and res3 then
                    uiParent = res3
                else
                    local ok4, res4 = pcall(function()
                        return lp:WaitForChild("PlayerGui")
                    end)
                    if ok4 and res4 then
                        uiParent = res4
                    end
                end
            end
        end
    end
    if not uiParent then
        return
    end

    local currentCam = ws.CurrentCamera
    local defaultFov = currentCam and currentCam.FieldOfView or 70

    local defaultWalkSpeed = 16
    do
        local c = lp.Character
        if c then
            local hum = c:FindFirstChildWhichIsA("Humanoid")
            if hum then
                defaultWalkSpeed = hum.WalkSpeed or defaultWalkSpeed
            end
        end
    end

    local defaultJump = 50
    do
        local c = lp.Character
        if c then
            local hum = c:FindFirstChildWhichIsA("Humanoid")
            if hum then
                if hum.UseJumpPower ~= false then
                    defaultJump = hum.JumpPower or defaultJump
                else
                    defaultJump = hum.JumpHeight or defaultJump
                end
            end
        end
    end

    local defaultMaxZoom = lp.CameraMaxZoomDistance or 128
    local defaultMinZoom = lp.CameraMinZoomDistance or 0.5
    local defaultFogColor = L.FogColor or Color3.new(1, 1, 1)
    local defaultFogStart = L.FogStart or 0
    local defaultFogEnd = L.FogEnd or 1000
    local defaultFogColorStr = string.format(
        "%d %d %d",
        math.floor(defaultFogColor.R * 255 + 0.5),
        math.floor(defaultFogColor.G * 255 + 0.5),
        math.floor(defaultFogColor.B * 255 + 0.5)
    )
    local defaultGrav = ws.Gravity

    local function roundInit(v)
        local sign = 1
        if v < 0 then
            sign = -1
            v = -v
        end
        local n3 = v * 1000
        local n3i = math.floor(n3 + 1e-7)
        local rem = n3i % 10
        local base = (n3i - rem) / 10
        local dec2
        if rem > 5 then
            dec2 = base + 1
        else
            dec2 = base
        end
        local res = (dec2 / 100) * sign
        return res
    end

    local function formatInit(v)
        local s = string.format("%.3f", v)
        s = s:gsub("0+$", "")
        s = s:gsub("%.$", "")
        return s
    end

    local initFlySpeedVal = roundInit(100)
    local initFlySpeedStr = formatInit(initFlySpeedVal)
    local initTpSpeedVal = roundInit(50)
    local initTpSpeedStr = formatInit(initTpSpeedVal)
    local initFovVal = roundInit(defaultFov)
    local initFovStr = formatInit(initFovVal)
    local initWalkVal = roundInit(defaultWalkSpeed)
    local initWalkStr = formatInit(initWalkVal)
    local initJumpVal = roundInit(defaultJump)
    local initJumpStr = formatInit(initJumpVal)
    local initMaxZoomVal = roundInit(defaultMaxZoom)
    local initMaxZoomStr = formatInit(initMaxZoomVal)
    local initMinZoomVal = roundInit(defaultMinZoom)
    local initMinZoomStr = formatInit(initMinZoomVal)
    local initFogStartVal = roundInit(defaultFogStart)
    local initFogStartStr = formatInit(initFogStartVal)
    local initFogEndVal = roundInit(defaultFogEnd)
    local initFogEndStr = formatInit(initFogEndVal)
    local initGravVal = roundInit(defaultGrav)
    local initGravStr = formatInit(initGravVal)

    local destroyed = false
    local conns = {}
    local refs = {}
    local allButtons = {}
    local allGroupLabels = {}
    local allInputs = {}
    local allDisplays = {}

    local function addConn(cn)
        if cn then
            conns[#conns + 1] = cn
        end
        return cn
    end

    local function playOverlay(gui)
        local TS = S(game, "TweenService")
        local f = Instance.new("Frame")
        f.Name = "LemeOverlay"
        f.Size = UDim2.new(1, 0, 1, 0)
        f.Position = UDim2.new(0, 0, 0, 0)
        f.BackgroundColor3 = Color3.new(0, 0, 0)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.ZIndex = 1000
        f.Parent = gui

        local twIn = TS:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.5 })
        twIn:Play()
        twIn.Completed:Wait()

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.BorderSizePixel = 0
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        lbl.Position = UDim2.new(0.5, 0, 0.5, 0)
        lbl.Size = UDim2.new(0, 300, 0, 60)
        lbl.Font = Enum.Font.Code
        lbl.Text = "Leme GUI V2"
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.TextSize = 28
        lbl.TextTransparency = 1
        lbl.ZIndex = f.ZIndex + 1
        lbl.Parent = f

        local twTextIn = TS:Create(lbl, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
        twTextIn:Play()
        twTextIn.Completed:Wait()

        task.wait(1)

        local twTextOut = TS:Create(lbl, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 })
        twTextOut:Play()
        twTextOut.Completed:Wait()

        lbl:Destroy()

        local twOut = TS:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
        twOut:Play()
        twOut.Completed:Wait()

        f:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Leme GUI V2"
    gui.DisplayOrder = 2147483647
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = uiParent

    task.spawn(function()
        playOverlay(gui)
    end)

    local FRAME_W = 420
    local FRAME_H = 280
    local MAIN_MARGIN = 10
    local BTN_H = 30
    local TOGGLE_SIZE = 56

    refs.main = Instance.new("Frame")
    refs.main.Name = "Main"
    refs.main.AnchorPoint = Vector2.new(0.5, 1)
    refs.main.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
    refs.main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    refs.main.BackgroundTransparency = 0.2
    refs.main.BorderSizePixel = 0
    refs.main.ZIndex = 10
    refs.main.Parent = gui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = refs.main

    refs.title = Instance.new("TextLabel")
    refs.title.BackgroundTransparency = 1
    refs.title.BorderSizePixel = 0
    refs.title.Position = UDim2.new(0, 12, 0, 8)
    refs.title.Size = UDim2.new(1, -24, 0, 24)
    refs.title.Font = Enum.Font.Code
    refs.title.Text = "Leme GUI V2"
    refs.title.TextColor3 = Color3.new(1, 1, 1)
    refs.title.TextSize = 20
    refs.title.TextXAlignment = Enum.TextXAlignment.Left
    refs.title.ZIndex = 11
    refs.title.Parent = refs.main

    refs.scroll = Instance.new("ScrollingFrame")
    refs.scroll.BackgroundTransparency = 1
    refs.scroll.BorderSizePixel = 0
    refs.scroll.Position = UDim2.new(0, 12, 0, 40)
    refs.scroll.Size = UDim2.new(1, -24, 1, -52)
    refs.scroll.ZIndex = 11
    refs.scroll.ScrollBarThickness = 4
    refs.scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    refs.scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    refs.scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    refs.scroll.Parent = refs.main

    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Vertical
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 8)
    list.Parent = refs.scroll

    local function createGroup(nameEn, nameJp, order, key)
        local gFrame = Instance.new("Frame")
        gFrame.Name = key .. "Group"
        gFrame.BackgroundTransparency = 1
        gFrame.BorderSizePixel = 0
        gFrame.Size = UDim2.new(1, 0, 0, 40)
        gFrame.AutomaticSize = Enum.AutomaticSize.Y
        gFrame.LayoutOrder = order
        gFrame.ZIndex = 11
        gFrame.Parent = refs.scroll

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.BorderSizePixel = 0
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.Font = Enum.Font.Code
        lbl.Text = nameEn
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.TextSize = 18
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 12
        lbl.Parent = gFrame
        lbl:SetAttribute("TextEn", nameEn)
        lbl:SetAttribute("TextJp", nameJp)
        table.insert(allGroupLabels, lbl)
        refs["groupLabel_" .. key] = lbl

        local btnFrame = Instance.new("Frame")
        btnFrame.Name = "Buttons"
        btnFrame.BackgroundTransparency = 1
        btnFrame.BorderSizePixel = 0
        btnFrame.Position = UDim2.new(0, 0, 0, 22)
        btnFrame.Size = UDim2.new(1, 0, 0, 32)
        btnFrame.AutomaticSize = Enum.AutomaticSize.Y
        btnFrame.ZIndex = 11
        btnFrame.Parent = gFrame

        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.new(0, 140, 0, 28)
        grid.CellPadding = UDim2.new(0, 8, 0, 6)
        grid.FillDirection = Enum.FillDirection.Horizontal
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.Parent = btnFrame

        return btnFrame
    end

    local function createButton(parent, textEn, textJp, order, key, isToggle)
        local b = Instance.new("TextButton")
        b.Name = key
        b.BackgroundColor3 = refs.main.BackgroundColor3
        b.BackgroundTransparency = refs.main.BackgroundTransparency
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.Font = Enum.Font.Code
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 14
        b.ZIndex = 12
        b.LayoutOrder = order
        b.Parent = parent
        b:SetAttribute("TextEn", textEn)
        b:SetAttribute("TextJp", textJp)
        b:SetAttribute("IsToggle", isToggle and true or false)
        b.Text = textEn
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = b
        refs[key] = b
        table.insert(allButtons, b)
        return b
    end

    local function createLabeledInput(parent, labelEn, labelJp, order, defaultValue, key)
        local cell = Instance.new("Frame")
        cell.Name = key .. "Cell"
        cell.BackgroundTransparency = 1
        cell.BorderSizePixel = 0
        cell.ZIndex = 12
        cell.LayoutOrder = order
        cell.ClipsDescendants = false
        cell.Parent = parent

        local tb = Instance.new("TextBox")
        tb.Name = key
        tb.BackgroundColor3 = refs.main.BackgroundColor3
        tb.BackgroundTransparency = refs.main.BackgroundTransparency
        tb.BorderSizePixel = 0
        tb.Font = Enum.Font.Code
        tb.TextColor3 = Color3.new(1, 1, 1)
        tb.TextSize = 14
        tb.TextXAlignment = Enum.TextXAlignment.Left
        tb.ClearTextOnFocus = false
        tb.ZIndex = 13
        tb.Size = UDim2.new(1, 0, 1, -4)
        tb.Position = UDim2.new(0, 0, 0, 2)
        tb.Parent = cell

        local prefixEn = labelEn .. " "
        local prefixJp = labelJp .. " "
        tb:SetAttribute("PrefixEn", prefixEn)
        tb:SetAttribute("PrefixJp", prefixJp)
        tb:SetAttribute("Prefix", prefixEn)
        tb.Text = prefixEn .. tostring(defaultValue)

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = tb

        refs[key] = tb
        table.insert(allInputs, tb)

        local enforcing = false
        local function enforce()
            if enforcing then
                return
            end
            enforcing = true
            local pf = tb:GetAttribute("Prefix") or ""
            local tx = tb.Text or ""
            if #tx < #pf or tx:sub(1, #pf) ~= pf then
                tx = pf
            end
            tb.Text = tx
            local minCur = #pf + 1
            local cur = tb.CursorPosition
            if cur == -1 or cur < minCur then
                tb.CursorPosition = minCur
            end
            enforcing = false
        end

        tb:GetPropertyChangedSignal("Text"):Connect(enforce)

        tb.Focused:Connect(function()
            local pf = tb:GetAttribute("Prefix") or ""
            local minCur = #pf + 1
            task.defer(function()
                if not tb or not tb.Parent then
                    return
                end
                local tx = tb.Text or ""
                local cur = #tx + 1
                if cur < minCur then
                    cur = minCur
                end
                tb.CursorPosition = cur
            end)
        end)

        return tb
    end

    local function createDisplayCell(parent, labelEn, labelJp, order, key)
        local cell = Instance.new("Frame")
        cell.Name = key .. "Cell"
        cell.BackgroundTransparency = 1
        cell.BorderSizePixel = 0
        cell.ZIndex = 12
        cell.LayoutOrder = order
        cell.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Name = key
        lbl.BackgroundColor3 = refs.main.BackgroundColor3
        lbl.BackgroundTransparency = refs.main.BackgroundTransparency
        lbl.BorderSizePixel = 0
        lbl.Font = Enum.Font.Code
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 13
        lbl.Size = UDim2.new(1, 0, 1, -4)
        lbl.Position = UDim2.new(0, 0, 0, 2)
        lbl.Parent = cell
        lbl:SetAttribute("LabelEn", labelEn)
        lbl:SetAttribute("LabelJp", labelJp)

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = lbl

        refs[key] = lbl
        table.insert(allDisplays, lbl)
        return lbl
    end

    refs.flyGroup = createGroup("Fly", "飛行", 1, "Fly")
    refs.tpWalkGroup = createGroup("TP Walk", "TP歩行", 2, "TPWalk")
    refs.flingGroup = createGroup("Fling", "吹き飛ばす", 3, "Fling")
    refs.antiGroup = createGroup("Anti", "耐性", 4, "Anti")
    refs.humanoidGroup = createGroup("Humanoid", "体", 5, "Humanoid")
    refs.otherGroup = createGroup("Other", "その他", 6, "Other")
    refs.fovGroup = createGroup("FOV", "視野", 7, "FOV")
    refs.speedGroup = createGroup("Speed", "歩く速度", 8, "SpeedGroup")
    refs.jumpGroup = createGroup("Jump", "ジャンプ力", 9, "Jump")
    refs.gravGroup = createGroup("Gravity", "重力", 10, "Gravity")
    refs.maxZoomGroup = createGroup("MaxZoom", "最大ズーム", 11, "MaxZoom")
    refs.minZoomGroup = createGroup("MinZoom", "最小ズーム", 12, "MinZoom")
    refs.fogGroup = createGroup("Fog", "霧", 13, "Fog")
    refs.fbGroup = createGroup("Full Bright", "フルブライト", 14, "FullBright")
    refs.desyncGroup = createGroup("Desync", "非同期", 15, "Desync")
    refs.teleportGroup = createGroup("Teleport", "テレポート", 16, "Teleport")
    refs.resetCamGroup = createGroup("Reset Camera", "カメラ初期化", 17, "ResetCamera")
    refs.scriptGroup = createGroup("Script", "スクリプト", 99, "Script")

    createButton(refs.flyGroup, "Fly", "飛行", 1, "flyBtn", true)
    createButton(refs.flyGroup, "Hover", "ホバリング", 2, "hoverBtn", true)
    createButton(refs.flyGroup, "Velocity", "ベクトル", 3, "velBtn", true)
    createLabeledInput(refs.flyGroup, "Speed", "速度", 4, initFlySpeedStr, "flySpeedInput")
    createButton(refs.flyGroup, "Smart Fly", "スマート飛行", 5, "smartFlyBtn", true)
    createButton(refs.flyGroup, "Trigger", "トリガーキー", 6, "smartFlyTrigBtn", false)

    createButton(refs.tpWalkGroup, "TP Walk", "TP歩行", 1, "tpWalkBtn", true)
    createLabeledInput(refs.tpWalkGroup, "Speed", "速度", 2, initTpSpeedStr, "tpWalkSpeedInput")

    createLabeledInput(refs.flingGroup, "Target", "対象", 1, "", "flingTargetInput")
    createDisplayCell(refs.flingGroup, "Target", "対象", 2, "flingTargetDisplay")
    createButton(refs.flingGroup, "Fling", "吹き飛ばす", 3, "flingBtn", false)
    createButton(refs.flingGroup, "Touch Fling", "接触吹き飛ばし", 4, "touchFlingBtn", true)

    createButton(refs.antiGroup, "Anti Void", "奈落耐性", 1, "antiVoidBtn", true)
    createButton(refs.antiGroup, "Anti AFK", "放置耐性", 2, "antiAfkBtn", false)
    createButton(refs.antiGroup, "Anti Fling", "吹き飛ばし耐性", 3, "antiFlingBtn", true)

    createButton(refs.humanoidGroup, "Kill Self", "自殺", 1, "killSelfBtn", false)
    createButton(refs.humanoidGroup, "Loop Kill", "自殺ループ", 2, "loopKillBtn", true)
    createButton(refs.humanoidGroup, "No clip", "すり抜け", 3, "noclipBtn", true)
    createButton(refs.humanoidGroup, "Fly Jump", "無限ジャンプ", 4, "flyJumpBtn", true)
    createButton(refs.humanoidGroup, "Anchor", "体を固定", 5, "anchorBtn", true)
    createButton(refs.humanoidGroup, "Smart Reset", "スマートリセット", 6, "smartResetBtn", true)
    createButton(refs.humanoidGroup, "Trigger", "トリガーキー", 7, "smartResetTrigBtn", false)

    createButton(refs.otherGroup, "Rejoin", "再参加", 1, "rejoinBtn", false)
    createButton(refs.otherGroup, "ESP", "ESP", 2, "espBtn", true)
    createButton(refs.otherGroup, "Mini ESP", "ミニESP", 3, "miniEspBtn", true)
    createButton(refs.otherGroup, "Status", "ステータス", 4, "statusBtn", true)
    createButton(refs.otherGroup, "Chat", "チャット", 5, "chatBtn", true)
    createButton(refs.otherGroup, "Instant Prompt", "即時プロンプト", 6, "instantPromptBtn", false)

    createButton(refs.fovGroup, "Set FOV", "視野を設定", 1, "setFovBtn", false)
    createButton(refs.fovGroup, "Loop FOV", "視野を固定", 2, "loopFovBtn", true)
    createLabeledInput(refs.fovGroup, "FOV", "視野", 3, initFovStr, "fovInput")

    createButton(refs.speedGroup, "Set Speed", "速度を設定", 1, "setSpeedBtn", false)
    createButton(refs.speedGroup, "Loop Speed", "速度を固定", 2, "loopSpeedBtn", true)
    createLabeledInput(refs.speedGroup, "Speed", "速度", 3, initWalkStr, "speedInput")

    createButton(refs.jumpGroup, "Set Jump", "ジャンプを設定", 1, "setJumpBtn", false)
    createButton(refs.jumpGroup, "Loop Jump", "ジャンプ固定", 2, "loopJumpBtn", true)
    createLabeledInput(refs.jumpGroup, "Jump", "ジャンプ力", 3, initJumpStr, "jumpInput")

    createButton(refs.gravGroup, "Set Grav", "重力を設定", 1, "setGravBtn", false)
    createButton(refs.gravGroup, "Loop Grav", "重力を固定", 2, "loopGravBtn", true)
    createLabeledInput(refs.gravGroup, "Grav", "重力", 3, initGravStr, "gravInput")

    createButton(refs.maxZoomGroup, "Set MaxZoom", "最大ズームを設定", 1, "setMaxZoomBtn", false)
    createButton(refs.maxZoomGroup, "Loop MaxZoom", "最大ズームを固定", 2, "loopMaxZoomBtn", true)
    createLabeledInput(refs.maxZoomGroup, "MaxZoom", "最大ズーム", 3, initMaxZoomStr, "maxZoomInput")
    createButton(refs.maxZoomGroup, "No MaxZoom", "最大ズームを無効", 4, "noMaxZoomBtn", true)

    createButton(refs.minZoomGroup, "Set MinZoom", "最小ズームを設定", 1, "setMinZoomBtn", false)
    createButton(refs.minZoomGroup, "Loop MinZoom", "最小ズームを固定", 2, "loopMinZoomBtn", true)
    createLabeledInput(refs.minZoomGroup, "MinZoom", "最小ズーム", 3, initMinZoomStr, "minZoomInput")
    createButton(refs.minZoomGroup, "No MinZoom", "最小ズームを無効", 4, "noMinZoomBtn", true)

    createButton(refs.fogGroup, "No Fog", "霧なし", 1, "noFogBtn", true)
    createButton(refs.fogGroup, "Set Fog", "霧を設定", 2, "setFogBtn", false)
    createButton(refs.fogGroup, "Loop Fog", "霧を固定", 3, "loopFogBtn", true)
    createLabeledInput(refs.fogGroup, "FogColor", "霧の色", 4, defaultFogColorStr, "fogColorInput")
    createLabeledInput(refs.fogGroup, "FogStart", "霧の開始距離", 5, initFogStartStr, "fogStartInput")
    createLabeledInput(refs.fogGroup, "FogEnd", "霧の終了距離", 6, initFogEndStr, "fogEndInput")

    createButton(refs.fbGroup, "Full Bright", "フルブライト", 1, "fbBtn", false)
    createButton(refs.fbGroup, "Loop FB", "ループ", 2, "loopFbBtn", true)

    local desyncPosTb = createLabeledInput(refs.desyncGroup, "Desync Pos", "非同期座標", 3, "0 0 0", "desyncPosInput")
    refs.desyncPosCell = desyncPosTb.Parent
    refs.desyncPosCell.Visible = false
    createButton(refs.desyncGroup, "Desync", "非同期", 1, "desyncBtn", true)
    createButton(refs.desyncGroup, "Desync Pos", "非同期座標", 2, "desyncPosBtn", true)

    createButton(refs.resetCamGroup, "Reset Camera", "カメラ初期化", 1, "resetCamBtn", false)
    createButton(refs.resetCamGroup, "Loop Reset", "ループ初期化", 2, "loopResetCamBtn", true)

    createButton(refs.scriptGroup, "Load IY", "IYスクリプト", 1, "loadIYBtn", false)
    createButton(refs.scriptGroup, "Load RSpy", "スパイスクリプト", 2, "loadRSpyBtn", false)
    createButton(refs.scriptGroup, "Load Dex", "エクスプローラースクリプト", 3, "loadDexBtn", false)
    createButton(refs.scriptGroup, "Load ShiftLock", "シフトロックスクリプト", 4, "loadShiftLockBtn", false)
    createButton(refs.scriptGroup, "Unload", "スクリプトを削除", 5, "unloadBtn", false)
    createButton(refs.scriptGroup, "Reload", "リロード", 6, "reloadBtn", false)
    createButton(refs.scriptGroup, "Keep Script", "スクリプト保持", 7, "keepScriptBtn", true)
    createButton(refs.scriptGroup, "Language", "言語", 8, "languageBtn", false)

    createButton(refs.teleportGroup, "TP to", "テレポート", 1, "tpToBtn", false)
    createLabeledInput(refs.teleportGroup, "Pos", "座標", 2, "0 0 0", "tpPosInput")
    createButton(refs.teleportGroup, "Set Pos", "現在の座標に設定", 3, "setPosBtn", false)

    refs.toggle = Instance.new("TextButton")
    refs.toggle.Name = "Toggle"
    refs.toggle.AnchorPoint = Vector2.new(0.5, 1)
    refs.toggle.Size = UDim2.new(0, TOGGLE_SIZE, 0, TOGGLE_SIZE)
    refs.toggle.BackgroundColor3 = refs.main.BackgroundColor3
    refs.toggle.BackgroundTransparency = refs.main.BackgroundTransparency
    refs.toggle.BorderSizePixel = 0
    refs.toggle.Text = ""
    refs.toggle.AutoButtonColor = false
    refs.toggle.ZIndex = 20
    refs.toggle.Parent = gui

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = refs.toggle

    local btnX = 0.5
    local targetBtnX = btnX
    local open = false

    local dragging = false
    local dragMoved = false
    local mouseDown = false
    local dragCandidate = false
    local dragStartX = 0
    local dragBtnStartX = 0

    local tweening = false

    local function toggleHiddenPos()
        return UDim2.new(btnX, 0, 1, -BTN_H)
    end

    local function toggleShownPos()
        local off = -(MAIN_MARGIN + FRAME_H + 10)
        return UDim2.new(btnX, 0, 1, off)
    end

    local function mainHiddenPos()
        return UDim2.new(btnX, 0, 1, FRAME_H)
    end

    local function mainShownPos()
        return UDim2.new(btnX, 0, 1, -MAIN_MARGIN)
    end

    refs.main.Position = mainHiddenPos()
    refs.toggle.Position = toggleHiddenPos()

    local function toggleMain()
        if destroyed or tweening or dragging then
            return
        end
        tweening = true
        local newMain = open and mainHiddenPos() or mainShownPos()
        local newToggle = open and toggleHiddenPos() or toggleShownPos()
        local TS2 = S(game, "TweenService")
        local info = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local twMain = TS2:Create(refs.main, info, { Position = newMain })
        local twToggle = TS2:Create(refs.toggle, info, { Position = newToggle })
        twMain:Play()
        twToggle:Play()
        twMain.Completed:Connect(function()
            open = not open
            tweening = false
        end)
    end

    refs.toggle.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        if dragMoved then
            return
        end
        toggleMain()
    end)

    local function getChar()
        return lp.Character
    end

    local st = {
        noclipOn = false,
        noclipSaved = {},
        tpOn = false,
        tpSpeed = initTpSpeedVal,
        tpSavedWalkSpeed = nil,
        anchorOn = false,
        anchorData = nil,
        antiVoidOn = true,
        antiVoidSaved = ws.FallenPartsDestroyHeight,
        antiFlingOn = false,
        antiFlingSaved = {},
        touchFlingOn = false,
        flyJumpOn = false,
        flyMode = "none",
        flySpeed = initFlySpeedVal,
        flyPos = nil,
        hoverTarget = nil,
        hoverY = nil,
        velAnchorPos = nil,
        velDamping = 50,
        moveKeys = { W = false, A = false, S = false, D = false, Q = false, E = false },
        fovLoop = false,
        fovValue = initFovVal,
        speedLoop = false,
        speedValue = initWalkVal,
        jumpLoop = false,
        jumpValue = initJumpVal,
        maxZoomLoop = false,
        maxZoomValue = initMaxZoomVal,
        minZoomLoop = false,
        minZoomValue = initMinZoomVal,
        gravLoop = false,
        gravValue = initGravVal,
        noFogOn = false,
        fogLoop = false,
        fogColor = defaultFogColor,
        fogStart = initFogStartVal,
        fogEnd = initFogEndVal,
        espOn = false,
        miniEspOn = false,
        espTimer = 0,
        statusOn = false,
        statusGui = nil,
        statusLabel = nil,
        antiFlingInterval = 0.2,
        espInterval = 0.1,
        statusFpsFrames = 0,
        statusFpsStart = time(),
        statusFpsNow = 0,
        pingQ = {},
        pingHead = 1,
        pingTail = 0,
        pingSum = 0,
        fpsQ = {},
        fpsHead = 1,
        fpsTail = 0,
        fpsSum = 0,
        fullBrightLoopOn = false,
        smartFlyOn = false,
        smartFlyKey = Enum.KeyCode.E,
        smartFlyWaitingKey = false,
        smartResetOn = false,
        smartResetKey = Enum.KeyCode.R,
        smartResetWaitingKey = false,
        chatOn = true,
        tpPos = nil,
        noMaxZoomOn = false,
        noMaxZoomSaved = nil,
        noMinZoomOn = false,
        noMinZoomSaved = nil,
        loopKillOn = false,
        flingTarget = nil,
        flingRunning = false,
        flingCooldownEnd = 0,
        desyncOn = false,
        desyncPosOn = false,
        desyncSavedCF = nil,
        desyncRealCF = nil,
        desyncRealVel = nil,
        desyncRealRotVel = nil,
        desyncDummy = nil,
        desyncDummyRoot = nil,
        desyncDummyMotorMap = {},
        desyncSourceChar = nil,
        desyncPosTarget = nil,
        desyncMaterialSaved = {},
        resetCamLoopOn = false,
        keepScriptOn = true,
        language = "en",
    }

    local hoverAlign, hoverOri, hoverAtt, hoverOriAtt

    local vUser do
        pcall(function()
            vUser = game:GetService("VirtualUser")
        end)
    end

    local antiAfkLoaded = false
    local qtp
    pcall(function()
        qtp = queue_on_teleport or queueteleport
    end)

    local function queueSelf()
        if not qtp then
            return
        end
        pcall(function()
            qtp("loadstring(game:HttpGet'x.gd/https://raw.githubusercontent.com/Lemedios/Leme-GUI-V2/refs/heads/main/Leme-GUI-V2.Luau')()")
        end)
    end

    local function setToggleText(btn, isOn)
        if not btn then
            return
        end
        local baseEn = btn:GetAttribute("TextEn") or btn.Text
        local baseJp = btn:GetAttribute("TextJp") or baseEn
        local base = st.language == "jp" and baseJp or baseEn
        local onStr, offStr
        if st.language == "jp" then
            onStr, offStr = "オン", "オフ"
        else
            onStr, offStr = "ON", "OFF"
        end
        btn.Text = string.format("%s [%s]", base, isOn and onStr or offStr)
    end

    local function updNoclipBtn()
        setToggleText(refs.noclipBtn, st.noclipOn)
    end

    local function updTpBtn()
        setToggleText(refs.tpWalkBtn, st.tpOn)
    end

    local function updAnchorBtn()
        setToggleText(refs.anchorBtn, st.anchorOn)
    end

    local function updAntiVoidBtn()
        setToggleText(refs.antiVoidBtn, st.antiVoidOn)
    end

    local function updAntiFlingBtn()
        setToggleText(refs.antiFlingBtn, st.antiFlingOn)
    end

    local function updTouchFlingBtn()
        setToggleText(refs.touchFlingBtn, st.touchFlingOn)
    end

    local function updFlyJumpBtn()
        setToggleText(refs.flyJumpBtn, st.flyJumpOn)
    end

    local function updFlyBtns()
        setToggleText(refs.flyBtn, st.flyMode == "fly")
        setToggleText(refs.hoverBtn, st.flyMode == "hover")
        setToggleText(refs.velBtn, st.flyMode == "vel")
    end

    local function updEspBtn()
        setToggleText(refs.espBtn, st.espOn)
    end

    local function updMiniEspBtn()
        setToggleText(refs.miniEspBtn, st.miniEspOn)
    end

    local function updStatusBtn()
        setToggleText(refs.statusBtn, st.statusOn)
    end

    local function updLoopFovBtn()
        setToggleText(refs.loopFovBtn, st.fovLoop)
    end

    local function updLoopSpeedBtn()
        setToggleText(refs.loopSpeedBtn, st.speedLoop)
    end

    local function updLoopJumpBtn()
        setToggleText(refs.loopJumpBtn, st.jumpLoop)
    end

    local function updLoopMaxZoomBtn()
        setToggleText(refs.loopMaxZoomBtn, st.maxZoomLoop)
    end

    local function updLoopMinZoomBtn()
        setToggleText(refs.loopMinZoomBtn, st.minZoomLoop)
    end

    local function updLoopFogBtn()
        setToggleText(refs.loopFogBtn, st.fogLoop)
    end

    local function updNoFogBtn()
        setToggleText(refs.noFogBtn, st.noFogOn)
    end

    local function updLoopFbBtn()
        setToggleText(refs.loopFbBtn, st.fullBrightLoopOn)
    end

    local function updLoopGravBtn()
        setToggleText(refs.loopGravBtn, st.gravLoop)
    end

    local function updSmartFlyBtn()
        setToggleText(refs.smartFlyBtn, st.smartFlyOn)
    end

    local function updSmartResetBtn()
        setToggleText(refs.smartResetBtn, st.smartResetOn)
    end

    local function updChatBtn()
        setToggleText(refs.chatBtn, st.chatOn)
    end

    local function updNoMaxZoomBtn()
        setToggleText(refs.noMaxZoomBtn, st.noMaxZoomOn)
    end

    local function updNoMinZoomBtn()
        setToggleText(refs.noMinZoomBtn, st.noMinZoomOn)
    end

    local function updLoopKillBtn()
        setToggleText(refs.loopKillBtn, st.loopKillOn)
    end

    local function updDesyncBtn()
        setToggleText(refs.desyncBtn, st.desyncOn)
    end

    local function updDesyncPosBtn()
        setToggleText(refs.desyncPosBtn, st.desyncPosOn)
        if refs.desyncPosCell then
            refs.desyncPosCell.Visible = st.desyncPosOn
        end
    end

    local function updLoopResetCamBtn()
        setToggleText(refs.loopResetCamBtn, st.resetCamLoopOn)
    end

    local function updKeepScriptBtn()
        setToggleText(refs.keepScriptBtn, st.keepScriptOn)
    end

    local function updFlingTargetDisplay()
        local lbl = refs.flingTargetDisplay
        if not lbl then
            return
        end
        local baseEn = lbl:GetAttribute("LabelEn") or "Target"
        local baseJp = lbl:GetAttribute("LabelJp") or baseEn
        local base = st.language == "jp" and baseJp or baseEn
        local name = st.flingTarget and st.flingTarget.Name or "None"
        lbl.Text = base .. " [" .. name .. "]"
    end

    local function updLanguageBtn()
        local btn = refs.languageBtn
        if not btn then
            return
        end
        local baseEn = btn:GetAttribute("TextEn") or "Language"
        local baseJp = btn:GetAttribute("TextJp") or "言語"
        if st.language == "jp" then
            btn.Text = baseJp .. " [日本語]"
        else
            btn.Text = baseEn .. " [English]"
        end
    end

    local function applyLanguage()
        for _, lbl in ipairs(allGroupLabels) do
            local en = lbl:GetAttribute("TextEn")
            local jp = lbl:GetAttribute("TextJp") or en
            if en then
                lbl.Text = st.language == "jp" and jp or en
            end
        end

        for _, btn in ipairs(allButtons) do
            local en = btn:GetAttribute("TextEn")
            local jp = btn:GetAttribute("TextJp") or en
            if en then
                local isToggle = btn:GetAttribute("IsToggle")
                if not isToggle then
                    btn.Text = st.language == "jp" and jp or en
                end
            end
        end

        for _, tb in ipairs(allInputs) do
            local en = tb:GetAttribute("PrefixEn")
            local jp = tb:GetAttribute("PrefixJp") or en
            if en then
                local oldPf = tb:GetAttribute("Prefix") or en
                local tx = tb.Text or ""
                local value = tx:sub(#oldPf + 1)
                local newPf = st.language == "jp" and jp or en
                tb:SetAttribute("Prefix", newPf)
                tb.Text = newPf .. value
            end
        end

        updNoclipBtn()
        updTpBtn()
        updAnchorBtn()
        updAntiVoidBtn()
        updAntiFlingBtn()
        updTouchFlingBtn()
        updFlyJumpBtn()
        updFlyBtns()
        updEspBtn()
        updMiniEspBtn()
        updStatusBtn()
        updLoopFovBtn()
        updLoopSpeedBtn()
        updLoopJumpBtn()
        updLoopMaxZoomBtn()
        updLoopMinZoomBtn()
        updNoFogBtn()
        updLoopFogBtn()
        updLoopFbBtn()
        updLoopGravBtn()
        updSmartFlyBtn()
        updSmartResetBtn()
        updChatBtn()
        updNoMaxZoomBtn()
        updNoMinZoomBtn()
        updLoopKillBtn()
        updDesyncBtn()
        updDesyncPosBtn()
        updLoopResetCamBtn()
        updKeepScriptBtn()
        updLanguageBtn()
        updFlingTargetDisplay()
    end

    local function rejoin()
        if #P:GetPlayers() == 1 then
            lp:Kick("Rejoining...")
            task.wait()
            T:Teleport(game.PlaceId, lp)
        else
            T:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
        end
    end

    local function killSelf()
        local c = getChar()
        if not c then
            return
        end
        local hum = c:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Dead)
        end
    end

    local function enableAntiAfk()
        local env = typeof(getgenv) == "function" and getgenv() or _G
        if env.AntiAFK or antiAfkLoaded then
            pcall(function()
                SG:SetCore("SendNotification", { Title = "Anti AFK", Text = "Already Loaded", Duration = 5 })
            end)
            return
        end
        if typeof(getgenv) == "function" then
            env.AntiAFK = true
        else
            antiAfkLoaded = true
        end
        if not vUser then
            return
        end
        lp.Idled:Connect(function()
            pcall(function()
                vUser:CaptureController()
                vUser:SetKeyDown(Enum.KeyCode.F15)
                vUser:SetKeyUp(Enum.KeyCode.F15)
            end)
        end)
        pcall(function()
            SG:SetCore("SendNotification", { Title = "Anti AFK", Text = "Load Completed", Duration = 5 })
        end)
    end

    local FLOAT_NAME = "FloatPart"

    local function cacheNoclip()
        local saved = st.noclipSaved
        for k in pairs(saved) do
            saved[k] = nil
        end
        local c = getChar()
        if not c then
            return
        end
        for _, p2 in ipairs(c:GetDescendants()) do
            if p2:IsA("BasePart") then
                saved[p2] = p2.CanCollide
            end
        end
    end

    local function restoreNoclip()
        for p2, v in pairs(st.noclipSaved) do
            if p2 and p2.Parent then
                p2.CanCollide = v
            end
        end
    end

    local function toggleNoclip()
        st.noclipOn = not st.noclipOn
        if st.noclipOn then
            cacheNoclip()
        else
            restoreNoclip()
        end
        updNoclipBtn()
    end

    local function toggleTpWalk()
        st.tpOn = not st.tpOn
        local c = getChar()
        local hum = c and c:FindFirstChildWhichIsA("Humanoid")
        if st.tpOn then
            if hum then
                st.tpSavedWalkSpeed = hum.WalkSpeed
                hum.WalkSpeed = 0
            else
                st.tpSavedWalkSpeed = nil
            end
        else
            if hum then
                hum.WalkSpeed = st.tpSavedWalkSpeed or defaultWalkSpeed
            end
        end
        updTpBtn()
    end

    local function updateTpWalk(dt)
        if not st.tpOn then
            return
        end
        local c = getChar()
        local hum = c and c:FindFirstChildWhichIsA("Humanoid")
        local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp2 then
            return
        end
        hum.WalkSpeed = 0
        local move = hum.MoveDirection
        local flat = Vector3.new(move.X, 0, move.Z)
        if flat.Magnitude > 0 then
            flat = flat.Unit
            local d = flat * st.tpSpeed * dt
            local pos = hrp2.Position + d
            local look = hrp2.CFrame.LookVector
            hrp2.CFrame = CFrame.new(pos, pos + look)
            local v = hrp2.AssemblyLinearVelocity
            hrp2.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
        end
    end

    local function createHoverAlign(hrp2)
        if not hrp2 then
            return
        end
        if not hoverAlign then
            hoverAlign = Instance.new("AlignPosition")
            hoverAlign.ApplyAtCenterOfMass = true
            hoverAlign.Responsiveness = 1/0
            hoverAlign.MaxForce = 1/0
            hoverAlign.Mode = Enum.PositionAlignmentMode.OneAttachment
            hoverAlign.Parent = hrp2
            hoverAtt = Instance.new("Attachment")
            hoverAtt.Parent = hrp2
            hoverAlign.Attachment0 = hoverAtt
        end
        if not hoverOri then
            hoverOri = Instance.new("AlignOrientation")
            hoverOri.Responsiveness = 1/0
            hoverOri.MaxTorque = 1/0
            hoverOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
            hoverOri.Parent = hrp2
            hoverOriAtt = Instance.new("Attachment")
            hoverOriAtt.Parent = hrp2
            hoverOri.Attachment0 = hoverOriAtt
        end
        local cam2 = ws.CurrentCamera
        if not cam2 then
            return
        end
        local cf = cam2.CFrame
        local _, y = cf:ToOrientation()
        hoverOri.CFrame = CFrame.fromOrientation(0, y, 0)
        local tgt = st.hoverTarget or hrp2.Position
        local yPos = st.hoverY or tgt.Y
        hoverAlign.Position = Vector3.new(tgt.X, yPos, tgt.Z)
    end

    local function removeHoverAlign()
        if hoverAlign then
            pcall(function()
                hoverAlign:Destroy()
            end)
            hoverAlign = nil
        end
        if hoverAtt then
            pcall(function()
                hoverAtt:Destroy()
            end)
            hoverAtt = nil
        end
        if hoverOri then
            pcall(function()
                hoverOri:Destroy()
            end)
            hoverOri = nil
        end
        if hoverOriAtt then
            pcall(function()
                hoverOriAtt:Destroy()
            end)
            hoverOriAtt = nil
        end
    end

    local function toggleAnchor()
        if st.anchorOn then
            local data = st.anchorData
            if data and data.frozen and not data.unfrozenOnce then
                data.frozen = false
                data.unfrozenOnce = true
                local hrp2 = data.hrp
                if hrp2 and hrp2.Parent then
                    local sv = data.savedVel or Vector3.zero
                    local srv = data.savedRotVel or Vector3.zero
                    hrp2.AssemblyLinearVelocity = sv
                    hrp2.AssemblyAngularVelocity = srv
                    hrp2.RotVelocity = srv
                    hrp2.Velocity = sv
                end
                local hum = data.hum
                if hum and hum.Parent then
                    for _, t2 in ipairs(hum:GetPlayingAnimationTracks()) do
                        t2:Stop()
                    end
                end
                if data.hb and data.hb.Connected then
                    data.hb:Disconnect()
                end
            end
            st.anchorOn = false
            st.anchorData = nil
        else
            local c = getChar()
            local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not c or not hrp2 or not hum then
                st.anchorOn = false
                st.anchorData = nil
                updAnchorBtn()
                return
            end
            local data = {
                char = c,
                hrp = hrp2,
                hum = hum,
                frozen = true,
                unfrozenOnce = false,
                savedVel = hrp2.AssemblyLinearVelocity,
                savedRotVel = hrp2.AssemblyAngularVelocity,
                freezeCF = hrp2.CFrame,
            }
            data.hb = addConn(R.Heartbeat:Connect(function()
                if destroyed then
                    return
                end
                if not st.anchorOn then
                    return
                end
                if data.frozen ~= true then
                    return
                end
                local h = data.hrp
                local hm = data.hum
                if not h or not hm or not h.Parent or not hm.Parent then
                    return
                end
                h.AssemblyAngularVelocity = Vector3.zero
                h.AssemblyLinearVelocity = Vector3.zero
                h.RotVelocity = Vector3.zero
                h.Velocity = Vector3.zero
                h.CFrame = data.freezeCF
                for _, t2 in ipairs(hm:GetPlayingAnimationTracks()) do
                    t2:AdjustSpeed(0)
                end
            end))
            st.anchorData = data
            st.anchorOn = true
        end
        updAnchorBtn()
    end

    local function toggleAntiVoid()
        st.antiVoidOn = not st.antiVoidOn
        if st.antiVoidOn then
            st.antiVoidSaved = ws.FallenPartsDestroyHeight
        else
            local ok, v = pcall(function()
                return st.antiVoidSaved
            end)
            if ok and v ~= nil then
                ws.FallenPartsDestroyHeight = v
            end
        end
        updAntiVoidBtn()
    end

    local function updateAntiVoid()
        if st.antiVoidOn then
            ws.FallenPartsDestroyHeight = 0/0
        end
    end

    local function toggleAntiFling()
        st.antiFlingOn = not st.antiFlingOn
        if not st.antiFlingOn then
            for p2, v in pairs(st.antiFlingSaved) do
                if p2 and p2.Parent then
                    p2.CanCollide = v
                end
            end
            st.antiFlingSaved = {}
        end
        updAntiFlingBtn()
    end

    local function updateAntiFling()
        if not st.antiFlingOn then
            return
        end
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= lp then
                local c = pl.Character
                if c then
                    for _, p2 in ipairs(c:GetDescendants()) do
                        if p2:IsA("BasePart") and p2.Name ~= FLOAT_NAME then
                            if st.antiFlingSaved[p2] == nil then
                                st.antiFlingSaved[p2] = p2.CanCollide
                            end
                            if p2.CanCollide then
                                p2.CanCollide = false
                            end
                        end
                    end
                end
            end
        end
    end

    local touchRunning = false
    local touchStopRequested = false
    local touchThread

    local function touchLoop()
        touchRunning = true
        local movel = 0
        while not destroyed and not touchStopRequested do
            R.Heartbeat:Wait()
            if destroyed or touchStopRequested then
                break
            end
            local c = getChar()
            local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
            if hrp2 then
                local vel = hrp2.Velocity
                hrp2.Velocity = Vector3.new(0, 340282356779733642748073463979561713663, 0)
                R.RenderStepped:Wait()
                if destroyed or touchStopRequested then
                    hrp2.Velocity = vel
                    break
                end
                hrp2.Velocity = vel + Vector3.new(0, movel, 0)
                movel = -movel
            end
        end
        touchRunning = false
        touchStopRequested = false
    end

    local function toggleTouchFling()
        if st.touchFlingOn then
            st.touchFlingOn = false
            touchStopRequested = true
        else
            st.touchFlingOn = true
            if not touchRunning then
                touchStopRequested = false
                touchThread = coroutine.create(touchLoop)
                coroutine.resume(touchThread)
            end
        end
        updTouchFlingBtn()
    end

    local function toggleFlyJump()
        st.flyJumpOn = not st.flyJumpOn
        updFlyJumpBtn()
    end

    local function setFlyMode(m)
        local prev = st.flyMode
        if prev == m then
            m = "none"
        end

        local c = getChar()
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
        local savedLook

        if prev == "fly" and hrp2 then
            savedLook = hrp2.CFrame.LookVector
        end

        st.flyMode = m

        if m == "none" then
            if hum then
                hum.Sit = false
            end
            if savedLook and hrp2 and hum then
                hum.AutoRotate = false
                local pos = hrp2.Position
                hrp2.CFrame = CFrame.new(pos, pos + savedLook)
                task.delay(0.1, function()
                    if destroyed then
                        return
                    end
                    local c2 = getChar()
                    local hum2 = c2 and c2:FindFirstChildOfClass("Humanoid")
                    if hum2 then
                        hum2.AutoRotate = true
                    end
                end)
            elseif hum then
                hum.AutoRotate = true
            end
            st.flyPos = nil
            st.hoverTarget = nil
            st.hoverY = nil
            st.velAnchorPos = nil
            removeHoverAlign()
        elseif m == "fly" then
            if hum then
                hum.Sit = true
                hum.AutoRotate = false
            end
            st.hoverTarget = nil
            st.hoverY = nil
            st.velAnchorPos = nil
            removeHoverAlign()
            st.flyPos = hrp2 and hrp2.Position or nil
        elseif m == "hover" then
            if hum then
                hum.Sit = true
                hum.AutoRotate = true
            end
            st.flyPos = nil
            st.velAnchorPos = nil
            if hrp2 then
                st.hoverTarget = hrp2.Position
                st.hoverY = hrp2.Position.Y
                createHoverAlign(hrp2)
            end
        elseif m == "vel" then
            if hum then
                hum.Sit = true
                hum.AutoRotate = true
            end
            st.flyPos = nil
            st.hoverTarget = nil
            st.hoverY = nil
            removeHoverAlign()
            st.velAnchorPos = hrp2 and hrp2.Position or nil
        end

        updFlyBtns()
    end

    local function getAdornee(c)
        if not c or not c.Parent then
            return nil
        end
        local hrp2 = c:FindFirstChild("HumanoidRootPart")
        if hrp2 and hrp2:IsA("BasePart") then
            return hrp2
        end
        if c.PrimaryPart and c.PrimaryPart:IsA("BasePart") then
            return c.PrimaryPart
        end
        local h = c:FindFirstChild("Head")
        if h and h:IsA("BasePart") then
            return h
        end
        for _, ch in ipairs(c:GetChildren()) do
            if ch:IsA("BasePart") then
                return ch
            end
        end
        return nil
    end

    local function healthColor(r)
        if r >= 0.8 then
            return Color3.fromRGB(120, 230, 120)
        elseif r >= 0.6 then
            return Color3.fromRGB(230, 230, 120)
        elseif r >= 0.4 then
            return Color3.fromRGB(255, 170, 80)
        elseif r > 0 then
            return Color3.fromRGB(230, 120, 120)
        else
            return Color3.fromRGB(0, 0, 0)
        end
    end

    local function buildNameGui(b)
        b:ClearAllChildren()
        b.Size = UDim2.new(0, 190, 0, 72)
        b.StudsOffset = Vector3.new(0, 3.5, 0)
        b.SizeOffset = Vector2.new(0, 1)
        b.AlwaysOnTop = true
        b.MaxDistance = 0

        local mainF = Instance.new("Frame")
        mainF.Name = "MainFrame"
        mainF.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        mainF.BackgroundTransparency = 0.15
        mainF.BorderSizePixel = 0
        mainF.Size = UDim2.new(1, 0, 1, 0)
        mainF.Parent = b

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = mainF

        local top = Instance.new("Frame")
        top.Name = "TopFrame"
        top.BackgroundTransparency = 1
        top.BorderSizePixel = 0
        top.Size = UDim2.new(1, -16, 0.45, 0)
        top.Position = UDim2.new(0, 8, 0, 4)
        top.Parent = mainF

        local dName = Instance.new("TextLabel")
        dName.Name = "DisplayName"
        dName.BackgroundTransparency = 1
        dName.BorderSizePixel = 0
        dName.Size = UDim2.new(0.6, 0, 0.5, 0)
        dName.TextColor3 = Color3.new(1, 1, 1)
        dName.Font = Enum.Font.Code
        dName.TextScaled = true
        dName.TextXAlignment = Enum.TextXAlignment.Left
        dName.TextYAlignment = Enum.TextYAlignment.Center
        dName.Parent = top

        local uName = Instance.new("TextLabel")
        uName.Name = "Username"
        uName.BackgroundTransparency = 1
        uName.BorderSizePixel = 0
        uName.Size = UDim2.new(0.6, 0, 0.5, 0)
        uName.Position = UDim2.new(0, 0, 0.5, 0)
        uName.TextColor3 = Color3.fromRGB(180, 180, 200)
        uName.Font = Enum.Font.Code
        uName.TextScaled = true
        uName.TextXAlignment = Enum.TextXAlignment.Left
        uName.TextYAlignment = Enum.TextYAlignment.Center
        uName.Parent = top

        local hLbl = Instance.new("TextLabel")
        hLbl.Name = "HealthLabel"
        hLbl.BackgroundTransparency = 1
        hLbl.BorderSizePixel = 0
        hLbl.Size = UDim2.new(0.35, -4, 0.3, 0)
        hLbl.Position = UDim2.new(0.65, 0, 0, 4)
        hLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
        hLbl.Font = Enum.Font.Code
        hLbl.TextScaled = true
        hLbl.TextXAlignment = Enum.TextXAlignment.Right
        hLbl.TextYAlignment = Enum.TextYAlignment.Center
        hLbl.Parent = mainF

        local bottom = Instance.new("Frame")
        bottom.Name = "BottomFrame"
        bottom.BackgroundTransparency = 1
        bottom.BorderSizePixel = 0
        bottom.Size = UDim2.new(1, -16, 0.45, 0)
        bottom.Position = UDim2.new(0, 8, 0.5, 0)
        bottom.Parent = mainF

        local hBg = Instance.new("Frame")
        hBg.Name = "HealthBackground"
        hBg.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
        hBg.BorderSizePixel = 0
        hBg.Size = UDim2.new(0.6, 0, 0.4, 0)
        hBg.Position = UDim2.new(0, 16, 0, 4)
        hBg.Parent = bottom

        local hBgC = Instance.new("UICorner")
        hBgC.CornerRadius = UDim.new(0, 4)
        hBgC.Parent = hBg

        local hFill = Instance.new("Frame")
        hFill.Name = "HealthFill"
        hFill.BackgroundColor3 = Color3.fromRGB(120, 230, 120)
        hFill.BorderSizePixel = 0
        hFill.Size = UDim2.new(1, 0, 1, 0)
        hFill.Parent = hBg

        local hFillC = Instance.new("UICorner")
        hFillC.CornerRadius = UDim.new(0, 4)
        hFillC.Parent = hFill

        local tLbl = Instance.new("TextLabel")
        tLbl.Name = "TeamLabel"
        tLbl.BackgroundTransparency = 1
        tLbl.BorderSizePixel = 0
        tLbl.Size = UDim2.new(1, 0, 0.4, 0)
        tLbl.Position = UDim2.new(0, 0, 0.5, 0)
        tLbl.TextColor3 = Color3.fromRGB(200, 200, 255)
        tLbl.Font = Enum.Font.Code
        tLbl.TextScaled = true
        tLbl.TextXAlignment = Enum.TextXAlignment.Left
        tLbl.TextYAlignment = Enum.TextYAlignment.Center
        tLbl.Parent = bottom
    end

    local function ensureNameEsp(c, pl)
        if not c or not c.Parent then
            return
        end
        local ad = getAdornee(c)
        if not ad then
            return
        end
        local bb
        for _, v in ipairs(c:GetChildren()) do
            if v:IsA("BillboardGui") and v.Name == "NameESP" then
                bb = v
                break
            end
        end
        if not bb then
            bb = Instance.new("BillboardGui")
            bb.Name = "NameESP"
            bb.Parent = c
        end
        buildNameGui(bb)
        bb.Adornee = ad
        local mainF = bb:FindFirstChild("MainFrame")
        if not mainF or not mainF:IsA("Frame") then
            return
        end
        local top = mainF:FindFirstChild("TopFrame")
        local bottom = mainF:FindFirstChild("BottomFrame")
        local dName = top and top:FindFirstChild("DisplayName")
        local uName = top and top:FindFirstChild("Username")
        local hLbl = mainF:FindFirstChild("HealthLabel")
        local hBg = bottom and bottom:FindFirstChild("HealthBackground")
        local hFill = hBg and hBg:FindFirstChild("HealthFill")
        local tLbl = bottom and bottom:FindFirstChild("TeamLabel")

        if dName and dName:IsA("TextLabel") then
            dName.Text = pl.DisplayName
        end
        if uName and uName:IsA("TextLabel") then
            uName.Text = "@ " .. pl.Name
        end

        local hum = c:FindFirstChildOfClass("Humanoid")
        local hNow, hMax = 0, 0
        if hum then
            hNow = math.max(0, hum.Health)
            hMax = math.max(1, hum.MaxHealth)
        end
        local r = 0
        if hMax > 0 then
            r = math.clamp(hNow / hMax, 0, 1)
        end
        if hLbl and hLbl:IsA("TextLabel") then
            hLbl.Text = string.format("%d/%d", hNow, hMax)
        end
        local col = healthColor(r)
        if hFill and hFill:IsA("Frame") then
            hFill.Size = UDim2.new(r, 0, 1, 0)
            hFill.BackgroundColor3 = col
        end
        if tLbl and tLbl:IsA("TextLabel") then
            local tName = "Team: None"
            local tColor = Color3.fromRGB(200, 200, 255)
            if pl.Team then
                tName = "Team: " .. pl.Team.Name
                if pl.TeamColor then
                    tColor = pl.TeamColor.Color
                end
            end
            tLbl.Text = tName
            tLbl.TextColor3 = tColor
        end
    end

    local function clearNameEsp()
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= lp then
                local c = pl.Character
                if c then
                    for _, v in ipairs(c:GetChildren()) do
                        if v:IsA("BillboardGui") and v.Name == "NameESP" then
                            v:Destroy()
                        end
                    end
                end
            end
        end
    end

    local function ensureMiniEsp(c, pl)
        if not c or not c.Parent then
            return
        end
        local head = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
        if not head then
            return
        end
        local bb
        for _, v in ipairs(c:GetChildren()) do
            if v:IsA("BillboardGui") and v.Name == "MiniESP" then
                bb = v
                break
            end
        end
        if not bb then
            bb = Instance.new("BillboardGui")
            bb.Name = "MiniESP"
            bb.Size = UDim2.new(0, 280, 0, 30)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.MaxDistance = 0
            bb.Parent = c
            local lbl = Instance.new("TextLabel")
            lbl.Name = "Name"
            lbl.BackgroundTransparency = 1
            lbl.BorderSizePixel = 0
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.Font = Enum.Font.Code
            lbl.TextColor3 = Color3.new(1, 1, 1)
            lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
            lbl.TextStrokeTransparency = 0
            lbl.TextScaled = false
            lbl.TextSize = 24
            lbl.TextWrapped = false
            lbl.Parent = bb
        end
        bb.Adornee = head
        local lbl2 = bb:FindFirstChild("Name")
        if lbl2 and lbl2:IsA("TextLabel") then
            lbl2.Text = pl.DisplayName
        end
    end

    local function clearMiniEsp()
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= lp then
                local c = pl.Character
                if c then
                    for _, v in ipairs(c:GetChildren()) do
                        if v:IsA("BillboardGui") and v.Name == "MiniESP" then
                            v:Destroy()
                        end
                    end
                end
            end
        end
    end

    local function updateEsp(dt)
        if not st.espOn and not st.miniEspOn then
            return
        end
        st.espTimer += dt
        if st.espTimer < st.espInterval then
            return
        end
        st.espTimer = 0
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= lp then
                local c = pl.Character
                if c then
                    if st.espOn then
                        ensureNameEsp(c, pl)
                    end
                    if st.miniEspOn then
                        ensureMiniEsp(c, pl)
                    end
                end
            end
        end
    end

    local function toggleESP()
        if st.espOn then
            st.espOn = false
            clearNameEsp()
        else
            st.espOn = true
            if st.miniEspOn then
                st.miniEspOn = false
                clearMiniEsp()
            end
        end
        updEspBtn()
        updMiniEspBtn()
    end

    local function toggleMiniESP()
        if st.miniEspOn then
            st.miniEspOn = false
            clearMiniEsp()
        else
            st.miniEspOn = true
            if st.espOn then
                st.espOn = false
                clearNameEsp()
            end
        end
        updEspBtn()
        updMiniEspBtn()
    end

    local function sRound(n)
        if n >= 0 then
            return math.floor(n + 0.5)
        else
            return math.ceil(n - 0.5)
        end
    end

    local function pushPing(now, v)
        local q = st.pingQ
        local h = st.pingHead
        local t2 = st.pingTail + 1
        q[t2] = { t = now, v = v }
        st.pingTail = t2
        st.pingSum += v
        local cutoff = now - 5
        while h <= t2 and q[h] and q[h].t < cutoff do
            st.pingSum -= q[h].v
            q[h] = nil
            h += 1
        end
        st.pingHead = h
    end

    local function avgPing()
        local h = st.pingHead
        local t2 = st.pingTail
        local count = t2 - h + 1
        if count > 0 then
            return st.pingSum / count
        end
        return 0
    end

    local function pushFps(now, v)
        local q = st.fpsQ
        local h = st.fpsHead
        local t2 = st.fpsTail + 1
        q[t2] = { t = now, v = v }
        st.fpsTail = t2
        st.fpsSum += v
        local cutoff = now - 5
        while h <= t2 and q[h] and q[h].t < cutoff do
            st.fpsSum -= q[h].v
            q[h] = nil
            h += 1
        end
        st.fpsHead = h
    end

    local function avgFps()
        local h = st.fpsHead
        local t2 = st.fpsTail
        local count = t2 - h + 1
        if count > 0 then
            return st.fpsSum / count
        end
        return 0
    end

    local function readPing()
        local ok, v = pcall(function()
            return ST.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if ok and typeof(v) == "number" then
            return v
        end
        local ok2, s = pcall(function()
            return ST.Network.ServerStatsItem["Data Ping"]:GetValueString()
        end)
        if ok2 and typeof(s) == "string" then
            local n = tonumber((s:gsub("[^%d%.]", "")))
            if n then
                return n
            end
        end
        local ps = ST:FindFirstChild("PerformanceStats")
        if ps and ps:FindFirstChild("Ping") then
            local item = ps.Ping
            local ok3, v3 = pcall(function()
                return item:GetValue()
            end)
            if ok3 and typeof(v3) == "number" then
                return v3
            end
            local ok4, s4 = pcall(function()
                return item:GetValueString()
            end)
            if ok4 and typeof(s4) == "string" then
                local n2 = tonumber((s4:gsub("[^%d%.]", "")))
                if n2 then
                    return n2
                end
            end
        end
        return 0
    end

    local function getPos()
        local c = getChar()
        if c and c.Parent then
            local hrp2 = c:FindFirstChild("HumanoidRootPart")
            if hrp2 and hrp2.Parent then
                local p2 = hrp2.Position
                return p2.X, p2.Y, p2.Z
            end
            local cf = c:GetPivot()
            local p2 = cf.Position
            return p2.X, p2.Y, p2.Z
        end
        local cam2 = ws.CurrentCamera
        if cam2 then
            local p2 = cam2.CFrame.Position
            return p2.X, p2.Y, p2.Z
        end
        return 0, 0, 0
    end

    local function tryClipboard(s)
        local ok = false
        if typeof(setclipboard) == "function" then
            ok = pcall(function()
                setclipboard(s)
            end)
            if ok then
                return true
            end
        end
        local GSvc = game:GetService("GuiService")
        if GSvc and GSvc.SetClipboard then
            ok = pcall(function()
                GSvc:SetClipboard(s)
            end)
            if ok then
                return true
            end
        end
        local ok2, studio = pcall(function()
            return game:GetService("StudioService")
        end)
        if ok2 and studio and studio.CopyToClipboard then
            ok = pcall(function()
                studio:CopyToClipboard(s)
            end)
            if ok then
                return true
            end
        end
        return false
    end

    local function createStatusGui()
        if st.statusGui then
            st.statusGui:Destroy()
            st.statusGui = nil
        end
        local sg = Instance.new("ScreenGui")
        sg.Name = "MinimalPerfHUD"
        sg.IgnoreGuiInset = true
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.DisplayOrder = 2147483647
        sg.Parent = uiParent
        st.statusGui = sg

        local hud = Instance.new("Frame")
        hud.Name = "HUDContainer"
        hud.BackgroundTransparency = 1
        hud.AnchorPoint = Vector2.new(0.5, 0)
        hud.Position = UDim2.new(0.5, 0, 0, 6)
        hud.Size = UDim2.new(0, 680, 0, 60)
        hud.Parent = sg

        local btn = Instance.new("TextButton")
        btn.Name = "CopyPosButton"
        btn.AutoButtonColor = false
        btn.Text = "📋"
        btn.Font = Enum.Font.Code
        btn.TextSize = 16
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextStrokeColor3 = Color3.new(0, 0, 0)
        btn.TextStrokeTransparency = 0
        btn.BackgroundColor3 = Color3.new(1, 1, 1)
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(0, 22, 0, 22)
        btn.Position = UDim2.new(0, 0, 0, 0)
        btn.Parent = hud

        local lbl = Instance.new("TextLabel")
        lbl.Name = "HUDText"
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        lbl.TextStrokeTransparency = 0
        lbl.Font = Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.TextWrapped = false
        lbl.TextScaled = false
        lbl.TextSize = 14
        lbl.AnchorPoint = Vector2.new(0, 0)
        lbl.Position = UDim2.new(0, 28, 0, 0)
        lbl.Size = UDim2.new(1, -28, 1, 0)
        lbl.RichText = false
        lbl.Parent = hud

        st.statusLabel = lbl

        local locked = false
        btn.Activated:Connect(function()
            if locked then
                return
            end
            locked = true
            local x, y, z = getPos()
            local txt = string.format("%d, %d, %d", sRound(x), sRound(y), sRound(z))
            tryClipboard(txt)
            btn.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
            btn.Text = "✅"
            task.delay(2, function()
                if not btn or not btn.Parent then
                    return
                end
                btn.BackgroundColor3 = Color3.new(1, 1, 1)
                btn.Text = "📋"
                locked = false
            end)
        end)
    end

    local function updateStatus(dt)
        if not st.statusOn or not st.statusLabel or not st.statusLabel.Parent then
            return
        end
        local now = time()
        local x, y, z = getPos()
        local pingNow = readPing()
        pushPing(now, pingNow)
        st.statusFpsFrames += 1
        if now - st.statusFpsStart >= 1 then
            st.statusFpsNow = st.statusFpsFrames / (now - st.statusFpsStart)
            pushFps(now, st.statusFpsNow)
            st.statusFpsFrames = 0
            st.statusFpsStart = now
        end
        local c = getChar()
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local spd, jmp = 0, 0
        if hum then
            spd = hum.WalkSpeed or 0
            jmp = hum.JumpPower or 0
        end
        local txt = "pos: " .. string.format("%d, %d, %d", sRound(x), sRound(y), sRound(z))
            .. "\nping: now:" .. string.format("%.0f", pingNow) .. " avg:" .. string.format("%.0f", avgPing())
            .. "\nfps: now:" .. string.format("%.0f", st.statusFpsNow) .. " avg:" .. string.format("%.0f", avgFps())
            .. "\nspeed: " .. string.format("%.0f", spd)
            .. "\njump: " .. string.format("%.0f", jmp)
        st.statusLabel.Text = txt
    end

    local function toggleStatus()
        st.statusOn = not st.statusOn
        if st.statusOn then
            createStatusGui()
        else
            if st.statusGui then
                st.statusGui:Destroy()
                st.statusGui = nil
                st.statusLabel = nil
            end
        end
        updStatusBtn()
    end

    local function readNumber(tb, fallback)
        local pf = tb:GetAttribute("Prefix") or ""
        local tx = tb.Text or ""
        local num = tx:sub(#pf + 1)
        local v = tonumber(num)
        if v then
            return v
        end
        return fallback
    end

    local function parseFogColor()
        local tb = refs.fogColorInput
        local pf = tb:GetAttribute("Prefix") or ""
        local tx = tb.Text or ""
        local v = tx:sub(#pf + 1)
        local nums = {}
        for n in string.gmatch(v, "%d+") do
            nums[#nums + 1] = tonumber(n)
        end
        if #nums >= 3 then
            local r = math.clamp(nums[1] or 255, 0, 255)
            local g2 = math.clamp(nums[2] or 255, 0, 255)
            local b2 = math.clamp(nums[3] or 255, 0, 255)
            st.fogColor = Color3.fromRGB(r, g2, b2)
            tb.Text = pf .. string.format("%d %d %d", r, g2, b2)
        else
            st.fogColor = defaultFogColor
            tb.Text = pf .. defaultFogColorStr
        end
    end

    local function parseFogStart()
        local tb = refs.fogStartInput
        local n = readNumber(tb, st.fogStart)
        st.fogStart = n
        local pf = tb:GetAttribute("Prefix") or ""
        tb.Text = pf .. tostring(n)
    end

    local function parseFogEnd()
        local tb = refs.fogEndInput
        local n = readNumber(tb, st.fogEnd)
        st.fogEnd = n
        local pf = tb:GetAttribute("Prefix") or ""
        tb.Text = pf .. tostring(n)
    end

    local function applyFullBright()
        L.Brightness = 2
        L.ClockTime = 14
        L.FogEnd = 100000
        L.GlobalShadows = false
        L.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end

    local function applyResetCamera()
        local cam2 = ws.CurrentCamera
        if not cam2 then
            return
        end
        cam2.CameraType = Enum.CameraType.Custom
        lp.CameraMaxZoomDistance = 1000
        lp.CameraMinZoomDistance = 0
        cam2.FieldOfView = 70
    end

    local function applyLoops()
        local cam2 = ws.CurrentCamera
        if st.fovLoop and cam2 then
            cam2.FieldOfView = st.fovValue
        end
        if st.speedLoop then
            local c = getChar()
            local hum = c and c:FindFirstChildWhichIsA("Humanoid")
            if hum then
                hum.WalkSpeed = st.speedValue
            end
        end
        if st.jumpLoop then
            local c = getChar()
            local hum = c and c:FindFirstChildWhichIsA("Humanoid")
            if hum then
                if hum.UseJumpPower ~= false then
                    hum.UseJumpPower = true
                    hum.JumpPower = st.jumpValue
                else
                    hum.JumpHeight = st.jumpValue
                end
            end
        end
        if st.maxZoomLoop and not st.noMaxZoomOn then
            lp.CameraMaxZoomDistance = st.maxZoomValue
        end
        if st.minZoomLoop and not st.noMinZoomOn then
            lp.CameraMinZoomDistance = st.minZoomValue
        end
        if st.noMaxZoomOn then
            lp.CameraMaxZoomDistance = 1/0
        end
        if st.noMinZoomOn then
            lp.CameraMinZoomDistance = -1/0
        end
        if st.gravLoop then
            ws.Gravity = st.gravValue
        end
        if st.fogLoop and not st.noFogOn then
            L.FogColor = st.fogColor
            L.FogStart = st.fogStart
            L.FogEnd = st.fogEnd
        end
        if st.noFogOn then
            L.FogEnd = 1/0
            for _, v in ipairs(L:GetChildren()) do
                if v:IsA("Atmosphere") then
                    v:Destroy()
                end
            end
        end
        if st.fullBrightLoopOn then
            applyFullBright()
        end
        if st.resetCamLoopOn then
            applyResetCamera()
        end
    end

    local function updateFly(dt)
        if st.flyMode == "none" then
            return
        end
        if st.desyncOn or st.desyncPosOn then
            return
        end
        local c = getChar()
        local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local cam2 = ws.CurrentCamera
        if not hrp2 or not hum or not cam2 then
            return
        end

        hum.Sit = true

        local cf = cam2.CFrame
        local look = cf.LookVector
        local right = cf.RightVector
        local up = cf.UpVector

        if st.flyMode == "fly" then
            if not st.flyPos then
                st.flyPos = hrp2.Position
            end

            hrp2.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp2.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

            local move = hum.MoveDirection
            local dir = Vector3.new(0, 0, 0)

            if move.Magnitude > 0 then
                local localDir = cf:VectorToObjectSpace(move)
                dir = cf.LookVector * (-localDir.Z) + cf.RightVector * localDir.X
            end

            if st.moveKeys.E then
                dir += up
            end
            if st.moveKeys.Q then
                dir -= up
            end

            if dir.Magnitude > 0 then
                dir = dir.Unit
                st.flyPos = st.flyPos + dir * st.flySpeed * dt
            end

            hrp2.CFrame = CFrame.new(st.flyPos)
        elseif st.flyMode == "hover" then
            if not st.hoverTarget then
                st.hoverTarget = hrp2.Position
            end
            if not st.hoverY then
                st.hoverY = hrp2.Position.Y
            end

            local look2 = cf.LookVector
            local right2 = cf.RightVector
            local flatF = Vector3.new(look2.X, 0, look2.Z)
            local flatR = Vector3.new(right2.X, 0, right2.Z)
            if flatF.Magnitude > 0 then
                flatF = flatF.Unit
            end
            if flatR.Magnitude > 0 then
                flatR = flatR.Unit
            end
            local up2 = Vector3.new(0, 1, 0)

            local mv = Vector3.new(0, 0, 0)
            if st.moveKeys.W then
                mv += flatF
            end
            if st.moveKeys.S then
                mv -= flatF
            end
            if st.moveKeys.D then
                mv += flatR
            end
            if st.moveKeys.A then
                mv -= flatR
            end
            if st.moveKeys.E then
                mv += up2
            end
            if st.moveKeys.Q then
                mv -= up2
            end

            if mv.Magnitude > 0 then
                mv = mv.Unit * st.flySpeed * dt
                st.hoverTarget = st.hoverTarget + mv
                st.hoverY = st.hoverTarget.Y
            end

            createHoverAlign(hrp2)
        elseif st.flyMode == "vel" then
            if not st.velAnchorPos then
                st.velAnchorPos = hrp2.Position
            end

            local move = hum.MoveDirection
            local dir = Vector3.new(0, 0, 0)

            if move.Magnitude > 0 then
                local localDir = cf:VectorToObjectSpace(move)
                dir = cf.LookVector * (-localDir.Z) + cf.RightVector * localDir.X
            end

            if st.moveKeys.E then
                dir += up
            end
            if st.moveKeys.Q then
                dir -= up
            end

            if dir.Magnitude > 0 then
                dir = dir.Unit * st.flySpeed * dt
                st.velAnchorPos = st.velAnchorPos + dir
            end

            local diff = st.velAnchorPos - hrp2.Position
            local dist = diff.Magnitude
            local v = Vector3.new(0, 0, 0)
            if dist > 0 then
                local d2 = diff / dist
                local damp = st.velDamping or 50
                v = d2 * dist * damp
            end

            hrp2.AssemblyLinearVelocity = v
            hrp2.Velocity = v

            local curRot = hrp2.CFrame.Rotation
            local targetRot = cf.Rotation
            local delta = targetRot * curRot:Inverse()
            local axis, angle = delta:ToAxisAngle()
            local deg = math.deg(angle)
            local angVel = Vector3.new(0, 0, 0)
            if deg > 0.01 then
                local mag = deg
                angVel = axis * mag
            end
            hrp2.AssemblyAngularVelocity = angVel
            hrp2.RotVelocity = angVel
        end
    end

    local function updateChat()
        local tcs = S(game, "TextChatService")
        if not tcs then
            return
        end
        local cfg = tcs.ChatWindowConfiguration
        if not cfg then
            return
        end
        local desired = st.chatOn
        if cfg.Enabled ~= desired then
            cfg.Enabled = desired
        end
    end

    local function parseTpPos()
        local tb = refs.tpPosInput
        local pf = tb:GetAttribute("Prefix") or ""
        local tx = tb.Text or ""
        local body = tx:sub(#pf + 1)
        local nums = {}
        for token in string.gmatch(body, "[^%s]+") do
            local v = tonumber(token)
            if v then
                nums[#nums + 1] = v
            end
        end
        if #nums >= 3 then
            local x, y, z = nums[1], nums[2], nums[3]
            st.tpPos = Vector3.new(x, y, z)
            tb.Text = pf .. string.format("%.2f %.2f %.2f", x, y, z)
        end
    end

    local function toggleNoMaxZoom()
        st.noMaxZoomOn = not st.noMaxZoomOn
        if st.noMaxZoomOn then
            st.noMaxZoomSaved = lp.CameraMaxZoomDistance
            if st.maxZoomLoop then
                st.maxZoomLoop = false
                updLoopMaxZoomBtn()
            end
        else
            if st.noMaxZoomSaved ~= nil then
                lp.CameraMaxZoomDistance = st.noMaxZoomSaved
            end
        end
        updNoMaxZoomBtn()
    end

    local function toggleNoMinZoom()
        st.noMinZoomOn = not st.noMinZoomOn
        if st.noMinZoomOn then
            st.noMinZoomSaved = lp.CameraMinZoomDistance
            if st.minZoomLoop then
                st.minZoomLoop = false
                updLoopMinZoomBtn()
            end
        else
            if st.noMinZoomSaved ~= nil then
                lp.CameraMinZoomDistance = st.noMinZoomSaved
            end
        end
        updNoMinZoomBtn()
    end

    local function updateFlingTargetFromInput()
        local tb = refs.flingTargetInput
        if not tb then
            return
        end
        local pf = tb:GetAttribute("Prefix") or ""
        local tx = tb.Text or ""
        local body = tx:sub(#pf + 1)
        body = body:gsub("^%s+", ""):gsub("%s+$", "")
        if body == "" then
            st.flingTarget = nil
            updFlingTargetDisplay()
            return
        end
        local lower = string.lower(body)
        local candidates = {}
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= lp and pl.Name and string.find(string.lower(pl.Name), lower, 1, true) then
                candidates[#candidates + 1] = pl
            end
        end
        local target = nil
        if #candidates == 1 then
            target = candidates[1]
        elseif #candidates == 0 then
            local c2 = {}
            for _, pl in ipairs(P:GetPlayers()) do
                if pl ~= lp and pl.DisplayName and string.find(string.lower(pl.DisplayName), lower, 1, true) then
                    c2[#c2 + 1] = pl
                end
            end
            if #c2 == 1 then
                target = c2[1]
            end
        end
        st.flingTarget = target
        updFlingTargetDisplay()
    end

    local function parseDesyncPosInput()
        local tb = refs.desyncPosInput
        if not tb then
            return
        end
        local pf = tb:GetAttribute("Prefix") or ""
        local tx = tb.Text or ""
        local body = tx:sub(#pf + 1)
        local nums = {}
        for token in string.gmatch(body, "[^%s]+") do
            local v = tonumber(token)
            if v then
                nums[#nums + 1] = v
            end
        end
        if #nums >= 3 then
            local x, y, z = nums[1], nums[2], nums[3]
            st.desyncPosTarget = Vector3.new(x, y, z)
            tb.Text = pf .. string.format("%.2f %.2f %.2f", x, y, z)
        else
            st.desyncPosTarget = nil
        end
    end

    local function stylizeDesyncPart(part)
        part.Anchored = false
        part.CanCollide = false
        part.Massless = true
        part.Material = Enum.Material.ForceField
        part.Color = Color3.new(1, 0, 0)
    end

    local function createDesyncDummy(original)
        if st.desyncDummy then
            st.desyncDummy:Destroy()
            st.desyncDummy = nil
            st.desyncDummyRoot = nil
            st.desyncDummyMotorMap = {}
            st.desyncSourceChar = nil
        end
        if not original then
            return
        end
        if not original.Archivable then
            original.Archivable = true
        end
        local d = original:Clone()
        d.Name = "DesyncDummy"
        d.Parent = ws
        st.desyncDummy = d
        st.desyncSourceChar = original
        st.desyncDummyMotorMap = {}
        for _, v in ipairs(d:GetDescendants()) do
            if v:IsA("BasePart") then
                stylizeDesyncPart(v)
            elseif v:IsA("Humanoid") then
                v.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            elseif v:IsA("Animator") or v:IsA("AnimationController") then
                v:Destroy()
            elseif v:IsA("Motor6D") then
                local origMotor = original:FindFirstChild(v.Name, true)
                if origMotor and origMotor:IsA("Motor6D") then
                    st.desyncDummyMotorMap[v] = origMotor
                end
            end
        end
        st.desyncDummyRoot = d:FindFirstChild("HumanoidRootPart")
    end

    local function applyDesyncMaterials()
        local char = lp.Character
        if not char then
            return
        end
        local saved = st.desyncMaterialSaved
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                if saved[v] == nil then
                    saved[v] = v.Material
                end
                if v.Material ~= Enum.Material.ForceField then
                    v.Material = Enum.Material.ForceField
                end
            end
        end
    end

    local function restoreDesyncMaterials()
        local saved = st.desyncMaterialSaved
        for part, mat in pairs(saved) do
            if part and part.Parent then
                part.Material = mat
            end
        end
        for k in pairs(saved) do
            saved[k] = nil
        end
    end

    local function resetDesyncChar()
        local char = lp.Character
        if not char then
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then
            return
        end
        if st.desyncRealCF then
            root.CFrame = st.desyncRealCF
        end
        if st.desyncRealVel then
            root.AssemblyLinearVelocity = st.desyncRealVel
        end
        if st.desyncRealRotVel then
            root.AssemblyAngularVelocity = st.desyncRealRotVel
        end
    end

    local function updateDesync()
        if not (st.desyncOn or st.desyncPosOn) then
            return
        end
        local char = lp.Character
        if not char then
            return
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then
            return
        end

        if st.desyncSourceChar ~= char or not st.desyncDummy or not st.desyncDummy.Parent then
            createDesyncDummy(char)
        end

        if st.desyncOn then
            if not st.desyncSavedCF then
                st.desyncSavedCF = root.CFrame
            end
        else
            local pos = st.desyncPosTarget
            local curCF = root.CFrame
            if pos then
                st.desyncSavedCF = CFrame.new(pos, pos + curCF.LookVector)
            else
                st.desyncSavedCF = curCF
            end
        end

        local savedCF = st.desyncSavedCF
        if not savedCF then
            return
        end

        st.desyncRealCF = root.CFrame
        st.desyncRealVel = root.AssemblyLinearVelocity
        st.desyncRealRotVel = root.AssemblyAngularVelocity

        root.CFrame = savedCF
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

        local dRoot = st.desyncDummyRoot
        if dRoot and dRoot.Parent then
            dRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            dRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            dRoot.CFrame = savedCF
            for dMotor, oMotor in pairs(st.desyncDummyMotorMap) do
                if dMotor.Parent and oMotor.Parent then
                    dMotor.Transform = oMotor.Transform
                end
            end
        end

        applyDesyncMaterials()
    end

    local function startFling()
        if st.flingRunning then
            return
        end
        local now = time()
        if now < (st.flingCooldownEnd or 0) then
            return
        end
        local target = st.flingTarget
        if not target then
            return
        end
        local tChar = target.Character
        local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if not tHRP then
            return
        end
        local c = getChar()
        local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
        if not hrp2 then
            return
        end

        st.flingRunning = true
        st.flingCooldownEnd = now + 3

        local prevTouch = st.touchFlingOn
        if not prevTouch then
            toggleTouchFling()
        end

        local startCFrame = hrp2.CFrame
        local startAV = hrp2.AssemblyAngularVelocity
        local startLV = hrp2.AssemblyLinearVelocity
        local startRV = hrp2.RotVelocity
        local startV = hrp2.Velocity

        local startTime = time()
        while not destroyed and time() - startTime < 3 do
            R.Heartbeat:Wait()
            tChar = target.Character
            tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
            c = getChar()
            hrp2 = c and c:FindFirstChild("HumanoidRootPart")
            if not tHRP or not hrp2 then
                break
            end
            local tPos = tHRP.Position
            local tVel = tHRP.AssemblyLinearVelocity
            local center = tPos + tVel * 0.5

            local r = 5 * math.pow(math.random(), 1/3)
            local uRand = math.random()
            local vRand = math.random()
            local theta = math.acos(2 * uRand - 1)
            local phi = 2 * math.pi * vRand
            local sinT = math.sin(theta)
            local offset = Vector3.new(
                r * sinT * math.cos(phi),
                r * math.cos(theta),
                r * sinT * math.sin(phi)
            )

            local pos = center + offset
            local randCF = CFrame.fromEulerAnglesXYZ(
                math.random() * math.pi * 2,
                math.random() * math.pi * 2,
                math.random() * math.pi * 2
            )
            hrp2.CFrame = CFrame.new(pos) * randCF
        end

        c = getChar()
        local hrpNow = c and c:FindFirstChild("HumanoidRootPart")
        if hrpNow then
            hrpNow.CFrame = startCFrame
            hrpNow.AssemblyAngularVelocity = startAV
            hrpNow.AssemblyLinearVelocity = startLV
            hrpNow.RotVelocity = startRV
            hrpNow.Velocity = startV
        end

        if not prevTouch and st.touchFlingOn then
            toggleTouchFling()
        end

        st.flingRunning = false
    end

    local function runUrl(url)
        local ok, res = pcall(function()
            return game:HttpGet(url)
        end)
        if not ok or type(res) ~= "string" then
            return
        end
        local fn = loadstring(res)
        if not fn then
            return
        end
        pcall(fn)
    end

    local isPC = (U.KeyboardEnabled == true)

    if not isPC then
        if refs.smartFlyBtn then
            refs.smartFlyBtn.Visible = false
        end
        if refs.smartFlyTrigBtn then
            refs.smartFlyTrigBtn.Visible = false
        end
        if refs.smartResetBtn then
            refs.smartResetBtn.Visible = false
        end
        if refs.smartResetTrigBtn then
            refs.smartResetTrigBtn.Visible = false
        end
    end

    local hbConn = addConn(R.Heartbeat:Connect(function(dt)
        if destroyed then
            return
        end
        updateTpWalk(dt)
        updateAntiVoid()
        updateAntiFling()
        updateDesync()
        updateFly(dt)
        updateEsp(dt)
        updateStatus(dt)
        applyLoops()
        updateChat()
        if st.loopKillOn then
            local c = getChar()
            local hum = c and c:FindFirstChildWhichIsA("Humanoid")
            if hum then
                local hs = hum:GetState()
                if hs ~= Enum.HumanoidStateType.Dead then
                    hum:ChangeState(Enum.HumanoidStateType.Dead)
                end
            end
        end
        local diff = targetBtnX - btnX
        if math.abs(diff) > 1e-4 then
            local a = math.clamp(dt * 6, 0, 1)
            btnX = btnX + diff * a
            local tPos = refs.toggle.Position
            local mPos = refs.main.Position
            refs.toggle.Position = UDim2.new(btnX, 0, tPos.Y.Scale, tPos.Y.Offset)
            refs.main.Position = UDim2.new(btnX, 0, mPos.Y.Scale, mPos.Y.Offset)
        end
    end))

    addConn(R.RenderStepped:Connect(function()
        if destroyed then
            return
        end
        local c = getChar()
        local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
        local cam2 = ws.CurrentCamera
        if not c or not hrp2 or not cam2 then
            return
        end
        if st.flyMode == "fly" and not (st.desyncOn or st.desyncPosOn) then
            local cf = cam2.CFrame
            local rx, ry = cf:ToOrientation()
            local pos = hrp2.Position
            hrp2.CFrame = CFrame.new(pos) * CFrame.fromOrientation(rx, ry, 0)
        end
    end))

    R:BindToRenderStep("Leme_DesyncRevert", Enum.RenderPriority.Camera.Value - 1, function()
        if destroyed then
            return
        end
        if not (st.desyncOn or st.desyncPosOn) then
            return
        end
        local char = lp.Character
        if not char then
            return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then
            return
        end
        if not st.desyncRealCF or not st.desyncRealVel or not st.desyncRealRotVel then
            return
        end
        root.CFrame = st.desyncRealCF
        root.AssemblyLinearVelocity = st.desyncRealVel
        root.AssemblyAngularVelocity = st.desyncRealRotVel
    end)

    addConn(R.Stepped:Connect(function()
        if destroyed then
            return
        end
        if not st.noclipOn then
            return
        end
        local c = getChar()
        if not c then
            return
        end
        for _, ch in ipairs(c:GetDescendants()) do
            if ch:IsA("BasePart") and ch.CanCollide == true and ch.Name ~= FLOAT_NAME then
                ch.CanCollide = false
            end
        end
    end))

    addConn(U.JumpRequest:Connect(function()
        if destroyed then
            return
        end
        if not st.flyJumpOn then
            return
        end
        local c = getChar()
        local hum = c and c:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))

    addConn(lp.CharacterAdded:Connect(function(newChar)
        task.wait(0.1)
        if st.noclipOn then
            cacheNoclip()
        end
        if st.flyMode ~= "none" then
            st.flyPos = nil
            st.hoverTarget = nil
            st.hoverY = nil
            st.velAnchorPos = nil
            removeHoverAlign()
        end
        if st.anchorOn and st.anchorData and st.anchorData.frozen and not st.anchorData.unfrozenOnce then
            local c = newChar or getChar()
            local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if hrp2 and hum then
                st.anchorData.char = c
                st.anchorData.hrp = hrp2
                st.anchorData.hum = hum
                hrp2.AssemblyAngularVelocity = Vector3.zero
                hrp2.AssemblyLinearVelocity = Vector3.zero
                hrp2.RotVelocity = Vector3.zero
                hrp2.Velocity = Vector3.zero
                hrp2.CFrame = st.anchorData.freezeCF or hrp2.CFrame
            end
        end
    end))

    addConn(P.PlayerRemoving:Connect(function(pl)
        if st.flingTarget == pl then
            st.flingTarget = nil
            updFlingTargetDisplay()
        end
    end))

    addConn(ws.ChildRemoved:Connect(function(c)
        if destroyed then
            return
        end
        if c == st.desyncDummy then
            st.desyncDummy = nil
            st.desyncDummyRoot = nil
            st.desyncDummyMotorMap = {}
            st.desyncSourceChar = nil
        end
    end))

    refs.rejoinBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        rejoin()
    end)

    refs.killSelfBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        killSelf()
    end)

    refs.loopKillBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.loopKillOn = not st.loopKillOn
        updLoopKillBtn()
    end)

    refs.antiAfkBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        enableAntiAfk()
    end)

    refs.noclipBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        toggleNoclip()
    end)

    refs.tpWalkBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        toggleTpWalk()
    end)

    refs.anchorBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        toggleAnchor()
    end)

    refs.antiVoidBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        toggleAntiVoid()
    end)

    refs.antiFlingBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        toggleAntiFling()
    end)

    refs.touchFlingBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        toggleTouchFling()
    end)

    refs.flyJumpBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        toggleFlyJump()
    end)

    refs.flyBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        setFlyMode("fly")
    end)

    refs.hoverBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        setFlyMode("hover")
    end)

    refs.velBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        setFlyMode("vel")
    end)

    refs.espBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        toggleESP()
    end)

    refs.miniEspBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        toggleMiniESP()
    end)

    refs.statusBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        toggleStatus()
    end)

    refs.chatBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.chatOn = not st.chatOn
        updChatBtn()
    end)

    refs.instantPromptBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        local function apply(prompt)
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
            end
        end
        for _, descendant in ipairs(workspace:GetDescendants()) do
            apply(descendant)
        end
        workspace.DescendantAdded:Connect(apply)
    end)

    refs.setFovBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.fovInput, st.fovValue)
        if n and n > 0 then
            st.fovValue = n
        end
        local pf = refs.fovInput:GetAttribute("Prefix") or ""
        refs.fovInput.Text = pf .. tostring(st.fovValue)
        local cam2 = ws.CurrentCamera
        if cam2 then
            cam2.FieldOfView = st.fovValue
        end
    end)

    refs.loopFovBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.fovLoop = not st.fovLoop
        updLoopFovBtn()
    end)

    refs.fovInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.fovInput, st.fovValue)
        if n and n > 0 then
            st.fovValue = n
        end
        local pf = refs.fovInput:GetAttribute("Prefix") or ""
        refs.fovInput.Text = pf .. tostring(st.fovValue)
    end)

    refs.setSpeedBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.speedInput, st.speedValue)
        if n and n > 0 then
            st.speedValue = n
        end
        local pf = refs.speedInput:GetAttribute("Prefix") or ""
        refs.speedInput.Text = pf .. tostring(st.speedValue)
        local c = getChar()
        local hum = c and c:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum.WalkSpeed = st.speedValue
        end
    end)

    refs.loopSpeedBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.speedLoop = not st.speedLoop
        updLoopSpeedBtn()
    end)

    refs.speedInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.speedInput, st.speedValue)
        if n and n > 0 then
            st.speedValue = n
        end
        local pf = refs.speedInput:GetAttribute("Prefix") or ""
        refs.speedInput.Text = pf .. tostring(st.speedValue)
    end)

    refs.setJumpBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.jumpInput, st.jumpValue)
        if n and n > 0 then
            st.jumpValue = n
        end
        local pf = refs.jumpInput:GetAttribute("Prefix") or ""
        refs.jumpInput.Text = pf .. tostring(st.jumpValue)
        local c = getChar()
        local hum = c and c:FindFirstChildWhichIsA("Humanoid")
        if hum then
            if hum.UseJumpPower ~= false then
                hum.UseJumpPower = true
                hum.JumpPower = st.jumpValue
            else
                hum.JumpHeight = st.jumpValue
            end
        end
    end)

    refs.loopJumpBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.jumpLoop = not st.jumpLoop
        updLoopJumpBtn()
    end)

    refs.jumpInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.jumpInput, st.jumpValue)
        if n and n > 0 then
            st.jumpValue = n
        end
        local pf = refs.jumpInput:GetAttribute("Prefix") or ""
        refs.jumpInput.Text = pf .. tostring(st.jumpValue)
    end)

    refs.setGravBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.gravInput, st.gravValue)
        if n then
            st.gravValue = n
        end
        local pf = refs.gravInput:GetAttribute("Prefix") or ""
        refs.gravInput.Text = pf .. tostring(st.gravValue)
        ws.Gravity = st.gravValue
    end)

    refs.loopGravBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.gravLoop = not st.gravLoop
        updLoopGravBtn()
    end)

    refs.gravInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.gravInput, st.gravValue)
        if n then
            st.gravValue = n
        end
        local pf = refs.gravInput:GetAttribute("Prefix") or ""
        refs.gravInput.Text = pf .. tostring(st.gravValue)
    end)

    refs.setMaxZoomBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.maxZoomInput, st.maxZoomValue)
        if n and n >= 0 then
            st.maxZoomValue = n
        end
        local pf = refs.maxZoomInput:GetAttribute("Prefix") or ""
        refs.maxZoomInput.Text = pf .. tostring(st.maxZoomValue)
        lp.CameraMaxZoomDistance = st.maxZoomValue
    end)

    refs.loopMaxZoomBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.maxZoomLoop = not st.maxZoomLoop
        updLoopMaxZoomBtn()
    end)

    refs.maxZoomInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.maxZoomInput, st.maxZoomValue)
        if n and n >= 0 then
            st.maxZoomValue = n
        end
        local pf = refs.maxZoomInput:GetAttribute("Prefix") or ""
        refs.maxZoomInput.Text = pf .. tostring(st.maxZoomValue)
    end)

    refs.setMinZoomBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.minZoomInput, st.minZoomValue)
        if n and n >= 0 then
            st.minZoomValue = n
        end
        local pf = refs.minZoomInput:GetAttribute("Prefix") or ""
        refs.minZoomInput.Text = pf .. tostring(st.minZoomValue)
        lp.CameraMinZoomDistance = st.minZoomValue
    end)

    refs.loopMinZoomBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.minZoomLoop = not st.minZoomLoop
        updLoopMinZoomBtn()
    end)

    refs.minZoomInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.minZoomInput, st.minZoomValue)
        if n and n >= 0 then
            st.minZoomValue = n
        end
        local pf = refs.minZoomInput:GetAttribute("Prefix") or ""
        refs.minZoomInput.Text = pf .. tostring(st.minZoomValue)
    end)

    refs.noMaxZoomBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        toggleNoMaxZoom()
    end)

    refs.noMinZoomBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        toggleNoMinZoom()
    end)

    refs.noFogBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.noFogOn = not st.noFogOn
        if st.noFogOn then
            st.fogLoop = false
            updLoopFogBtn()
        end
        updNoFogBtn()
    end)

    refs.setFogBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        parseFogColor()
        parseFogStart()
        parseFogEnd()
        L.FogColor = st.fogColor
        L.FogStart = st.fogStart
        L.FogEnd = st.fogEnd
    end)

    refs.loopFogBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.fogLoop = not st.fogLoop
        if st.fogLoop then
            st.noFogOn = false
            updNoFogBtn()
        end
        updLoopFogBtn()
    end)

    refs.fogColorInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        parseFogColor()
    end)

    refs.fogStartInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        parseFogStart()
    end)

    refs.fogEndInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        parseFogEnd()
    end)

    refs.fbBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        applyFullBright()
    end)

    refs.loopFbBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.fullBrightLoopOn = not st.fullBrightLoopOn
        updLoopFbBtn()
    end)

    refs.flySpeedInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.flySpeedInput, st.flySpeed)
        if n and n > 0 then
            st.flySpeed = n
        end
        local pf = refs.flySpeedInput:GetAttribute("Prefix") or ""
        refs.flySpeedInput.Text = pf .. tostring(st.flySpeed)
    end)

    refs.tpWalkSpeedInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        local n = readNumber(refs.tpWalkSpeedInput, st.tpSpeed)
        if n and n > 0 then
            st.tpSpeed = n
        end
        local pf = refs.tpWalkSpeedInput:GetAttribute("Prefix") or ""
        refs.tpWalkSpeedInput.Text = pf .. tostring(st.tpSpeed)
    end)

    refs.smartFlyBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        if not isPC then
            return
        end
        st.smartFlyOn = not st.smartFlyOn
        updSmartFlyBtn()
    end)

    refs.smartFlyTrigBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        if not isPC then
            return
        end
        st.smartFlyWaitingKey = true
        refs.smartFlyTrigBtn.Text = st.language == "jp" and "トリガーキー [...]" or "Trigger [...]"
    end)

    refs.smartResetBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        if not isPC then
            return
        end
        st.smartResetOn = not st.smartResetOn
        updSmartResetBtn()
    end)

    refs.smartResetTrigBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        if not isPC then
            return
        end
        st.smartResetWaitingKey = true
        refs.smartResetTrigBtn.Text = st.language == "jp" and "トリガーキー [...]" or "Trigger [...]"
    end)

    refs.resetCamBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        applyResetCamera()
    end)

    refs.loopResetCamBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.resetCamLoopOn = not st.resetCamLoopOn
        updLoopResetCamBtn()
    end)

    refs.loadIYBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        runUrl("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
    end)

    refs.loadRSpyBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        runUrl("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua")
    end)

    refs.loadDexBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        runUrl("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua")
    end)

    refs.loadShiftLockBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        runUrl("https://rawscripts.net/raw/Universal-Script-Shiftlock-script-42373")
    end)

    refs.tpPosInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        parseTpPos()
    end)

    refs.tpToBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        parseTpPos()
        local pos = st.tpPos
        if not pos then
            return
        end
        local c = getChar()
        local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
        if hrp2 then
            hrp2.CFrame = CFrame.new(pos)
        end
    end)

    refs.setPosBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        local x, y, z = getPos()
        local function r2(v)
            return math.floor(v * 100 + 0.5) / 100
        end
        x, y, z = r2(x), r2(y), r2(z)
        st.tpPos = Vector3.new(x, y, z)
        local tb = refs.tpPosInput
        local pf = tb:GetAttribute("Prefix") or ""
        tb.Text = pf .. string.format("%.2f %.2f %.2f", x, y, z)
    end)

    refs.flingTargetInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        updateFlingTargetFromInput()
    end)

    refs.flingBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        startFling()
    end)

    refs.desyncPosInput.FocusLost:Connect(function()
        if destroyed then
            return
        end
        parseDesyncPosInput()
    end)

    refs.desyncBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        local prevActive = st.desyncOn or st.desyncPosOn
        st.desyncOn = not st.desyncOn
        if st.desyncOn then
            st.desyncPosOn = false
        end
        local nowActive = st.desyncOn or st.desyncPosOn
        if prevActive and not nowActive then
            resetDesyncChar()
        end
        st.desyncSavedCF = nil
        st.desyncRealCF = nil
        st.desyncRealVel = nil
        st.desyncRealRotVel = nil
        if not st.desyncOn and not st.desyncPosOn then
            restoreDesyncMaterials()
            if st.desyncDummy then
                st.desyncDummy:Destroy()
                st.desyncDummy = nil
                st.desyncDummyRoot = nil
                st.desyncDummyMotorMap = {}
                st.desyncSourceChar = nil
            end
        end
        updDesyncBtn()
        updDesyncPosBtn()
    end)

    refs.desyncPosBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        local prevActive = st.desyncOn or st.desyncPosOn
        st.desyncPosOn = not st.desyncPosOn
        if st.desyncPosOn then
            st.desyncOn = false
            if not st.desyncPosTarget then
                local c = getChar()
                local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
                if hrp2 then
                    local p2 = hrp2.Position
                    st.desyncPosTarget = Vector3.new(p2.X, p2.Y, p2.Z)
                    local tb = refs.desyncPosInput
                    local pf = tb:GetAttribute("Prefix") or ""
                    tb.Text = pf .. string.format("%.2f %.2f %.2f", p2.X, p2.Y, p2.Z)
                end
            end
        end
        local nowActive = st.desyncOn or st.desyncPosOn
        if prevActive and not nowActive then
            resetDesyncChar()
        end
        st.desyncSavedCF = nil
        st.desyncRealCF = nil
        st.desyncRealVel = nil
        st.desyncRealRotVel = nil
        if not st.desyncOn and not st.desyncPosOn then
            restoreDesyncMaterials()
            if st.desyncDummy then
                st.desyncDummy:Destroy()
                st.desyncDummy = nil
                st.desyncDummyRoot = nil
                st.desyncDummyMotorMap = {}
                st.desyncSourceChar = nil
            end
        end
        updDesyncBtn()
        updDesyncPosBtn()
    end)

    local function openLanguageDialog()
        if refs.languageOverlay then
            return
        end
        local overlay = Instance.new("Frame")
        overlay.Name = "LanguageOverlay"
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.Position = UDim2.new(0, 0, 0, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 0.4
        overlay.BorderSizePixel = 0
        overlay.ZIndex = 1001
        overlay.Parent = gui
        refs.languageOverlay = overlay

        local inner = Instance.new("Frame")
        inner.Size = UDim2.new(0, 220, 0, 120)
        inner.AnchorPoint = Vector2.new(0.5, 0.5)
        inner.Position = UDim2.new(0.5, 0, 0.5, 0)
        inner.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        inner.BackgroundTransparency = 0.1
        inner.BorderSizePixel = 0
        inner.ZIndex = 1002
        inner.Parent = overlay

        local ic = Instance.new("UICorner")
        ic.CornerRadius = UDim.new(0, 10)
        ic.Parent = inner

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.BorderSizePixel = 0
        title.Size = UDim2.new(1, 0, 0, 28)
        title.Position = UDim2.new(0, 0, 0, 8)
        title.Font = Enum.Font.Code
        title.TextColor3 = Color3.new(1, 1, 1)
        title.TextSize = 18
        title.ZIndex = 1003
        title.Text = st.language == "jp" and "言語を選択" or "Select Language"
        title.Parent = inner

        local btnFrame = Instance.new("Frame")
        btnFrame.BackgroundTransparency = 1
        btnFrame.BorderSizePixel = 0
        btnFrame.Size = UDim2.new(1, -20, 0, 70)
        btnFrame.Position = UDim2.new(0, 10, 0, 40)
        btnFrame.ZIndex = 1003
        btnFrame.Parent = inner

        local list2 = Instance.new("UIListLayout")
        list2.FillDirection = Enum.FillDirection.Vertical
        list2.Padding = UDim.new(0, 8)
        list2.SortOrder = Enum.SortOrder.LayoutOrder
        list2.HorizontalAlignment = Enum.HorizontalAlignment.Center
        list2.Parent = btnFrame

        local function makeLangButton(text, code)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 26)
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            b.BackgroundTransparency = 0.1
            b.BorderSizePixel = 0
            b.Font = Enum.Font.Code
            b.TextSize = 14
            b.TextColor3 = Color3.new(1, 1, 1)
            b.AutoButtonColor = false
            b.Text = text
            b.ZIndex = 1004
            b.Parent = btnFrame
            local c2 = Instance.new("UICorner")
            c2.CornerRadius = UDim.new(0, 6)
            c2.Parent = b
            return b
        end

        local enBtn = makeLangButton("English", "en")
        local jpBtn = makeLangButton("日本語", "jp")

        local function refreshSel()
            local current = st.language
            if current == "en" then
                enBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
                jpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            else
                jpBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
                enBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
        end

        refreshSel()

        local function selectLang(code)
            st.language = code
            applyLanguage()
            if refs.languageOverlay then
                refs.languageOverlay:Destroy()
                refs.languageOverlay = nil
            end
        end

        enBtn.MouseButton1Click:Connect(function()
            selectLang("en")
        end)

        jpBtn.MouseButton1Click:Connect(function()
            selectLang("jp")
        end)
    end

    refs.languageBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        openLanguageDialog()
    end)

    refs.toggle.InputBegan:Connect(function(input)
        if destroyed then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mouseDown = true
            dragCandidate = true
            dragging = false
            dragMoved = false
            dragStartX = input.Position.X
            dragBtnStartX = btnX
        end
    end)

    U.InputChanged:Connect(function(input)
        if destroyed then
            return
        end
        if not mouseDown then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local cam2 = ws.CurrentCamera
        if not cam2 then
            return
        end
        local vs = cam2.ViewportSize
        if vs.X <= 0 then
            return
        end
        local dx = (input.Position.X - dragStartX) / vs.X
        local threshold = 0.01
        if dragCandidate and math.abs(dx) > threshold then
            dragCandidate = false
            dragging = true
            dragMoved = true
        end
        if dragging then
            targetBtnX = math.clamp(dragBtnStartX + dx, 0, 1)
        end
    end)

    U.InputEnded:Connect(function(input)
        if destroyed then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mouseDown = false
            dragging = false
            dragCandidate = false
        end
        if U:GetFocusedTextBox() then
            return
        end
        local kc = input.KeyCode
        if kc == Enum.KeyCode.W then
            st.moveKeys.W = false
        end
        if kc == Enum.KeyCode.A then
            st.moveKeys.A = false
        end
        if kc == Enum.KeyCode.S then
            st.moveKeys.S = false
        end
        if kc == Enum.KeyCode.D then
            st.moveKeys.D = false
        end
        if kc == Enum.KeyCode.Q then
            st.moveKeys.Q = false
        end
        if kc == Enum.KeyCode.E then
            st.moveKeys.E = false
        end
    end)

    U.InputBegan:Connect(function(input, processed)
        if destroyed then
            return
        end

        if input.UserInputType == Enum.UserInputType.Keyboard and isPC then
            if st.smartFlyWaitingKey then
                st.smartFlyWaitingKey = false
                if input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
                    st.smartFlyKey = input.KeyCode
                end
                refs.smartFlyTrigBtn.Text = st.language == "jp"
                    and ("トリガーキー [" .. (st.smartFlyKey and st.smartFlyKey.Name or "None") .. "]")
                    or ("Trigger [" .. (st.smartFlyKey and st.smartFlyKey.Name or "None") .. "]")
                return
            end
            if st.smartResetWaitingKey then
                st.smartResetWaitingKey = false
                if input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
                    st.smartResetKey = input.KeyCode
                end
                refs.smartResetTrigBtn.Text = st.language == "jp"
                    and ("トリガーキー [" .. (st.smartResetKey and st.smartResetKey.Name or "None") .. "]")
                    or ("Trigger [" .. (st.smartResetKey and st.smartResetKey.Name or "None") .. "]")
                return
            end
        end

        local kc = input.KeyCode
        local isMove = (kc == Enum.KeyCode.W or kc == Enum.KeyCode.A or kc == Enum.KeyCode.S or kc == Enum.KeyCode.D or kc == Enum.KeyCode.Q or kc == Enum.KeyCode.E)
        if (not isMove) and processed then
            return
        end
        if U:GetFocusedTextBox() then
            return
        end

        if kc == Enum.KeyCode.W then
            st.moveKeys.W = true
        end
        if kc == Enum.KeyCode.A then
            st.moveKeys.A = true
        end
        if kc == Enum.KeyCode.S then
            st.moveKeys.S = true
        end
        if kc == Enum.KeyCode.D then
            st.moveKeys.D = true
        end
        if kc == Enum.KeyCode.Q then
            st.moveKeys.Q = true
        end
        if kc == Enum.KeyCode.E then
            st.moveKeys.E = true
        end

        if isPC and input.UserInputType == Enum.UserInputType.Keyboard then
            if st.smartFlyOn and kc == st.smartFlyKey then
                setFlyMode("fly")
            end
            if st.smartResetOn and kc == st.smartResetKey then
                killSelf()
            end
        end
    end)

    updNoclipBtn()
    updTpBtn()
    updAnchorBtn()
    updAntiVoidBtn()
    updAntiFlingBtn()
    updTouchFlingBtn()
    updFlyJumpBtn()
    updFlyBtns()
    updEspBtn()
    updMiniEspBtn()
    updStatusBtn()
    updLoopFovBtn()
    updLoopSpeedBtn()
    updLoopJumpBtn()
    updLoopMaxZoomBtn()
    updLoopMinZoomBtn()
    updNoFogBtn()
    updLoopFogBtn()
    updLoopFbBtn()
    updLoopGravBtn()
    updSmartFlyBtn()
    updSmartResetBtn()
    updChatBtn()
    updNoMaxZoomBtn()
    updNoMinZoomBtn()
    updLoopKillBtn()
    updDesyncBtn()
    updDesyncPosBtn()
    updLoopResetCamBtn()
    updKeepScriptBtn()
    updFlingTargetDisplay()
    updLanguageBtn()
    applyLanguage()

    if st.keepScriptOn then
        queueSelf()
    end

    function C.D()
        if destroyed then
            return
        end
        destroyed = true
        touchStopRequested = true
        if hbConn and hbConn.Connected then
            hbConn:Disconnect()
        end
        R:UnbindFromRenderStep("Leme_DesyncRevert")
        for i = #conns, 1, -1 do
            local c = conns[i]
            conns[i] = nil
            if c and c.Connected then
                c:Disconnect()
            end
        end
        clearNameEsp()
        clearMiniEsp()
        if st.statusGui then
            st.statusGui:Destroy()
            st.statusGui = nil
            st.statusLabel = nil
        end
        removeHoverAlign()
        restoreDesyncMaterials()
        if st.desyncDummy then
            st.desyncDummy:Destroy()
            st.desyncDummy = nil
            st.desyncDummyRoot = nil
            st.desyncDummyMotorMap = {}
            st.desyncSourceChar = nil
        end
        pcall(function()
            gui:Destroy()
        end)
        if g.LemeGUIV2 == C then
            g.LemeGUIV2 = nil
        end
    end

    refs.unloadBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        C.D()
    end)

    refs.reloadBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        C.D()
        task.defer(Start)
    end)

    refs.keepScriptBtn.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end
        st.keepScriptOn = not st.keepScriptOn
        if st.keepScriptOn then
            queueSelf()
        end
        updKeepScriptBtn()
    end)
end

Start()
