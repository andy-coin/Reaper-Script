  
  r=reaper
  
  --------------
  local function GetWindowPosition(hwnd)
      local _, l, t, r, b = reaper.JS_Window_GetRect(hwnd)
      return l, t, r, b
  end
  
  --------------
  local function SetWindowPosition(hwnd, l, t, r, b)
      reaper.JS_Window_SetPosition(hwnd, l, t, r - l, math.abs(b - t))
  end
  
  --------------
  local function GetOpenProjects()
      local projects = {}
      local p = 0
      repeat
          local proj = reaper.EnumProjects(p)
          if reaper.ValidatePtr(proj, 'ReaProject*') then
              projects[#projects + 1] = proj
          end
          p = p + 1
      until not proj
      return projects
  end

  --------------
  local function GetAllFloatingFXWindows()
      local hwnds = {}
      local projects = GetOpenProjects()
  
      --for _, proj in ipairs(projects) do
      local master_track = reaper.GetMasterTrack(0)
      for fx = 0, reaper.TrackFX_GetCount(master_track) - 1 do
          local hwnd = reaper.TrackFX_GetFloatingWindow(master_track, fx)
          if hwnd then hwnds[#hwnds + 1] = hwnd end
      end
      for t = 0, reaper.CountTracks(proj) - 1 do
          local track = reaper.GetTrack(proj, t)
          for fx = 0, reaper.TrackFX_GetCount(track) - 1 do
              local hwnd = reaper.TrackFX_GetFloatingWindow(track, fx)
              if hwnd then hwnds[#hwnds + 1] = hwnd end
          end
          for fx = 0, reaper.TrackFX_GetRecCount(track) - 1 do
              local fx_in = fx + 0x1000000
              local hwnd = reaper.TrackFX_GetFloatingWindow(track, fx_in)
              if hwnd then hwnds[#hwnds + 1] = hwnd end
          end
      
          for i = 0, reaper.CountTrackMediaItems(track) - 1 do
              local item = reaper.GetTrackMediaItem(track, i)
              for tk = 0, reaper.GetMediaItemNumTakes(item) - 1 do
                  local take = reaper.GetMediaItemTake(item, tk)
                  if reaper.ValidatePtr(take, 'MediaItem_Take*') then
                      for fx = 0, reaper.TakeFX_GetCount(take) - 1 do
                          local hwnd = reaper.TakeFX_GetFloatingWindow(take, fx)
                          if hwnd then
                              hwnds[#hwnds + 1] = hwnd
                          end
                      end
                  end
              end
          end
      end
      --end
      return hwnds,#projects
  end
  
  --------------
  local function main()
      
      --my screen is 1415*2560
      
      --best left is 466/101
      --best top is 1318/1415
      --best right is 2436/2560
      --best bottom is 766/621
      --width_zone is 1970/2459
      --height zone is 
      
      HWND,X=GetAllFloatingFXWindows()
      
      if #HWND == 0 then return end
      
      extname="MIDI_OPEN"
      midi=reaper.GetExtState(extname,"MIDI_OPEN",false)
      MIDI = reaper.MIDIEditor_GetActive()
      
      left={}
      right={}
      top={}
      bottom={}
      width={}
      height={}
      POINT={}
      LAND={}
      size={}
      W=0
      if X>1 then
         X=15
      else
         x=0
      end
      
      for abi=1,#HWND do
          left[abi],top[abi],right[abi],bottom[abi]=GetWindowPosition(HWND[abi])
          --reaper.ShowConsoleMsg(left[abi].."|"..top[abi].."|"..right[abi].."|"..bottom[abi].."\n")
          width[abi]=right[abi]-left[abi]
          height[abi]=top[abi]-bottom[abi]
          size[abi]=width[abi]*height[abi]
          W=W+width[abi]
      end
      
      abigel=#HWND
      repeat
          max=0
          for abi=1,abigel do
              if max<size[abi] then
                 max=size[abi]
                 key=abi
              end
          end
          table.insert(HWND,HWND[key])
          table.remove(HWND,key)
          table.insert(left,left[key])
          table.remove(left,key)
          table.insert(right,right[key])
          table.remove(right,key)
          table.insert(top,top[key])
          table.remove(top,key)
          table.insert(bottom,bottom[key])
          table.remove(bottom,key)
          table.insert(width,width[key])
          table.remove(width,key)
          table.insert(height,height[key])
          table.remove(height,key)
          table.insert(size,size[key])
          table.remove(size,key)
          abigel=abigel-1
      until abigel<=0
      
      if W<=1970 then
         for abi=1,#HWND do
             if abi==1 then
                left[1]=math.floor((1970-W)/2+350)
                right[1]=left[1]+width[1]
             else
                left[abi]=right[abi-1]+1
                right[abi]=left[abi]+width[abi]
             end
             if height[abi]<680 or midi=="0" or not MIDI then
                top[abi]=1212-X
                bottom[abi]=top[abi]-height[abi]
             else
                top[abi]=1311-X
                bottom[abi]=top[abi]-height[abi]
             end
         end
      elseif W>1970 and W<=2459 then
         for abi=1,#HWND do
             if abi==1 then
                left[1]=math.floor((2459-W)/2+101)
                right[1]=left[1]+width[1]
             else
                left[abi]=right[abi-1]+1
                right[abi]=left[abi]+width[abi]
             end
             if height[abi]<680 or midi=="0" or not MIDI then
                top[abi]=1212-X
                bottom[abi]=top[abi]-height[abi]
             else
                top[abi]=1311-X
                bottom[abi]=top[abi]-height[abi]
             end
         end
      else
         W=0
         key=1
         for abi=1,#HWND do
             abii=abi
             repeat
                 if not width[abii] then break end 
                 W=W+width[abii]
                 if W>2459 then
                    W=W-width[abii]
                    break
                 end
                 abii=abii+1
             until W>2459
              
             if abi==1 then
                left[1]=math.floor((2459-W)/2+101)
                right[1]=left[1]+width[1]
             else
                left[abi]=right[abi-1]+1
                right[abi]=left[abi]+width[abi]
             end
             
             if right[abi]>2560 then
                Puzzle=true
             end
             
             if not Puzzle then
                if height[abi]<680 or midi=="0" or not MIDI then
                   top[abi]=1212-X
                   bottom[abi]=top[abi]-height[abi]
                else
                   top[abi]=1311-X
                   bottom[abi]=top[abi]-height[abi]
                end
             else
                --reaper.ShowConsoleMsg(#POINT.."|"..key.."\n")
                if reset then
                   top[abi]=top[abi-1]
                   bottom[abi]=top[abi]-height[abi]
                else
                   top[abi]=POINT[key].B
                   bottom[abi]=top[abi]-height[abi]
                end
             end
             
             if abi==1 then
                POINT[#POINT+1]={L=left[abi]+1,B=bottom[abi]-1}
             end
             
             if bottom[abi]<0 or right[abi]>2560 then
                for abii=1,#POINT do
                    left[abi]=POINT[abii].L
                    top[abi]=POINT[abii].B
                    right[abi]=left[abi]+width[abi]
                    bottom[abi]=top[abi]-height[abi]
                    
                    Y=2560-right[abi]
                    Z=POINT[abii].B
                    
                    if Y>0 and Z>0 then
                       FOUND=true
                       table.remove(POINT,abii)
                       --key=abii
                       break
                    end
                    --reaper.ShowConsoleMsg(POINT[abii].L.."|"..POINT[abii].B.."\n")
                end
                
                if not FOUND then
                   for abii=1,#POINT do
                       l=POINT[abii].L
                       t=POINT[abii].B
                       r=l+width[abi]
                       b=t-height[abi]
                       
                       if r<=2560 then
                          ab=r-l
                       else
                          ab=2560-l
                       end
                       
                       if b>0 then
                          cd=t-b
                       else
                          cd=t
                       end
                       
                       LAND[#LAND+1]=ab*cd
                   end
                   
                   for abii=1,#LAND do
                       land=0
                       if land<=LAND[abii] then
                          land=LAND[abii]
                          max=abii
                       end
                   end
                   left[abi]=POINT[max].L
                   top[abi]=POINT[max].B
                   right[abi]=left[abi]+width[abi]
                   bottom[abi]=top[abi]-height[abi]
                   key=max
                end
                W=0
                reset=true
                --table.remove(POINT,key)
             end

             if height[abi-1] and height[abi]~=height[abi-1] or reset then
                POINT[#POINT+1]={L=left[abi]+1,B=bottom[abi]-1}
             end
         end
      end
      
      for abi=1,#HWND do
          --reaper.ShowConsoleMsg("width="..width[abi].."|height="..height[abi].."\n")
          SetWindowPosition(HWND[abi],left[abi],bottom[abi],right[abi],top[abi])
      end
  end
  
  
  reaper.defer(main)
  
  
