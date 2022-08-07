
  
  r=reaper
  
  ---------------------------------------
  
  local function main()
    
      FX,tr_n,it_n,fx_n = reaper.GetFocusedFX2() 
      
      
      if FX==0 or FX>=4 then
          
          Act="Switch track input"
          if reaper.CountSelectedTracks(0)~=1 then return end

          tr=reaper.GetSelectedTrack(0,0)
          
          input=reaper.GetMediaTrackInfo_Value(tr,"I_RECINPUT")
          --mon=reaper.GetMediaTrackInfo_Value(tr,"I_RECMON")
          reaper.SetMediaTrackInfo_Value(tr,"I_RECMON",1)
          if input==0 then 
             reaper.SetMediaTrackInfo_Value(tr,"I_RECINPUT",1)
          elseif input==1 then
             reaper.SetMediaTrackInfo_Value(tr,"I_RECINPUT",1026)
          elseif input==1026 then 
             reaper.SetMediaTrackInfo_Value(tr,"I_RECINPUT",1030)
             reaper.SetMediaTrackInfo_Value(tr,"I_RECMON",0)
          elseif input==1030 then
             reaper.SetMediaTrackInfo_Value(tr,"I_RECINPUT",0)
          elseif input>=4096 then
             mode=reaper.GetMediaTrackInfo_Value(tr,"I_RECMODE")
             if mode==7 then
                reaper.SetMediaTrackInfo_Value(tr,"I_RECMODE",8)
             elseif mode==8 then
                reaper.SetMediaTrackInfo_Value(tr,"I_RECMODE",7)
             end
          else
             return
          end
      
      elseif FX == 1 then
          
          Act="Switch track FX preset"
          tr=reaper.GetTrack(0,tr_n-1)
          preset,All=reaper.TrackFX_GetPresetIndex(tr,fx_n)
          if preset+1>=All then 
             preset=-1
          end
          reaper.TrackFX_SetPresetByIndex(tr,fx_n,preset+1)
          
      elseif FX == 2 then 
          
          Act="Switch take FX preset"
          tr=reaper.GetTrack(0,tr_n-1)
          item=reaper.GetTrackMediaItem(tr,it_n)
          take=reaper.GetActiveTake(item)
          preset,All=reaper.TakeFX_GetPresetIndex(take,fx_n)
          reaper.TakeFX_GetPreset(take,fx_n)
          if preset+1>=All then 
             preset=-1
          end
          reaper.TakeFX_SetPresetByIndex(take,fx_n,preset+1)
      end  
        
  end
  
  

reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock("Trigger next preset for FX of selected tracks",-1)
 
