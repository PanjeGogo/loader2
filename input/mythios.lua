-- Decoded from client.txt: decimal ASCII escapes converted to plain Lua source.
-- Static decode only; this file has not been executed.

local SLUG,BASE="@freemium","https://mythios.online"
local W=warn or print
local LS=loadstring or load
-- Yield one frame so the latest UI status is drawn before work that does not yield (decrypt, compile).
local function paint()
    pcall(function()
        if type(task)=="table" and type(task.wait)=="function" then task.wait() elseif type(wait)=="function" then wait() end
    end)
end
-- Optional executor-local key persistence. The file contains only the key string.
local KEY_FILE="mythios/key.lua"
local function keyText(value)
    if type(value)~="string" then return "" end
    return (value:gsub("^%s+",""):gsub("%s+$",""))
end
local function loadStoredKey()
    local ok,value=pcall(function()
        if type(readfile)~="function" then return "" end
        if type(isfile)=="function" and not isfile(KEY_FILE) then return "" end
        return readfile(KEY_FILE)
    end)
    local key=ok and keyText(value) or ""
    if #key>64 or not key:match("^[A-Za-z0-9_-]+$") then return "" end
    return key
end
local function persistKey(key)
    key=keyText(key)
    if key=="" or key=="FREE" or #key>64 or not key:match("^[A-Za-z0-9_-]+$") then return false end
    local ok,saved=pcall(function()
        if type(writefile)~="function" then return false end
        if type(makefolder)=="function" then
            local exists=false
            if type(isfolder)=="function" then local good,v=pcall(isfolder,"mythios");exists=good and v==true end
            if not exists then pcall(makefolder,"mythios") end
        end
        writefile(KEY_FILE,key)
        return true
    end)
    return ok and saved==true
end
local function forgetStoredKey()
    if type(delfile)=="function" then local ok,result=pcall(delfile,KEY_FILE);if ok and result~=false then return end end
    if type(writefile)=="function" then pcall(writefile,KEY_FILE,"") end
end
local function explicitKey()
    local getters={
        function() return scriptkey end,
        function() return script_key end,
        function() if type(getgenv)=="function" then return getgenv().scriptkey end end,
        function() if type(getgenv)=="function" then return getgenv().script_key end end,
        function() if type(shared)=="table" then return shared.scriptkey end end,
        function() if type(shared)=="table" then return shared.script_key end end,
    }
    for _,get in ipairs(getters) do
        local ok,value=pcall(get)
        local key=ok and keyText(value) or ""
        if key~="" then return key end
    end
    return ""
end
local K=explicitKey()
local keySource=K~="" and "explicit" or "none"
if K=="" then K=loadStoredKey();if K~="" then keySource="saved" end end
-- End key persistence
local __b32=bit32
if type(__b32)~="table" then
local MOD=4294967296
local function norm(n) n=n%MOD; if n<0 then n=n+MOD end; return n end
local function band(a,b) a,b=norm(a),norm(b) local r,p=0,1 for _=1,32 do local abit,bbit=a%2,b%2 if abit==1 and bbit==1 then r=r+p end a,b,p=(a-abit)/2,(b-bbit)/2,p*2 end return r end
local function bor(a,b) a,b=norm(a),norm(b) local r,p=0,1 for _=1,32 do local abit,bbit=a%2,b%2 if abit==1 or bbit==1 then r=r+p end a,b,p=(a-abit)/2,(b-bbit)/2,p*2 end return r end
local function bxor(a,b,...) a,b=norm(a),norm(b) local r,p=0,1 for _=1,32 do local abit,bbit=a%2,b%2 if abit~=bbit then r=r+p end a,b,p=(a-abit)/2,(b-bbit)/2,p*2 end if select("#",...)>0 then return bxor(r,...) end return r end
local function bnot(a) return norm(MOD-1-norm(a)) end
local function lshift(a,n) n=math.floor(tonumber(n) or 0)%32 return norm(norm(a)*(2^n)) end
local function rshift(a,n) n=math.floor(tonumber(n) or 0)%32 return math.floor(norm(a)/(2^n)) end
local function rrotate(a,n) n=math.floor(tonumber(n) or 0)%32 a=norm(a) return norm(rshift(a,n)+lshift(a,32-n)) end
__b32={band=band,bor=bor,bxor=bxor,bnot=bnot,lshift=lshift,rshift=rshift,rrotate=rrotate}
end
local band,bxor,bnot,rrot,rshift=__b32.band,__b32.bxor,__b32.bnot,__b32.rrotate,__b32.rshift
local schar,sbyte,ssub,srep,fmt,floor=string.char,string.byte,string.sub,string.rep,string.format,math.floor
-- Reuse byte values instead of calling tonumber/string.char for every hex pair.
local hexBytes={}
for i=0,255 do
    local h=fmt("%02x",i)
    local c=schar(i)
    hexBytes[h]=c
    hexBytes[string.upper(h)]=c
    hexBytes[string.upper(ssub(h,1,1))..ssub(h,2,2)]=c
    hexBytes[ssub(h,1,1)..string.upper(ssub(h,2,2))]=c
