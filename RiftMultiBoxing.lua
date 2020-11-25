--[[
   Rift MultiBoxing Addon Copyright 2020 Sean Kennedy

	MIT License

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]

local Addon, RMBA = ...

RMBASettings = {
   debug = false,
   visible = true,
   broadcastVersion = true,
   broadcastChannel = "party",
   windowSettings = { 
			rows = 5,
			width = 300,
			height = 115,
			x = 10,
			y = UIParent:GetHeight() - 150,
		   },
}

function SlashHandler( args )
	RMBA.Utils:PrintDebug( "SlashHandler" )

	-- Parse command into separate tokens
	local argv = {}
	local i = 1
	for str in string.gmatch( args, "([^ ]+)" ) do
		RMBA.Utils:PrintDebug( str )
		argv[i] = str
		i = i + 1
	end
   
	-- Convert command to lower case for case insensitive comparisons
	if nil ~= argv[1] then
		argv[1] = string.lower( argv[1] )
	end
   
	if argv[1] == RMBAL:TXT("command_show") then
		RMBASettings.visible = true
		RMBA.Window:SetVisible( RMBASettings.visible )
		return
	elseif argv[1] == RMBAL:TXT("command_hide") then
		RMBASettings.visible = false
		RMBA.Window:SetVisible( RMBASettings.visible )
		return
	elseif argv[1] == RMBAL:TXT("command_channel") then
		if (argv[2] == RMBAL:TXT("channel_party")) or (argv[2] == RMBAL:TXT("channel_party")) then
			RMBASettings = argv[2]
		else
			print( RMBAL:TXT("text_errorChannel") )
		end
		return
	elseif argv[1] == "debug" then
		RMBASettings.debug = not RMBASettings.debug
		RMBA.Utils:PrintDebug( "Debugging: "..tostring(RMBASettings.debug) )
		if (true == RMBASettings.debug) then
			RMBA.Utils:PrintDebug( "Debugging: - Strict mode enabled" )
			Command.System.Strict()
		end
		return
	elseif argv[1] == RMBAL:TXT("command_team") then
		if argv[2] == RMBAL:TXT("command_team_master") then
		RMBA.Team:Master( argv[3] )
		return
	elseif argv[2] == RMBAL:TXT("command_team_list") then
		RMBA.Team:List()
		return
	elseif argv[2] == RMBAL:TXT("command_team_add") then
		RMBA.Team:Add( argv[3], true )
		return
	elseif argv[2] == RMBAL:TXT("command_team_remove") then
		RMBA.Team:Remove( argv[3] )
		return
	end end

	print( RMBAL:TXT("text_commandLine1") )
	print( RMBAL:TXT("text_commandLine2") )
	print( RMBAL:TXT("text_commandLine3") )
	print( RMBAL:TXT("text_commandLine4") )
	print( RMBAL:TXT("text_commandLine5") )
	print( RMBAL:TXT("text_commandLine6") )
	print( RMBAL:TXT("text_commandLine7") )
	print( RMBAL:TXT("text_commandLine8") )
	print( RMBAL:TXT("text_commandLine9") )
end

function Init( event, addonName )
   RMBA.Utils:PrintDebug( "Init()" )

   if addonName ~= Addon.toc.Identifier then return end

   RMBA.Comm:SetBroadcastVersion( RMBASettings.broadcastVersion )
   RMBA.Comm:Initialize()

   RMBA.Team:Initalize()

   RMBA.Window = Window:new( RMBASettings.windowSettings )
   RMBA.Window:SetTitle( Addon.name )
   RMBA.Window:SetVisible( RMBASettings.visible )

   local str = string.format( RMBAL:TXT("text_initComplete"), Addon.toc.Version )
   Command.Console.Display( "general", false, str, true )
end

function PreLoad( event, addonName )
   RMBA.Utils:PrintDebug( "PreLoad()" )
   RMBA.Comm:PreLoad()
end

function PreSave( event, addonName )
   RMBA.Utils:PrintDebug( "PreSave()" )
   
   RMBASettings.windowSettings.width = RMBA.Windows:GetWidth()
   RMBASettings.windowSettings.height = RMBA.Windows:GetHeight()
   RMBASettings.windowSettings.x = RMBA.Windows:GetLeft()
   RMBASettings.windowSettings.y = RMBA.Windows:GetTop()
   
   RMBA.Comm:PreSave()
end

table.insert( Command.Slash.Register("rmba"), {SlashHandler, Addon.identifier, "Slash Command"} )

Command.Event.Attach( Event.Addon.Load.End, Init, "Initial setup" )
Command.Event.Attach( Event.Addon.SavedVariables.Load.Begin, PreLoad, "Load settings begin" )
Command.Event.Attach( Event.Addon.SavedVariables.Save.Begin, PreSave, "Save settings begin" )
