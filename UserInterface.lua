-- Rift MultiBoxing Addon Utilities
-- Written By Molikar@Hailol
-- Copyright 2020

local Addon, RMBA = ...
local Context = UI.CreateContext( Addon.identifier )

Window = {}
Window.__index = Window

local CallingColors = {}

function Window:new( settings )
	local self = {}

	self.settings = settings
	self.frames = {}
	self.chars = {}
	self.numRows = 0
	self.showScrollbar = false
	self.scrollOffset = 0
	self.rowPadding = 1
	self.rowHeight = 18
	self.rowFontSize = 12
	self.rowFontColor = {1, 1, 1}
	self.expBarWidth = 110
	self.headerHeight = 24
	
	setmetatable( self, Window )

	self:Initialize()
	self:SetRows( 0 )
	
	return self
end

function Window:Initialize()
	RMBA.Utils:PrintDebug( "Window:Initialize()" )

	CallingColors[1] = {r = 1.0, g = 0.0, b = 0.0}	-- warrior
	CallingColors[2] = {r = 0.8, g = 0.5, b = 1.0}	-- mage
	CallingColors[3] = {r = 1.0, g = 1.0, b = 0.0}	-- rogue
	CallingColors[4] = {r = 0.0, g = 1.0, b = 0.0}	-- cleric
	CallingColors[5] = {r = 0.5, g = 1.0, b = 0.5}	-- primalist (what is colour here??)
	CallingColors[6] = {r = 0.2, g = 0.8, b = 0.2}	-- rested exp
	CallingColors[7] = {r = 0.0, g = 1.0, b = 1.0}	-- regular exp
	CallingColors[8] = {r = 1.0, g = 0.0, b = 0.0}	-- health
	CallingColors[9] = {r = 0.0, g = 0.0, b = 0.0}	-- black
	CallingColors[10] = {r = 1.0, g = 0.68, b = 0.18}	-- purple

	local window = self
	local frames = self.frames

	frames.base = UI.CreateFrame( "Frame", "RMBA_base", Context )
	frames.base:SetLayer(1)
	frames.base:SetWidth( window.settings.width )
	frames.base:SetHeight( window.settings.height )
	frames.base:SetPoint( "TOPLEFT", UIParent, "TOPLEFT", window.settings.x, window.settings.y )
	window:addBorder( frames.base, 3, 0.8, 0.75, 0.4, 0.6 )
	window:handleFrameMovement( frames.base )

	frames.interior = UI.CreateFrame( "Texture", "RMBA_interior", frames.base )
	frames.interior:SetLayer(1)
	frames.interior:SetWidth( window.settings.width )
	frames.interior:SetHeight( window.settings.height - self.headerHeight )
	frames.interior:SetPoint( "BOTTOMLEFT", frames.base, "BOTTOMLEFT" )
	frames.interior:SetBackgroundColor( CallingColors[9].r, CallingColors[9].g, CallingColors[9].b )
	frames.interior:SetAlpha( 0.45 )

	frames.header = UI.CreateFrame( "Texture", "RMBA_header", frames.base )
	frames.header:SetPoint( "TOPLEFT", frames.base, "TOPLEFT" )
	frames.header:SetPoint( "TOPRIGHT", frames.base, "TOPRIGHT" )
	frames.header:SetHeight( self.headerHeight )
	frames.header:SetLayer( 0 )
	frames.header:SetTexture( Addon.identifier, [[textures\header.png]] )

	frames.headerLabel = UI.CreateFrame( "Text", "RMBA_headerLabel", frames.base )
	frames.headerLabel:SetPoint( "TOPLEFT", frames.header, "TOPLEFT", 7, 2 )
	frames.headerLabel:SetLayer( 1 )
	frames.headerLabel:SetMouseMasking( "limited" )
	frames.headerLabel:EventAttach( Event.UI.Input.Mouse.Cursor.In, 
					function()
						frames.headerLabel:SetFontColor( 0.8, 0.8, 0.8 )
					end, "_MouseCursorIn" ) 
	frames.headerLabel:EventAttach( Event.UI.Input.Mouse.Cursor.Out,
					function()
						frames.headerLabel:SetFontColor( 1, 1, 1 )
					end, "_MouseCursorOut" ) 

	frames.buttons = {}
	frames.buttons.close = window:createIconButton( "RMBA_buttonClose", frames.base, [[textures\cross.png]],
							"TOPRIGHT", frames.header, "TOPRIGHT", -4, 4, RMBAL:TXT("tooltip_close"),
							function()
								Command.Console.Display( "general", false, RMBAL:TXT("close_message"), true )
								RMBA.Window:setVisible( false )
								RMBA.tooltip:hide()
							end)

	frames.buttons.config = window:createIconButton( "RMBA_buttonConfigure", frames.base, [[textures\gear.png]],
							"TOPRIGHT", frames.header, "TOPRIGHT", -24, 4, RMBAL:TXT("tooltip_configure"),
							function()
								RMBA.Utils:PrintDebug( "Configure settings" )
							end)
