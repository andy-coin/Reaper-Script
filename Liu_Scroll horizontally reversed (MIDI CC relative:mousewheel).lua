  
  r=reaper
  
  local function main()
  
      _,_,_,_,_,_,mouse_wheel  = reaper.get_action_context() 
      
      times=math.abs(math.floor(mouse_wheel/8))
      
      if mouse_wheel>0 then
         for abi=1,times do
             reaper.CSurf_OnScroll(-1,0)
         end
      else
         for abi=1,times do
             reaper.CSurf_OnScroll(1,0)
         end
      end
      
  end
  
  reaper.defer(main)