end
local function unhex(s) return (s:gsub("%x%x",hexBytes)) end
local Kc={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}
local M32=4294967296
local function H(msg)
local len=#msg local bl=len*8 local tail=""
for i=7,0,-1 do tail=tail..schar(floor(bl/2^(8*i))%256) end
msg=msg.."\128"..srep("\0",(55-len)%64)..tail
local h0,h1,h2,h3,h4,h5,h6,h7=0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19
local w={}
for c=1,#msg,64 do
for i=0,15 do local a,b,cc,d=sbyte(msg,c+i*4,c+i*4+3) w[i]=((a*256+b)*256+cc)*256+d end
for i=16,63 do local x,y=w[i-15],w[i-2] local s0=bxor(rrot(x,7),rrot(x,18),rshift(x,3)) local s1=bxor(rrot(y,17),rrot(y,19),rshift(y,10)) w[i]=(w[i-16]+s0+w[i-7]+s1)%M32 end
local a,b,cc,d,e,f,g,h=h0,h1,h2,h3,h4,h5,h6,h7
for i=0,63 do
local S1=bxor(rrot(e,6),rrot(e,11),rrot(e,25)) local ch=bxor(band(e,f),band(bnot(e),g)) local t1=(h+S1+ch+Kc[i+1]+w[i])%M32
local S0=bxor(rrot(a,2),rrot(a,13),rrot(a,22)) local mj=bxor(band(a,b),band(a,cc),band(b,cc)) local t2=(S0+mj)%M32
h,g,f,e,d,cc,b,a=g,f,e,(d+t1)%M32,cc,b,a,(t1+t2)%M32
end
h0,h1,h2,h3=(h0+a)%M32,(h1+b)%M32,(h2+cc)%M32,(h3+d)%M32
h4,h5,h6,h7=(h4+e)%M32,(h5+f)%M32,(h6+g)%M32,(h7+h)%M32
end
local out={} for _,v in ipairs({h0,h1,h2,h3,h4,h5,h6,h7}) do out[#out+1]=schar(floor(v/16777216)%256,floor(v/65536)%256,floor(v/256)%256,v%256) end
return table.concat(out)
end
local function X(s) return (s:gsub(".",function(c) return fmt("%02x",sbyte(c)) end)) end
local function Z(s,ch) local o={} for i=1,#s do o[i]=schar(bxor(sbyte(s,i),ch)) end return table.concat(o) end
local function M(k,m) if #k>64 then k=H(k) end k=k..srep("\0",64-#k) return H(Z(k,0x5c)..H(Z(k,0x36)..m)) end
local function E(a,b) if #a~=#b then return false end local r=0 local bor=__b32.bor for i=1,#a do r=bor(r,bxor(sbyte(a,i),sbyte(b,i))) end return r==0 end
-- SALT recovered from auth salt_enc under KS (not embedded in this client).
local SALT=""
local function pad(k) if #k>64 then k=H(k) end return k..srep("\0",64-#k) end
local function PM(msg) local k=pad(SALT) return H(Z(k,0x5c)..H(Z(k,0x36)..msg)) end
local function PS(prefix,KS) return H(prefix.."|"..SALT..KS) end
local function unxor_salt(hex,ks)
  local stream=H(ks..":csalt")
  local raw=unhex(hex)
  local o={}
  for i=1,#raw do o[i]=schar(bxor(sbyte(raw,i),sbyte(stream,((i-1)%#stream)+1))) end
  return table.concat(o)
end
-- Soft anti-tamper: do not fail when loadstring/request are Lua wrappers (Volt/UNC common). HMAC session is the real check.
local function U(s) return (tostring(s):gsub("[^%w%-_%.~]",function(c) return fmt("%%%02X",sbyte(c)) end)) end
local function G(url)
local ok,body=pcall(function() return game:HttpGet(url) end)
if ok and type(body)=="string" then return body end
ok,body=pcall(function() return game:HttpGetAsync(url) end)
if ok and type(body)=="string" then return body end
if type(httpget)=="function" then ok,body=pcall(httpget,url) if ok and type(body)=="string" then return body end end
if type(HttpGet)=="function" then ok,body=pcall(HttpGet,url) if ok and type(body)=="string" then return body end end
for _,get in ipairs({function() return request end,function() return http_request end,function() return syn.request end,function() return http.request end,function() return fluxus.request end}) do
local found,req=pcall(get)
if found and type(req)=="function" then
local ok2,r=pcall(req,{Url=url,Method="GET"})
if ok2 and type(r)=="table" and (not r.StatusCode or r.StatusCode<400) and type(r.Body or r.body)=="string" then return r.Body or r.body end
if ok2 and type(r)=="string" then return r end
end
end
return nil
end
local function RH()
for _,f in ipairs({function() return gethwid() end,function() return get_hwid() end,function() return getexecutorhwid() end,function() return game:GetService("RbxAnalyticsService"):GetClientId() end}) do
local ok,v=pcall(f) if ok and v~=nil and tostring(v)~="" then return tostring(v) end
end
return nil
end

-- Mid-session heartbeat (analytics + expiry notice).
-- Expiry does NOT stop the running script. It only shows a Discord popup once.
-- Next load still requires a valid key/trial (server auth). Heartbeats continue
-- after expiry for telemetry; server marks status=expired so live counters exclude them.
local pendingHb=nil
local hbPopupShown=false
local function openDiscord(url)
  url=tostring(url or (BASE.."/discord"))
  pcall(function() if type(setclipboard)=="function" then setclipboard(url) end end)
  local opened=false
  pcall(function()
    local gs=game:GetService("GuiService")
    if gs and type(gs.OpenBrowserWindow)=="function" then gs:OpenBrowserWindow(url); opened=true end
  end)
  if not opened then pcall(function() if type(open_browser)=="function" then open_browser(url); opened=true end end) end
  W("[Mythios] Discord: "..url)
  return opened
end
local function showExpiryPopup(message, discordUrl)
  message=tostring(message or "Access ended \226\128\148 join our Discord server for help.")
  discordUrl=tostring(discordUrl or (BASE.."/discord"))
  pcall(function()
    local parent=game:GetService("CoreGui")
    pcall(function()
      if type(gethui)=="function" then local h=gethui(); if h then parent=h end end
    end)
    local old=parent:FindFirstChild("MythiosExpiry")
    if old then old:Destroy() end
    local gui=Instance.new("ScreenGui")
    gui.Name="MythiosExpiry"
    gui.IgnoreGuiInset=true
    gui.ResetOnSpawn=false
    gui.DisplayOrder=2147483646
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.Parent=parent
    local dim=Instance.new("Frame")
    dim.Size=UDim2.fromScale(1,1)
    dim.BackgroundColor3=Color3.fromRGB(0,0,0)
    dim.BackgroundTransparency=0.35
    dim.BorderSizePixel=0
    dim.Parent=gui
    local card=Instance.new("Frame")
    card.AnchorPoint=Vector2.new(0.5,0.5)
    card.Position=UDim2.fromScale(0.5,0.5)
    card.Size=UDim2.fromOffset(360,210)
    card.BackgroundColor3=Color3.fromRGB(22,18,32)
    card.BorderSizePixel=0
    card.Parent=dim
    local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,14); corner.Parent=card
    local stroke=Instance.new("UIStroke"); stroke.Color=Color3.fromRGB(168,85,247); stroke.Thickness=1.5; stroke.Parent=card
    local title=Instance.new("TextLabel")
    title.BackgroundTransparency=1
    title.Position=UDim2.fromOffset(20,18)
    title.Size=UDim2.new(1,-40,0,28)
    title.Font=Enum.Font.GothamBold
    title.TextSize=18
    title.TextColor3=Color3.fromRGB(248,113,113)
    title.TextXAlignment=Enum.TextXAlignment.Left
    title.Text="Access expired"
    title.Parent=card
    local body=Instance.new("TextLabel")
    body.BackgroundTransparency=1
    body.Position=UDim2.fromOffset(20,52)
    body.Size=UDim2.new(1,-40,0,70)
    body.Font=Enum.Font.Gotham
    body.TextSize=14
    body.TextColor3=Color3.fromRGB(220,214,240)
    body.TextWrapped=true
    body.TextXAlignment=Enum.TextXAlignment.Left
    body.TextYAlignment=Enum.TextYAlignment.Top
    body.Text=message
    body.Parent=card
    local join=Instance.new("TextButton")
    join.Position=UDim2.fromOffset(20,140)
    join.Size=UDim2.new(1,-40,0,40)
    join.BackgroundColor3=Color3.fromRGB(88,101,242)
    join.Text="Join Discord"
    join.Font=Enum.Font.GothamBold
    join.TextSize=15
    join.TextColor3=Color3.fromRGB(255,255,255)
    join.AutoButtonColor=true
    join.Parent=card
    local jc=Instance.new("UICorner"); jc.CornerRadius=UDim.new(0,10); jc.Parent=join
    join.MouseButton1Click:Connect(function() openDiscord(discordUrl) end)
  end)
  W("[Mythios] "..message)
end
local function hbWait(sec)
  if type(task)=="table" and type(task.wait)=="function" then task.wait(sec); return true end
  if type(wait)=="function" then wait(sec); return true end
  -- No yielding wait available: skip heartbeat rather than busy-spin the CPU.
  return false
end
local function startHeartbeat(hb)
  if type(hb)~="table" or type(hb.token)~="string" or #hb.token~=32 then return end
  local interval=tonumber(hb.interval) or 2100
  if interval<60 then interval=60 end
  local token,hw=hb.token,tostring(hb.hwid or "")
  local function maybePopup(data)
    if hbPopupShown then return end
    local access=tostring(data and (data.access or data.status) or "")
    local expired=data and (data.access_expired==true or data.show_popup==true
      or access=="expired" or access=="TRIAL_ENDED" or access=="KEY_EXPIRED"
      or access=="BANNED" or access=="REVOKED")
    if not expired then return end
    hbPopupShown=true
    local msg=(type(data.message)=="string" and data.message~="") and data.message or "Access ended \226\128\148 join our Discord server for help."
    local disc=data.discord or (BASE.."/discord")
    showExpiryPopup(msg,disc)
  end
  local function ping()
    local body=G(BASE.."/api/heartbeat.php?action=ping&token="..U(token).."&hwid="..U(hw))
    if type(body)~="string" or body=="" then return end
    local ok,data=pcall(function() return game:GetService("HttpService"):JSONDecode(body) end)
    if not ok or type(data)~="table" then return end
    -- Never tear down the script. Popup once on access expiry; keep pinging for telemetry.
    maybePopup(data)
    if type(data.interval)=="number" and data.interval>=60 then interval=data.interval end
  end
  -- First check ~60s after load; then every interval (~35m). Sampling is coarse by design.
  if not hbWait(60) then return end
  ping()
  while true do
    if not hbWait(interval) then return end
    ping()
  end
