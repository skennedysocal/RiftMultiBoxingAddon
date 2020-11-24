-- Rift MultiBoxing Addon: Communication
-- Written By Molikar@Hailol
-- Copyright 2020

local Addon, RMBA = ...

RMBA.Comm = {
	lastUpdate = 0,
	seenNewerVersion = false,
	broadcastVersion = true,
	lastBroadcast = 0,
	playerName = "RMBA",
	messageID = { 
		["Version"]  = "RMBAVersion", 
		["Team"]     = "TeamUpdate", 
		["Member"]   = "MemberUpdate", 
		["Settings"] = "SettingsUpdate", 
	},
}
RMBA.Comm__index = RMBA.Comm

function RMBA.Comm:PreLoad()
	if true == RMBA.Comm.broadcastVersion then
		Command.Message.Broadcast( RMBASettings.broadcastChannel or "party", nil, self.messageID["Version"], Addon.toc.Version )
		RMBA.Comm.lastBroadcast = os.time()
	end
end

function RMBA.Comm:PreSave()
end

function RMBA.Comm:Initialize()
	RMBA.Utils:PrintDebug( "RMBA.Comm.Initialize()" )
	self.playerName = Inspect.Unit.Detail("player")["name"]

	Command.Message.Accept( nil, self.messageID["Version"] )
	Command.Message.Accept( nil, self.messageID["Team"] )
	Command.Message.Accept( nil, self.messageID["Member"] )
	Command.Message.Accept( nil, self.messageID["Settings"] )
end

function RMBA.Comm:SetBroadcastVersion( broadcast )
	RMBA.Utils:PrintDebug( "RMBA.Comm.SetBroadcastVersion()" )
	if nil ~= broadcast then 
		RMBA.Comm.broadcastVersion = broadcast 
	end
end

function RMBA.Comm:CheckVersion( version )
	if true == self.seenNewerVersion then return end
	local outOfDate = self:CompareVersions( Addon.toc.Version, version )

	if true == outOfDate then
		local message = string.format( TXT("text_outOfDate"), Addon.toc.Identifier, version )
		Command.Console.Display( "general", true, message, true)
		self.seenNewerVersion = true
	end
end

function RMBA.Comm:CompareVersions( current, visible )
	local lCurrent = current
	local lVisible = visible

	-- These can be nil
	if nil == current then 
		lCurrent = "0.0.0.0"
	end
	if nil == visible then 
		lVisible = "0.0.0.0"
	end

	local vt1 = RMBA.Utils:split( lCurrent, "." )
	local vt2 = RMBA.Utils:split( lVisible, "." )

	if vt1[1] > vt2[1] then return false end
	if vt1[1] < vt2[1] then return true end
   
	-- vt1[1] == vt2[1]
	if vt1[2] > vt2[2] then return false end
	if vt1[2] < vt2[2] then return true end

	-- vt1[2] == vt2[2]
	if vt1[3] > vt2[3] then return false end
	if vt1[3] < vt2[3] then return true end

	-- vt1[3] == vt2[3]
	if vt1[4] > vt2[4] then return false end
	if vt1[4] < vt2[4] then return true end

	-- Versions are the same
	return false
end

function RMBA.Comm:TeamChanged( data )
	local index = RMBA.Team:GetIndex( data )
	if nil == index then return end

	RMBA.Utils:PrintDebug( "RMBA.Comm.TeamChanged() - "..data )
end

function RMBA.Comm:MemberChanged( data )
	if nil == data then return end
	RMBA.Utils:PrintDebug( "RMBA.Comm.MemberChanged() - "..data )

	local member, broadcast = RMBA.Member:GetMemberFromData( data )
	if nil == member then 
	    RMBA.Utils:PrintError( "RMBA.Comm.MemberChanged() - Failed to get member from data" )
		return 
	end

	RMBA.Team:Update( member, broadcast )
	RMBA.Window:Update()
end

function RMBA.Comm.MessageHandler( event, from, type, channel, identifier, data )
	if nil == type then return end
	if nil == data then return end
	if from == RMBA.Comm.playerName then 
		--RMBA.Utils:PrintDebug( "Not sending message to self" )
		return
	end

	if identifier == RMBA.Comm.messageID["Version"] then
		RMBA.Utils:PrintDebug( "CheckVersion: "..from..", version = "..data )
		RMBA.Comm:CheckVersion( data )
	elseif identifier == RMBA.Comm.messageID["Team"] then
		RMBA.Comm:TeamChanged( data )
	elseif identifier == RMBA.Comm.messageID["Member"] then
		RMBA.Comm:MemberChanged( data )
	end
end

function RMBA.Comm.TeamUpdate( event )
	RMBA.Utils:PrintDebug( "RMBA.Comm.TeamUpdate()" )
	Command.Message.Broadcast( RMBASettings.broadcastChannel or "party", nil, RMBA.Comm.messageID["Team"], RMBA.Comm.playerName )
end

function RMBA.Comm.MemberUpdate( event, member )
	if nil == member then return end
	RMBA.Utils:PrintDebug( "RMBA.Comm.MemberUpdate()")

	local data = member:GetDataFromMember()
	dump( data )
	Command.Message.Broadcast( RMBASettings.broadcastChannel or "party", nil, RMBA.Comm.messageID["Member"], data )
end

Command.Event.Attach( Event.Message.Receive, RMBA.Comm.MessageHandler, "Communication handler" )
Command.Event.Attach( Event.RiftMultiBoxingAddon.Team.Change, RMBA.Comm.TeamUpdate, "Team update notification" )
Command.Event.Attach( Event.RiftMultiBoxingAddon.Member.Update, RMBA.Comm.MemberUpdate, "Member update notification" )
