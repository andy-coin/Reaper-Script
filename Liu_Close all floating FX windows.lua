  
  r=reaper
  
  local function FindWindow(window_titles, child_id, child_must_visible)
    local arr = reaper.new_array({}, 128)
    for i = 1, #window_titles do
      local title = reaper.JS_Localize(window_titles[i], 'common')
      reaper.JS_Window_ArrayFind(title, true, arr)
      local handles = arr.table()
      for j = 1, #handles do
        local hwnd = reaper.JS_Window_HandleFromAddress(handles[j]) -- window handle
        local child_hwnd =  reaper.JS_Window_FindChildByID(hwnd, child_id) -- child handle
        if child_hwnd then -- child control found
          if child_must_visible and not reaper.JS_Window_IsVisible(child_hwnd) then -- child must be visible
            return nil
          else
            return hwnd
          end
        end
      end
    end
  end
  
  local function CloseMonFX()
    local t = {'FX: Monitoring','FX: Monitoring [BYPASSED]'} -- titlebar text(s) to find
    local hwnd = FindWindow(t, 1076, true) -- 1076 = child id to find, true = child must be visible, i.e., docked but tab not selected.
    if hwnd then-- close fx monitor window
       reaper.JS_Window_Destroy(hwnd) -- Tested Win7 & MacOS 10.12.
    end
    local master=reaper.GetMasterTrack(0)
    local tuner=0x1000000
    if reaper.TrackFX_GetOpen(master,tuner) then
       reaper.TrackFX_Show(master,tuner,2)
    end
  end
 
  local function main()
      
      FX,tr_n,it_n,fx_n = reaper.GetFocusedFX2() 
      
      if FX~=0 then
         cmd=reaper.NamedCommandLookup("_S&M_WNCLS3")
         reaper.Main_OnCommand(cmd,0)
         cmd=reaper.NamedCommandLookup("_S&M_WNCLS4")
         reaper.Main_OnCommand(cmd,0)
         CloseMonFX()
      else
         reaper.Main_OnCommand(40151,0)
         return
      end
    
  end
  
  main()
  
  reaper.defer(function() end)
  
  
  
