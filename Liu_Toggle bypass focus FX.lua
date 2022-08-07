  
  r=reaper
  
  --------------
  local function main()
  
      retval,tr_n,it_n,fx_n = reaper.GetFocusedFX2()
      
      if retval==0 then return end
      
      if it_n==-1 then
         if tr_n==0 then
            tr=reaper.GetMasterTrack(0)
         else
            tr=reaper.GetTrack(0,tr_n-1)
         end
         bypass=reaper.TrackFX_GetEnabled(tr,fx_n)
         reaper.TrackFX_SetEnabled(tr,fx_n,not bypass)
      else
         if tr_n==0 then
            tr=reaper.GetMasterTrack(0)
         else
            tr=reaper.GetTrack(0,tr_n-1)
         end
         it=reaper.GetTrackMediaItem(tr,it_n)
         tk=reaper.GetActiveTake(it)
         bypass=reaper.TakeFX_GetEnabled(tk,fx_n)
         reaper.TakeFX_SetEnabled(tk,fx_n,not bypass)
      end  
      
  end
  
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock("Toggle bypass focus FX",-1)
