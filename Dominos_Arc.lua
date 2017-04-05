local function VerifyDefaults(self, sets)
	if sets.ARC then
		-- return
	end
	sets.ARC = sets.ARC or {}

	sets.ARC.yFlex = sets.ARC.yFlex or 0
	sets.ARC.yArc = sets.ARC.yArc or 0
	sets.ARC.yShift = sets.ARC.yShift or 0

	sets.ARC.xFlex = sets.ARC.xFlex or 0
	sets.ARC.xArc = sets.ARC.xArc or 0
	sets.ARC.xShift = sets.ARC.xShift or 0
end
function Dominos.ActionBar:GetDefaults()
	local defaults = {}
	defaults.point = 'BOTTOM'
	defaults.x = 0
	defaults.y = 40*(self.id-1)
	defaults.pages = {}
	defaults.spacing = 4
	defaults.padW = 2
	defaults.padH = 2
	defaults.numButtons = self:MaxLength()
	VerifyDefaults(self, defaults)
	return defaults
end


local config





 local function NewButton(self, name, width, height, click)
print(self, name, width, height, click)
	local button = CreateFrame('Button', nil, self, 'UIMenuButtonStretchTemplate')
	button:ClearAllPoints()
	button.Text:SetAllPoints(button)
	button.Text:SetText(name)



	button:SetScript('OnClick', click)

	local prev = self.lastWidget

	button:ClearAllPoints()
	
	if prev then
		button:SetPoint('Top', self.lastWidget, 'Bottom', 0, -10)
	else
		button:SetPoint('TOPLEFT', 0, -2)
	end
	button:SetSize(width, height)

	local width, height = button:GetSize()
	self.height = self.height + (height + 2)
	self.width = max(self.width, width)
	self.lastWidget = button

	self:Render()


	return button
end

local function CreateMenu(self)
config = Dominos:GetOptions()
	local panel = self.menu:NewPanel("Arc")
	local c = panel:NewCheckButton{
			name = "Enable",
			get = function() return panel.owner.sets.ARC.arcEnable end,
			set = function(self, enable)
				panel.owner.sets.ARC.arcEnable = self:GetChecked() or false
				panel.owner:Layout()
			end
	}
	local slider = panel:NewSlider{
		name = "Y Arc",
		min = -100,
		max = 100,
		get = function(self) --Getter
			return panel.owner.sets.ARC.yArc*2
		end,
		set = function(self) --Setter
			local owner = panel.owner
			owner.sets.ARC.yArc = self:GetValue()/2
			owner:Layout()
			return owner.sets.ARC.yArc
		end,
	}
	local slider = panel:NewSlider{
		name = "Y Flex",
		min = -100,
		max = 100,
		get = function(self) --Getter
			return panel.owner.sets.ARC.yFlex
		end,
		set = function(self) --Setter
			local owner = panel.owner
			owner.sets.ARC.yFlex = self:GetValue()
			owner:Layout()
			return owner.sets.ARC.yFlex
		end,
	}
	local slider = panel:NewSlider{
		name = "Y Offset",
		min = -100,
		max = 100,
		get = function(self) --Getter
			return panel.owner.sets.ARC.yShift
		end,
		set = function(self) --Setter
			local owner = panel.owner
			owner.sets.ARC.yShift = self:GetValue()
			owner:Layout()
			return owner.sets.ARC.yShift
		end,
	}
	local slider = panel:NewSlider{
		name = "X Arc",
		min = -100,
		max = 100,
		get = function(self) --Getter
			return panel.owner.sets.ARC.xArc*2
		end,
		set = function(self) --Setter
			local owner = panel.owner
			owner.sets.ARC.xArc = self:GetValue()/2
			owner:Layout()
			return owner.sets.ARC.xArc
		end,
	}
	local slider = panel:NewSlider{
		name = "X Arc Shift",
		min = -100,
		max = 100,
		get = function(self) --Getter
			return panel.owner.sets.ARC.xFlex
		end,
		set = function(self) --Setter
			local owner = panel.owner
			owner.sets.ARC.xFlex = self:GetValue()
			owner:Layout()
			return owner.sets.ARC.xFlex
		end,
	}
	local slider = panel:NewSlider{
		name = "X Offset",
		min = -100,
		max = 100,
		get = function(self) --Getter
			return panel.owner.sets.ARC.xShift
		end,
			set = function(self) --Setter
			local owner = panel.owner
			owner.sets.ARC.xShift = self:GetValue()
			owner:Layout()
			return owner.sets.ARC.xShift
		end,
	}

	panel.NewButton = panel.NewButton or NewButton


	local c = panel:NewButton("Apply to All", 250, 36, function(self)
			panel.owner:ApplyToAll(panel.owner.sets)
		end)
	return panel
end
hooksecurefunc(Dominos.ActionBar, "CreateMenu", CreateMenu)
local ButtonBar = Dominos.ButtonBar
local function GetPoint(t, r, zeroA, zeroB, offset, arc, l)
	local point = (zeroA) - (t - ((l*(((zeroB - math.abs(offset)) - r)^2)) * (arc/100)))
	return point