end
local function MythiosUI(info)
	info = type(info) == "table" and info or {}
	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer

	local C = {
		bg = Color3.fromRGB(14, 13, 20),
		panel = Color3.fromRGB(21, 19, 29),
		stroke = Color3.fromRGB(42, 36, 56),
		strokeSoft = Color3.fromRGB(38, 35, 47),
		accent = Color3.fromRGB(124, 58, 237),
		accentLite = Color3.fromRGB(139, 92, 246),
		accentHover = Color3.fromRGB(157, 107, 255),
		text = Color3.fromRGB(240, 238, 246),
		textDim = Color3.fromRGB(169, 163, 184),
		muted = Color3.fromRGB(142, 135, 159),
		placeholder = Color3.fromRGB(107, 100, 128),
		pillText = Color3.fromRGB(237, 231, 255),
		valid = Color3.fromRGB(34, 197, 94),
		invalid = Color3.fromRGB(239, 68, 68),
		checking = Color3.fromRGB(90, 88, 104),
		mutedBtn = Color3.fromRGB(36, 34, 46),
		headerFallback = Color3.fromRGB(26, 21, 48),
	}

	local CARD_W = 420
	local HEADER_H = 120
	local BODY_PAD_T, BODY_PAD_B = 16, 18
	local H_COMPACT, H_KEY = 408, 454
	local ACTION_W = 132

	local function mk(className, props, parent)
		local inst = Instance.new(className)
		for k, v in pairs(props) do
			inst[k] = v
		end
		if parent then
			inst.Parent = parent
		end
		return inst
	end
	local function corner(parent, r)
		return mk("UICorner", { CornerRadius = UDim.new(0, r or 10) }, parent)
	end
	local function stroke(parent, color, th, tr)
		return mk("UIStroke", {
			Color = color or C.stroke,
			Thickness = th or 1,
			Transparency = tr or 0,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}, parent)
	end
	local function pad(parent, t, b, l, r)
		return mk("UIPadding", {
			PaddingTop = UDim.new(0, t or 0),
			PaddingBottom = UDim.new(0, b or 0),
			PaddingLeft = UDim.new(0, l or 0),
			PaddingRight = UDim.new(0, r or 0),
		}, parent)
	end
	local function tween(inst, props, t)
		local tw = TweenService:Create(inst, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
		tw:Play()
		return tw
	end

	local function siteOrigin()
		local candidates = { info.logo or "", info.website or "", info.discord or "", info.getKeyLink or "", BASE or "" }
		for _, u in ipairs(candidates) do
			if type(u) == "string" and u ~= "" then
				local origin = string.match(u, "^(https?://[^/]+)")
				if origin then
					return origin
				end
			end
		end
		if type(BASE) == "string" and BASE ~= "" then
			return string.gsub(BASE, "/$", "")
		end
		return ""
	end
	local function siteUrl(path)
		local origin = siteOrigin()
		if origin == "" then
			return ""
		end
		return origin .. path
	end

	local function destroyOld()
		local names = { "MythiosLoader", "MythiOsKeyLoader" }
		local parents = {}
		pcall(function()
			if type(gethui) == "function" then
				table.insert(parents, gethui())
			end
		end)
		pcall(function()
			table.insert(parents, game:GetService("CoreGui"))
		end)
		pcall(function()
			if LocalPlayer then
				table.insert(parents, LocalPlayer:FindFirstChildOfClass("PlayerGui"))
			end
		end)
		for _, parent in ipairs(parents) do
			if parent then
				for _, name in ipairs(names) do
					local old = parent:FindFirstChild(name)
					if old then
						pcall(function()
							old:Destroy()
						end)
					end
				end
			end
		end
	end
	destroyOld()

	local gui = mk("ScreenGui", {
		Name = "MythiosLoader",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 10000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	local attached = false
	local function attach(v)
		if not v then
			return
		end
		local ok = pcall(function()
			gui.Parent = v
		end)
		if ok and gui.Parent == v then
			attached = true
		end
	end
	if type(gethui) == "function" then
		local ok, v = pcall(gethui)
		if ok then
			attach(v)
		end
	end
	if not attached then
		pcall(function()
			attach(game:GetService("CoreGui"))
		end)
	end
	if not attached then
		pcall(function()
			local pg = LocalPlayer and (LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10))
			attach(pg)
		end)
	end
	if not attached then
		gui:Destroy()
		error("Could not display loader UI")
	end

	local closed = false
	local busy = false
	local resolved = info.resolved ~= false and info.tier ~= nil
	local currentInfo = info
	local spinnerConn = nil
	local viewportConn = nil
	local submitCb = nil

	local dragBeganConn = nil
	local dragEndedConn = nil
	local dragChangedConn = nil

	local function stopSpinner()
		if spinnerConn then
			spinnerConn:Disconnect()
			spinnerConn = nil
		end
	end

	local function disconnectDrag()
		if viewportConn then
			viewportConn:Disconnect()
			viewportConn = nil
		end
		if dragBeganConn then
			dragBeganConn:Disconnect()
			dragBeganConn = nil
		end
		if dragEndedConn then
			dragEndedConn:Disconnect()
			dragEndedConn = nil
		end
		if dragChangedConn then
			dragChangedConn:Disconnect()
			dragChangedConn = nil
		end
	end

	local dim = mk("Frame", {
		Name = "Dim",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
	}, gui)

	local glow = mk("Frame", {
		Name = "Glow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(CARD_W + 28, H_COMPACT + 28),
		BackgroundColor3 = C.accent,
		BackgroundTransparency = 0.88,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, gui)
	corner(glow, 20)

	local root = mk("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(CARD_W, H_COMPACT),
		BackgroundColor3 = C.bg,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		ZIndex = 10,
		Active = true,
		ClipsDescendants = true,
	}, gui)
	corner(root, 14)
	stroke(root, C.stroke, 1, 0)
	local rootScale = mk("UIScale", { Scale = 1 }, root)

	pcall(function()
		local cam = workspace.CurrentCamera
		local gScale = mk("UIScale", { Scale = 1 }, glow)
		local function fitBoth()
			if not gui.Parent or not cam then
				return
			end
			local s = cam.ViewportSize
			local sc = math.clamp(math.min((s.X - 24) / CARD_W, (s.Y - 24) / H_KEY), 0.72, 1.1)
			rootScale.Scale = sc
			gScale.Scale = sc
		end
		fitBoth()
		viewportConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if gui.Parent then
				fitBoth()
			end
		end)
	end)

	local function setCardHeight(withKey, extra)
		local h = (withKey and H_KEY or H_COMPACT) + (extra or 0)
		root.Size = UDim2.fromOffset(CARD_W, h)
		glow.Size = UDim2.fromOffset(CARD_W + 28, h + 28)
	end

	local header = mk("Frame", {
		Name = "Header",
		BackgroundColor3 = C.headerFallback,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, HEADER_H),
		ClipsDescendants = true,
		ZIndex = 20,
	}, root)
	local skyFallback = mk("Frame", {
		BackgroundColor3 = C.headerFallback,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 20,
	}, header)
	mk("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(36, 24, 64), Color3.fromRGB(14, 13, 20)),
		Rotation = 90,
	}, skyFallback)
	local skyImg = mk("ImageLabel", {
		Name = "Skyline",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Image = "",
		ImageColor3 = Color3.fromRGB(255, 240, 255),
		ScaleType = Enum.ScaleType.Crop,
		Visible = false,
		ZIndex = 21,
	}, header)
	do
		local f = mk("Frame", {
			BackgroundColor3 = C.bg,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 56),
			ZIndex = 22,
		}, header)
		mk("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.35, 0.55),
				NumberSequenceKeypoint.new(1, 0),
			}),
			Rotation = 90,
		}, f)
	end

	local logoMark = mk("TextLabel", {
		Name = "LogoMark",
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(18, 18),
		Size = UDim2.fromOffset(44, 44),
		Font = Enum.Font.GothamBold,
		Text = "M",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 20,
		ZIndex = 24,
	}, header)
	corner(logoMark, 22)
	local logoImg = mk("ImageLabel", {
		Name = "LogoImage",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Image = "",
		Visible = false,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 25,
	}, logoMark)
	corner(logoImg, 22)
	mk("TextLabel", {
		Name = "Brand",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(72, 24),
		Size = UDim2.fromOffset(200, 32),
		Font = Enum.Font.GothamBold,
		Text = "MythiOs",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 26,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 24,
	}, header)

	local closeBtn = mk("TextButton", {
		Name = "Close",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 10),
		Size = UDim2.fromOffset(28, 28),
		Font = Enum.Font.GothamBold,
		Text = "X",
		TextColor3 = C.textDim,
		TextSize = 14,
		ZIndex = 26,
	}, header)

	local body = mk("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, HEADER_H),
		Size = UDim2.new(1, 0, 1, -HEADER_H),
		ZIndex = 15,
	}, root)
	pad(body, BODY_PAD_T, BODY_PAD_B, 20, 20)

	mk("TextLabel", {
		Name = "DetectedLbl",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Enum.Font.GothamMedium,
		Text = "Detected game",
		TextColor3 = C.textDim,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 16,
	}, body)

	local gameRow = mk("Frame", {
		Name = "GameRow",
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, 0, 0, 64),
		ZIndex = 16,
	}, body)
	corner(gameRow, 10)
	stroke(gameRow, C.strokeSoft, 1, 0)

	local detectingHold = mk("Frame", {
		Name = "DetectingHold",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 19,
		Visible = not resolved,
	}, gameRow)
	mk("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, detectingHold)
	local spinnerBox = mk("Frame", {
		Name = "Spinner",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(18, 18),
		LayoutOrder = 1,
		ClipsDescendants = true,
		ZIndex = 20,
	}, detectingHold)
	local spinnerImg = mk("ImageLabel", {
		Name = "Arc",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Image = "",
		Visible = false,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 21,
	}, spinnerBox)
	local spinnerFallback = mk("Frame", {
		Name = "Fallback",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 21,
	}, spinnerBox)
	local spinnerStroke = mk("UIStroke", {
		Color = C.accent,
		Thickness = 2,
		Transparency = 0,
	}, spinnerFallback)
	corner(spinnerFallback, 9)
	local spinnerGradient = mk("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, C.accent),
			ColorSequenceKeypoint.new(0.45, C.accent),
			ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, C.accent),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.55, 0.15),
			NumberSequenceKeypoint.new(1, 0.85),
		}),
		Rotation = 0,
	}, spinnerStroke)
	local detectingText = mk("TextLabel", {
		Name = "DetectingText",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = Enum.Font.GothamMedium,
		Text = "Detecting game...",
		TextColor3 = C.textDim,
		TextSize = 14,
		LayoutOrder = 2,
		ZIndex = 20,
	}, detectingHold)

	local iconBox = mk("Frame", {
		Name = "IconBox",
		BackgroundColor3 = Color3.fromRGB(26, 24, 36),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(10, 8),
		Size = UDim2.fromOffset(48, 48),
		Visible = false,
		ZIndex = 17,
	}, gameRow)
	corner(iconBox, 8)
	local gameIcon = mk("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Image = "",
		ScaleType = Enum.ScaleType.Crop,
		Visible = false,
		ZIndex = 18,
	}, iconBox)
	corner(gameIcon, 8)
	local iconFallback = mk("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamBold,
		Text = "\226\151\135",
		TextColor3 = C.textDim,
		TextSize = 18,
		Visible = false,
		ZIndex = 18,
	}, iconBox)

	local gameNameLbl = mk("TextLabel", {
		Name = "GameName",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(68, 0),
		Size = UDim2.new(1, -180, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = C.text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Visible = false,
		ZIndex = 17,
	}, gameRow)

	local pill = mk("TextLabel", {
		Name = "StatusPill",
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(104, 28),
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = C.pillText,
		TextSize = 12,
		Visible = false,
		ZIndex = 18,
	}, gameRow)
	corner(pill, 8)

	mk("TextLabel", {
		Name = "Executor",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 126),
		Size = UDim2.new(1, 0, 0, 16),
		Font = Enum.Font.GothamMedium,
		Text = "Executor: Unknown",
		TextColor3 = C.muted,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 16,
	}, body)
	local execLbl = body:FindFirstChild("Executor")
	pcall(function()
		if type(identifyexecutor) == "function" then
			local n = identifyexecutor()
			if n and tostring(n) ~= "" then
				execLbl.Text = "Executor: " .. tostring(n)
			end
		end
	end)

	local track = mk("Frame", {
		Name = "Track",
		BackgroundColor3 = C.strokeSoft,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 116),
		Size = UDim2.new(1, 0, 0, 4),
		Visible = false,
		ZIndex = 16,
	}, body)
	corner(track, 2)
	local bar = mk("Frame", {
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.12, 1),
		ZIndex = 17,
	}, track)
	corner(bar, 2)

	local detail = mk("TextLabel", {
		Name = "Detail",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 96),
		Size = UDim2.new(1, 0, 0, 16),
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = C.muted,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Visible = false,
		ZIndex = 16,
	}, body)

	local keyRow = mk("Frame", {
		Name = "KeyRow",
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 136),
		Size = UDim2.new(1, 0, 0, 44),
		Visible = false,
		ZIndex = 16,
	}, body)
	corner(keyRow, 10)
	local keyStroke = stroke(keyRow, C.strokeSoft, 1, 0)
	mk("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.fromOffset(24, 44),
		Font = Enum.Font.GothamBold,
		Text = "\226\151\139",
		TextColor3 = C.textDim,
		TextSize = 14,
		ZIndex = 18,
	}, keyRow)
	local keyBox = mk("TextBox", {
		Name = "KeyBox",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(40, 0),
		Size = UDim2.new(1, -50, 1, 0),
		Font = Enum.Font.GothamMedium,
		PlaceholderText = "MYTH-XXXX-XXXX-XXXX",
		PlaceholderColor3 = C.placeholder,
		Text = "",
		TextColor3 = C.text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 18,
	}, keyRow)

	local submit = mk("TextButton", {
		Name = "Submit",
		AutoButtonColor = false,
		Active = false,
		BackgroundColor3 = C.mutedBtn,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 150),
		Size = UDim2.new(1, 0, 0, 46),
		Text = "",
		ZIndex = 16,
	}, body)
	corner(submit, 10)
	local submitGradient = mk("UIGradient", {
		Color = ColorSequence.new(C.accentLite, C.accent),
		Rotation = 90,
		Enabled = false,
	}, submit)
	local submitLabel = mk("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamBold,
		Text = "Detecting Game",
		TextColor3 = C.muted,
		TextSize = 16,
		TextTransparency = 0.1,
		ZIndex = 17,
	}, submit)

	local actions = mk("Frame", {
		Name = "Actions",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 210),
		Size = UDim2.new(1, 0, 0, 44),
		ZIndex = 16,
	}, body)
	local actionsLayout = mk("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, actions)

	local function webImage(img, url, file, onOk)
		if type(url) ~= "string" or url == "" then
			return
		end
		if type(getcustomasset) ~= "function" or type(writefile) ~= "function" then
			return
		end
		task.spawn(function()
			local ok = pcall(function()
				local data
				if type(isfile) == "function" and type(readfile) == "function" and isfile(file) then
					data = readfile(file)
				end
				if type(data) ~= "string" or string.sub(data, 1, 4) ~= "\137PNG" then
					data = game:HttpGet(url)
					if type(data) ~= "string" or string.sub(data, 1, 4) ~= "\137PNG" then
						error("not png")
					end
					if type(makefolder) == "function" then
						local exists = type(isfolder) == "function" and isfolder("mythios")
						if not exists then pcall(makefolder, "mythios") end
					end
					writefile(file, data)
				end
				local id = getcustomasset(file)
				if type(id) ~= "string" or id == "" then
					error("no asset")
				end
				if not gui.Parent then
					return
				end
				img.Image = id
				img.Visible = true
				if type(onOk) == "function" then
					onOk()
				end
			end)
			if not ok and img then
				img.Visible = false
			end
		end)
	end

	local function makeAction(name, order)
		local btn = mk("TextButton", {
			Name = name,
			AutoButtonColor = false,
			BackgroundColor3 = C.panel,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(ACTION_W, 44),
			Text = "",
			LayoutOrder = order,
			Visible = true,
			ZIndex = 17,
		}, actions)
		corner(btn, 10)
		stroke(btn, C.strokeSoft, 1, 0)
		local content = mk("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -10, 1, 0),
			ZIndex = 18,
		}, btn)
		mk("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, content)
		local icon = mk("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 16),
			Image = "",
			ImageColor3 = C.pillText,
			Visible = false,
			LayoutOrder = 1,
			ZIndex = 19,
		}, content)
		local lbl = mk("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(0, 16),
			AutomaticSize = Enum.AutomaticSize.X,
			Font = Enum.Font.GothamMedium,
			Text = name,
			TextColor3 = C.text,
			TextSize = 13,
			LayoutOrder = 2,
			ZIndex = 19,
		}, content)
		btn.MouseEnter:Connect(function()
			tween(btn, { BackgroundColor3 = Color3.fromRGB(28, 26, 40) }, 0.15)
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, { BackgroundColor3 = C.panel }, 0.18)
		end)
		return btn, icon, lbl
	end

	local getKeyBtn, getKeyIcon, getKeyLbl = makeAction("Get Key", 1)
	local discordBtn, discordIcon = makeAction("Discord", 2)
	local websiteBtn, websiteIcon = makeAction("Website", 3)
	getKeyBtn.Visible = false

	local toast = mk("Frame", {
		Name = "Toast",
		BackgroundColor3 = C.panel,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -12),
		AutomaticSize = Enum.AutomaticSize.XY,
		Visible = false,
		ZIndex = 40,
	}, root)
	corner(toast, 8)
	stroke(toast, C.strokeSoft, 1, 0.2)
	pad(toast, 8, 8, 10, 10)
	mk("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, toast)
	local toastLabel = mk("TextLabel", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = C.text,
		TextSize = 12,
		LayoutOrder = 1,
		ZIndex = 41,
	}, toast)
	local toastCopy = mk("TextButton", {
		Name = "CopyLink",
		AutoButtonColor = false,
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(78, 24),
		Font = Enum.Font.GothamMedium,
		Text = "Copy Link",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12,
		Visible = false,
		LayoutOrder = 2,
		ZIndex = 41,
	}, toast)
	corner(toastCopy, 6)
	local toastUrlBox = mk("TextBox", {
		Name = "UrlBox",
		BackgroundColor3 = Color3.fromRGB(26, 24, 36),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(220, 24),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = C.textDim,
		TextSize = 11,
		ClearTextOnFocus = false,
		TextEditable = false,
		Visible = false,
		LayoutOrder = 3,
		ZIndex = 41,
	}, toast)
	corner(toastUrlBox, 6)
	local toastToken = 0
	local toastCopyUrl = ""
	local toastSticky = false

	local function hideToast()
		toastToken = toastToken + 1
		toastSticky = false
		toastCopyUrl = ""
		if toast and toast.Parent then
			toast.Visible = false
			toastCopy.Visible = false
			toastUrlBox.Visible = false
		end
	end

	local function showToast(msg, copyUrl, showUrlBox, sticky)
		toastToken = toastToken + 1
		local token = toastToken
		toastCopyUrl = tostring(copyUrl or "")
		toastSticky = sticky == true and toastCopyUrl ~= ""
		toastLabel.Text = tostring(msg or "")
		toastLabel.TextTransparency = 0
		toast.BackgroundTransparency = 0.05
		toastCopy.Visible = toastCopyUrl ~= "" and not showUrlBox
		toastUrlBox.Visible = showUrlBox == true and toastCopyUrl ~= ""
		if toastUrlBox.Visible then
			toastUrlBox.Text = toastCopyUrl
		end
		toast.Visible = true
		if toastSticky then
			return
		end
		task.delay(1.8, function()
			if token ~= toastToken or not toast.Parent or toastSticky then
				return
			end
			toast.Visible = false
			toastCopy.Visible = false
			toastUrlBox.Visible = false
		end)
	end

	local function copyText(text)
		text = tostring(text or "")
		if text == "" then
			return false
		end
		for _, f in ipairs({
			function()
				if type(setclipboard) == "function" then
					setclipboard(text)
					return true
				end
			end,
			function()
				if type(toclipboard) == "function" then
					toclipboard(text)
					return true
				end
			end,
		}) do
			local ok, v = pcall(f)
			if ok and v then
				return true
			end
		end
		return false
	end

	local function handleLink(url)
		url = string.gsub(string.gsub(tostring(url or ""), "^%s+", ""), "%s+$", "")
		if url == "" then
			showToast("Link not configured.")
			return
		end
		if copyText(url) then
			showToast("Link copied.")
			return
		end
		showToast("Could not copy link.", url, true, true)
	end

	toastCopy.MouseButton1Click:Connect(function()
		if toastCopyUrl == "" then
			return
		end
		local url = toastCopyUrl
		if copyText(url) then
			showToast("Link copied.")
		else
			showToast("Could not copy link.", url, true, true)
		end
	end)

	local function startSpinner()
		stopSpinner()
		spinnerStroke.Transparency = 0
		spinnerConn = RunService.RenderStepped:Connect(function(dt)
			if spinnerImg.Visible then
				spinnerImg.Rotation = (spinnerImg.Rotation + dt * 360) % 360
			else
				spinnerGradient.Rotation = (spinnerGradient.Rotation + dt * 360) % 360
			end
		end)
	end

	local function setPrimary(active, text)
		if active then
			submitGradient.Enabled = true
			submit.BackgroundColor3 = C.accentLite
			submitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			submitLabel.TextTransparency = 0
			submit.Active = true
		else
			submitGradient.Enabled = false
			submit.BackgroundColor3 = C.mutedBtn
			submitLabel.TextColor3 = C.muted
			submitLabel.TextTransparency = 0.1
			submit.Active = false
		end
		if text then
			submitLabel.Text = text
		end
	end

	local function setPill(state)
		if state == "free" then
			pill.Text = "Free"
			pill.BackgroundColor3 = C.valid
			pill.TextColor3 = Color3.fromRGB(255, 255, 255)
			pill.Size = UDim2.fromOffset(64, 28)
		elseif state == "key" then
			pill.Text = "Key required"
			pill.BackgroundColor3 = C.accent
			pill.TextColor3 = C.pillText
			pill.Size = UDim2.fromOffset(104, 28)
		elseif state == "checking" then
			pill.Text = "Checking..."
			pill.BackgroundColor3 = C.checking
			pill.TextColor3 = C.text
			pill.Size = UDim2.fromOffset(96, 28)
		elseif state == "valid" then
			pill.Text = "Valid"
			pill.BackgroundColor3 = C.valid
			pill.TextColor3 = Color3.fromRGB(255, 255, 255)
			pill.Size = UDim2.fromOffset(72, 28)
		elseif state == "invalid" then
			pill.Text = "Invalid"
			pill.BackgroundColor3 = C.invalid
			pill.TextColor3 = Color3.fromRGB(255, 255, 255)
			pill.Size = UDim2.fromOffset(72, 28)
		elseif state == "unsupported" then
			pill.Text = "Unsupported"
			pill.BackgroundColor3 = C.invalid
			pill.TextColor3 = Color3.fromRGB(255, 255, 255)
			pill.Size = UDim2.fromOffset(104, 28)
		elseif state == "error" then
			pill.Text = "Error"
			pill.BackgroundColor3 = C.invalid
			pill.TextColor3 = Color3.fromRGB(255, 255, 255)
			pill.Size = UDim2.fromOffset(72, 28)
		elseif state == "ready" then
			pill.Text = "Ready"
			pill.BackgroundColor3 = C.valid
			pill.TextColor3 = Color3.fromRGB(255, 255, 255)
			pill.Size = UDim2.fromOffset(72, 28)
		elseif state == "loading" then
			pill.Text = "Loading"
			pill.BackgroundColor3 = C.accent
			pill.TextColor3 = C.pillText
			pill.Size = UDim2.fromOffset(80, 28)
		else
			pill.Visible = false
			return
		end
		pill.Visible = true
	end

	local function shake()
		local base = root.Position
		task.spawn(function()
			for i = 1, 5 do
				local ox = (i % 2 == 0) and 6 or -6
				root.Position = UDim2.new(base.X.Scale, base.X.Offset + ox, base.Y.Scale, base.Y.Offset)
				task.wait(0.03)
			end
			root.Position = base
		end)
	end

	local function flashKey()
		tween(keyStroke, { Color = C.invalid }, 0.12)
		task.delay(0.45, function()
			if keyStroke and keyStroke.Parent then
				tween(keyStroke, { Color = C.strokeSoft }, 0.2)
			end
		end)
	end

	local function layout(mode)
		local showKey = mode == "key"
		local showGetKey = mode == "key"
		local extra = showKey and currentInfo.trialEnded == true and 18 or 0
		detail.Size = UDim2.new(1, 0, 0, extra > 0 and 32 or 16)
		detail.TextWrapped = extra > 0
		detail.TextTruncate = extra > 0 and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd
		keyRow.Position = UDim2.fromOffset(0, 136 + extra)
		keyRow.Visible = showKey
		getKeyBtn.Visible = showGetKey
		if showKey then
			execLbl.Position = UDim2.fromOffset(0, 116 + extra)
			submit.Position = UDim2.fromOffset(0, 190 + extra)
			actions.Position = UDim2.fromOffset(0, 250 + extra)
			setCardHeight(true, extra)
			getKeyBtn.Size = UDim2.new(1 / 3, -6, 1, 0)
			discordBtn.Size = UDim2.new(1 / 3, -6, 1, 0)
			websiteBtn.Size = UDim2.new(1 / 3, -6, 1, 0)
		else
			execLbl.Position = UDim2.fromOffset(0, 126)
			submit.Position = UDim2.fromOffset(0, 150)
			actions.Position = UDim2.fromOffset(0, 210)
			setCardHeight(false)
			discordBtn.Size = UDim2.fromOffset(ACTION_W, 44)
			websiteBtn.Size = UDim2.fromOffset(ACTION_W, 44)
		end
		discordBtn.Visible = mode ~= "unsupported"
		websiteBtn.Visible = mode ~= "unsupported"
	end

	local function revealGame(meta)
		meta = type(meta) == "table" and meta or {}
		local name = tostring(meta.gameName or currentInfo.gameName or "Mythios")
		local tier = string.lower(tostring(meta.tier or ""))
		detectingHold.Visible = false
		stopSpinner()
		gameNameLbl.Text = name
		gameNameLbl.Visible = true
		gameNameLbl.Position = UDim2.fromOffset(68, 0)
		gameNameLbl.Size = UDim2.new(1, -180, 1, 0)
		iconBox.Visible = true
		local uid = 0
		pcall(function()
			uid = tonumber(game.GameId) or 0
		end)
		if uid > 0 then
			gameIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(uid) .. "&w=150&h=150"
			gameIcon.Visible = true
			iconFallback.Visible = false
		else
			gameIcon.Visible = false
			iconFallback.Visible = true
		end
		if tier == "free" then
			setPill("free")
			layout("free")
			setPrimary(false, "Starting...")
		elseif tier == "paid" or tier == "free_key" then
			setPill("key")
			layout("idle")
			setPrimary(false, "Waiting...")
			if tier == "paid" then
				getKeyLbl.Text = "Get Premium"
			else
				getKeyLbl.Text = "Get Key"
			end
		else
			setPill("key")
			layout("idle")
			setPrimary(false, "Waiting...")
		end
	end

	local function applyLinks(meta)
		meta = type(meta) == "table" and meta or currentInfo
		local origin = siteOrigin()
		if origin ~= "" then currentInfo.discord = origin .. "/discord" end
		local logoUrl = type(meta.logo) == "string" and meta.logo ~= "" and meta.logo or siteUrl("/assets/mythios-logo-128.png?v=3")
		local discordIconUrl = type(meta.discordIcon) == "string" and meta.discordIcon ~= "" and meta.discordIcon or siteUrl("/assets/discord-mark.png?v=1")
		webImage(logoImg, logoUrl, "mythios/logo-v3.png", function()
			logoMark.Text = ""
		end)
		webImage(skyImg, siteUrl("/assets/home-skyline.png"), "mythios/header-skyline-v1.png", function()
			skyImg.Visible = true
			skyFallback.Visible = false
		end)
		webImage(discordIcon, discordIconUrl, "mythios/discord-mark-v1.png")
		webImage(websiteIcon, siteUrl("/assets/loader/icon_website.png"), "mythios/icon-website-v1.png", function() end)
		webImage(getKeyIcon, siteUrl("/assets/loader/icon_get_key.png"), "mythios/icon-get-key-v1.png")
		webImage(spinnerImg, siteUrl("/assets/loader/spinner_arc.png"), "mythios/spinner-arc-v1.png", function()
			spinnerImg.Visible = true
			spinnerFallback.Visible = false
		end)
		if origin == "" and type(BASE) == "string" then
			webImage(skyImg, string.gsub(BASE, "/$", "") .. "/assets/home-skyline.png", "mythios/header-skyline-v1.png", function()
				skyImg.Visible = true
				skyFallback.Visible = false
			end)
		end
	end

	local ui = {}

	function ui.destroy()
		closed = true
		busy = false
		submitCb = nil
		hideToast()
		stopSpinner()
		disconnectDrag()
		pcall(function()
			gui:Destroy()
		end)
	end

	function ui.resolve(meta)
		if closed or not gui.Parent then
			return
		end
		currentInfo = type(meta) == "table" and meta or currentInfo
		resolved = true
		applyLinks(currentInfo)
		revealGame(currentInfo)
	end

	-- Status line while the game is not resolved yet (PlaceId is read locally; the server check is pending).
	function ui.status(text)
		if closed or not gui.Parent or resolved then
			return
		end
		detectingText.Text = tostring(text or "")
		setPrimary(false, "Checking...")
	end

	function ui.progress(text, n)
		if closed or not gui.Parent then
			return
		end
		busy = false
		keyRow.Visible = false
		getKeyBtn.Visible = false
		track.Visible = true
		detail.Visible = true
		detail.Text = tostring(text or "")
		detail.TextColor3 = C.muted
		n = tonumber(n) or 0
		if n < 0 then
			n = 0
		end
		if n > 1 then
			n = 1
		end
		pcall(function()
			tween(bar, { Size = UDim2.fromScale(n, 1) }, 0.2)
		end)
		setPill("loading")
		setPrimary(false, "Loading...")
		layout(string.lower(tostring(currentInfo.tier or "")) == "free" and "free" or "idle")
		if detectingHold.Visible then
			detectingHold.Visible = false
			stopSpinner()
		end
	end

	function ui.fail(text)
		if not gui.Parent then
			return
		end
		busy = false
		stopSpinner()
		detectingHold.Visible = false
		detail.Visible = true
		detail.Text = tostring(text or "Something went wrong")
		detail.TextColor3 = C.invalid
		setPill("error")
		setPrimary(false, "Unavailable")
		track.Visible = false
		keyRow.Visible = false
		getKeyBtn.Visible = false
		layout("idle")
		showToast(tostring(text or "Something went wrong"))
	end

	function ui.unsupported()
		if not gui.Parent then
			return
		end
		busy = false
		stopSpinner()
		detectingHold.Visible = false
		gameNameLbl.Text = "Game not supported"
		gameNameLbl.Visible = true
		gameNameLbl.Position = UDim2.fromOffset(16, 0)
		gameNameLbl.Size = UDim2.new(1, -140, 1, 0)
		iconBox.Visible = false
		setPill("unsupported")
		detail.Visible = true
		detail.Text = "This game is not supported by Mythios yet"
		detail.TextColor3 = C.invalid
		keyRow.Visible = false
		getKeyBtn.Visible = false
		setPrimary(false, "Unavailable")
		layout("unsupported")
	end

	function ui.prompt(submit, err)
		if not gui.Parent then
			return
		end
		busy = false
		submitCb = submit
		local trialNotice = "Your trial expired, please join our Discord server to extend it \226\128\148 free key, no ads, no server join required."
		local trialEnded = currentInfo.trialEnded == true
		if trialEnded and not err then err = trialNotice end
		local isTrialNotice = trialEnded and err == trialNotice
		stopSpinner()
		detectingHold.Visible = false
		track.Visible = false
		detail.Visible = err ~= nil
		if err and not isTrialNotice then
			detail.Text = tostring(err)
			detail.TextColor3 = C.invalid
			setPill("invalid")
			flashKey()
			shake()
		else
			detail.Text = isTrialNotice and trialNotice or ""
			detail.TextColor3 = C.muted
			setPill("key")
		end
		local paid = string.lower(tostring(currentInfo.tier or "")) == "paid"
		getKeyLbl.Text = (trialEnded or currentInfo.hasTrial == true) and "Get Key" or (paid and "Get Premium" or "Get Key")
		layout("key")
		setPrimary(true, "Submit")
		keyBox.Text = ""
		if not gameNameLbl.Visible then
			revealGame(currentInfo)
			layout("key")
			setPrimary(true, "Submit")
		end
	end

	function ui.done()
		if not gui.Parent then
			return
		end
		busy = false
		stopSpinner()
		keyRow.Visible = false
		getKeyBtn.Visible = false
		track.Visible = true
		bar.BackgroundColor3 = C.valid
		bar.Size = UDim2.fromScale(1, 1)
		detail.Visible = true
		detail.Text = tostring(currentInfo.gameName or "Mythios") .. " loaded"
		detail.TextColor3 = C.valid
		setPill("ready")
		setPrimary(false, "Ready")
		task.delay(0.65, function()
			if not gui.Parent then
				return
			end
			for _, v in ipairs(gui:GetDescendants()) do
				pcall(function()
					local goal = {}
					if v:IsA("GuiObject") then
						goal.BackgroundTransparency = 1
					end
					if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
						goal.TextTransparency = 1
					end
					if v:IsA("ImageLabel") then
						goal.ImageTransparency = 1
					end
					if v:IsA("UIStroke") then
						goal.Transparency = 1
					end
					if next(goal) then
						tween(v, goal, 0.25)
					end
				end)
			end
			task.delay(0.3, function()
				ui.destroy()
			end)
		end)
	end

	local function doSubmit()
		if busy or closed or not submit.Active then
			return
		end
		if type(submitCb) ~= "function" then
			return
		end
		local key = string.gsub(string.gsub(tostring(keyBox.Text or ""), "^%s+", ""), "%s+$", "")
		if key == "" then
			ui.fail("Enter a key first.")
			busy = false
			layout("key")
			setPrimary(true, "Submit")
			return
		end
		busy = true
		setPrimary(false, "Checking...")
		setPill("checking")
		submitCb(key)
	end

	submit.MouseButton1Click:Connect(doSubmit)
	keyBox.FocusLost:Connect(function(enter)
		if enter then
			doSubmit()
		end
	end)
	submit.MouseEnter:Connect(function()
		if busy or not submit.Active or not submitGradient.Enabled then
			return
		end
		tween(submit, { BackgroundColor3 = C.accentHover }, 0.15)
	end)
	submit.MouseLeave:Connect(function()
		if busy or not submitGradient.Enabled then
			return
		end
		tween(submit, { BackgroundColor3 = C.accentLite }, 0.18)
	end)

	getKeyBtn.MouseButton1Click:Connect(function()
		local paid = string.lower(tostring(currentInfo.tier or "")) == "paid"
		local trialHub = currentInfo.trialEnded == true or currentInfo.hasTrial == true
		local url = trialHub and currentInfo.discord or (paid and currentInfo.website or currentInfo.getKeyLink)
		handleLink(url)
	end)
	discordBtn.MouseButton1Click:Connect(function()
		handleLink(currentInfo.discord)
	end)
	websiteBtn.MouseButton1Click:Connect(function()
		handleLink(currentInfo.website)
	end)

	closeBtn.MouseButton1Click:Connect(function()
		ui.destroy()
	end)

	do
		local dragging = false
		local dragStart, startPos
		dragBeganConn = header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = root.Position
			end
		end)
		dragEndedConn = header.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		dragChangedConn = UserInputService.InputChanged:Connect(function(input)
			if not dragging then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local delta = input.Position - dragStart
				root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				glow.Position = root.Position
			end
		end)
	end

	gui.Destroying:Connect(function()
		closed = true
		hideToast()
		stopSpinner()
		disconnectDrag()
	end)
	gui.AncestryChanged:Connect(function(_, parent)
		if not parent then
			closed = true
			hideToast()
			stopSpinner()
			disconnectDrag()
		end
	end)

	applyLinks(currentInfo)
	if not resolved then
		layout("idle")
		setPrimary(false, "Detecting Game")
		detectingHold.Visible = true
		startSpinner()
	else
		revealGame(currentInfo)
	end

	return ui
