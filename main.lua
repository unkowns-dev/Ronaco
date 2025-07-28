local ronaco = {}
local UserInputService = game:GetService("UserInputService")

function ronaco.init(screenGui, options)
	options = options or {}
	local position = options.position or UDim2.new(0, 0, 0, 0)
	local size = options.size or UDim2.new(0, 600, 0, 400)
	local syntax = options.syntax or {}

	local container = Instance.new("Frame")
	container.Name = "RonacoContainer"
	container.Size = size
	container.Position = position
	container.BackgroundColor3 = Color3.fromRGB(24, 28, 34)
	container.BorderSizePixel = 0
	container.Parent = screenGui
	container.ClipsDescendants = true
	
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "EditorScrollFrame"
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.Position = UDim2.new(0, 48, 0, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	scrollFrame.Parent = container
	
	local lineScroll = Instance.new("ScrollingFrame")
	lineScroll.Name = "LineScroll"
	lineScroll.Size = UDim2.new(0, 48, 1, 0)
	lineScroll.Position = UDim2.new(0, 0, 0, 0)
	lineScroll.BackgroundColor3 = Color3.fromRGB(32, 36, 44)
	lineScroll.BorderSizePixel = 0
	lineScroll.ScrollBarThickness = 0
	lineScroll.CanvasSize = UDim2.new(0, 0, 1, 0)
	lineScroll.ScrollBarImageTransparency = 1
	lineScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	lineScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	lineScroll.Parent = container
	
	local lineNumbers = Instance.new("TextLabel")
	lineNumbers.Name = "LineNumbers"
	lineNumbers.Size = UDim2.new(0, 48, 1, 0)
	lineNumbers.BackgroundColor3 = Color3.fromRGB(32, 36, 44)
	lineNumbers.TextColor3 = Color3.fromRGB(102, 113, 132)
	lineNumbers.Font = Enum.Font.Code
	lineNumbers.TextSize = 18
	lineNumbers.TextXAlignment = Enum.TextXAlignment.Center
	lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
	lineNumbers.Text = "1"
	lineNumbers.TextWrapped = true
	lineNumbers.Parent = lineScroll

	local highlightLabel = Instance.new("TextLabel")
	highlightLabel.Name = "HighlightLabel"
	highlightLabel.Size = UDim2.new(1, 0, 1, 0)
	highlightLabel.Position = UDim2.new(0, 6, 0, 0)
	highlightLabel.BackgroundTransparency = 1
	highlightLabel.TextXAlignment = Enum.TextXAlignment.Left
	highlightLabel.TextYAlignment = Enum.TextYAlignment.Top
	highlightLabel.Font = Enum.Font.Code
	highlightLabel.TextSize = 18
	highlightLabel.TextColor3 = Color3.new(1, 1, 1)
	highlightLabel.TextWrapped = false
	highlightLabel.RichText = true
	highlightLabel.Text = ""
	highlightLabel.ZIndex = 100
	highlightLabel.Parent = scrollFrame

	local textbox = Instance.new("TextBox")
	textbox.Name = "CodeInput"
	textbox.Size = UDim2.new(1, 0, 1, 0)
	textbox.Position = UDim2.new(0, 6, 0, 0)
	textbox.BackgroundTransparency = 1
	textbox.TextColor3 = Color3.fromRGB(220, 220, 230)
	textbox.Font = Enum.Font.Code 
	textbox.TextSize = 18
	textbox.ClearTextOnFocus = false
	textbox.MultiLine = true
	textbox.TextXAlignment = Enum.TextXAlignment.Left
	textbox.TextYAlignment = Enum.TextYAlignment.Top
	textbox.Text = ""
	textbox.CursorPosition = 0
	textbox.ZIndex = 1
	textbox.Parent = scrollFrame
	textbox.TextWrapped = false
	local border = Instance.new("Frame")
	border.Name = "Border"
	border.BackgroundColor3 = Color3.fromRGB(70, 75, 90)
	border.BorderSizePixel = 0
	border.Size = UDim2.new(1, 0, 1, 0)
	border.Position = UDim2.new(0, 0, 0, 0)
	border.Parent = container
	border.ZIndex = 0

	local function escapePattern(text)
		return text:gsub("([^%w])", "%%%1")
	end

	local function escapeHtml(text)
		text = text:gsub("&", "&amp;")
		text = text:gsub("<", "&lt;")
		text = text:gsub(">", "&gt;")
		return text
	end

	local function applySyntaxHighlight(text)
		text = escapeHtml(text)

		local strColor = syntax["STR"] or Color3.fromRGB(214, 157, 133)
		local numColor = syntax["NUM"] or Color3.fromRGB(181, 206, 168)
		local funcColor = syntax["FUNC"] or Color3.fromRGB(220, 220, 170)

		local hexStrColor = string.format("#%02X%02X%02X", strColor.R * 255, strColor.G * 255, strColor.B * 255)
		local hexNumColor = string.format("#%02X%02X%02X", numColor.R * 255, numColor.G * 255, numColor.B * 255)
		local hexFuncColor = string.format("#%02X%02X%02X", funcColor.R * 255, funcColor.G * 255, funcColor.B * 255)

		local segments = {}
		local functions = {}
		local instanceVars = {}
		local i = 1

		while i <= #text do
			local c = text:sub(i, i)
			local matched = false

			if c == '"' then
				local j = i + 1
				while j <= #text and text:sub(j, j) ~= '"' do
					j += 1
				end
				local str = text:sub(i, j)
				table.insert(segments, string.format('<font color="%s">%s</font>', hexStrColor, str))
				i = j + 1
				matched = true

			elseif text:sub(i):match("^local%s+") then
				local matchedStr = text:sub(i):match('^(local%s+[%w_]+%s*=%s*Instance%.new%(%s*"[^"]-"%s*%))')
				if matchedStr then
					local varName, className = matchedStr:match('local%s+([%w_]+)%s*=%s*Instance%.new%(%s*"([^"]-)"%s*%)')
					if varName and className then
						instanceVars[varName] = className

						local hexLocal = string.format("#%02X%02X%02X", (syntax["local"] or Color3.new(1,0,0)).R * 255, (syntax["local"] or Color3.new(1,0,0)).G * 255, (syntax["local"] or Color3.new(1,0,0)).B * 255)
						local hexInstance = string.format("#%02X%02X%02X", (syntax["Instance"] or Color3.new(0,0,1)).R * 255, (syntax["Instance"] or Color3.new(0,0,1)).G * 255, (syntax["Instance"] or Color3.new(0,0,1)).B * 255)
						local hexNew = string.format("#%02X%02X%02X", (syntax["new"] or Color3.new(0,0,1)).R * 255, (syntax["new"] or Color3.new(0,0,1)).G * 255, (syntax["new"] or Color3.new(0,0,1)).B * 255)
						local hexStr = hexStrColor

						local colored = string.format(
							'<font color="%s">local</font> %s = <font color="%s">Instance</font>.<font color="%s">new</font>(<font color="%s">"%s"</font>)',
							hexLocal, varName, hexInstance, hexNew, hexStr, className
						)

						table.insert(segments, colored)
						i = i + #matchedStr
						matched = true
					end
				end
			end
			if not matched then
				for word, color in pairs(syntax) do
					if word ~= "STR" and word ~= "NUM" and word ~= "FUNC" then
						local len = #word
						local sub = text:sub(i, i + len - 1)
						if sub == word and
							(i == 1 or not text:sub(i - 1, i - 1):match("[%w_]")) and
							(i + len > #text or not text:sub(i + len, i + len):match("[%w_]")) then
							local hex = string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
							table.insert(segments, string.format('<font color="%s">%s</font>', hex, word))
							i = i + len
							matched = true
							break
						end
					end
				end
			end

			if not matched then
				local var, prop = text:sub(i):match("^([%w_]+)%.([%w_]+)")
				if var and prop and instanceVars[var] then
					local classType = instanceVars[var]
					local classProps = (syntax["INSTANCES"] or {})[classType]
					if classProps and classProps[prop] then
						local hex = string.format("#%02X%02X%02X", classProps[prop].R * 255, classProps[prop].G * 255, classProps[prop].B * 255)
						table.insert(segments, var .. ".")
						table.insert(segments, string.format('<font color="%s">%s</font>', hex, prop))
						i = i + #var + 1 + #prop
						matched = true
					end
				end
			end

			if not matched and text:sub(i):match("^function%s+") then
				local funcMatch = text:sub(i):match("^function%s+([%w_]+)")
				if funcMatch then
					table.insert(functions, funcMatch)
					local fullMatch = "function " .. funcMatch
					local hexKeyword = string.format("#%02X%02X%02X", (syntax["function"] or Color3.new(1,1,1)).R * 255,
						(syntax["function"] or Color3.new(1,1,1)).G * 255,
						(syntax["function"] or Color3.new(1,1,1)).B * 255)
					table.insert(segments, string.format('<font color="%s">function</font> ', hexKeyword))
					table.insert(segments, string.format('<font color="%s">%s</font>', hexFuncColor, funcMatch))
					i = i + #fullMatch
					matched = true
				end
			end

			if not matched then
				for _, funcName in ipairs(functions) do
					local len = #funcName
					if text:sub(i, i + len) == funcName .. "(" then
						table.insert(segments, string.format('<font color="%s">%s</font>', hexFuncColor, funcName))
						table.insert(segments, "(")
						i = i + len + 1
						matched = true
						break
					end
				end
			end

			if not matched and text:sub(i):match("^%d") then
				local num = text:sub(i):match("^%d+")
				table.insert(segments, string.format('<font color="%s">%s</font>', hexNumColor, num))
				i = i + #num
				matched = true
			end

			if not matched then
				table.insert(segments, text:sub(i, i))
				i += 1
			end
		end

		return table.concat(segments)
	end

	local function updateLineNumbers()
		local text = textbox.Text or ""
		local lines = 1
		for _ in string.gmatch(text, "\n") do
			lines = lines + 1
		end

		local lineNumberText = ""
		for i = 1, lines do
			lineNumberText = lineNumberText .. i .. "\n"
		end

		lineNumbers.Text = lineNumberText
	end

	local function updateHighlight()
		highlightLabel.Text = applySyntaxHighlight(textbox.Text)
	end
	
	local function updateCanvasSize()
		local textBounds = textbox.TextBounds
		local newHeight = math.max(textBounds.Y, scrollFrame.AbsoluteSize.Y)
		scrollFrame.CanvasSize = UDim2.new(0, textBounds.X + 12 + 48, 0, newHeight) 
		lineScroll.CanvasSize = UDim2.new(0, 48, 0, newHeight)

	end

	scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		local y = scrollFrame.CanvasPosition.Y
		lineScroll.CanvasPosition = Vector2.new(0, y)
	
		highlightLabel.Position = UDim2.new(0, 6, 0, -y)
		textbox.Position = UDim2.new(0, 6, 0, -y)
	end)

	
	textbox.FocusLost:Connect(function()
		updateLineNumbers()
		updateHighlight()
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			task.defer(function()
				updateLineNumbers()
				updateHighlight()
			end)
		end
	end)
  
	updateLineNumbers()
	updateHighlight()
	
	local RunService = game:GetService("RunService")
	local lastText = ""

	RunService.RenderStepped:Connect(function()
		local currentText = textbox.Text
		if currentText ~= lastText then
			lastText = currentText
			updateLineNumbers()
			updateHighlight()
			updateCanvasSize()
		end

		local scrollY = scrollFrame.CanvasPosition.Y
		textbox.Position = UDim2.new(0, 6, 0, -scrollY)
		highlightLabel.Position = UDim2.new(0, 6, 0, -scrollY)
		lineNumbers.Position = UDim2.new(0, 0, 0, -scrollY)
	end)


	
	return {
		Container = container,
		TextBox = textbox,
		LineNumbers = lineNumbers,
		HighlightLabel = highlightLabel,
		ScrollFrame = scrollFrame,
	}
end

return ronaco
