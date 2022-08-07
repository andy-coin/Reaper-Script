  
  r=reaper 
      
  ---------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  trackzzz = {}
  local function SaveSelectedTracks (table)--trackzzz
    for i = 0, reaper.CountSelectedTracks(0)-1 do
      table[i+1] = reaper.GetSelectedTrack(0, i)
    end
  end
  
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  local function RestoreSelectedTracks (table)--trackzzz
    reaper.Main_OnCommand(40297,0)
    for _, track in ipairs(table) do
      reaper.SetTrackSelected(track, true)
    end
  end
  
  -----------------------SAVE INITIAL SELECTED ITEMS------------------------------------
  itemzzz = {}
  local function SaveSelectedItems (table)--itemzzz
    for i = 0, reaper.CountSelectedMediaItems(0)-1 do
      table[i+1] = reaper.GetSelectedMediaItem(0, i)
    end
  end
  
  -----------------------------RESTORE INITIAL SELECTED ITEMS------------------------------------
  
  local function RestoreSelectedItems (table)--itemzzz
    reaper.Main_OnCommand(40289, 0) 
    for _, item in ipairs(table) do
      reaper.SetMediaItemSelected(item, true)
    end
  end
  
  -----------------------------------SAVE SCREEN POSITION-------------------------------------------------
  
  local function SaveScreenPosition()
  
  OldStart,OldEnd = reaper.BR_GetArrangeView(0)
  ext_name = "Screen Position Start"
  OldStart = reaper.SetExtState(ext_name,"Screen Position Start",OldStart, true)
  ext_name = "Screen Position End"
  OldEnd = reaper.SetExtState(ext_name,"Screen Position End",OldEnd, true)
  end
  
  -----------------------------------LOAD SCREEN POSITION-------------------------------------------------
  
  local function LoadScreenPosition()
  
  ext_name = "Screen Position Start"
  OldStart = reaper.GetExtState(ext_name,"Screen Position Start",false)
  ext_name = "Screen Position End"
  OldEnd = reaper.GetExtState(ext_name,"Screen Position End",false)
  reaper.BR_SetArrangeView(0,OldStart,OldEnd)
  end
  
  -----------------------------------ADJUST GRID-------------------------------------------------
    
  local function AdjustGrid()
      stages = {6,16,17.5,23.3,53,120,360,1000,3000} -- no grid
      
      grid_t = {}
      for i = 1,-7, -1 do grid_t[#grid_t+1] = 2^i end
      zoom_lev = reaper.GetHZoomLevel()   
      
      if zoom_lev>17 then
           
         for i = 1, #stages-1 do
             if zoom_lev > stages[i] and zoom_lev <= stages[i+1] then
                reaper.SetProjectGrid( 0, grid_t[i] )
                break
             end
         end
         
      else
         
         for i = 1, #stages-1 do
             if zoom_lev > stages[i] and zoom_lev <= stages[i+1] then
                reaper.SetProjectGrid( 0, grid_t[i] )
                break
             end
         end
         
      end
  end
  
  ------------------------------Main Action-------------------------------------------------
  
  local function main()
  
      SaveSelectedTracks(trackzzz)
      SaveSelectedItems(itemzzz)
      if reaper.CountMediaItems(0) == 0 then return end
         CurStart,CurEnd = reaper.BR_GetArrangeView(0)
         reaper.Main_OnCommand(40182,0)--select all items
         cmd=reaper.NamedCommandLookup("_SWS_HZOOMITEMS")
         reaper.Main_OnCommand(cmd,0)--horizontal zoom to fit item
         NewStart,NewEnd = reaper.BR_GetArrangeView(0)
         PerfectEnd=NewStart+(NewEnd-NewStart)/1.13*1.05
         
         Start = CurStart-NewStart
         End = CurEnd-PerfectEnd
         
      if Start > -3 and Start < 3 and End > -3 and End < 3 then
         Toggle = 1
      else 
         Toggle = 0
      end
      
      --reaper.ShowConsoleMsg(Start..","..End..","..Toggle)
      
      if Toggle == 0 then
         reaper.BR_SetArrangeView(0, CurStart, CurEnd)
         SaveScreenPosition()
         reaper.BR_SetArrangeView(0, NewStart, PerfectEnd)
      else
         LoadScreenPosition()
         cmd=reaper.NamedCommandLookup("_SWS_TOGZOOMIONLY")
      if 1==reaper.GetToggleCommandState(cmd) then
         reaper.SetToggleCommandState(0,cmd,0)
      end
         reaper.Main_OnCommand(40289,0)
      end
      
      RestoreSelectedTracks(trackzzz)
      RestoreSelectedItems(itemzzz)
      reaper.NamedCommandLookup("_S&M_SCROLL_ITEM")--scroll to select item
      AdjustGrid()
  end
  
  reaper.defer(main)
  
  
  
  
  

