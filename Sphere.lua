local def = {
	rings = 1,
	offset =  0,
	space =  0,
	rowspace =  0,
	spin =  0,
}

local function VerifyDefaults(self, sets)
	if sets.Sphere then
		-- return
	end
	sets.Sphere = sets.Sphere or {}

	for key, val in pairs(def) do
	sets.Sphere[key] = sets.Sphere[key] or val
	end
end
function Dominos.ActionBar:GetDefaults()
	local defaults = {}
	defaults.point = "BOTTOM"
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
	local button = CreateFrame("Button", nil, self, "UIMenuButtonStretchTemplate")
	button:ClearAllPoints()
	button.Text:SetAllPoints(button)
	button.Text:SetText(name)



	button:SetScript("OnClick", click)

	local prev = self.lastWidget

	button:ClearAllPoints()
	
	if prev then
		button:SetPoint("Top", self.lastWidget, "Bottom", 0, -10)
	else
		button:SetPoint("TOPLEFT", 0, -2)
	end
	button:SetSize(width, height)

	local width, height = button:GetSize()
	self.height = self.height + (height + 2)
	self.width = max(self.width, width)
	self.lastWidget = button

	self:Render()


	return button
end

local function NewSlider(panel, name, min, max, key)
	local slider = panel:NewSlider{
		name = name,
		min = min,
		max = max,
		get = function(self) --Getter
			return panel.owner.sets.Sphere[key]
		end,
		set = function(self) --Setter
			local owner = panel.owner
			panel.owner.sets.Sphere[key] = self:GetValue()
			owner:Layout()
			return panel.owner.sets.Sphere[key]
		end,
	}
	slider:SetScript("OnMouseUp", function(self)
		if IsShiftKeyDown() then
			self:SetValue(def[key])
		end
	end)
end



local function CreateMenu(self)
config = Dominos:GetOptions()
	local panel = self.menu:NewPanel("Sphere")
	local c = panel:NewCheckButton{
			name = "Enable",
			get = function() return panel.owner.sets.Sphere.Enable end,
			set = function(self, enable)
				panel.owner.sets.Sphere.Enable = self:GetChecked() or false
				panel.owner:Layout()
			end
	}
	local c = panel:NewCheckButton{
			name = "Reverse Offset",
			get = function() return panel.owner.sets.Sphere.rev end,
			set = function(self, enable)
				panel.owner.sets.Sphere.rev = self:GetChecked() or false
				panel.owner:Layout()
			end
	}
--	NewRingsSlider(panel)

	local slider = panel:NewSlider{
		name = "Rings",
		min = 1,

		max = function()
			local num = panel.owner:NumButtons()
			return num
		end,
		get = function()
			local num = panel.owner:NumButtons()
			local rings = panel.owner:NumRings()
			return (num + 1) - rings
		end,

		set = function(_, value)
			local num = panel.owner:NumButtons()
			local val = value
			panel.owner:SetRings((num + 1) - val)
		end
	}
	slider:SetScript("OnMouseUp", function(self)
		if IsShiftKeyDown() then
			self:SetValue(def.rings)
		end
	end)
	
	NewSlider(panel, "Offset", -180, 180, "offset")
	NewSlider(panel, "Spin", -180, 180, "spin")
	NewSlider(panel, "Icon Spacing", -13, 32, "space")
	NewSlider(panel, "Ring Spacing", -100, 100, "rowspace")



	panel.NewButton = panel.NewButton or NewButton
	local c = panel:NewButton("Apply to All", 250, 36, function(self)
		panel.owner:ApplyRingsToAll(panel.owner.sets)
	end)

	panel.NewButton = panel.NewButton or NewButton
	local c = panel:NewButton("Reset", 250, 36, function(self)
		panel.owner.sets.Sphere = nil
		VerifyDefaults(panel.owner, panel.owner.sets)
		panel:Hide()
		panel:Show()
	end)
	return panel
end
hooksecurefunc(Dominos.ActionBar, "CreateMenu", CreateMenu)
local ButtonBar = Dominos.ButtonBar

