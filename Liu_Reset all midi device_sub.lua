
  r=reaper
  
  --------------
  local function main()
    
    local bool,name = reaper.GetMIDIInputName(7,"") 
    
    if not bool then
      reaper.Main_OnCommand(41175,0)
    end 
    
  end
  
  reaper.defer(main)
