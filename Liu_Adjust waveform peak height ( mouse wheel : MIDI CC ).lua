  r=reaper
  
  -------------------------------------------------------------------- 
  local function main()
    
    _,_,_,_,_,_,mouse_scroll  = reaper.get_action_context()
    
    extname="abi"
    abi=reaper.GetExtState(extname,"abi",false) 
    abi=tonumber(abi)
    
    if type(abi)~="number" then
      abi = 0
    end
    
    if abi%2==0 then
      
      if mouse_scroll < 0 then
        reaper.Main_OnCommand(40156,0)--increase
      else -- mouse_scroll > 0 
        reaper.Main_OnCommand(40155,0)--decrease
      end
    
    end
    abi=abi%3+1
    reaper.SetExtState(extname,"abi",abi,false)
    reaper.UpdateArrange()
  end
  
  
  reaper.defer(main)
