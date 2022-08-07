
  r=reaper
  
  ----------
  
  function runloop()
    local newtime=os.time()
    
    if (loopcount < 1) then
      if newtime-lasttime >= wait_time_in_seconds then
     lasttime=newtime
     loopcount = loopcount+1
      end
    else
      ----------------------------------------------------
      -- PUT ACTION(S) YOU WANT TO RUN AFTER WAITING HERE
      
      reaper.TrackCtl_SetToolTip("", x, y, true )
      
      ----------------------------------------------------
      loopcount = loopcount+1
    end
    if 
      (loopcount < 2) then reaper.defer(runloop) 
    end
  end
  
  ----------
  
  function DisplayTooltip(message)
    wait_time_in_seconds = 3
    lasttime=os.time()
    loopcount=0
    
    x, y = reaper.GetMousePosition()
    reaper.TrackCtl_SetToolTip( message, x, y, false )
    
    runloop()
  end
  
  ----------
  
  function main()
    
    reaper.Main_OnCommand(40026,0)--Save
    DisplayTooltip("Preject Saved >_< ")
  
  end
  
  reaper.defer(main)
