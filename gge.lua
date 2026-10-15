local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Toggles = getgenv().Toggles or Library.Toggles
local Options = getgenv().Options or Library.Options

-- ==========================================
-- Services & Local Player 설정
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local lp = LocalPlayer
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Global Config & State Table (통합 관리)
getgenv().Config = getgenv().Config or {}
getgenv().State = getgenv().State or {}

local Window = Library:CreateWindow({
    Title = 'Yumu Enchantment - discord.gg/qTV5c5Fn6',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Character = Window:AddTab('Character'),
    Misc = Window:AddTab('Misc'),
    Setting = Window:AddTab('Setting')
}

-- ============================================================
-- 헬퍼
-- ============================================================
local _0l1lOIIII0 = true

local function is_teammate(player)
    if not _0l1lOIIII0 then return false end
    local a = LocalPlayer:GetAttribute("TeamID")
    local b = player:GetAttribute("TeamID")
    if a == nil or b == nil then return false end
    return a == b
end

local function get_character(playerOrChar)
    local char = playerOrChar
    if typeof(playerOrChar) == "Instance" and playerOrChar:IsA("Player") then
        char = playerOrChar.Character
    end
    if not char then return true end
    if char:FindFirstChildOfClass("ForceField") then return true end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild("Attachment") then return true end
    local flag = char:GetAttribute("Immune") or char:GetAttribute("Invincible") or char:GetAttribute("IsImmune")
    if flag == true then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local f2 = hum:GetAttribute("Immune") or hum:GetAttribute("Invincible")
        if f2 == true then return true end
    end
    return false
end

local function get_player_from_part(player)
    local char = player and player.Character
    if not char then return false end
    local flags = {"Reflecting","IsReflecting","BulletReflect","Reflect","Deflecting","Parrying"}
    for _, k in ipairs(flags) do
        local v = char:GetAttribute(k)
        if v == true or v == 1 or v == "true" then return true end
    end
    return false
end

-- ============================================================
-- 변수
-- ============================================================
local _2631x704  = true
local flyEnabled = false
local _8080x566  = 50000000
local _lII0ll    = false
local _4012x732  = 0.25
local a85b57c99  = 0.1
local L555_61    = false
local __lhiRNgvZ = 3
local a73b35c96  = nil

-- 🔹 Ragebot 모드 ("gun" 또는 "knife")
local RagebotMode = "gun"

-- 🔹 knife 모드 TP 뒤쪽 거리 (스터드)
local KnifeBackStuds = 2

local L389_46    = nil
local L273_20    = nil
local _10O0lO    = nil

-- 🔹 Knife 오토 리모트용
local KnifeRemote       = nil
local KnifeSwingRemote  = nil
local KnifeCachedID     = nil

-- ============================================================
-- Knife 리모트 탐색 (Roblox Rivals 기반)
-- ============================================================
task.spawn(function()
    pcall(function()
        local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
        if not Remotes then return end

        local searchRoots = {
            Remotes,
            Remotes:FindFirstChild("Replication"),
            Remotes:FindFirstChild("Replication") and Remotes.Replication:FindFirstChild("Fighter"),
            Remotes:FindFirstChild("Combat"),
            Remotes:FindFirstChild("Melee"),
        }

        for _, root in ipairs(searchRoots) do
            if root then
                for _, obj in ipairs(root:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local n = string.lower(obj.Name)
                        if n:find("knife") or n:find("melee") or n:find("stab") or n:find("slash") or n:find("swing") then
                            if not KnifeRemote then
                                KnifeRemote = obj
                            else
                                KnifeSwingRemote = obj
                            end
                        end
                    end
                end
            end
        end
    end)
end)

-- Knife ObjectID 캐시 (칼 장착 시)
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            local ps = LocalPlayer.PlayerScripts
            local okFighter, FighterController = pcall(require, ps.Controllers.FighterController)
            if not (okFighter and FighterController) then return end
            local lf = FighterController.LocalFighter
            if not lf then return end
            local item = lf.EquippedItem
            if not item then return end
            local ok, id = pcall(function() return item:Get("ObjectID") end)
            if not ok or not id then
                ok, id = pcall(function() return item.Data and item.Data.ObjectID end)
            end
            if ok and id then
                local nm = ""
                pcall(function() nm = string.lower(tostring(item.Name or item.Data and item.Data.Name or "")) end)
                if nm:find("knife") or nm:find("karambit") or nm:find("melee") or nm:find("dagger") or nm:find("blade") then
                    KnifeCachedID = id
                end
            end
        end)
    end
end)

