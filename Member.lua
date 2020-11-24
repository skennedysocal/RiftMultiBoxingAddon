-- Rift MultiBoxing Addon Team
-- Written By Molikar@Hailol
-- Copyright 2020

local Addon, RMBA = ...

RMBA.Member = {}
RMBA.Member.__index = RMBA.Member

function RMBA.Member:new( name )
   local self = {}
   setmetatable( self, RMBA.Member )
   
   self.name = name
   self.class = ""
   self.role = ""
   self.level = 0
   self.neededExp = 0
   self.accumulatedExp = 0
   self.restedExp = 0
   self.resource = 0
   self.raceName = ""
   self.health = 0
   self.healthMax = 0
   self.coordX = 0
   self.coordY = 0
   self.coordZ = 0

   self:Initalize()

   return self
end

function RMBA.Member:Initalize()
	RMBA.Utils:PrintDebug( "RMBA.Member:Initialize()" )
	
	local name = Inspect.Unit.Detail("player")["name"]
	if nil == self.name then
		self.name = name
	elseif name ~= self.name then 
		return 
	end

	local expInfo = Inspect.Experience()
	if nil == expInfo then
		self.accumulatedExp = 0
		self.neededExp = 0
		self.restedExp = 0
	else
		self.accumulatedExp = expInfo.accumulated
		self.neededExp = expInfo.needed
		self.restedExp = expInfo.rested
	end
	self.level = Inspect.Unit.Detail("player")["level"] or 0
	self.class = Inspect.Unit.Detail("player")["calling"] or ""
	self.class = Inspect.Unit.Detail("player")["role"] or ""
	self.raceName = Inspect.Unit.Detail("player")["raceName"] or ""
	self.health = Inspect.Unit.Detail("player")["health"] or 0
	self.healthMax = Inspect.Unit.Detail("player")["healthMax"] or 0
	self.coordX = Inspect.Unit.Detail("player")["coordX"] or 0
	self.coordY = Inspect.Unit.Detail("player")["coordY"] or 0
	self.coordZ = Inspect.Unit.Detail("player")["coordZ"] or 0
end

function RMBA.Member:Update()
	RMBA.Utils:PrintDebug( "RMBA.Member:Update() -- "..self.name)

	local expInfo = Inspect.Experience()
	if nil == expInfo then
		self.accumulatedExp = 0
		self.neededExp = 0
		self.restedExp = 0
	else
		self.accumulatedExp = expInfo.accumulated
		self.neededExp = expInfo.needed
		self.restedExp = expInfo.rested
	end
	self.level = Inspect.Unit.Detail("player")["level"] or 0
	self.class = Inspect.Unit.Detail("player")["calling"] or ""
	self.role = Inspect.Unit.Detail("player")["role"] or ""
	self.raceName = Inspect.Unit.Detail("player")["raceName"] or ""
	self.health = Inspect.Unit.Detail("player")["health"] or 0
	self.healthMax = Inspect.Unit.Detail("player")["healthMax"] or 0
	self.coordX = Inspect.Unit.Detail("player")["coordX"] or 0
	self.coordY = Inspect.Unit.Detail("player")["coordY"] or 0
	self.coordZ = Inspect.Unit.Detail("player")["coordZ"] or 0
end

function RMBA.Member:GetDataFromMember()
	RMBA.Utils:PrintDebug( "RMBA.Team:GetDataFromMember() - "..self.name )

	local data = string.format( "%s,%d,%d,%d,%d,%s,%s,%s,%d,%d,%d,%d,%d",
					self.name or "",
					self.accumulatedExp or 0,
					self.neededExp or 0,
					self.restedExp or 0,
					self.level or 0,
					self.class or "",
					self.role or "",
					self.raceName or "",
					self.health or 0,
					self.healthMax or 0,
					self.coordX or 0,
					self.coordY or 0,
					self.coordZ or 0)
	return data
end

function RMBA.Member:GetMemberFromData( data )
	if nil == data then
		RMBA.Utils:PrintError( "RMBA.Member:GetMemberFromData() - empty data" )
		return nil, false
	end
	RMBA.Utils:PrintDebug( "RMBA.Team:GetMemberFromData()")
   
	local list = RMBA.Utils:split( data, "," )
	if nil == list then 
		RMBA.Utils:PrintError( "RMBA.Member:GetMemberFromData() - Failed to split data: "..data )
		return nil, false
	end
	if nil == list[1] then
		RMBA.Utils:PrintError( "RMBA.Member:GetMemberFromData() - Failed to get member name" )
		return nil, false
	end
   
	local member = RMBA.Member:new( list[1] )
	if nil == member then
		RMBA.Utils:PrintError( "RMBA.Member:GetMemberFromData() - Call to RMBA.Member:new("..list[1]..") failed" )
		return nil, false
	end
   
	local broadcast = false
	if (nil ~= member.class) and (member.name == self.playerName) then
		broadcast = true
	end

	member.name = list[1]
	member.accumulatedExp = list[2]
	member.neededExp = list[3]
	member.restedExp = list[4]
	member.level = list[5]
	member.class = list[6]
	member.role = list[7]
	member.raceName = list[8]
	member.health = list[9]
	member.healthMax = list[10]
	member.coordX = list[11]
	member.coordY = list[12]
	member.coordZ = list[13]
	
	return member, broadcast
end
