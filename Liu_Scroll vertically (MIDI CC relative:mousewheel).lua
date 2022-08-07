  
  r=reaper
  
  local function main()
  
      _,_,_,_,_,_,mouse_wheel  = reaper.get_action_context() 
      
      
      editor=reaper.GetExtState("editor_toggle","editor_toggle",false)
      
      midi=reaper.GetExtState("MIDI_OPEN","MIDI_OPEN",false)
      
      if editor~="0" and midi=="0" then return end
      
      times=math.floor(mouse_wheel/6)
      reaper.CSurf_OnScroll(0,-times)

  end
  
  reaper.defer(main)
