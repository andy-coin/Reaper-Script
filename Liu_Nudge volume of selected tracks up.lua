  
  r=reaper
  
  --------------
  local function SelTrFilter()
      
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
  
      SelTrFilter()
      cmd=reaper.NamedCommandLookup("_XENAKIOS_NUDGSELTKVOLUP")
      reaper.Main_OnCommand(cmd,0)
      
      for abi=1,reaper.CountSelectedTracks(0) do
          tr=reaper.GetSelectedTrack(0,abi-1)
          VOL=reaper.GetMediaTrackInfo_Value(tr,"D_VOL")
          if VOL>3.981071705535 then
             reaper.SetMediaTrackInfo_Value(tr,"D_VOL",3.981071705535)
          end
      end
  
  end
  
  reaper.defer(main)
