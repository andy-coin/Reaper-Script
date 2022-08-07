  
  r=reaper
  
  local function main()
  
      master=reaper.GetMasterTrack(0)
      
      tuner=0x1000000
      
      if reaper.TrackFX_GetOpen(master,tuner) then
         reaper.TrackFX_Show(master,tuner,2)
      else
         reaper.TrackFX_Show(master,tuner,3)
      end
      
      
  end
  
  reaper.defer(main)