-- ============================================================
-- Desync 타이밍 루프
-- ============================================================
task.spawn(function()
    while true do
        if _lII0ll and L555_61 then
            _2631x704 = true
            local atk = a85b57c99
            if typeof(atk) ~= "number" or atk < 0.01 then atk = 0.01 end
            task.wait(atk)
            if _lII0ll and L555_61 then
                _2631x704 = false
                local hid = _4012x732
                if typeof(hid) ~= "number" or hid < 0.01 then hid = 0.01 end
                task.wait(hid)
            else
                _2631x704 = true
            end
        else
            _2631x704 = true
            task.wait(0.05)
        end
    end
end)

-- ============================================================
-- 타겟 헤드 반환
-- ============================================================
local function get_character_root(char)
    if not char then return nil end
    return char:FindFirstChild("HitboxHead")
        or char:FindFirstChild("HitboxHeadSmall")
        or char:FindFirstChild("Head")
end

-- ============================================================
-- Remote Attack Engine (GUN)
-- ============================================================
local v71190 = function(on) end

task.spawn(function()
    pcall(function()
        local ps = LocalPlayer.PlayerScripts
        local okFighter, FighterController = pcall(require, ps.Controllers.FighterController)
        local okEnum, EnumLibrary           = pcall(require, ReplicatedStorage.Modules.EnumLibrary)
        local UseItemRemote = ReplicatedStorage.Remotes.Replication.Fighter.UseItem
        local StartShooting
        pcall(function() StartShooting = EnumLibrary:ToEnum("StartShooting") end)

        local function getObjectID()
            if not (okFighter and FighterController) then return nil end
            local lf = FighterController.LocalFighter; if not lf then return nil end
            local item = lf.EquippedItem;              if not item then return nil end
            local ok, id = pcall(function() return item:Get("ObjectID") end)
            if ok and id then return id end
            ok, id = pcall(function() return item.Data and item.Data.ObjectID end)
            return ok and id or nil
        end

        local function buildPayload(originPos, targetPart)
            local tPos = targetPart.Position
            local lookCF = CFrame.lookAt(originPos, tPos)
            local rx, ry, rz = lookCF:ToOrientation()
            local rot = {
                [utf8.char(0)] = originPos.X, [utf8.char(1)] = originPos.Y, [utf8.char(2)] = originPos.Z,
                [utf8.char(3)] = rx,          [utf8.char(4)] = ry,          [utf8.char(5)] = rz,
            }
            local rel = targetPart.CFrame:ToObjectSpace(CFrame.new(tPos))
            local ox, oy, oz = rel:ToOrientation()
            return {
                [utf8.char(1)] = {
                    [utf8.char(0)] = rot,
                    [utf8.char(1)] = rot,
                    [utf8.char(2)] = targetPart,
                    [utf8.char(3)] = {
                        [utf8.char(0)] = rel.X, [utf8.char(1)] = rel.Y, [utf8.char(2)] = rel.Z,
                        [utf8.char(3)] = ox,    [utf8.char(4)] = oy,    [utf8.char(5)] = oz,
                    },
                },
            }
        end

        v71190 = function(on)
            if _10O0lO then _10O0lO:Disconnect(); _10O0lO = nil end
            if not on then return end

            local cachedID = nil
            _10O0lO = RunService.Heartbeat:Connect(function()
                -- 🔹 gun 모드일 때만 발사
                if RagebotMode ~= "gun" then return end
                if not L555_61 or not _2631x704 then return end
                if not a73b35c96 or not a73b35c96.Parent then return end

                local model = a73b35c96:FindFirstAncestorOfClass("Model") or a73b35c96.Parent
                local plr   = Players:GetPlayerFromCharacter(model)
                if not plr or plr == LocalPlayer then return end
                if is_teammate(plr) or get_character(plr) or get_player_from_part(plr) then return end

                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local id = getObjectID()
                if id then cachedID = id else id = cachedID end
                if not id then return end

                local target = a73b35c96
                local origin = target.Position + Vector3.new(0, 0.1, 0)
                local payload = buildPayload(origin, target)
                pcall(function()
                    if id and StartShooting then
                        UseItemRemote:FireServer(id, StartShooting, payload, nil)
                    end
                end)
            end)
        end
    end)
end)

