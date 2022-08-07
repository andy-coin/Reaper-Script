
  r=reaper
  
  ---------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  abizzz = {}
  local function SaveSelectedTracks (table)--trackzzz
    for i = 0, reaper.CountSelectedTracks(0)-1 do
      table[i+1] = reaper.GetSelectedTrack(0, i)
    end
  end
  
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  local function RestoreSelectedTracks (table)--trackzzz
    reaper.Main_OnCommand(40297,0)
    for _, track in ipairs(table) do
      reaper.SetTrackSelected(track, true)
    end
  end
  
  -----
  local function main()
  
    SaveSelectedTracks(abizzz)
    
    cmd=reaper.NamedCommandLookup("_SWS_SELTRKWITEM")
    reaper.Main_OnCommand(cmd,0)
    reaper.Main_OnCommand(40421,0)--select all items
    reaper.Main_OnCommand(40318,0)--move left
    cmd=reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX")
    reaper.Main_OnCommand(cmd,0)
    
    RestoreSelectedTracks(abizzz)
    
  end
  
  reaper.defer(main)
