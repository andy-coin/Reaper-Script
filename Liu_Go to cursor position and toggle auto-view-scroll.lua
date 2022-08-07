
  r=reaper
  
  --------------
  local function GetWindow(name)
      local title = reaper.JS_Localize(name, "common")
      local arr = reaper.new_array({}, 1024)
      reaper.JS_Window_ArrayFind(title, true, arr)
      local adr = arr.table()
      for j = 1, #adr do
          local hwnd = reaper.JS_Window_HandleFromAddress(adr[j])
          -- verify window by checking if it also has a specific child.
          --if reaper.JS_Window_FindChildByID(hwnd, 1045) then -- 1045:ID of volume control in media explorer.
            return hwnd
          --end 
      end
  end
  
  --------------
  local function main()
      
      hwnd = GetWindow("Video Window")
      focus=reaper.JS_Window_GetFocus()
      
      if hwnd and focus==hwnd then
         --tval, val = reaper.BR_Win32_GetPrivateProfileString( "reaper_video", "fullscreen", "",  reaper.get_ini_file() )
         reaper.JS_WindowMessage_Send(hwnd, "WM_LBUTTONDBLCLK", 1,1,0,0)
         return
      end
      
      play=reaper.GetPlayState()
      p=reaper.GetPlayPosition()
      Start,End=reaper.GetSet_ArrangeView2(0,false,0,0,0,0)
      
      if p>Start and p<End then In=true end
      
      if play==1 or play==5 then
         if In then
            reaper.Main_OnCommand(40036,0)
         else
            if reaper.GetToggleCommandState(40036)==1 then
               reaper.Main_OnCommand(40036,0)
            end
         end
      else
         if reaper.GetToggleCommandState(40036)==1 then
            reaper.Main_OnCommand(40036,0)
         end
      end
      
      reaper.Main_OnCommand(40150,0)
  end
  
  reaper.defer(main)
