  
  r=reaper
  
  local function main()
      
      if reaper.CountSelectedTracks(0)~=1 then return end
      
      tr=reaper.GetSelectedTrack(0,0)
      mode=reaper.GetMediaTrackInfo_Value(tr,"I_RECMODE") 
      
      if mode~=7 and mode~=8 then return end
      
      local FX=reaper.TrackFX_AddByName(tr,"midi_transpose",false,0)
      
      if FX~=0 then
         reaper.TrackFX_AddByName(tr,"midi_transpose",false,-1000)
         reaper.TrackFX_SetPresetByIndex(tr,0,4)
      end
      
      local octave=reaper.TrackFX_GetPresetIndex(tr,0)
      
      if octave~=0 then
         reaper.TrackFX_SetPresetByIndex(tr,0,octave-1)
      end
  end
  
  main()
  reaper.defer(function() end)
