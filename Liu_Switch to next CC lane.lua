
  r=reaper
  
  -- Misc functions ------------------------------------------------------------------------------------------------------
  local function GetVisibleCCLanes (take)
      local visibleLanes = {}
      if take ~= nil then
          local takeGuid = "GUID " .. reaper.BR_GetMediaItemTakeGUID(take)
          local _, chunk = reaper.GetItemStateChunk(reaper.GetMediaItemTake_Item(take), "", false)
          local takeGuidLineFound = 0
          for line in chunk:gmatch("([^\n]*)\n?") do
  
              -- MIDI take chunk starts with GUID - mark when found
              if line == takeGuid then
                  takeGuidLineFound = 1
              else
                  if     takeGuidLineFound == 1 and line == "<SOURCE MIDI"      then takeGuidLineFound = 2
                  elseif takeGuidLineFound >= 2 and line.sub(line, 1, 1) == "<" then takeGuidLineFound = takeGuidLineFound + 1
                  elseif takeGuidLineFound >  2 and line == ">"                 then takeGuidLineFound = takeGuidLineFound - 1
                  elseif takeGuidLineFound == 2 and line == ">"                 then takeGuidLineFound = 0
                  end
  
                  -- We're inside MIDI take chunk, search for CC lanes data
                  if takeGuidLineFound == 2 then
                      local lineTokens = {}
                      for token in line:gmatch("[^%s]+") do
                          lineTokens[#lineTokens + 1] = token
                      end
                      -- CC lane found, save it
                      if #lineTokens > 0 and lineTokens[1] == "VELLANE" then
                          local newLane = {lane = tonumber(lineTokens[2]), height = tonumber(lineTokens[3])}
                          local saveLane = true
                          for _, lane in ipairs(visibleLanes) do if lane.lane == newLane.lane then saveLane = false break end end
                          if saveLane == true then
                              visibleLanes[#visibleLanes + 1] = newLane
                          end
                      end
                  end
              end
          end
      end
      return visibleLanes
  end
  
  -- Main ----------------------------------------------------------------------------------------------------------------
  function Main ()
    local midiEditor = reaper.MIDIEditor_GetActive()
    if midiEditor ~= nil then
        local take = reaper.MIDIEditor_GetTake(midiEditor)
        if take ~= nil then
            local visibleLanes = GetVisibleCCLanes(take)
  
            if #visibleLanes == 1 and visibleLanes[1].height <= 9 then
              cmd=reaper.NamedCommandLookup("_FNG_ME_TOP_CC_LANE")
              reaper.MIDIEditor_LastFocused_OnCommand(cmd, false)--Show only Top CC lane
              cmd=reaper.NamedCommandLookup("_BR_ME_SET_CC_LANES_HEIGHT_100")
              reaper.MIDIEditor_LastFocused_OnCommand(cmd, false)--Set all CC lanes' height to 100 pixel
              cmd=reaper.NamedCommandLookup("_BR_ME_INC_CC_LANES_HEIGHT_100")
              reaper.MIDIEditor_LastFocused_OnCommand(cmd, false)--Increase all CC lanes' height by 100 pixel
              cmd=reaper.NamedCommandLookup("_BR_ME_INC_CC_LANES_HEIGHT_100")
              reaper.MIDIEditor_LastFocused_OnCommand(cmd, false)--Increase all CC lanes' height by 100 pixel
            else
              cmd=reaper.NamedCommandLookup("_FNG_ME_SHOW_USED_CC_LANES")
              reaper.MIDIEditor_LastFocused_OnCommand(cmd, false)--Show only used CC lanes
              cmd=reaper.NamedCommandLookup("_FNG_ME_CYCLE_CC_LANE")
              reaper.MIDIEditor_LastFocused_OnCommand(cmd, false)--Cycle through CC lanes
              cmd=reaper.NamedCommandLookup("_FNG_ME_TOP_CC_LANE")
              reaper.MIDIEditor_LastFocused_OnCommand(cmd, false)--Show only top CC lane
              cmd=reaper.NamedCommandLookup("_BR_ME_SET_CC_LANES_HEIGHT_100")
              reaper.MIDIEditor_LastFocused_OnCommand(cmd, false)--Set all CC lanes' height to 100 pixel
              cmd=reaper.NamedCommandLookup("_BR_ME_INC_CC_LANES_HEIGHT_100")
              reaper.MIDIEditor_LastFocused_OnCommand(cmd, false)--Increase all CC lanes' height by 100 pixel
              cmd=reaper.NamedCommandLookup("_BR_ME_INC_CC_LANES_HEIGHT_100")
              reaper.MIDIEditor_LastFocused_OnCommand(cmd, false)--Increase all CC lanes' height by 100 pixel
            end
        end
    end
  end
  
  reaper.defer(Main)
