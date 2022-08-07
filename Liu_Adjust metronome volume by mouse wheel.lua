  
  r=reaper
  
  local function main()
      
      
      _,_,_,_,_,_,mouse_scroll  = reaper.get_action_context()
      
      --[[extname="abi"
      abi=reaper.GetExtState(extname,"abi",false) 
      abi=tonumber(abi)
      
      if type(abi)~="number" then
        abi = 0
      end--]]
      
      --if abi%3==0 then
      
         if mouse_scroll > 0 then
           cmd=reaper.NamedCommandLookup("_S&M_METRO_VOL_UP")
         else -- mouse_scroll > 0 
           cmd=reaper.NamedCommandLookup("_S&M_METRO_VOL_DOWN")
         end
         
      --end
      
      --abi=abi%3+1
      --reaper.SetExtState(extname,"abi",abi,false)
      
      reaper.Main_OnCommand(cmd,0)
      reaper.Main_OnCommand(cmd,0)
  
  end
  
  reaper.defer(main)