end

local info={supported=true,gameName="Mythios",tier="paid",mode="none"}
local place=0
pcall(function() place=tonumber(game.PlaceId) or 0 end)
local ui
-- One request (api/start.php) returns game info, the access result and, when allowed, the script.
-- ONE turns off and the older loader-info/auth/load requests are used if that reply is unusable.
local ONE=SLUG=="@freemium" or SLUG=="@premium"
local function device()
    local hw=RH() if not hw then return nil end
    local seed=tostring(os.clock())..tostring(os.time())..tostring({})..tostring(math.random())
    pcall(function() seed=seed..tostring(tick())..game:GetService("HttpService"):GenerateGUID(false) end)
    local exec=""
    pcall(function()
      if type(identifyexecutor)=="function" then local a=identifyexecutor(); if a~=nil then exec=tostring(a) end end
    end)
    if exec=="" then pcall(function() if type(getexecutorname)=="function" then local a=getexecutorname(); if a~=nil then exec=tostring(a) end end end) end
    if exec=="" then pcall(function() if type(ExecutorName)=="string" then exec=ExecutorName end end) end
    if #exec>64 then exec=string.sub(exec,1,64) end
    return X(H("mythios-hwid|"..hw)),ssub(X(H(seed..hw)),1,32),exec
end
local function oneCall(key,startup,hasUi)
    local hwid,nonce,exec=device()
    if not hwid then return nil,"[Mythios] could not read HWID" end
    local gid=0
    pcall(function() gid=tonumber(game.GameId) or 0 end)
    local body=G(BASE.."/api/start.php?script="..U(SLUG).."&key="..U(key).."&hwid="..hwid.."&nonce="..nonce.."&ts="..os.time().."&place_id="..tostring(place).."&game_id="..tostring(gid)..(exec~="" and ("&executor="..U(exec)) or "")..(startup and ("&phase=start&ui="..(hasUi and "1" or "0")) or "&phase=auth"))
    if type(body)~="string" or ssub(body,1,6)~="MYTH1\n" then return nil,"[Mythios] could not reach server" end
    local a=string.find(body,"\n",7,true)
    local b=a and string.find(body,"\n",a+1,true)
    if not b then return nil,"[Mythios] invalid server response" end
    local ok,v=pcall(function() return game:GetService("HttpService"):JSONDecode(ssub(body,7,a-1)) end)
    local r={hwid=hwid,nonce=nonce,info=ok and type(v)=="table" and v or nil,auth=ssub(body,a+1,b-1),load=ssub(body,b+1)}
    body=nil
    if r.auth=="" then r.auth=nil end
    if r.load=="" then r.load=nil end
    return r
