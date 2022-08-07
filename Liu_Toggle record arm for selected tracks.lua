
  r=reaper
  
  --------------
  local function ChangeBufferSize()
  
      for abi=1,reaper.CountTracks(0) do
          local tr=reaper.GetTrack(0,abi-1)
          if reaper.GetMediaTrackInfo_Value(tr,"I_RECARM")==1 then
             cmd=reaper.NamedCommandLookup("_RSbcc69ced35229feaa2b5a1b73638e06b5e19d723")--set buffer size to 64
             reaper.Main_OnCommand(cmd,0)
             return
          end
      end
      
      cmd=reaper.NamedCommandLookup("_RS84cd6d5120685c9c5bad735b576b605ba0dafafd")--set buffer size to 1024
      reaper.Main_OnCommand(cmd,0)
  end
  
  --------------
  local function SelTrzFilter()
      
      trz={}
      for abi=1,reaper.CountSelectedTracks(0) do
          trz[abi]=reaper.GetSelectedTrack(0,abi-1)
      end
      for abi=1,#trz do
          local _,state=reaper.GetTrackState(trz[abi])
          parent=reaper.GetParentTrack(trz[abi])
          if parent and reaper.GetMediaTrackInfo_Value(parent,"I_FOLDERCOMPACT")==2 then
             reaper.SetTrackSelected(trz[abi],false)
          elseif state>=512 and state<1024 then
             reaper.SetTrackSelected(trz[abi],false)
          elseif state>=1536 then
             reaper.SetTrackSelected(trz[abi],false)
          end
      end
  end
  
  --------------
  local function main()
      
      SelTrzFilter()
      local arm=0
      for abi=1,reaper.CountSelectedTracks(0) do
          tr=reaper.GetSelectedTrack(0,abi-1)
          Rec=reaper.GetMediaTrackInfo_Value(tr,"I_RECARM")
          if Rec==0 then
             arm=1
             break
          end
      end
  
      for abi=1,reaper.CountSelectedTracks(0) do
          
          local tr=reaper.GetSelectedTrack(0,abi-1)
          if reaper.GetMediaTrackInfo_Value(tr,"B_AUTO_RECARM")==0 then
             reaper.SetMediaTrackInfo_Value(tr,"I_RECARM",arm)
             input=reaper.GetMediaTrackInfo_Value(tr,"I_RECINPUT")
             if input ~= 1030 then
                reaper.SetMediaTrackInfo_Value(tr,"I_RECMON",arm)
             end
          else
             reaper.SetMediaTrackInfo_Value(tr,"B_AUTO_RECARM",0)
             input=reaper.GetMediaTrackInfo_Value(tr,"I_RECINPUT")
             if input ~= 1030 then
                reaper.SetMediaTrackInfo_Value(tr,"I_RECMON",1)
             end
          end
          
      end
      play=reaper.GetPlayState()
      if play==0 then
         ChangeBufferSize()
      end
  end
  
  main()