end
local function Layout(self)
	VerifyDefaults(self, self.sets)
	if not self.sets.ARC.arcEnable then
		return
	end

	local numButtons = #self.buttons

	if numButtons < 1 then
		ButtonBar.proto.Layout(self)
		return
	end
	local arc = self.sets.ARC
	local yFlex, yArc, yShift, xFlex, xArc, xShift = self:GetArc()

	local cols = min(self:NumColumns(), numButtons)
	local rows = ceil(numButtons / cols)
	local isLeftToRight = self:GetLeftToRight()
	local isTopToBottom = self:GetTopToBottom()
	local pW, pH = self:GetPadding()

	-- grab base button sizes
	local l, r, t, b = self:GetButtonInsets()
	local w, h = self.buttons[1]:GetSize()
	local spacing = self:GetSpacing()
	local bW = w + spacing
	local bH = h + spacing

	local hSpacing = spacing - (l + r)
	local vSpacing = spacing - (t + b)

	--base bar size, no arc applied
	local width= (cols * w) + ((cols-1) + hSpacing)
	local height = (rows * h) + ((rows-1) + vSpacing)
	--changes the flex point of the vertical and horizontal arcs
	local xFlex = (((xFlex or 0)/100)/2 * (height))
	local yFlex = (((yFlex or 0)/100)/2 * (width))

	local a = (height/2)/((width/2)^2)
	local b = (width/2)/((height/2)^2)
	local xArc = xArc
	local yArc = yArc
	local xOff = -l
	local yOff = -t

	--align buttons based on center of frame
	local zeroX, zeroY = xOff + (bW)*(((cols)/2) - .5), yOff + (bH)*(((rows)/2) - .5)
	--flex buttons over center of the bar, with x and y curve offsets
	local R = 0
	local fX, fY = xOff + bW*0, yOff + bH*0
	local dX, dY = xOff + bW*(cols-1), yOff + bH*(rows-1)

	if cols < 3 then
		yArc = 0
	end
	if rows < 3 then
		xArc = 0
	end

	do
		fX, fY = (zeroX) - (fX - ((b*(((zeroY - math.abs(xFlex)) - fY)^2)) * ((xArc/100) * width))), zeroY - (fY - ((a*(((zeroX - math.abs(yFlex)) - fX)^2)) * ((yArc/100)*height)))
		fX, fY = (fX- zeroX)/2, (fY - zeroY)/2
		dX, dY = (zeroX) - (dX - ((b*(((zeroY - math.abs(xFlex)) - dY)^2)) * ((xArc/100) * width))), zeroY - (dY - ((a*(((zeroX - math.abs(yFlex)) - dX)^2)) * ((yArc/100)*height)))
		dX, dY = (dX- zeroX)/2, (dY - zeroY)/2
	end

	local flexX, flexY = dX, dY


	if (math.abs(fY) > math.abs(dY)) and (yFlex<0)then
		flexY = fY
	end

	if (math.abs(fX) > math.abs(dX)) and (xFlex>0) then
		flexX = fX
	end

	local maxX, maxY = 0, 0
	local minX, minY = 0, 0
	for i, button in ipairs(self.buttons) do

		local row = floor((i - 1) / cols)
		if self:GetTopToBottom() then
			row = rows - (row + 1)
		else
			row = floor((i - 1) / cols)
		end
		local col = (i - 1) % cols
		if self:GetLeftToRight() then
			col = cols - (col + 1)
		else
			col = (i - 1) % cols
		end

		local x, y = xOff + bW*col, yOff + bH*row
		x, y = -(x - ((b*(((zeroY - xFlex) - y)^2)) * ((xArc/100) * width))), -(y - ((a*(((zeroX - yFlex) - x)^2)) * ((yArc/100)*height)))
		x = x - flexX
		y = - (y - flexY)

		if x > maxX then
			maxX = x
		end
		if x < minX then
			minX = x
		end

		if y > maxY then
			maxY = y
		end
		if y < minY then
			minY = y
		end
		button:SetParent(self.header)
		button:ClearAllPoints()
		button:SetPoint('Center', x + xShift, y + yShift)
	end

	local pW, pH = self:GetPadding()
	local spacing = self:GetSpacing()
	local barWidth = (math.abs(maxX)+ math.abs(minX))+ bH + (pW*2) - spacing
	local barHeight = (math.abs(maxY)+ math.abs(minY))+ bH + (pH*2) - spacing

	self:TrySetSize(barWidth, barHeight)
end
hooksecurefunc(Dominos.ActionBar, "Layout", Layout)

function Dominos.ActionBar:GetArc()
	local sets = self.sets.ARC
	if not sets then
		return
	end

	local yFlex = sets.yFlex
	local yArc = sets.yArc
	local yShift = sets.yShift

	local xFlex = sets.xFlex
	local xArc = sets.xArc
	local xShift = sets.xShift
	
	return yFlex, yArc, yShift, xFlex, xArc, xShift
end

function Dominos.ActionBar:ApplyToAll(sets)
	for _,bar in self:GetAll() do
		if bar.sets.ARC then
			bar.sets.ARC = CopyTable(sets.ARC)
			bar:Layout()
		end
	end
end