end
local first
if SLUG=="@freemium" or SLUG=="@premium" then
    -- No window before the reply: the game's Loader UI setting (default/none/custom) is only known from it.
    -- ui=1 tells the server this client can show the key screen if the game uses the default loader.
    first=oneCall(K,true,type(MythiosUI)=="function")
    local ok,v=true,first and first.info
    if type(v)~="table" then
        ONE=false first=nil
        local raw=G(BASE.."/api/loader-info.php?place_id="..tostring(place))
        ok,v=pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
    end
    if not ok or type(v)~="table" or v.error then
        if ui and type(ui.fail)=="function" then
            local okFail,errFail=pcall(ui.fail,"Could not load game information. Try again.")
            if not okFail then W("[Mythios] "..tostring(errFail)) ui=nil end
        end
        return W("[Mythios] Could not load game information. Try again.")
    end
    info=v
end
info.gameName=tostring(info.gameName or "Mythios")
info.mode=info.mode or "default"
if SLUG=="@freemium" or SLUG=="@premium" then
    if info.mode=="none" or info.mode=="custom" then
        if ui and type(ui.destroy)=="function" then
            local okDes,errDes=pcall(ui.destroy)
            if not okDes then W("[Mythios] "..tostring(errDes)) end
        end
        ui=nil
    elseif not ui then
        local ok,v=pcall(MythiosUI,info) if ok then ui=v else W("[Mythios] "..tostring(v)) end
    end
