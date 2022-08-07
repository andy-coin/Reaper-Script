  
  r=reaper
  
  local function main()
  
      Item=reaper.GetToggleCommandState(40253)
      Time=reaper.GetToggleCommandState(40076)
      
      if Item==0 and Time==0 then
         reaper.Main_OnCommand(40076,0)
      elseif Item==0 and Time==1 then      
         reaper.Main_OnCommand(40253,0)
      elseif Time==0 and Item==1 then
         reaper.Main_OnCommand(40252,0)
      end
      
  end
  
  main()
