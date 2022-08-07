  
  r=reaper
  
  local function main()
      
      track=reaper.GetSelectedTrack(0,0) 
      if not track then
         track=reaper.GetTrack(0,reaper.CountTracks(0)-1)
         if not track then
            cmd=reaper.NamedCommandLookup("_S&M_ADD_TRTEMPLATE3")
            reaper.Main_OnCommand(cmd,0)
            return
         end
      end
      
      depth=reaper.GetMediaTrackInfo_Value(track,"I_FOLDERDEPTH")
      compact=reaper.GetMediaTrackInfo_Value(track,"I_FOLDERCOMPACT")
      parent=reaper.GetParentTrack(track)
      
      if parent or depth==1 then
         if compact==2 then
            idx=reaper.GetMediaTrackInfo_Value(track,"IP_TRACKNUMBER")
            abi=0
            repeat
                track=reaper.GetTrack(0,idx+abi)
                depth=reaper.GetMediaTrackInfo_Value(track,"I_FOLDERDEPTH")
                abi=abi+1
            until depth==-1 or abi>500
            reaper.SetOnlyTrackSelected(track)
         elseif compact==1 then
            mini=true
         end
      end 
      
      cmd=reaper.NamedCommandLookup("_S&M_ADD_TRTEMPLATE3")
      reaper.Main_OnCommand(cmd,0)
      
      audio=reaper.GetSelectedTrack(0,0)
      
      if mini then
         cmd=reaper.NamedCommandLookup("_SWS_MINTRACKS")
         reaper.Main_OnCommand(cmd,0)
         return
      end
      
      
      first=reaper.GetTrack(0,0)
      tcph=reaper.GetMediaTrackInfo_Value(audio,"I_TCPH")
      if parent then
         TCPH=reaper.GetMediaTrackInfo_Value(parent,"I_TCPH")
      else
         TCPH=reaper.GetMediaTrackInfo_Value(first,"I_TCPH")
      end
      
      times=(TCPH-tcph)/2
      
      if times>0 then
         for abi=1,times do
             reaper.Main_OnCommand(41327,0)
         end
      
      elseif times<0 then
          for abi=1,-times do
              reaper.Main_OnCommand(41328,0)
          end
      end
  
  end
  
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock("Create new audio track",-1)