end

function Window:SetVisible( visible )
	RMBASettings.visible = visible
	self.frames.base:SetVisible( visible )
end

function Window:SetTitle( title )
	self.frames.headerLabel:SetText( tostring(title) )
end

function Window:SetWidth( width )
	self.frames.base:SetWidth( width )
	self:update()
end

function Window:Resize()
	RMBA.Utils:PrintDebug( "Window:Resize()" )
	self.frames.base:SetPoint( "TOPLEFT", UIParent, "TOPLEFT", self.settings.x, self.settings.y )
	self.frames.base:SetWidth( self.settings.width )
	
	self:SetRows( self.settings.rows )
end

function Window:Update()
	RMBA.Utils:PrintDebug( "Window:Update()" )

	if self.frames.rows then
		for i = 1, #self.frames.rows, 1 do
			local member = RMBA.Team:GetTeamMember( i )
			if nil ~= member then
				local columnWidth = self.frames.base:GetWidth() / 3
				local distance = RMBA.Utils:GetDistance( member.name ) or 0
				
				-- Name
				if (member.class == "warrior") then
					self.frames.rows[i].background:SetBackgroundColor( CallingColors[1].r, CallingColors[1].g, CallingColors[1].b )
				elseif (member.class == "mage") then
					self.frames.rows[i].background:SetBackgroundColor( CallingColors[2].r, CallingColors[2].g, CallingColors[2].b )
				elseif (member.class == "rogue") then
					self.frames.rows[i].background:SetBackgroundColor( CallingColors[3].r, CallingColors[3].g, CallingColors[3].b )
				elseif (member.class == "cleric") then
					self.frames.rows[i].background:SetBackgroundColor( CallingColors[4].r, CallingColors[4].g, CallingColors[4].b )
				end
				self.frames.rows[i].leftLabel:SetText( tostring(member.level or 0).." "..member.name )

				-- Health
				if (nil ~= member.health) and (nil ~= member.healthMax) and (0 ~= member.healthMax) then
					local index = 8
					if distance > 15.0 then
						local diststr = string.format( "%.2f", distance or 0.0 )
						self.frames.rows[i].healthLabel:SetText( diststr )
						self.frames.rows[i].directionFrame:SetVisible( true )
						self.frames.rows[i].directionFrame:SetTexture( Addon.identifier, RMBA.Utils:GetDirectionTexture( member.name ) )
						index = 10
					else
						self.frames.rows[i].directionFrame:SetVisible( false )
						self.frames.rows[i].healthLabel:SetText( "" )
					end
					if (tonumber(member.healthMax) > 0) then
						self.frames.rows[i].healthFrame:SetWidth( columnWidth * (member.health / member.healthMax) )
					end
					self.frames.rows[i].healthFrame:SetBackgroundColor( CallingColors[index].r, CallingColors[index].g, CallingColors[index].b )
				end

				-- Experience
				if (nil ~= member.accumulatedExp) and (nil ~= member.neededExp) then
					local index = 7
					if (nil ~= member.rested) and (tonumber(member.rested) > 0) then
						index = 6
					end
					local width = 0
					if (tonumber(member.neededExp) > 0) then
						width = columnWidth * (tonumber(member.accumulatedExp) / tonumber(member.neededExp))
					end
					self.frames.rows[i].expFrame:SetWidth( width )
					self.frames.rows[i].expFrame:SetBackgroundColor( CallingColors[index].r, CallingColors[index].g, CallingColors[index].b )
				end
				
			end
		end
	end
