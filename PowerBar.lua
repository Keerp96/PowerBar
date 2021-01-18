PowerBar = LibStub("AceAddon-3.0"):NewAddon("PowerBar", "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0", "AceTimer-3.0", "LibBars-1.0")
local bars = LibStub("LibBars-1.0")
local media = LibStub("LibSharedMedia-3.0")
local mod = PowerBar
local bar, group
local db


local classIcons = {
	["WARRIOR"] = {0, 0.25, 0, 0.25},
	["MAGE"] = {0.25, 0.49609375, 0, 0.25},
	["ROGUE"] = {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"] = {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"] = {0, 0.25, 0.25, 0.5},
	["SHAMAN"] = {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"] = {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"] = {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"] = {0, 0.25, 0.5, 0.75},
	["DEATHKNIGHT"] = {0.25, 0.49609375, 0.5, 0.75},
}

local classPowerColors = {
	{48/255, 113/255, 191/255 },	-- mana
	{226/255, 45/255, 75/255 },	-- rage
	{1, 210/255, 0 },				-- focus
	{1, 220/255, 25/255 },			-- energy
	{1, 1, 1},						-- happiness
	{1, 1, 1},						-- runes
	{0, 209/255, 1 }				-- runic power
}

local defaults = {
	char = {
		direction = bars.LEFT_TO_RIGHT,
		font = "Fritz Quadrata",
		fontsize = 12,
		background = {r = 0, g = 0, b = 0, a = 0.5},
		length = 100,
		thickness = 20,
		tickWidth = 2,
		color = {},
		tickcolor = {},
		bgcolor = {},
		tickSpells = {},
		hideWhenFull = true,
		flashAtFull = true
	}
}

---- Config
local options = {
	type = "group",
	args = {
		display = {
			type = "group",
			name = "Display Options",
			args = {
				hideWhenFull = {
					type = "toggle",
					name = "Hide when full",
					order = 2,
					get = function() return db.hideWhenFull end,
					set = function(info, v)
						db.hideWhenFull = v
					end
				},
				flashAtFiveCP = {
					type = "toggle",
					name = "Flash at 5 CP",
					order = 3,
					get = function() return db.flashAtFull end,
					set = function(info, v)
						db.flashAtFull = v
					end
				},
				colorHeader = {
					type = "header",
					name = "Colors",
					order = 50
				},
				lock = {
					type = "toggle",
					name = "Lock PowerBar",
					order = 1,
					get = function() return db.locked end,
					set = function(info, v)
						db.locked = v
						mod:UpdateDisplay()
					end
				},
				direction = {
					type = "select",
					name = "Bar direction",
					order = 105,
					values = {
						[bars.LEFT_TO_RIGHT] ="Left to right",
						[bars.BOTTOM_TO_TOP] ="Bottom to top",
						[bars.RIGHT_TO_LEFT] ="Right to left",
						[bars.TOP_TO_BOTTOM] ="Top to bottom"
					},
					get = function()
						return db.direction
					end,
					set = function(info, v)
						db.direction = v
						mod:UpdateDisplay()
						mod:AddTickLines()
					end
				},
				font = {
					type = "select",
					name ="Font",
					dialogControl = 'LSM30_Font',
					order = 106,
					values = AceGUIWidgetLSMlists.font,
					get = function() return db.font end,
					set = function(info, v)
						db.font = v
						mod:UpdateDisplay()
					end
				},
				texture = {
					type = "select",
					name ="Texture",
					order = 107,
					values = AceGUIWidgetLSMlists.statusbar,
					dialogControl = 'LSM30_Statusbar',
					get = function() return db.texture end,
					set = function(info, v)
						db.texture = v
						mod:UpdateDisplay()
					end
				},
				fontsize = {
					type = "range",
					name ="Font Size",
					min = 4,
					max = 30,
					step = 1,
					bigStep = 1,
					get = function() return db.fontsize end,
					set = function(info, v)
						db.fontsize = v
						mod:UpdateDisplay()
					end
				},
				sizeHeader = {
					type = "header",
					name ="Bar Size",
					order = 60,
				},
				length = {
					type = "range",
					name ="Bar length",
					min = 5,
					max = 600,
					order = 61,
					step = 1,
					bigStep = 1,
					get = function() return db.length end,
					set = function(info, v)
						db.length = v
						mod:UpdateDisplay()
					end
				},
				thickness = {
					type = "range",
					name ="Bar thickness",
					min = 5,
					max = 600,
					order = 62,
					step = 1,
					bigStep = 1,
					get = function() return db.thickness end,
					set = function(info, v)
						db.thickness = v
						mod:UpdateDisplay()
					end
				},
				barcolor = {
					type = "color",
					name ="Bar color",
					order = 51,
					hasAlpha = true,
					get = function() return db.color.r, db.color.g, db.color.b, db.color.a end,
					set = function(info, r, g, b, a)
						db.color.r, db.color.g, db.color.b, db.color.a = r, g, b, a
						mod:UpdateDisplay()
					end
				},
				bgcolor = {
					type = "color",
					name ="Background color",
					order = 52,
					hasAlpha = true,
					get = function() return db.bgcolor.r, db.bgcolor.g, db.bgcolor.b, db.bgcolor.a end,
					set = function(info, r, g, b, a)
						db.bgcolor.r, db.bgcolor.g, db.bgcolor.b, db.bgcolor.a = r, g, b, a
						mod:UpdateDisplay()
					end
				}
			}
		},
		ticks = {
			type = "group",
			name ="Ticks",
			args = {
				tickcolor = {
					type = "color",
					name ="Tick color",
					hasAlpha = true,
					get = function() return db.tickcolor.r, db.tickcolor.g, db.tickcolor.b, db.tickcolor.a end,
					set = function(info, r, g, b, a)
						db.tickcolor.r, db.tickcolor.g, db.tickcolor.b, db.tickcolor.a = r, g, b, a
						mod:AddTickLines()
					end
				},
				tickThickness = {
					type = "range",
					name ="Tick thickness",
					min = 1,
					max = 5,
					step = 1,
					bigStep = 1,
					get = function() return db.tickWidth end,
					set = function(info, v)
						db.tickWidth = v
						mod:AddTickLines()
					end
				},
				spells = {
					type = "group",
					name ="Show ticks for...",
					inline = true,
					args = {
					}
				}
			}
		}
	}
}

function mod:LibSharedMedia_Registered()
	self:UpdateDisplay()
end

function mod:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("PowerBarDB", defaults)
	db = self.db.char

	group = self:NewBarGroup("PowerBarGroup", nil, 100, 10, "PowerBarGroup")
	bar = group:NewCounterBar("Energy", "Energy", 0, 1)

	local class = classIcons[select(2, UnitClass("player"))]
	bar:SetIcon("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
	bar.icon:SetTexCoord(class[1], class[2], class[3], class[4])

	bar:SetLength(100)
	bar:SetThickness(10)

	bar:SetMaxValue(100)
	bar:SetValue(50)

	self:HookScript(bar, "OnSizeChanged", "AddTickLines")

	self.bar = bar
	self:SetupOptions()
end

function mod:InjectSpells()
	local names = {}

	for i = 1, 999 do
		local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
		if not name then break end
		names[name] = true
	end

	local t = options.args.ticks.args.spells.args
	for k, v in pairs(names) do
		local name, rank, icon, cost = GetSpellInfo(k)
		if cost and cost > 0 then
			t[name:gsub(" ", "_")] = {
				type = "toggle",
				name = name,
				icon = icon,
				get = function()
					return db.tickSpells[name] ~= nil
				end,
				set = function(info, v)
					db.tickSpells[name] = v and cost or nil
					mod:AddTickLines()
				end
			}
		end
	end
end

local spellsScanned = false
function mod:OnEnable()
	self:RegisterEvent("UNIT_MAXENERGY")
	self:RegisterEvent("UNIT_MAXRAGE", "UNIT_MAXENERGY")
	self:RegisterEvent("UNIT_MAXMANA", "UNIT_MAXENERGY")
	self:RegisterEvent("UNIT_MAXRUNIC_POWER", "UNIT_MAXENERGY")

	self:ScheduleRepeatingTimer("UNIT_ENERGY", 0.05, "player")
	self:UNIT_MAXENERGY(nil, "player")

	media.RegisterCallback(mod, "LibSharedMedia_Registered")
	self:LibSharedMedia_Registered()

	self:UpdateDisplay()
	self:AddTickLines()

	if not spellsScanned then
		self:InjectSpells()
		spellsScanned = true
	end
end

function mod:UpdateDisplay()
	bar:SetFont(media:Fetch("font", db.font), db.fontsize)
	group:SetTexture(media:Fetch("statusbar", db.texture))
	local r, g, b = unpack(classPowerColors[UnitPowerType("player")])

	local xr, xg, xb, xa = db.color.r or r, db.color.g or g, db.color.b or b, db.color.a or 1
	group:UnsetAllColors()
	group:SetColorAt(1.0, xr, xg, xb, xa)
	group:SetLength(db.length)
	group:SetThickness(db.thickness)
	group:SetOrientation(db.direction)

	xr, xg, xb, xa = db.bgcolor.r or (r / 2), db.bgcolor.g or (g / 2), db.bgcolor.b or (b / 2), db.bgcolor.a or 0.5
	bar:SetBackgroundColor(xr, xg, xb, xa)

	if db.locked then
		group:HideAnchor()
	else
		group:ShowAnchor()
	end
end

do
	local tickTextures = {}
	local newTextures = {}
	function mod:AddTickLines()
		for _, v in ipairs(tickTextures) do v:Hide() end
		for k, _ in pairs(db.tickSpells) do
			local v = select(4, GetSpellInfo(k))
			local t = tremove(tickTextures)
			if not t then
				t = bar:CreateTexture(nil, "OVERLAY")
				t:SetTexture([[Interface\Buttons\WHITE8X8]])
			end
			tinsert(newTextures, t)
			t:Show()
			t:SetVertexColor(db.tickcolor.r or 0, db.tickcolor.g or 0, db.tickcolor.b or 0, db.tickcolor.a or 0.5)
			t:SetHeight(db.tickWidth)
			t:SetWidth(db.tickWidth)

			t:ClearAllPoints()
			if db.direction == 1 or db.direction == 3 then
				t:SetPoint("TOP", bar, "TOP", 0, 0)
				t:SetPoint("BOTTOM", bar, "BOTTOM", 0, 0)
				if db.direction == 1 then
					t:SetPoint("LEFT", bar, "LEFT", bar:GetWidth() * (v/100), 0)
				else
					t:SetPoint("RIGHT", bar, "RIGHT", bar:GetWidth() * (v/100) * -1, 0)
				end
			else
				t:SetPoint("LEFT", bar, "LEFT", 0, 0)
				t:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
				if db.direction == 2 then
					t:SetPoint("BOTTOM", bar, "BOTTOM", 0, bar:GetHeight() * (v/100))
				else
					t:SetPoint("TOP", bar, "TOP", 0, bar:GetHeight() * (v/100) * -1)
				end
			end
		end

		for _, v in ipairs(newTextures) do
			tinsert(tickTextures, v)
		end
		for i = 1, #newTextures do
			tremove(newTextures)
		end
	end
end

do
	local function flashBar(self)
		self:SetAlpha((0.25 * math.sin(GetTime() * 7)) + 0.75)
	end

	local MAX_CP = 5
	function mod:UNIT_ENERGY(token)
		if UnitIsUnit("player", token) then
			bar:SetLabel(UnitMana(token))
			local cp = GetComboPoints("player")
			bar:SetTimerLabel(cp .. "|cffffcc44CP")
			if cp >= MAX_CP and db.flashAtFull and not self.flasher then
				self.flasher = true
				bar:AddOnUpdate(flashBar)
			elseif cp < MAX_CP and self.flasher then
				bar:RemoveOnUpdate(flashBar)
				self.flasher = false
				bar:SetAlpha(1)
			end
			bar:SetValue(UnitMana(token))
			if UnitMana(token) == UnitManaMax(token) and not InCombatLockdown() and db.hideWhenFull then
				group:Hide()
			else
				group:Show()
			end
		end
	end
end

function mod:FlashBar(arg)

end

function mod:UNIT_MAXENERGY(event, token)
	if UnitIsUnit("player", token) then
		bar:SetValue(UnitManaMax(token))
	end
end

function mod:SetupOptions()
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("PowerBar", options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("PowerBar", options, "powerbar")
	local ACD3 = LibStub("AceConfigDialog-3.0")

	ACD3:AddToBlizOptions("PowerBar", nil, nil, "display")
	-- ACD3:AddToBlizOptions("PowerBar", "Display Options", "PowerBar", "display")
	ACD3:AddToBlizOptions("PowerBar", "Tick Options", "PowerBar", "ticks")

	-- LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PowerBar", "Tick Options", "PowerBar", ticks)
end

