
  r=reaper
  
  -----
  local function IncreaseTrackHeight(x)
      
      for abi=1,reaper.CountTracks(0) do
          tr=reaper.GetTrack(0,abi-1)
          _,chunk=reaper.GetTrackStateChunk(tr,"",false)
          --x=reaper.GetMediaTrackInfo_Value(tr,"I_TCPH")
          --x=reaper.GetMediaTrackInfo_Value(tr,"I_HEIGHTOVERRIDE") 
          reaper.SetMediaTrackInfo_Value(tr,"I_HEIGHTOVERRIDE",x+2) 
          reaper.SetMediaTrackInfo_Value(tr,"B_HEIGHTLOCK",1)
          Chunk=string.gsub(chunk,chunk:match("TRACKHEIGHT ".."%d+"),"TRACKHEIGHT "..tostring(math.floor(x+2)))
          --reaper.SetTrackStateChunk(tr,Chunk,false)
          reaper.UpdateArrange()
      end
      --reaper.ShowConsoleMsg(chunk.."\n"..Chunk)
  end
  
  -----
  local function DecreaseTrackHeight(x)
      
      for abi=1,reaper.CountTracks(0) do
          tr=reaper.GetTrack(0,abi-1)
          _,chunk=reaper.GetTrackStateChunk(tr,"",false)
          --x=reaper.GetMediaTrackInfo_Value(tr,"I_TCPH")
          --x=reaper.GetMediaTrackInfo_Value(tr,"I_HEIGHTOVERRIDE") 
          if x<=24 then return end
          reaper.SetMediaTrackInfo_Value(tr,"I_HEIGHTOVERRIDE",x-2) 
          reaper.SetMediaTrackInfo_Value(tr,"B_HEIGHTLOCK",1)
          Chunk=string.gsub(chunk,chunk:match("TRACKHEIGHT ".."%d+"),"TRACKHEIGHT "..tostring(math.floor(x-2)))
          --reaper.SetTrackStateChunk(tr,Chunk,false)
          reaper.UpdateArrange()
      
      end
      
  end
  
  local function SelAllTrinScreen()
      
      reaper.Main_OnCommand(40297,0)
      
      trz={}
      for abi=1,reaper.CountTracks(0) do
          trz[abi]=reaper.GetTrack(0,abi-1)
          local _,state=reaper.GetTrackState(trz[abi])
          parent=reaper.GetParentTrack(trz[abi])
          if parent and reaper.GetMediaTrackInfo_Value(parent,"I_FOLDERCOMPACT")~=2 then
             reaper.SetTrackSelected(trz[abi],true)
          elseif state<512 then
             reaper.SetTrackSelected(trz[abi],true)
          elseif state>=1024 and state<1536 then
             reaper.SetTrackSelected(trz[abi],true)
          end
      end

  end
  
  -------------------------------------------------------------------- 
  local function main()
    
      tr={}
      for abi=1,reaper.CountSelectedTracks(0) do
          tr[abi]=reaper.GetSelectedTrack(0,abi-1)
      end
    
      SelAllTrinScreen()
    
      local tr_fir = reaper.GetTrack(0,0)
      local tr_sel = reaper.GetSelectedTrack(0,0)
      if not tr_sel then 
         tr_sel = tr_fir 
         bool=true 
      else 
         bool=false
      end
      tcph = reaper.GetMediaTrackInfo_Value(tr_sel,"I_TCPH")
      --tcph=reaper.GetMediaTrackInfo_Value(tr_sel,"I_HEIGHTOVERRIDE") 
      tcph = math.floor(tcph)
  
    _,_,_,_,_,_,mouse_scroll  = reaper.get_action_context() 
    
    if tcph < 36 then 
      times = 2
    elseif tcph > 151 then
      times = 8
    else 
      times = 4
    end
    
    if mouse_scroll < 0 then
        --IncreaseTrackHeight(tcph)
        reaper.Main_OnCommand(41327,0)
    else
        --DecreaseTrackHeight(tcph)
        reaper.Main_OnCommand(41328,0)
    end 
    reaper.Main_OnCommand(40297,0)
    for abi=1,#tr do
        reaper.SetTrackSelected(tr[abi],true)
    end
    reaper.Main_OnCommand(40913,0)
    for abi=1,30 do
        reaper.CSurf_OnScroll( 0, 1 )
    end
    reaper.UpdateArrange()
    --reaper.SetTrackSelected(tr_sel,bool)
    --reaper.SetTrackSelected(tr_sel,not bool)
    
  end
  
  window,_,_=reaper.BR_GetMouseCursorContext()
  if window ~= "midi_editor" then
     reaper.defer(main)
  end
  
