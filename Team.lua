-- Rift MultiBoxing Addon: Team
-- Written By Molikar@Hailol
-- Copyright 2020

local Addon, RMBA = ...

RMBATeam = {
   master = nil,
   current = nil,
   lastupdate = 0,
   members = {},
}

RMBA.Team = {
   Events = {
      Change = {},
      MemberUpdate = {},
   },
}
RMBA.Team.__index = RMBA.Team

function RMBA.Team:Initalize()
	RMBA.Utils:PrintDebug( "RMBA.Team:Initialize()" )

	RMBATeam.timestamp = Inspect.Time.Real()

	if nil == RMBATeam then RMBATeam = {} end
	RMBATeam.current = Inspect.Unit.Detail("player")["name"]

	local member = RMBA.Member:new( name )
	if nil == member then return end

	RMBA.Team.Events.MemberUpdate( member, true )
end

function RMBA.Team:Add( name, broadcast )
	RMBA.Utils:PrintDebug( "RMBA.Team:Add() - "..name )
	if nil == broadcast then broadcast = true end
	
	local index = self:GetIndex( name )
	if index == nil then
		local member = RMBA.Member:new( name )
		table.insert( RMBATeam.members, member )
	else
		RMBA.Utils:PrintDebug( "RMBA.Team:Add() - "..name.. " is already a member of the team" )
	end

	if true == broadcast then
		RMBA.Team.Events.MemberUpdate( member )
	end
end

function RMBA.Team:Update( member, broadcast )
	if nil == broadcast then broadcast = true end
	if nil == member then return end
	RMBA.Utils:PrintDebug( "RMBA.Team:Update() - "..member.name )
	
	local index = RMBA.Team:GetIndex( member.name )
	if nil == index then
		RMBA.Team:Add( member.name )
		index = RMBA.Team:GetIndex( member.name )
		if nil == member then return end
	end

	RMBA.Utils:PrintDebug( "RMBA.Team:Update() - "..member.name )
	RMBATeam.members[index].accumulatedExp = member.accumulatedExp
	RMBATeam.members[index].neededExp      = member.neededExp
	RMBATeam.members[index].restedExp      = member.restedExp
	RMBATeam.members[index].level          = member.level
	RMBATeam.members[index].class          = member.class
	RMBATeam.members[index].role           = member.role
	RMBATeam.members[index].raceName       = member.raceName
	RMBATeam.members[index].health         = member.health
	RMBATeam.members[index].healthMax      = member.healthMax

	if true == broadcast then
		RMBA.Team.Events.MemberUpdate( member )
	end
end

function RMBA.Team:Master( name, broadcast )
	if nil == broadcast then broadcast = true end
	if nil == name then return end
	RMBA.Utils:PrintDebug( "RMBA.Team:Master() - "..name )

	RMBATeam.master = name
	self.Events.Change()
	if true == broadcast then
		RMBA.Team.Events.Change( RMBATeam )
	end	
end

