local function VerifyDefaults(self, settings)
    if settings.ARC then
        return
    end
    settings.ARC = settings.ARC or {}
	settings.ARC.YarcOffset = settings.ARC.arcOffset or 0
	settings.ARC.Yarc = settings.ARC.arc or 0
	settings.ARC.XarcOffset = settings.ARC.XarcOffset or 0
	settings.ARC.Xarc = settings.ARC.Xarc or 0
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



local function CreateMenu(self)

	local panel = self.menu:NewPanel("Arc")
    local c = panel:NewCheckButton{
        name = "Enable",
        get = function() return panel.owner.sets.ARC.arcEnable end,
        set = function(self, enable)
            panel.owner.sets.ARC.arcEnable = self:GetChecked() or false
            panel.owner:Layout()
        end
    }
	local slider =  panel:NewSlider{
		name = "Y Arc",
		min = -400,
		max = 400,
		get = function(self) --Getter
			return panel.owner.sets.ARC.Yarc
		end,
		set = function(self) --Setter
			local owner = panel.owner
			owner.sets.ARC.Yarc = self:GetValue()
			owner:Layout()
			return owner.sets.ARC.Yarc
		end,
	}

	local slider =  panel:NewSlider{
		name = "Y Arc Shift",
		min = -200,
		max = 200,
		get = function(self) --Getter
			return panel.owner.sets.ARC.YarcOffset
		end,
		set = function(self) --Setter
			local owner = panel.owner
			owner.sets.ARC.YarcOffset = self:GetValue()
			owner:Layout()
			return owner.sets.ARC.YarcOffset
		end,
	}


	local slider =  panel:NewSlider{
		name = "X Arc",
		min = -400,
		max = 400,
		get = function(self) --Getter
			return panel.owner.sets.ARC.Xarc
		end,
		set = function(self) --Setter
			local owner = panel.owner
			owner.sets.ARC.Xarc = self:GetValue()
			owner:Layout()
			return owner.sets.ARC.Xarc
		end,
	}

	local slider =  panel:NewSlider{
		name = "X Arc Shift",
		min = -200,
		max = 200,
		get = function(self) --Getter
			return panel.owner.sets.ARC.XarcOffset
		end,
		set = function(self) --Setter
			local owner = panel.owner
			owner.sets.ARC.XarcOffset = self:GetValue()
			owner:Layout()
			return owner.sets.ARC.XarcOffset
		end,
	}

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

     if self.sets.ARC.arcEnable then
        local numButtons = #self.buttons
        if numButtons < 1 then
            ButtonBar.proto.Layout(self)
            return
        end

		local cols = min(self:NumColumns(), numButtons)
        local rows = ceil(numButtons / cols)
		local isLeftToRight = self:GetLeftToRight()
		local isTopToBottom = self:GetTopToBottom()
		local pW, pH = self:GetPadding()

		
		-- grab base button sizes
		local l, r, t, b = self:GetButtonInsets()
		local w, h = self:GetButtonSize()
		local spacing = self:GetSpacing()

		local bW = w + spacing
		local bH = h + spacing
		
		local hSpacing = spacing - (l + r)
		local vSpacing = spacing - (t + b)


		--base bar size, no arc applied
		local width= (cols * w) + ((cols-1) + hSpacing)
		local height = (rows * h) + ((rows-1) + vSpacing)

		--changes the flex point of the vertical and horizontal arcs
		local XCurveOffset = (((self.sets.ARC.XarcOffset or 0)/100) * (width))
		local YCurveOffset = (((self.sets.ARC.YarcOffset or 0)/100) * (height))
		
		local a = (height/2)/((width/2)^2)
		local b = (width/2)/((height/2)^2)

		local Xarc = self.sets.ARC.Xarc
		local Yarc = self.sets.ARC.Yarc

		local xOff = -l
		local yOff = -t
		
		--align buttons based on center of frame	
		local zeroX, zeroY = xOff + (bW)*(((cols)/2) - .5), yOff + (bH)*(((rows)/2) - .5)

		--flex buttons over center of the bar, with x and y curve offsets
		local R = 0

		local fX, fY = xOff + bW*0, yOff + bH*0
		fX, fY = (zeroX) - (fX - ((b*(((zeroY - math.abs(XCurveOffset)) - fY)^2)) * (Xarc/100))), zeroY - (fY - ((a*(((zeroX - math.abs(YCurveOffset)) - fX)^2)) * (Yarc/100)))
		fX, fY = (fX- zeroX)/2, (fY - zeroY)/2

		
		local dX, dY = xOff + bW*(cols-1), yOff + bH*(rows-1)
		dX, dY = (zeroX) - (dX - ((b*(((zeroY - math.abs(XCurveOffset)) - dY)^2)) * (Xarc/100))), zeroY - (dY - ((a*(((zeroX - math.abs(YCurveOffset)) - dX)^2)) * (Yarc/100)))
		dX, dY = (dX- zeroX)/2, (dY - zeroY)/2

		local flexX, flexY = dX, dY
		
		
		if math.abs(fY) > math.abs(dY) then
			flexY = fY
		end

		if math.abs(fX) > math.abs(dX) then
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
			x, y =  -(x - ((b*(((zeroY - XCurveOffset) - y)^2)) * (Xarc/100))), -(y - ((a*(((zeroX - YCurveOffset) - x)^2)) * (Yarc/100)))

			x = x - flexX
			y = - (y - flexY)
			
			if x > maxX then
				maxX = x
			end
			
			if y > maxY then
				maxY = y
			end

			if x < minX then
				minX = x
			end
			
			if y < minY then
				minY = y
			end

            button:SetParent(self.header)
            button:ClearAllPoints()
            button:SetPoint('Center', x, y )
        end


        local pW, pH = self:GetPadding()
		local spacing = self:GetSpacing()

		local barWidth = (math.abs(maxX)+ math.abs(minX))+ bH + (pW*2)
		local barHeight = (math.abs(maxY)+ math.abs(minY))+ bH + (pH*2)

		self:TrySetSize(barWidth, barHeight)
    end
end

hooksecurefunc(Dominos.ActionBar, "Layout", Layout)
