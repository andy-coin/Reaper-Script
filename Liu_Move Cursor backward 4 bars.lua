  
  r=reaper
  
  local function main()
  
    local P = reaper.GetPlayState()
    local B = reaper.GetCursorPosition()
    
    if P == 1 then
      
      local A = reaper.GetPlayPosition()
      reaper.SetEditCurPos(A,false,false)
      for abi = 1 ,4 do
      reaper.Main_OnCommand(41041,0)
      end
      
    else
      
      for abi = 1 ,4 do
      reaper.Main_OnCommand(41041,0)
      end
      
    
    end
  
  end
  
  reaper.defer(main)
  