function RMBA.Team:Add( name, broadcast )
	if nil == broadcast then broadcast = true end

	if nil == name then return end
	RMBA.Utils:PrintDebug( "RMBA.Team:Add() - "..name )

	local addUser = true
	for i, member in ipairs(RMBATeam.members) do 
		if name == member.name then
			addUser = false
			break
		end
	end

	if addUser == true then
		local member = RMBA.Member:new( name )
		table.insert( RMBATeam.members, member )
		RMBA.Team:Sort()

		if nil ~= RMBA.Window then
			RMBA.Window:SetRows( #RMBATeam.members )
			self.Events.Change()
		end
		
		if true == broadcast then
			RMBA.Team.Events.MemberUpdate( member )
		end
	end
end

function RMBA.Team:Remove( name, broadcast )
	if nil == name then return end
	if nil == RMBATeam then return end
	RMBA.Utils:PrintDebug( "RMBA.Team:Remove() - "..name )
   
	if RMBATeam.master == name then 
		RMBATeam.master = nil 
	end

	for i, member in ipairs(RMBATeam.members) do 
		if name == member.name then
			table.remove( RMBATeam.members, i )
			RMBA.Team:Sort()
			RMBA.Window:SetRows( #RMBATeam.members )
			self.Events.Change()
			break
		end
	end
end

function RMBA.Team:GetIndex( name )
   if nil == name then return end
   if nil == RMBATeam.members then return end
   RMBA.Utils:PrintDebug( "RMBA.Team:GetIndex() - "..name )

   local index = nil

   for i, member in ipairs(RMBATeam.members) do 
      if name == member.name then
         index = i
         break
      end
   end

   return index
end

function RMBA.Team:List()
	if nil == RMBATeam.members then 
		RMBA.Utils:PrintDebug( "RMBA.Team:List() - No team members" )
		return
	end
	
	if RMBATeam.master ~= nil then
		Command.Console.Display( "general", true, string.format( "%s %s", RMBAL:TXT("text_list_master"), RMBATeam.master), true )
	end
   
	Command.Console.Display( "general", true, RMBAL:TXT("text_list_team"), true )
	for i, member in ipairs(RMBATeam.members) do
		Command.Console.Display( "general", true, string.format( "%s %d %s %s", 
																	member.name or "", 
																	tostring(member.level or 0), 
																	member.class or "", 
																	member.role or ""), true )
	end
end

function RMBA.Team:Sort()
	local newlist = {}

	dump( RMBATeam.members )
	for k, v in RMBA.Utils:spairs(RMBATeam.members, function(t, a, b) return t[a].name < t[b].name end) do
		table.insert(newlist, v)
	end

	RMBATeam.members = newlist
end

function RMBA.Team.ExperienceChange( etable, accumulated, rested, needed )
   local index = RMBA.Team:GetIndex( RMBATeam.current )
   if nil == index then return end

   RMBA.Utils:PrintDebug( "RMBA.Team.ExperienceChange() - "..RMBATeam.members[index].name )
   RMBATeam.members[index]:Update()
   RMBA.Window:Update()
   
   RMBA.Team.Events.MemberUpdate( RMBATeam.members[index] )
end

function RMBA.Team.HealthChange( units )
	local index = RMBA.Team:GetIndex( RMBATeam.current )
	if nil == index then return end
	
	RMBA.Utils:PrintDebug( "RMBA.Team:HealthChange()" )
	RMBATeam.members[index]:Update()
	RMBA.Window:Update()

	RMBA.Team.Events.MemberUpdate( RMBATeam.members[index] )
end

function RMBA.Team.LevelChange( units )
   local index = RMBA.Team:GetIndex( RMBATeam.current )
   if nil == index then return end
   member = RMBATeam.members[index];
   if nil == member then return end

   RMBA.Utils:PrintDebug( "RMBA.Team.LevelChange() - "..RMBATeam.current  )
   member.level = Inspect.Unit.Detail("player")["level"]
   RMBA.Team.Events.MemberUpdate( member )
end

function RMBA.Team:GetTeamMember( index )
	if nil == RMBATeam.members then return nil end
	if index > #RMBATeam.members then return nil end

	return RMBATeam.members[index]
end

function RMBA.Team.OfflineChange( units )
   RMBA.Utils:PrintDebug( "RMBA.Team.OfflineChange()" )

   RMBA.Team.Events.Change()
end

function RMBA.Team.Join( handle, units )
	if nil == units then return end

	local playerFound = false
	local groupFound = false
	
	if ( type(units) == "table" ) then
		for k, v in pairs(units) do -- k would be player id
			if tostring(v) == "player" then
				playerFound = true
			elseif string.match(tostring(v), "group") then -- group01 is player 1, group02 player 2, etc
				groupFound = true
			end
		end
	end
	
	if ( (playerFound == true) and (groupFound == true) ) then
		RMBA.Utils:PrintDebug( "RMBA.Team.Join() - Adding "..RMBATeam.current.." to team" )
		RMBA.Team:Add( RMBATeam.current, true )
	end
	
end

function RMBA.Team.Leave( handle, units )
	if nil == units then return end
	if type(units) ~= "table" then return end
	
	for k, v in pairs(units) do -- k would be player id
		-- RMBA.Utils:PrintDebug( tostring(k).." = "..tostring(v) )
		if tostring(v) == "player" then
			local groupName = RMBA.Utils:GetGroupName( RMBATeam.current )
			if nil == groupName then
				RMBA.Utils:PrintDebug( "RMBA.Team.Join() - Removing "..RMBATeam.current.." from team" )
				RMBA.Team:Remove( RMBATeam.current, true )
			end
		end
	end
end

function RMBA.Team.Refresh()
	local ctx = Inspect.Time.Real()

	if ctx - RMBATeam.lastupdate > 5 then
		RMBA.Utils:PrintDebug( "RMBA.Team:Refresh()" )
		--dump( Inspect.Unit.Detail( "group01" ) )
		RMBATeam.lastupdate = ctx
		RMBA.Window:Update()
	end
end

RMBA.Team.Events.Change, RMBA.Team.Events.Change.EventTable = Utility.Event.Create( Addon.identifier, "Team.Change" )
RMBA.Team.Events.MemberUpdate, RMBA.Team.Events.MemberUpdate.EventTable = Utility.Event.Create( Addon.identifier, "Member.Update" )

Command.Event.Attach( Event.TEMPORARY.Experience, RMBA.Team.ExperienceChange, "Experience Change" )
Command.Event.Attach( Event.Unit.Detail.Level, RMBA.Team.LevelChange, "Level Change" )
Command.Event.Attach( Event.Unit.Detail.Offline, RMBA.Team.OfflineChange, "Offline Change" )
Command.Event.Attach( Event.Unit.Detail.Health, RMBA.Team.HealthChange, "Health Change" )
Command.Event.Attach( Event.Unit.Add, RMBA.Team.Join, "Join Team" )
Command.Event.Attach( Event.Unit.Remove, RMBA.Team.Leave, "Leave Team" )
Command.Event.Attach( Event.System.Update.Begin, RMBA.Team.Refresh, "Refresh Team" )