elseif info.mode~="none" and info.mode~="custom" then
    local ok,v=pcall(MythiosUI,info) if ok then ui=v else W("[Mythios] "..tostring(v)) end
end
if not info.supported then
    if not ui then local ok,v=pcall(MythiosUI,{gameName="Mythios"}) if ok then ui=v end end
    if ui then ui.unsupported() else W("[Mythios] This game is not supported by Mythios yet") end
    return
end
-- Presentation mode does not decide access. auth.php still resolves the game and key scope.
if info.mode~="none" and info.tier=="paid" and SLUG=="@freemium" then SLUG="@premium" end
local function authenticate(inputKey,pre)
local K=inputKey
local W=function(message) return false,(tostring(message):gsub("^%[Mythios%] ","")) end
local SALT=""
local function PM(msg) local k=pad(SALT) return H(Z(k,0x5c)..H(Z(k,0x36)..msg)) end
local function PS(prefix,KS) return H(prefix.."|"..SALT..KS) end
local hwid,nonce,resp,one
if ONE then
  one=pre
  if not (one and one.auth) then
    local why
    one,why=oneCall(K,false)
    if not one then return W(why) end
  end
  hwid,nonce,resp=one.hwid,one.nonce,one.auth
else
  local exec
  hwid,nonce,exec=device()
  if not hwid then return W("[Mythios] could not read HWID") end
  resp=G(BASE.."/api/auth.php?script="..U(SLUG).."&key="..U(K).."&hwid="..hwid.."&nonce="..nonce.."&ts="..os.time().."&place_id="..tostring(place)..(exec~="" and ("&executor="..U(exec)) or ""))