end

function Window:SetRows( number )
	RMBA.Utils:PrintDebug( "Window:SetRows() - "..tostring(number) )
	
	local forCount = number
	local rowCount = 0
	local count = math.max( number, 1 )
	self.settings.rows = count
	
	if self.frames.rows then
		self:ClearRows( #self.frames.rows )
	else
		self.frames.rows = {}
	end
	
	for i = rowCount + 1, forCount do
		local row = {}
		self.frames.rows[i] = row

		row.base = UI.CreateFrame( "Texture", "RMBA_rows_" .. i .. "_base", self.frames.base )
		row.background = UI.CreateFrame( "Texture", "RMBA_rows_" .. i .. "_background", row.base )
		row.icon = UI.CreateFrame( "Texture", "RMBA_rows_" .. i .. "_icon", row.base )
		row.leftLabel = UI.CreateFrame("Text", "RMBA_rows_" .. i .. "_leftLabel", row.base )

		row.expFrame = UI.CreateFrame("Texture", "RMBA_rows_" .. i .. "_experience", row.base )
		row.expFrameBackground = UI.CreateFrame("Texture", "RMBA_rows_" .. i .. "_experiencebg", row.base )
		row.expLabel = UI.CreateFrame("Text", "RMBA_rows_" .. i .. "_expLabel", row.base )
		
		row.healthFrame = UI.CreateFrame("Texture", "RMBA_rows_" .. i .. "_health", row.base )
		row.healthFrameBackground = UI.CreateFrame("Texture", "RMBA_rows_" .. i .. "_healthbg", row.base )
		row.healthLabel = UI.CreateFrame("Text", "RMBA_rows_" .. i .. "_healthLabel", row.base )

		row.directionFrame = UI.CreateFrame("Texture", "RMBA_rows_" .. i .. "_direction", row.base )
		row.directionFrame:SetHeight( 16 )
		row.directionFrame:SetWidth( 16 )

		if i == 1 then
			row.base:SetPoint( "TOPLEFT", self.frames.header, "BOTTOMLEFT", 1, self.rowPadding )
		else
			row.base:SetPoint( "TOPLEFT", self.frames.rows[i - 1].base, "BOTTOMLEFT", 0, self.rowPadding )
		end
	  
		local columnWidth = self.frames.base:GetWidth() / 3
	  
		row.base:SetHeight( self.rowHeight )
		row.base:SetMouseMasking( "limited" )
		row.base:SetLayer( 2 )
		row.base:SetVisible( true )
	  
		row.background:SetPoint( "TOPLEFT", row.base, "TOPLEFT" )
		row.background:SetPoint( "BOTTOM", row.base, "BOTTOM" )
		row.background:SetWidth( columnWidth )
		row.background:SetAlpha( 0.45 )
		row.background:SetLayer( 1 )
		row.background:SetTexture( Addon.identifier, [[textures\row.png]] )

		row.leftLabel:SetPoint( "CENTERY", row.base, "CENTERY" )
		row.leftLabel:SetPoint( "LEFT", row.base, "LEFT" )
		row.leftLabel:SetFontSize( self.rowFontSize )
		row.leftLabel:SetLayer( 3 )
	  
		row.healthFrame:SetPoint( "TOPLEFT", row.base, "TOPLEFT", columnWidth, 0 )
		row.healthFrame:SetPoint( "BOTTOM", row.base, "BOTTOM" )
		row.healthFrame:SetWidth( columnWidth )
		row.healthFrame:SetAlpha( 0.45 )
		row.healthFrame:SetLayer( 2)

		row.directionFrame:SetPoint( "TOPLEFT", row.healthFrame, "TOPLEFT", 10, 0 )

		row.healthLabel:SetPoint( "CENTERY", row.healthFrame, "CENTERY" )
		row.healthLabel:SetPoint( "CENTER", row.healthFrame, "CENTER" )
		row.healthLabel:SetFontSize( self.rowFontSize )
		row.healthLabel:SetLayer( 3 )

		row.expFrame:SetPoint( "TOPLEFT", row.base, "TOPLEFT", columnWidth * 2, 0 )
		row.expFrame:SetPoint( "BOTTOM", row.base, "BOTTOM" )
		row.expFrame:SetWidth( columnWidth )
		row.expFrame:SetAlpha( 0.45 )
		row.expFrame:SetLayer( 2 )

	end

	self:Update()
end

function Window:ClearRows( number )
	RMBA.Utils:PrintDebug( "Window:ClearRows()" )
	local count = math.max( number, 1 )
	
	for i = 1, count do
		if nil ~= self.frames.rows[i] then
			self.frames.rows[i].base:ClearAll()
			self.frames.rows[i].leftLabel:ClearAll()
			self.frames.rows[i].leftLabel:SetText("")
			self.frames.rows[i].background:ClearAll()
			self.frames.rows[i].healthFrame:ClearAll()
			self.frames.rows[i].healthLabel:SetText("")
			self.frames.rows[i].expFrame:ClearAll()
			self.frames.rows[i].directionFrame:ClearAll()
			table.remove( self.frames.rows[i] )
		end
	end
end

function Window:handleFrameMovement( frame )
	frame:EventAttach( Event.UI.Input.Mouse.Left.Down, 
				function() 
					local mouse = Inspect.Mouse()
					frame.mouseOffsetX = frame:GetLeft() - mouse.x
					frame.mouseOffsetY = frame:GetTop() - mouse.y
				end, "_LeftMouseDown" )

	frame:EventAttach( Event.UI.Input.Mouse.Left.Up, 
				function()
					frame.mouseOffsetX = nil
					frame.mouseOffsetY = nil
				end, "_LeftMouseUp" )
	
	frame:EventAttach( Event.UI.Input.Mouse.Cursor.Move, 
				function()
					if( frame.mouseOffsetX ) then
						local mouse = Inspect.Mouse()
						local x = mouse.x + frame.mouseOffsetX
						local y = mouse.y + frame.mouseOffsetY
						frame:SetPoint( "TOPLEFT", UIParent, "TOPLEFT", x, y )
					end
				end, "_MouseCursorMove" )
end

function Window:addBorder( parent, width, r, g, b, a )
	local frame = {}

	frame.left = UI.CreateFrame( "Frame", "Border", parent )
	frame.left:SetWidth( width )
	frame.left:SetPoint( "TOPRIGHT", parent, "TOPLEFT", 0, 0 - width )
	frame.left:SetPoint( "BOTTOMRIGHT", parent, "BOTTOMLEFT", 0, width )
	frame.left:SetBackgroundColor( r, g, b, a )

	frame.top = UI.CreateFrame( "Frame", "Border", parent )
	frame.top:SetHeight( width )
	frame.top:SetPoint( "BOTTOMLEFT", parent, "TOPLEFT", 0 - width, 0 )
	frame.top:SetPoint( "BOTTOMRIGHT", parent, "TOPRIGHT", width, 0 )
	frame.top:SetBackgroundColor( r, g, b, a )

	frame.right = UI.CreateFrame( "Frame", "Border", parent )
	frame.right:SetWidth( width )
	frame.right:SetPoint( "TOPLEFT", parent, "TOPRIGHT", 0, 0 - width )
	frame.right:SetPoint( "BOTTOMLEFT", parent, "BOTTOMRIGHT", 0, width )
	frame.right:SetBackgroundColor( r, g, b, a )

	frame.bottom = UI.CreateFrame( "Frame", "Border", parent )
	frame.bottom:SetHeight( width )
	frame.bottom:SetPoint( "TOPLEFT", parent, "BOTTOMLEFT", 0 - width, 0 )
	frame.bottom:SetPoint( "TOPRIGHT", parent, "BOTTOMRIGHT", width, 0 )
	frame.bottom:SetBackgroundColor( r, g, b, a )

	return frame
end

function Window:createIconButton( name, context, icon, anchor, parent, parentAnchor, x, y, tooltip, leftClick )
	local button = UI.CreateFrame( "Texture", name, context )

	button:SetTexture( Addon.identifier, icon )
	button:SetPoint( anchor, parent, parentAnchor, x, y )
	button:SetLayer( 1 )

	button:EventAttach( Event.UI.Input.Mouse.Left.Down, leftClick, "_LeftMouseDown" )

	button:EventAttach( Event.UI.Input.Mouse.Cursor.In, 
				 function()
			  AsyncFix = name
			  RMBA.tooltip:show( tooltip, button, true )
				 end, "_MouseCursorIn" ) 

	button:EventAttach( Event.UI.Input.Mouse.Cursor.Out,
				 function()
			  if name == AsyncFix then
				  RMBA.tooltip:hide()
			  end
				 end, "_MouseCursorOut" ) 

	return button
end

local TextEffect = {}
function Window:createTextFrame( name, context )
	local frame = UI.CreateFrame( "Text", name, context )
	frame:SetEffectGlow( TextEffect )

	return frame
end


local Tooltip = {
	maxWidth = 210,
	padding = 5,
	tooltip = nil,
}

function Tooltip:init()
	self.tooltip = UI.CreateFrame( "Frame", "RMBA_tooltip", Context )
	self.tooltip:SetVisible( false )
	self.tooltip:SetBackgroundColor( 0, 0, 0, 0.70 )
	self.tooltip:SetLayer( 2 )

	local borderTop = UI.CreateFrame( "Frame", "RMBA_tooltipBorderTop", self.tooltip )
	borderTop:SetBackgroundColor( 0.47, 0.47, 0.42 )
	borderTop:SetPoint( "TOPLEFT", self.tooltip, "TOPLEFT" )
	borderTop:SetPoint( "BOTTOMRIGHT", self.tooltip, "TOPRIGHT", 0, 1 )

	local borderLeft = UI.CreateFrame( "Frame", "RMBA_tooltipBorderLeft", self.tooltip )
	borderLeft:SetBackgroundColor( 0.47, 0.47, 0.42 )
	borderLeft:SetPoint( "TOPLEFT", self.tooltip, "TOPRIGHT", -1, 0 )
	borderLeft:SetPoint( "BOTTOMRIGHT", self.tooltip, "BOTTOMRIGHT" )

	local borderRight = UI.CreateFrame( "Frame", "RMBA_tooltipBorderRight", self.tooltip )
	borderRight:SetBackgroundColor( 0.47, 0.47, 0.42 )
	borderRight:SetPoint( "TOPLEFT", self.tooltip, "TOPLEFT" )
	borderRight:SetPoint( "BOTTOMRIGHT", self.tooltip, "BOTTOMLEFT", 1, 0 )

	local borderBottom = UI.CreateFrame( "Frame", "RMBA_tooltipBorderBottom", self.tooltip )
	borderBottom:SetBackgroundColor( 0.47, 0.47, 0.42 )
	borderBottom:SetPoint( "TOPLEFT", self.tooltip, "BOTTOMLEFT", 0, -1 )
	borderBottom:SetPoint( "BOTTOMRIGHT", self.tooltip, "BOTTOMRIGHT" )

	self.tooltipText = UI.CreateFrame( "Text", "RMBA_tooltipText", self.tooltip )
	self.tooltipText:SetWordwrap( false )
	self.tooltipText:SetFontSize( 13 )
	self.tooltipText:SetAlpha( 0.90 )
end

function Tooltip:show( text, anchor, center )
	if not self.tooltip then
		self:init()
	end

	self.tooltip:ClearAll()
	self.tooltipText:ClearAll()

	if center then
		self.tooltipText:SetPoint( "TOPCENTER", self.tooltip, "TOPCENTER", 0, self.padding )
	else
		self.tooltipText:SetPoint( "TOPLEFT", self.tooltip, "TOPLEFT", self.padding, self.padding )
	end
	self.tooltipText:SetText( "" )
	self.tooltipText:SetText( text, true )

	self.tooltipText:SetWidth( self.tooltipText:GetWidth() + 1 )
	self.tooltip:SetWidth( self.tooltipText:GetWidth() + 2 * self.padding )
	self.tooltip:SetHeight( self.tooltipText:GetHeight() + 2 * self.padding )
	
	if anchor then
		self.tooltip:SetPoint( "BOTTOMCENTER", anchor, "TOPCENTER", 0, -10 )
	else
		self.tooltip:SetPoint( "BOTTOMLEFT", UI.Native.TooltipAnchor, "BOTTOMLEFT" )
	end

	self.tooltip:SetVisible( true )
end

function Tooltip:hide()
	if not self.tooltip then
		return
	end

	self.tooltip:SetVisible( false )
end
RMBA.tooltip = Tooltip