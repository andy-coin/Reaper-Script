
  r=reaper
  
  --------------
  local function GetFirstItemPos(P)
      
      min=reaper.GetProjectLength(0)
      
      for abi=1,reaper.CountTracks(0) do
          tr=reaper.GetTrack(0,abi-1)
          it=reaper.GetTrackMediaItem(tr,0)
          if it then
             S=reaper.GetMediaItemInfo_Value(it,"D_POSITION")
             if min>S then
                min=S
             end
          end
      end
      
      return min
  end
  
  --------------
  local function main()
      
      local P=reaper.GetCursorPosition()
      local m=GetFirstItemPos(P)
      starttime,endtime=reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
      
      
      if starttime==endtime then
         if P==m then 
            reaper.SetEditCurPos(0,true,true)   
         elseif P==0 then
            reaper.SetEditCurPos(m,true,true)
         else
            reaper.SetEditCurPos(m,true,true)   
         end   
      else
         reaper.SetEditCurPos(starttime,true,true) 
      end
      
  end
  
  reaper.defer(main)