local function GetPoint(i, cols, rows, numButtons, base, offset, spin, circumference, diameter, rowspace, rev)
	offset = offset+ 90
	local I = (numButtons +1) - i
		local row = floor((I - 1) / cols)
		if row == (rows) then
			base = 360/floor(numButtons/rows)
		end

		row = (rows) -row		
		local angle = .5*((2*i*base)-(base+(2*((offset*row)-offset))))
		if (floor(row/2) == (row/2)) and rev then
			angle = -angle
		end
		
		angle = math.rad(angle - spin)
		local x, y, q = math.cos(angle), math.sin(angle), 1
		if x < 0 then q = q + 1 end
		if y > 0 then q = q + 2 end
		
		

		x, y = x*((circumference + ((diameter*1.5) * (row-1)) + ((rowspace *row) - rowspace))/2), y*((circumference + ((diameter*1.5) * (row-1)) + ((rowspace *row) - rowspace))/2)
		
		return -y, x
end

local function Layout(self)
	VerifyDefaults(self, self.sets)
	if not self.sets.Sphere.Enable then
		return
	end

	local numButtons = #self.buttons

	if numButtons < 1 then
		ButtonBar.proto.Layout(self)
		return
	end
	local Sphere = self.sets.Sphere
	local rings, offset, spin, space, rowspace, rev = self:GetSphere()
	spin = 90 - spin
	
	local cols = min(numButtons/((numButtons+1) - rings), numButtons)
	local rows = ceil(numButtons / cols)

	local isLeftToRight = self:GetLeftToRight()
	local isTopToBottom = self:GetTopToBottom()

	-- grab base button sizes
	local l, r, t, b = self:GetButtonInsets()
	local bW, bH = self:GetButtonSize()
	local pW, pH = self:GetPadding()

	local diameter =  math.sqrt((bW^2) + (bH^2)) + space - 3

	local base = 360/ceil(numButtons/rows)
	local offset = Sphere.offset - 90
	local circumference = ((diameter) * ceil(numButtons/rows)) / (math.pi)

	local left, right, top, bottom
	
	if not self.center  then
		self.center = CreateFrame("Frame", nil, self)
		self.center:SetSize(20, 20)
		self.center:SetPoint("Center", self)
	end
	local left, right, top, bottom = 0, 0, 0, 0
	for i, button in ipairs(self.buttons) do		
		x, y = GetPoint(i, cols, rows, numButtons, base, offset, spin, circumference, diameter, rowspace, rev)
		if isTopToBottom then
			y= -y
		end
		if isLeftToRight then
			x = -x
		end

		
		if x < left then
			left = x
		end
		
		if x > right then
			right = x
		end
				
		if y < bottom then
			bottom = y
		end
		
		if y > top then
			top = y
		end
		
		button:ClearAllPoints()
		button:SetPoint("Center", self.center, "Center", x , y)
	end

	local w, h = math.abs(left) + math.abs(right), math.abs(bottom) + math.abs(top)
	
	local barWidth = w + bW + (pW*2)
	local barHeight = h + bH + (pH*2)
	self:TrySetSize(barWidth, barHeight)
	
	
	local e, f = math.abs(right), math.abs(top)
	

	
	local x, y = (w/2) - (e), (h/2) - (f)
	
	
		
	self.center:SetPoint("Center", self, x, y)
	
end
hooksecurefunc(Dominos.ActionBar, "Layout", Layout)

function Dominos.ActionBar:GetSphere()
	local sets = self.sets.Sphere
	if not sets then
		return
	end

	local rings = sets.rings
	local offset = sets.offset
	local space = sets.space
	local spin = sets.spin
	local rowspace = sets.rowspace
	local rev = sets.rev

	return rings, offset, spin, space, rowspace, rev
end

function Dominos.ActionBar:NumRings()
	return self.sets.Sphere.rings
end

function Dominos.ActionBar:SetRings(value)
	self.sets.Sphere.rings = value
	self:Layout()
end


function Dominos.ActionBar:ApplyRingsToAll(sets)
	for _,bar in self:GetAll() do
		if bar.sets.Sphere then
			bar.sets.Sphere = CopyTable(sets.Sphere)
			bar:Layout()
		end
	end
end