end
if not resp then return W("[Mythios] could not reach server") end
-- Prefer staged salt (4-field auth). Legacy 5-field auth still accepted.
local status,token,sts,sig,senc=resp:match("^(%u[%u_]*)|(%x*)|(%d+)|(%x+)|(%x+)$")
if not status then status,token,sts,sig=resp:match("^(%u[%u_]*)|(%x*)|(%d+)|(%x+)$") end
if not status then return W("[Mythios] invalid server response") end
if status=="TRIAL_ENDED" then info.trialEnded=true end
local msgs={TRIAL_ENDED="Your trial expired, please join our Discord server to extend it \226\128\148 free key, no ads, no server join required.",KEY_INVALID="Invalid key",KEY_EXPIRED="Key expired",HWID_MISMATCH="HWID mismatch - reset your HWID",RATE_LIMITED="Too many requests, slow down",BANNED="You are banned",REPLAY="Request rejected",OUTDATED="This loader is outdated. Get the new one at "..BASE,PLACE_UNKNOWN="This game is not supported by Mythios yet",PREMIUM_REQUIRED="This game needs a Premium key. Use the Premium loader with script_key set",KEY_REQUIRED="script_key is not set. Get a key at "..BASE.."/keys.php"}
local KS=""
if #token==64 then KS=ssub(token,33) end
local kmat=(#KS>0) and KS or token
local authStatus,authToken,authSts,authSig=status,token,sts,sig
if type(senc)=="string" and #senc>0 then
  SALT=unxor_salt(senc,kmat)
  if not E(X(PM(status.."|"..token.."|"..nonce.."|"..sts)),sig) then return W("[Mythios] invalid server response") end
elseif status~="OK" and status~="FREE" then
  -- error reply: no salt_enc
else
  -- success without salt_enc: salt staged on load.php
end
if #token==64 then token=ssub(token,1,32) end
if status=="FREE" then K="FREE" status="OK" end
if status~="OK" then return false,(msgs[status] or "Authentication failed"),status end
-- With the one-request flow the script is already downloaded here.
if ui then ui.progress(one and "Unpacking script" or "Downloading script",.55) paint() end
local body
if one then body=one.load one.load=nil else body=G(BASE.."/api/load.php?token="..token.."&nonce="..nonce) end
if not body then return W("[Mythios] could not download script") end
local cthex,mac,lsenc=body:match("^(%x*)|(%x+)|(%x+)$")
if not cthex then cthex,mac=body:match("^(%x*)|(%x+)$") end
if not cthex then return W("[Mythios] load failed") end
if (not SALT or #SALT==0) and type(lsenc)=="string" and #lsenc>0 then
  SALT=unxor_salt(lsenc,kmat)
  if not E(X(PM(authStatus.."|"..authToken.."|"..nonce.."|"..authSts)),authSig) then return W("[Mythios] invalid server response") end
end
if not SALT or #SALT==0 then return W("[Mythios] invalid server response") end
local sk=PS(K.."|"..hwid.."|"..nonce.."|"..token,KS)
local ct=unhex(cthex)
if not E(X(M(sk,ct)),mac) then return W("[Mythios] integrity check failed") end
local unpackf=unpack or table.unpack
local out,buf,n={},{},#ct
for blk=0,floor((n-1)/32) do
local ks=H(sk..":"..blk)
for j=1,32 do
local i=blk*32+j if i>n then break end
buf[#buf+1]=bxor(sbyte(ct,i),sbyte(ks,j))
if #buf>=4000 then out[#out+1]=schar(unpackf(buf)) buf={} end
end
end
if #buf>0 then out[#out+1]=schar(unpackf(buf)) end
local src=table.concat(out) ct,cthex,body=nil,nil,nil
if ui then ui.progress("Preparing script",.75) paint() end
local fn,err=LS(src,"="..SLUG) src=nil
if not fn then return W("[Mythios] script error: "..tostring(err)) end
local ckb=H(sk..":ck")
local function DK(ci,hex)
local c=unhex(hex)
local o,b,m={}, {},#c
for blk=0,floor((m-1)/32) do
local ks=H(ckb..":"..ci..":"..blk)
for j=1,32 do local i=blk*32+j if i>m then break end b[#b+1]=bxor(sbyte(c,i),sbyte(ks,j)) if #b>=4000 then o[#o+1]=schar(unpackf(b)) b={} end end
end
if #b>0 then o[#o+1]=schar(unpackf(b)) end
return table.concat(o)
end
-- Potassium/UNC: Roblox globals may be lexical to THIS chunk only (not getgenv/_G).
-- Capture them here (HttpGet already proved `game` works) and pass into the VM env.
local host={}
for _,nm in ipairs({"game","workspace","script","Instance","Enum","Vector3","Vector2","CFrame","Color3","UDim2","UDim","Ray","Region3","TweenInfo","BrickColor","task","wait","spawn","delay","tick","time","typeof","Drawing","require","SharedTable","buffer"}) do
  local ok,v=pcall(function()
    if nm=="game" then return game elseif nm=="workspace" then return workspace
    elseif nm=="script" then return script elseif nm=="Instance" then return Instance
    elseif nm=="Enum" then return Enum elseif nm=="Vector3" then return Vector3
    elseif nm=="Vector2" then return Vector2 elseif nm=="CFrame" then return CFrame
    elseif nm=="Color3" then return Color3 elseif nm=="UDim2" then return UDim2
    elseif nm=="UDim" then return UDim elseif nm=="Ray" then return Ray
    elseif nm=="Region3" then return Region3 elseif nm=="TweenInfo" then return TweenInfo
    elseif nm=="BrickColor" then return BrickColor elseif nm=="task" then return task
    elseif nm=="wait" then return wait elseif nm=="spawn" then return spawn
    elseif nm=="delay" then return delay elseif nm=="tick" then return tick
    elseif nm=="time" then return time elseif nm=="typeof" then return typeof
    elseif nm=="Drawing" then return Drawing elseif nm=="require" then return require
    elseif nm=="SharedTable" then return SharedTable elseif nm=="buffer" then return buffer end
    return nil
  end)
  if ok and v~=nil then host[nm]=v end
end
-- Claim run-session via separate endpoint so load.php stays 3-field (old clients compatible).
do
  local claim=G(BASE.."/api/heartbeat.php?action=start&token="..U(token).."&nonce="..U(nonce).."&hwid="..U(hwid))
  if type(claim)=="string" and claim~="" then
    local okC,data=pcall(function() return game:GetService("HttpService"):JSONDecode(claim) end)
    if okC and type(data)=="table" and data.ok==true and type(data.token)=="string" and #data.token==32 and type(data.mac)=="string" then
      local interval=tonumber(data.interval) or 2100
      local expect=X(M(sk,"hb|"..string.lower(data.token).."|"..tostring(math.floor(interval))))
      if E(expect,string.lower(data.mac)) then
        pendingHb={token=string.lower(data.token),interval=interval,hwid=hwid}
      end
    end
  end
end
local ctx={sv=X(M(sk,"mythios-sv")),hwid=hwid,nonce=nonce,kh=ssub(X(H(K)),1,16),ts=os.time(),dk=DK,vk=H(sk..":vmconst"),host=host}
sk=nil
return true,function() return fn(K,ctx) end,authStatus=="OK"
end
local prepared
local loading=false
local function submitKey(key,pre)
    if loading then return false,"A load is already in progress." end
    if type(key)~="string" or #key>64 then return false,"Enter a valid key." end
    prepared=nil
    local ok,good,result,validated=pcall(authenticate,key,pre)
    if not ok then return false,"Could not prepare the script. Please try again." end
    if not good then
        if keySource=="saved" and key==K and (validated=="KEY_INVALID" or validated=="KEY_EXPIRED" or validated=="HWID_MISMATCH" or validated=="TRIAL_ENDED") then
            forgetStoredKey() K="" keySource="none"
        end
        return false,result
    end
    if validated==true then persistKey(key) end
    K=key prepared=result
    return true
end
local function loadPrepared()
    if loading then return false,"A load is already in progress." end
    if not prepared then
        local ok,err=submitKey(K)
        if not ok then return false,err end
    end
    loading=true
    local run=prepared prepared=nil
    -- Handoff is the completion point for the loader, not the game's lifetime loop.
    if ui then ui.done() end
    if pendingHb then
      local hb=pendingHb pendingHb=nil
      local function kick()
        local okHb,errHb=pcall(startHeartbeat,hb)
        if not okHb then W("[Mythios] heartbeat: "..tostring(errHb)) end
      end
      if type(task)=="table" and type(task.spawn)=="function" then task.spawn(kick)
      elseif type(spawn)=="function" then spawn(kick)
      else W("[Mythios] heartbeat skipped: no task.spawn/spawn") end
    end
    local ok,err=pcall(run)
    if not ok then W("[Mythios] Script error: "..tostring(err)) return false,tostring(err) end
    return true
end
local function start(key,pre)
    if ui then ui.progress("Checking access",.25) paint() end
    local ok,err=submitKey(key,pre)
    if not ok then
        if ui and info.tier~="free" then ui.prompt(start,err) elseif ui then ui.fail(err) else W("[Mythios] "..tostring(err)) end
        return
    end
    if ui then ui.progress("Starting your script",.9) end
    local good,msg=loadPrepared()
    if not good then if ui then ui.fail(msg) else W("[Mythios] "..tostring(msg)) end end
end
if info.mode=="custom" then
    local api={gameName=info.gameName,tier=info.tier,getKeyLink=info.getKeyLink,discord=info.discord,website=info.website,key=K,submitKey=submitKey,load=loadPrepared}
    local f,err=LS(info.custom or "","=MythiosCustomLoader")
    if not f then return W("[Mythios] Custom loader syntax error: "..tostring(err)) end
    local ok,msg=pcall(f,api)
    if not ok then W("[Mythios] Custom loader error: "..tostring(msg)) end
elseif ui and info.tier~="free" and K=="" and not info.hasTrial then ui.prompt(start)
else start(K,first) end
