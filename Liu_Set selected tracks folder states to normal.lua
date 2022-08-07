
  r=reaper
  
  local trackzzz={}
  local function SaveSelectedTracks (table)--trackzzz
      for i = 0, reaper.CountSelectedTracks(0)-1 do
        table[i+1] = reaper.GetSelectedTrack(0, i)
      end
  end
  
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  local function RestoreSelectedTracks (table)--trackzzz
      reaper.Main_OnCommand(40297,0)
      if #table==0 then return end
      reaper.SetOnlyTrackSelected(table[#table])
      for _, track in ipairs(table) do
        reaper.SetTrackSelected(track, true)
      end
  end
  
  --------------
  local function FollowParentTCPH(track)
    
    cmd=reaper.NamedCommandLookup("_SWS_MINTRACKS")
    reaper.Main_OnCommand(cmd,0)--minimize
    TCPH=reaper.GetMediaTrackInfo_Value(track,"I_TCPH")
    for abi=1,(TCPH-22)/2 do
        reaper.Main_OnCommand(41327,0)
    end
    
  end
  
  --------------
  local function main()
      
      SaveSelectedTracks(trackzzz)
      
      trz={}
      for abi=1,reaper.CountSelectedTracks() do
          tr=reaper.GetSelectedTrack(0,abi-1) 
          if reaper.GetMediaTrackInfo_Value(tr,"I_FOLDERDEPTH")==1 then
             trz[#trz+1]=tr
          end
      end
      
      for abi=1,#trz do
          reaper.SetOnlyTrackSelected(trz[abi])
          if reaper.GetMediaTrackInfo_Value(trz[abi],"I_FOLDERCOMPACT")~=0 then
             reaper.SetMediaTrackInfo_Value(trz[abi],"I_FOLDERCOMPACT",0)
             cmd = reaper.NamedCommandLookup("_SWS_SELCHILDREN")
             reaper.Main_OnCommand(cmd,0)--select only children track
             TCPH=reaper.GetMediaTrackInfo_Value(trz[abi],"I_TCPH")
             FollowParentTCPH(trz[abi])
          end
      end
      
      RestoreSelectedTracks(trackzzz)
      
      cmd=reaper.NamedCommandLookup("_S&M_FOLDEROFF")
      reaper.Main_OnCommand(cmd,0)
      
      
  end
  
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock("Set selected tracks folder states to normal",-1)
