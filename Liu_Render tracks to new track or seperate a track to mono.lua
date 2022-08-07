  
  r=reaper
  
  
  
  local function main()
  
      it_n=reaper.CountSelectedMediaItems(0)
      if it_n==0 then return end
      
      if it_n==1 then
         item=reaper.GetSelectedMediaItem(0,0)
         take=reaper.GetActiveTake(item)
         if not reaper.TakeIsMIDI(take) then
            fx_n=reaper.TakeFX_GetCount(take)
            if fx_n==0 then
               cmd=reaper.NamedCommandLookup("_RSa99915e06fb4fab15db4a17e7a3da19387c41f64")
               reaper.Main_OnCommand(cmd,0)
               return
            end
         else
            notes=reaper.MIDI_CountEvts(take)
            tr=reaper.GetMediaItemTrack(item)
            instrument=reaper.TrackFX_GetInstrument(tr)
            if notes==0 or instrument==-1 then return end
            midi=true
         end
      end
      
      cmd=reaper.NamedCommandLookup("_RSea76c5db6d32fba464b96715b423744be4f67b60")
      reaper.Main_OnCommand(cmd,0)
      
  end
  
  main()
