
  r=reaper
  
  local function main()
      
      if 1==reaper.GetToggleCommandState(42456) then
         reaper.Main_OnCommand(42457,0)
      elseif 1==reaper.GetToggleCommandState(42457) then
         reaper.Main_OnCommand(42458,0)
      elseif 1==reaper.GetToggleCommandState(42458) then
         reaper.Main_OnCommand(42456,0)
      end
  end
  
  reaper.defer(main)