-- ============================================================
-- 무기 장착 여부
-- ============================================================
local function hasWeaponEquipped()
    local ok = true
    pcall(function()
        local ps = LocalPlayer.PlayerScripts
        local s, fc = pcall(require, ps.Controllers.FighterController)
        if not s or not fc or not fc.LocalFighter then return end
        if not fc.LocalFighter.EquippedItem then ok = false end
    end)
    return ok
end

-- ============================================================
-- Desync 위치 복구
-- ============================================================
local function restore_desync_position()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not L389_46 then return end
    hrp.CFrame = L389_46
    if L273_20 then hrp.AssemblyLinearVelocity = L273_20 end
    L389_46 = nil
    L273_20 = nil
end

pcall(function() RunService:UnbindFromRenderStep("RestoreDesyncPerfect") end)
pcall(function() RunService:BindToRenderStep("RestoreDesyncPerfect", 0, restore_desync_position) end)
RunService.RenderStepped:Connect(restore_desync_position)

-- ============================================================
-- Heartbeat Desync Teleport + Knife TP
-- ============================================================
RunService.Heartbeat:Connect(function()
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if L389_46 then restore_desync_position() end

        if L555_61 and _2631x704 and a73b35c96 and hasWeaponEquipped() then
            local model = a73b35c96:FindFirstAncestorOfClass("Model") or a73b35c96.Parent
            local plr   = Players:GetPlayerFromCharacter(model)
            if plr and get_player_from_part(plr) then return end

            L389_46 = hrp.CFrame
            L273_20 = hrp.AssemblyLinearVelocity

            local tPos = a73b35c96.Position

            -- 🔹 gun 모드: 기존 로직 (칼 든 상대면 아래, 아니면 위)
            if RagebotMode == "gun" then
                local isKnife = false
                pcall(function()
                    if model then
                        for _, item in ipairs(model:GetChildren()) do
                            if item:IsA("Tool") and string.lower(item.Name):find("knife") then
                                isKnife = true
                                break
                            end
                        end
                    end
                    local charModel = plr and plr.Character
                    if charModel then
                        local tool = charModel:FindFirstChildOfClass("Tool")
                        if tool and string.lower(tool.Name):find("knife") then
                            isKnife = true
                        end
                    end
                end)

                local heightOffset = isKnife and -__lhiRNgvZ or __lhiRNgvZ
                local goal = tPos + Vector3.new(0, heightOffset, 0)
                hrp.CFrame = CFrame.new(goal, tPos)
                return
            end

            -- 🔹 knife 모드: 상대 등 뒤 KnifeBackStuds 스터드 위치로 TP
            --              + 내 캐릭터가 "상대가 바라보는 방향"과 같은 방향을 바라보게 회전
            if RagebotMode == "knife" then
                local targetHRP = model and model:FindFirstChild("HumanoidRootPart")
                local backOffset
                local lookTarget

                if targetHRP then
                    -- 상대의 LookVector 반대 방향 = 등 뒤 → KnifeBackStuds 스터드
                    backOffset = targetHRP.CFrame.LookVector * KnifeBackStuds
                    -- 내가 바라볼 지점 = 상대 위치 + 상대의 시선 방향 → 상대와 같은 방향을 봄
                    lookTarget = tPos + targetHRP.CFrame.LookVector
                else
                    backOffset = Vector3.new(0, 0, 0)
                    lookTarget = tPos
                end

                local goal = tPos + backOffset
                hrp.CFrame = CFrame.new(goal, lookTarget)
                return
            end
        end

        if flyEnabled then
            L389_46 = hrp.CFrame
            L273_20 = hrp.AssemblyLinearVelocity
            local dir = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100)).Unit
            local goal = hrp.Position + dir * _8080x566
            local rotOnly = L389_46 - L389_46.Position
            hrp.CFrame = CFrame.new(goal) * rotOnly
        end
    end)
end)

