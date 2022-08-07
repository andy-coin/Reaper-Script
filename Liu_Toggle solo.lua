  
  r=reaper
  
    local function SaveSelectedTracks (table)
      for i = 0, reaper.CountSelectedTracks(0)-1 do
        table[i+1] = reaper.GetSelectedTrack(0, i)
      end
    end
    
  -----
    
    local function RestoreSelectedTracks (table)
      reaper.Main_OnCommand(40297,0)
      for _, track in ipairs(table) do
        reaper.SetTrackSelected(track, true)
      end
    end
    
  -----
    
    itemzzz = {}
    local function SaveSelectedItems (table)--itemzzz
      for i = 0, reaper.CountSelectedMediaItems(0)-1 do
        table[i+1] = reaper.GetSelectedMediaItem(0, i)
      end
    end
    
  -----
    
    local function RestoreSelectedItems (table)--itemzzz
      reaper.Main_OnCommand(40289, 0)
      for _, item in ipairs(table) do
        reaper.SetMediaItemSelected(item, true)
      end
    end
    
  -----
  
  function main()
  
    trackzzz = {}
    itemzzz = {}
    SaveSelectedTracks (trackzzz)
    SaveSelectedItems (itemzzz)
    
      if reaper.AnyTrackSolo(0)== true then -- any solo tracks
      
        cmd=reaper.NamedCommandLookup("_BR_SAVE_SOLO_MUTE_ALL_TRACKS_SLOT_1")
        reaper.Main_OnCommand(cmd,0)--save solo and mute states slot 1
        reaper.Main_OnCommand(40340, 0)-- unsolo all tracks
        reaper.SetToggleCommandState( 0, 65735, 0)
      else
        
        cmd=reaper.NamedCommandLookup("_BR_RESTORE_SOLO_MUTE_ALL_TRACKS_SLOT_1")
        reaper.Main_OnCommand(cmd,0)--restore solo and mute states slot 1
      
      end
     
    RestoreSelectedTracks(trackzzz)
    RestoreSelectedItems (itemzzz)
    
  end
    
  -----
  
  reaper.defer(main)
  
  
  
  
  
  
  
  
  
  
  
  
  
  
