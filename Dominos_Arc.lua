local function VerifyDefaults(self, settings)
    if settings.ARC then
        return
    end
    settings.ARC = settings.ARC or {}
	settings.ARC.YarcOffset = settings.ARC.arcOffset or 0
	settings.ARC.Yarc = settings.ARC.arc or 0
	settings.ARC.XarcOffset = settings.ARC.XarcOffset or 0
	settings.ARC.Xarc = settings.ARC.Xarc or 0
	settings.ARC.XarcAdjust = settings.ARC.XarcAdjust or 0
	settings.ARC.YarcAdjust = settings.ARC.YarcAdjust or 0
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




hooksecurefunc(Dominos.ActionBar, "CreateMenu", function(self)
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
		min = -100,
		max = 100,
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
		name = "Y Offset",
		min = -100,
		max = 100,
		get = function(self) --Getter
			return panel.owner.sets.ARC.YarcAdjust
		end,
		set = function(self) --Setter
			local owner = panel.owner
			owner.sets.ARC.YarcAdjust = self:GetValue()
			owner:Layout()
			return owner.sets.ARC.YarcAdjust
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
		min = -100,
		max = 100,
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
	
	local slider =  panel:NewSlider{
		name = "X Offset",
		min = -100,
		max = 100,
		get = function(self) --Getter
			return panel.owner.sets.ARC.XarcAdjust
		end,
		set = function(self) --Setter
			local owner = panel.owner
			owner.sets.ARC.XarcAdjust = self:GetValue()
			owner:Layout()
			return owner.sets.ARC.XarcAdjust
		end,
	}
    return panel
end)

local ButtonBar = Dominos.ButtonBar


hooksecurefunc(Dominos.ActionBar, "Layout", function(self)
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
        -- grab base button sizes
        local l, r, t, b = self:GetButtonInsets()
        local bW, bH = self:GetButtonSize()
        local pW, pH = self:GetPadding()
        local spacing = self:GetSpacing()
        local buttonWidth = bW + spacing
        local buttonHeight = bH + spacing
        local xOff = pW - l
        local yOff = pH - t
        local YCurveOffset = (((self.sets.ARC.YarcOffset or 0)/100) * (self:GetWidth()))
        local XCurveOffset = (((self.sets.ARC.XarcOffset or 0)/100) * (self:GetHeight()))

        local width = (buttonWidth * cols)
        local height = buttonWidth * rows
        local Sx = (((width)/2) - YCurveOffset)--
        local Sy = (((height)/2) - XCurveOffset)--

        local a = (height/2)/((width/2)^2)
        local b = (width/2)/((height/2)^2)
        local Yarc = self.sets.ARC.Yarc/100
        local Xarc = self.sets.ARC.Xarc/100

        for i, button in ipairs(self.buttons) do
            local row = floor((i - 1) / cols)
            if not isTopToBottom then
                row = rows - (row + 1)
            end

            local col = (i - 1) % cols
            if not isLeftToRight then
                col = cols - (col + 1)
            end

            local x = xOff + buttonWidth*col
            local y = yOff + buttonHeight*row

            local lx = Sx - (x +(buttonWidth/2))
            local ly = Sy - (y +(buttonHeight/2))
            local y = (y - ((a*(lx^2)) * Yarc)) - self.sets.ARC.YarcAdjust
            local x = (x - ((b*(ly^2)) * Xarc)) + self.sets.ARC.XarcAdjust
            button:SetParent(self.header)
            button:ClearAllPoints()
            button:SetPoint('TOPLEFT', x, -y)
        end
        local barWidth = (buttonWidth * cols) + (pW * 2) - spacing
        local barHeight = (buttonHeight * rows) + (pH * 2) - spacing
        self:TrySetSize(barWidth, barHeight)
    end
end)
