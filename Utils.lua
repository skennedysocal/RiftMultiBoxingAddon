-- Rift MultiBoxing Addon Utilities
-- Written By Molikar@Hailol
-- Copyright 2020

local Addon, RMBA = ...

RMBA.Utils = {}

function RMBA.Utils:PrintError( str, channel )
   local lStr = str or ""
   local lChannel = channel
   if nil == lChannel then lChannel = "general" end
   
   Command.Console.Display( lChannel, false, "<font color='#FF0000'>"..tostring(lStr).."</font>", true )
end

function RMBA.Utils:PrintDebug( str, channel )
   --if false == RMBASettings.debug then return end
   
   local lStr = str or ""
   local lChannel = channel
   if nil == lChannel then lChannel = "general" end

   Command.Console.Display( lChannel, false, "<font color='#FF00FF'>"..tostring(lStr).."</font>", true )
end

function RMBA.Utils:GetDefaultWindowSettings()
   local windowDefaultSettings = {}

   windowDefaultSettings.rows = 5
   windowDefaultSettings.width = 300
   windowDefaultSettings.height = 150
   windowDefaultSettings.rowHeight = 18
   windowDefaultSettings.x = (UIParent:GetWidth() - windowDefaultSettings.width) / 2
   windowDefaultSettings.y = UIParent:GetHeight() / 2

   return windowDefaultSettings
end

function RMBA.Utils:split(inputstr, seperator)
	if seperator == nil then
		seperator = "%s"
	end
    
	local t = {}
	for str in string.gmatch(inputstr, "([^"..seperator.."]+)") do
		table.insert(t, str)
	end
	
	return t
end

function RMBA.Utils:spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function RMBA.Utils:GetGroupName( name )
	RMBA.Utils:PrintDebug( "RMBA.Member:GetGroupName() - "..name )

	for i = 1, 20 do
		local groupName = string.format( "group%02d", i) 
		local groupInfo = Inspect.Unit.Detail( groupName )
		if nil ~= groupInfo then
			if groupInfo.name == name then return groupName end
		end
	end

	return nil
end

function RMBA.Utils:GetGroupSize()
	RMBA.Utils:PrintDebug( "RMBA.Member:GetGroupSize()" )

	local count = 0
	for i = 1, 20 do
		local groupName = string.format( "group%02d", i) 
		local groupInfo = Inspect.Unit.Detail( groupName )
		if nil ~= groupInfo then
			count = count + 1
		end
	end

	return count
end

function RMBA.Utils:GetDistances()
	local leader = Inspect.Unit.Detail( "group01" )
	if nil == leader then return end
	RMBA.Utils:PrintDebug( "RMBA.Member:GetDistances() from "..leader.name )

	local distance = {}
	for i = 2, 20 do
		local groupName = string.format( "group%02d", i) 
		local slot = Inspect.Unit.Detail( groupName )
		if nil ~= slot then
			local d = RMBA.Utils:ComputeDistance( leader.coordX, leader.coordY, leader.coordZ, slot.coordX, slot.coordY, slot.coordZ )
			table.insert( distance, d )
		end
	end

	return distance
end

function RMBA.Utils:GetDistance( name )
	local leader = Inspect.Unit.Detail( "group01" )
	if nil == leader then return end
	--RMBA.Utils:PrintDebug( "RMBA.Member:GetDistance() from "..name.." to "..leader.name )

	for i = 2, 20 do
		local groupName = string.format( "group%02d", i) 
		local slot = Inspect.Unit.Detail( groupName )
		if (nil ~= slot) and (slot.name == name) then
			return RMBA.Utils:ComputeDistance( slot.coordX, slot.coordY, slot.coordZ, leader.coordX, leader.coordY, leader.coordZ )
		end
	end

	return 0
end

function RMBA.Utils:ComputeDistance( x1, y1, z1, x2, y2, z2 )
	return math.sqrt( (math.pow(x2 - x1, 2)) + (math.pow(y2 - y1, 2)) + (math.pow(z2 - z1, 2)) )
end

function RMBA.Utils:GetDirectionTexture( name )
	local leader = Inspect.Unit.Detail( "group01" )
	if nil == leader then return "" end

	local slot = nil
	for i = 2, 20 do
		slot = Inspect.Unit.Detail( string.format( "group%02d", i) )
		if (nil ~= slot) and (slot.name == name) then
			break
		end
		slot = nil
	end
	if nil == slot then return "" end

	local dx = slot.coordX - leader.coordX
	local dz = slot.coordZ - leader.coordZ
	local dt = (math.atan( dx, dz ) * 180) / math.pi

	if dt > 180 then dt = dt - 360 end
	if dt < -180 then dt = dt + 360 end

	if dt >= 169		then arrow = "Textures/compass-S.png"
	elseif dt >= 146	then arrow = "Textures/compass-SSW.png"
	elseif dt >= 124	then arrow = "Textures/compass-SW.png"
	elseif dt >= 101	then arrow = "Textures/compass-WSW.png"
	elseif dt >= 79		then arrow = "Textures/compass-W.png"
	elseif dt >= 56		then arrow = "Textures/compass-WNW.png"
	elseif dt >= 34		then arrow = "Textures/compass-NW.png"
	elseif dt >= 11		then arrow = "Textures/compass-NNW.png"
	elseif dt >= -11	then arrow = "Textures/compass-N.png"
	elseif dt >= -34	then arrow = "Textures/compass-NNE.png"
	elseif dt >= -56	then arrow = "Textures/compass-NE.png"
	elseif dt >= -79	then arrow = "Textures/compass-ENE.png"
	elseif dt >= -101	then arrow = "Textures/compass-E.png"
	elseif dt >= -124	then arrow = "Textures/compass-ESE.png"
	elseif dt >= -146	then arrow = "Textures/compass-SE.png"
	elseif dt >= -169	then arrow = "Textures/compass-SSE.png"
	else					 arrow = "Textures/compass-S.png"
	end

	return arrow
end
