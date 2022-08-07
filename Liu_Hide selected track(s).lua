  
  r=reaper
  
  local function main()
  
      reaper.Undo_BeginBlock()
      
      abi=1
      tr_n=reaper.CountSelectedTracks(0)
      tr={}
      for abi=1,tr_n do
          tr[abi]=reaper.GetSelectedTrack(0,abi-1)  
          reaper.SetMediaTrackInfo_Value(tr[abi],"I_RECARM",0)
          reaper.SetMediaTrackInfo_Value(tr[abi],"B_AUTO_RECARM",0)
      end
      for abi=1,#tr do
          if reaper.GetMediaTrackInfo_Value(tr[abi],"I_FOLDERDEPTH")==1 then
             abii=0
             idx=reaper.GetMediaTrackInfo_Value(tr[abi],"IP_TRACKNUMBER")
             repeat
                 child=reaper.GetTrack(0,idx+abii)
                 reaper.SetMediaTrackInfo_Value(child,"I_RECARM",0)
                 reaper.SetMediaTrackInfo_Value(child,"B_AUTO_RECARM",0)
                 reaper.SetTrackSelected(child,true)
                 if reaper.GetMediaTrackInfo_Value(child,"I_FOLDERDEPTH")==-1 then
                    break
                 end
                 abii=abii+1
             until abii==500
          end
      end

      reaper.Main_OnCommand(41593,0)
      reaper.Main_OnCommand(40297,0)
      reaper.Undo_EndBlock("Hide selected track(s)",-1)
  
  end
  
  main()
