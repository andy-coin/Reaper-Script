  
  r=reaper
  
  ---------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  local table={}
  local function SaveSelectedTracks (table)--trackzzz
    for i = 0, reaper.CountSelectedTracks(0)-1 do
      table[i+1] = reaper.GetSelectedTrack(0, i)
    end
  end
  
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  
  local function RestoreSelectedTracks (table)--trackzzz
    reaper.Main_OnCommand(40297,0)
    for _, track in ipairs(table) do
      reaper.SetTrackSelected(track, true)
    end
  end
  
  ---------------------------------------------------------------------------------------- 
  
  function main()
  
    SaveSelectedTracks(table)
    reaper.Main_OnCommand(40296,0)--select all tracks
    
    local tr_sel = reaper.GetSelectedTrack(0,0)
    local tcph = reaper.GetMediaTrackInfo_Value(tr_sel,"I_TCPH")
    local tcph = math.floor(tcph)
    
    _,_,_,_,_,_,mouse_scroll  = reaper.get_action_context()
    
    extname="abi"
    abi=reaper.GetExtState(extname,"abi",false) 
    abi=tonumber(abi)
    
    if type(abi)~="number" then
      abi = 0
    end
    
    if abi%3==0 then
      
      if mouse_scroll < 0 then
        reaper.Main_OnCommand(41327,0)--increase
      else -- mouse_scroll > 0 
        reaper.Main_OnCommand(41328,0)--decrease
      end
    
    end
    abi=abi%3+1
    reaper.SetExtState(extname,"abi",abi,false)
    RestoreSelectedTracks(table)
    reaper.UpdateArrange()
  end
  
  
  reaper.defer(main)
  
  
  
  


  
  
  
  
