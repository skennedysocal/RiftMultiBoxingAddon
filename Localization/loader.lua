-- Rift MultiBoxing AddOn Localizer
-- Written By Molikar@Hailol
-- Copyright 2020

local Addon, RMBA = ...
RMBAL = {}

local lang = Inspect.System.Language()
local RMBAStrings = RMBAStrings_en

if "French" == lang then
   RMBAStrings = RMBAStrings_en
elseif "German" == lang  then
   RMBAStrings = RMBAStrings_en
elseif "Korean" == lang then
   RMBAStrings = RMBAStrings_en
elseif "Russian" == lang  then
   RMBAStrings = RMBAStrings_en
elseif "Chinese" == lang  then
   RMBAStrings = RMBAStrings_en
elseif "Taiwanese" == lang  then
   RMBAStrings = RMBAStrings_en
end

function RMBAL:TXT( lookup ) 
   return RMBAStrings[lookup]
end
