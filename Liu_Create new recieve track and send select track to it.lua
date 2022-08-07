
  r=reaper
  
  local last_sel = reaper.GetSelectedTrack(0, reaper.CountSelectedTracks(0)-1)
  if not last_sel then return end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh( 1 )
  
  
  --local idx = reaper.GetMediaTrackInfo_Value(, "IP_TRACKNUMBER")
  reaper.InsertTrackAtIndex(reaper.CountTracks(0), true)
  local bus = reaper.GetTrack(0,reaper.CountTracks(0)-1)
  reaper.GetSetMediaTrackInfo_String( bus, "P_NAME", "Return", true )
  reaper.SetMediaTrackInfo_Value( bus, "I_CUSTOMCOLOR", 30759958)
  
  -- Loop through all tracks in the project
  for i = 0, reaper.CountSelectedTracks(0) - 1 do

      local tr = reaper.GetSelectedTrack(0, i)
      local send = reaper.CreateTrackSend(tr, bus)
      
      -- Make sure send is at unity, post-fader (overriding default send values)
      reaper.SetTrackSendInfo_Value(tr, 0, send, "D_VOL", 0)
      reaper.SetTrackSendInfo_Value(tr, 0, send, "I_SENDMODE", 0)    
  
  end
  
  
  reaper.PreventUIRefresh( -1 )
  
  reaper.TrackList_AdjustWindows( false )
  reaper.UpdateArrange()
  
  reaper.Undo_EndBlock("Create bus after selected tracks and reroute them", 0)
