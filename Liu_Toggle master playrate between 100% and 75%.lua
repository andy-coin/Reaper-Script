  
  r=reaper
  
  local function main()
      
      rate=reaper.Master_GetPlayRate(0)
      if rate~=0.75 then
         reaper.CSurf_OnPlayRateChange(0.75)
         Act="Set master playrate to 75%"
      else
         reaper.CSurf_OnPlayRateChange(1)
         Act="Set master playrate to 100%"
      end 
  
  end
  
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock(Act,-1)
