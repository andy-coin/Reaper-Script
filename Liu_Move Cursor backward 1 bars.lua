  
  r=reaper
  
  local function main()
  
    local P = reaper.GetPlayState()
    local B = reaper.GetCursorPosition()
    
    if P == 1 then
      
      local A = reaper.GetPlayPosition()
      reaper.SetEditCurPos(A-1,false,false)
      reaper.Main_OnCommand(41041,0)
      
    else
      
      reaper.Main_OnCommand(41041,0)
       
    end
  
  end
  
  reaper.defer(main)
  
