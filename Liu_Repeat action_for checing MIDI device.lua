--[[
Description: Repeat Action
Version: 1.1.0
Author: Lokasenna
Donation: https://paypal.me/Lokasenna
Changelog:
	Created scripts are automatically added to the Action List
	(MIDI actions should be in the MIDI Editor's action list)
	Will work with ReaScript and custom action IDs now
Links:
	Forum Thread http://forum.cockos.com/showthread.php?t=188632
	Lokasenna's Website http://forum.cockos.com/member.php?u=10417
About: 
	Allows action IDs to repeated at a specified interval
	
	1. This script won't do anything by itself; use the included script 'Lokasenna_Repeat Action - Add new action.lua' to generate a script
	for each action you want to repeat.
	
	2. In Reaper's action list, use the 'Load' button and browse to:
		'Reaper/Scripts/ReaTeam Scripts/Various/Lokasenna_Repeat Action/"

	3. Select the scripts you generated.
	
	4. Each script will be individually accessible in the action list for you to bind to a shortcut key.
Extensions:
Provides:
	[nomain] . > Lokasenna_Repeat Action/Lokasenna_Repeat Action.lua
	[main] Lokasenna_Repeat Action - Add new action.lua > Lokasenna_Repeat Action/Lokasenna_Repeat Action - Add new action.lua
--]]

local dm = debug_mode

local function Msg(str)
	reaper.ShowConsoleMsg(tostring(str).."\n")
end

---------------------------------------
------------ USER SETTINGS ------------

-- Minimum time (in seconds) to keep
-- window open if no key is detected
local close_time = 0     

---------------------------------------
---------------------------------------

local w, h = 192, 64


local startup = true
local key_down, hold_char
local last = reaper.time_precise()



if not (act and interval) then
	
	local script_path = debug.getinfo(1,'S').source:match[[^@?(.*[\/])[^\/]-$]]
	
	reaper.ShowMessageBox("This script needs an action ID to work with. Please use:\n\n\t'Lokasenna_Repeat Action - Add new action.lua'\n\nto generate a script for each action ID you want to repeat, then use the 'Load' button in Reaper's action list to find them - they're stored in:\n\n\t'"
		..(string.len(script_path) > 20 and ("..."..string.sub(script_path, -20) ) or script_path)
		.."Lokasenna_Repeat Action'", "Whoops", 0)
	return 0
end


-- Convert script GUIDs to action IDs if necessary
if string.sub(act, 1, 1) == "_" then act = reaper.NamedCommandLookup(act) end

-- Just some error checking because Lua occasionally 
-- throws a fit about numbers that are strings
act = tonumber(act)

-- Make really, really sure it's a valid action.
if not act or act <= 0 then
	reaper.ShowMessageBox("Invalid action ID.", "Whoops", 0)
	return 0
end

local wnd = midi and reaper.MIDIEditor_GetActive()
	

local char

local function check_act()
	
	_=dm and Msg(">check_act")
	
	local time = reaper.time_precise()

	_=dm and Msg("\tinterval set to: "..tostring(interval).." seconds")
	_=dm and Msg("\ttime since last action: "
		.. math.floor( (time - last) * 1000 ) / 1000
		.. " seconds"
	)

	if time - last > interval then
		
		if string.sub(act, 1, 1) == "_" then act = reaper.NamedCommandLookup(act) end
		
		-- Just some error checking because Lua occasionally 
		-- throws a fit about numbers that are strings
		act = tonumber(act)
		
		_=dm and Msg("\tinterval elapsed, running action: " .. tostring(act))
		
		if not midi then
			reaper.Main_OnCommand(act, 0)
		else
			reaper.MIDIEditor_OnCommand(wnd, act)
		end
		
		last = time
	
	end     
	
	_=dm and Msg("<check_act")
	
end



local function Main()
	
	local bool,neme = reaper.GetMIDIInputName(7,"")
	
	if bool then 
	  reaper.Main_OnCommand(41175,0)
	  return 
	end
	
	_=dm and Msg(">main")
	
	--char = gfx.getchar()
	
	--if char == -1 or char == 27 then return 0 end
	
	local diff = up_time and (reaper.time_precise() - up_time) or 0

	--[[     See if any of our numerous conditions for running the script are valid
		
	- Setup mode?
	- Shortcut key down?
	- Startup mode and the timer hasn't run out?
	- Running in "just leave the window open" mode?

	]]--       
		
		-- See if we need to run the action again
		check_act()


		--gfx.update()
		reaper.defer(Main)

		_=dm and Msg("\tquitting")




	_=dm and Msg("<main")
	
end

--gfx.init("Finding MIDI Device... ", 220,45,0, 1633, 1311)

reaper.defer(Main)
--reaper.UpdateArrange()
