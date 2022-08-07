  
  r=reaper
  
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
  local function Hide(tr)
      
      hide=false
      local _,state=reaper.GetTrackState(tr)
      parent=reaper.GetParentTrack(tr)
      if parent and reaper.GetMediaTrackInfo_Value(parent,"I_FOLDERCOMPACT")==2 then
         hide=true
      elseif state>=512 and state<1024 then
         hide=true
      elseif state>=1536 then
         hide=true
      end
      return hide
  
  end
  
  --------------
  local function SelItemFilter()
  
      itemz={}
      for abi=1,reaper.CountSelectedMediaItems(0) do
          itemz[abi]=reaper.GetSelectedMediaItem(0,abi-1)
      end
      
      abi=1
      for abi=1,#itemz do
          tr=reaper.GetMediaItemTrack(itemz[abi])
          if Hide(tr) then
             reaper.SetMediaItemSelected(itemz[abi],false)
          end
      end
      
  end
  
  
  --------------
  local function main()
      
      SelTrzFilter()
      SelItemFilter()
      reaper.SetExtState("Copy state","Copy state",4,false)
      reaper.Main_OnCommand(40059,0)
      
  end
  
  reaper.defer(main)