-- ============================================================
-- 타겟 탐색 스레드
-- ============================================================
task.spawn(function()
    while true do
        task.wait(0.01)
        if L555_61 and _2631x704 then
            local myPos = LocalPlayer.Character
                and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                and LocalPlayer.Character.HumanoidRootPart.Position
                or Vector3.zero

            local best, bestDist = nil, math.huge

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and not is_teammate(player) then
                    if get_character(player) or get_player_from_part(player) then continue end
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    local hum = player.Character:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local d = (Vector3.new(myPos.X, 0, myPos.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude
                        if d < bestDist then
                            bestDist = d
                            best = player
                        end
                    end
                end
            end

            if best and best.Character then
                a73b35c96 = get_character_root(best.Character)
            else
                a73b35c96 = nil
            end
        else
            a73b35c96 = nil
        end
    end
end)

-- ============================================================
-- 🔹 KNIFE AUTO REMOTE (칼 자동 원격 스윙/백스탭)
-- ============================================================
task.spawn(function()
    while true do
        task.wait(0.05)
        if RagebotMode == "knife" and L555_61 and _2631x704
           and a73b35c96 and a73b35c96.Parent and KnifeRemote then

            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local targetPos = a73b35c96.Position
                local dir = (targetPos - hrp.Position)
                if dir.Magnitude > 0.001 then dir = dir.Unit else dir = hrp.CFrame.LookVector end

                pcall(function() KnifeRemote:FireServer() end)
                pcall(function() KnifeRemote:FireServer("Slash") end)
                pcall(function() KnifeRemote:FireServer("Backstab") end)
                pcall(function() KnifeRemote:FireServer(KnifeCachedID or 0) end)
                pcall(function() KnifeRemote:FireServer(KnifeCachedID or 0, "Backstab") end)
                pcall(function() KnifeRemote:FireServer(hrp.CFrame, dir) end)
                pcall(function() KnifeRemote:FireServer(KnifeCachedID or 0, hrp.CFrame, a73b35c96) end)

                if KnifeSwingRemote then
                    pcall(function() KnifeSwingRemote:FireServer() end)
                    pcall(function() KnifeSwingRemote:FireServer("Slash") end)
                    pcall(function() KnifeSwingRemote:FireServer(KnifeCachedID or 0) end)
                end
            end
        end
    end
end)

-- ==========================================
-- Combat 탭 UI 구성
-- ==========================================
local RagebotGroup = Tabs.Combat:AddLeftGroupbox('Ragebot')

-- 🔹 모드 선택 (gun / knife)
RagebotGroup:AddDropdown('RagebotMode', {
    Values = { 'gun', 'knife' },
    Default = 1,
    Multi = false,
    Text = 'Mode',
    Tooltip = 'gun = 기본 발사 레이지봇 / knife = 상대 등 뒤로 TP 후 칼 오토 리모트',
    Callback = function(Value)
        RagebotMode = tostring(Value)
    end
})

RagebotGroup:AddToggle('RagebotEnabled', {
    Text = 'Enabled',
    Default = false,
    Callback = function(Value)
        L555_61 = Value
        pcall(function() v71190(Value) end)
    end
})

RagebotGroup:AddToggle('RagebotOrbit', {
    Text = 'Orbit',
    Default = false,
    Callback = function(Value)
        flyEnabled = Value
        if Value then
            _8080x566 = 5003
        end
    end
})

RagebotGroup:AddToggle('RagebotVoidspam', {
    Text = 'Void Spam',
    Default = false,
    Callback = function(Value)
        _lII0ll = Value
        if not Value then
            _2631x704 = true
        end
    end
})

RagebotGroup:AddSlider('RagebotHide', {
    Text = 'Hide Delay',
    Default = 0.25,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        _4012x732 = Value
    end
})

RagebotGroup:AddSlider('RagebotAttack', {
    Text = 'Attack Delay',
    Default = 0.1,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        a85b57c99 = Value
    end
})

-- 🔹 knife 모드 뒤쪽 거리 슬라이더
RagebotGroup:AddSlider('KnifeBackStuds', {
    Text = 'Knife Back Studs',
    Default = 2,
    Min = 0.5,
    Max = 6,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        KnifeBackStuds = Value
    end
})
