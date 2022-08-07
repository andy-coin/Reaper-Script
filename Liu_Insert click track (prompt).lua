
  r=reaper
  
  --------------
  local function MovetoNextGrid(division)
      
      --if division<=2 then
         local cursorpos = reaper.GetCursorPosition()
         local grid_duration
         if reaper.GetToggleCommandState( 41885 ) == 1 then -- Toggle framerate grid
           grid_duration = 0.4/reaper.TimeMap_curFrameRate( 0 )
         else
           local _, division = reaper.GetSetProjectGrid( 0, 0, 0, 0, 0 )
           local tmsgn_cnt = reaper.CountTempoTimeSigMarkers( 0 )
           local _, tempo
           if tmsgn_cnt == 0 then
             tempo = reaper.Master_GetTempo()
           else
             local active_tmsgn = reaper.FindTempoTimeSigMarker( 0, cursorpos )
             _, _, _, _, tempo = reaper.GetTempoTimeSigMarker( 0, active_tmsgn )
           end
           grid_duration = 60/tempo * division
         end
         
         local grid = cursorpos
         while (grid <= cursorpos) do
             cursorpos = cursorpos + grid_duration
             grid = reaper.SnapToGrid(0, cursorpos)
         end
         reaper.SetEditCurPos(grid,false,false)
      --[[else
         for abi=1,division/4 do
             reaper.Main_OnCommand(41040,0)--move to next bar
         end
      end--]]
      return grid
  end
  
  --------------
  local function prompt(P)
      
      ori_timesig_num,ori_timesig_demon,tempo=reaper.TimeMap_GetTimeSigAtTime(0,P)
      if tempo%1==0 then
         tempo=math.floor(tempo)
      end
      
      local default_beat = "1/"..ori_timesig_demon
      local default_pattern = "A"
      
      for abi=1,ori_timesig_demon-1 do
          default_pattern=default_pattern.."B"
      end
      
      local default_track = "bottom"
      
      local ok, csv = reaper.GetUserInputs("Insert click track",3,
        "Beat:,Pattern:,track position:, extrawidth=60",
        default_beat..','..default_pattern..','..default_track)
        
      if not ok then return false end
      --reaper.ShowConsoleMsg(csv)
      local beat,pattern,track = csv:match("^(.*),(.*),(.*)$")
      
      if beat:find("%d%/") then
         beat=beat:gsub("%d%/","")
         div=4/beat
      else
         div=4*beat
      end
      gap=60/tempo*ori_timesig_demon/beat
      
      click={}
      for v in pattern:gmatch("%a") do
          click[#click+1]=v
      end
      
      if track=='top' then
         track=1
      elseif track=='bottom' then
         track=reaper.CountTracks(0)+1
      elseif track=='current' then
         tr=reaper.GetLastTouchedTrack()
         track=reaper.GetMediaTrackInfo_Value(tr,"IP_TRACKNUMBER")
      elseif type(track)~="number" then
         track=reaper.CountTracks(0)+1
      end
      
      return gap,click,track,div
  
  end
  
  --------------
  local function GetProjectLength()
      
      min=reaper.GetProjectLength(0)
      max=min
      
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
      
      return min,max
  end
  
  --------------
  local function main()
      
      play=reaper.GetPlayState()
      
      if play~=0 and play~=2 then return end
      starttime,endtime = reaper.GetSet_LoopTimeRange2(0,false,false,0,0,false)
      if endtime==starttime then
         starttime,endtime=GetProjectLength()
         if endtime==starttime then return end
      end
      
      P=reaper.GetCursorPosition()
      gap,click,idx,div=prompt(P)
      
      if not gap then return end
      time=reaper.time_precise()
      itemz={}
      for abi=1,reaper.CountSelectedMediaItems(0) do
          itemz[abi]=reaper.GetSelectedMediaItem(0,abi-1)
      end
      
      trackz={}
      for abi=1,reaper.CountSelectedTracks(0) do
          trackz[abi]=reaper.GetSelectedTrack(0,abi-1)
      end
      
      if reaper.GetToggleCommandState( 41885 ) == 1 then -- Toggle framerate grid
        grid_duration = 0.4/reaper.TimeMap_curFrameRate( 0 )
      end
      
      if idx>reaper.CountTracks(0) then 
         idx=reaper.CountTracks(0)+1
      end
      
      idx=idx-1
      reaper.InsertTrackAtIndex(idx,false)
      tr=reaper.GetTrack(0,idx)
      tcph=reaper.GetMediaTrackInfo_Value(tr,"I_TCPH")
      reaper.UpdateArrange()
      target_tcph=reaper.GetMediaTrackInfo_Value(reaper.GetTrack(0,0),"I_TCPH")
      zoom=math.abs((tcph-target_tcph))/2
      reaper.SetOnlyTrackSelected(tr)
      if tcph<target_tcph then
         cmd=41327
      else
         cmd=41328
      end
      
      for abi=1,zoom do
          reaper.Main_OnCommand(cmd,0)
      end
      reaper.GetSetMediaTrackInfo_String(tr,"P_NAME","Click",true)
      
      reaper.PreventUIRefresh(1)
      
      trackidx=idx
      trackidx=trackidx<<16
      
      times=math.ceil((endtime-starttime))
       
      if times>=10*60 and times<20*60 then 
         retval=reaper.ShowMessageBox("It will take a while to create click track\nDo you want to continue?","Oops! >_<",4)
         if retval~=6 then return end
      elseif times>=20*60 then 
         retval=reaper.ShowMessageBox("It will take very long to create click track\nDo you want to continue?","Oops! >_<",4)
         if retval~=6 then return end
      end
      
      _, ori_div , ori_swing, ori_swing_seg = reaper.GetSetProjectGrid( 0, 0, 0, 0, 0 )
      if ori_div>div/4 then view=true end
      reaper.GetSetProjectGrid( 0, true, div/4, ori_swing, ori_swing_seg)
      if view then 
         CurStart,CurEnd = reaper.BR_GetArrangeView(0)
         reaper.BR_SetArrangeView(0, CurStart, CurStart+1)
      end 
      --reaper.ShowConsoleMsg(stop)
      reaper.SetEditCurPos(starttime,false,false)
      reaper.Main_OnCommand(40289,0)
      A_click={}
      B_click={}
      repeat
          for abii=1,#click do
              if click[abii]=='A' then
                 reaper.InsertMedia("/Users/andy/Library/Application Support/REAPER/Logic click sound/Primary Click.wav", 0+512+trackidx)
                 A=reaper.GetSelectedMediaItem(0,0)
                 reaper.SetMediaItemSelected(A,false)
                 A_click[#A_click+1]=A
              elseif click[abii]=='B' then
                 reaper.InsertMedia("/Users/andy/Library/Application Support/REAPER/Logic click sound/Secondary Click.wav", 0+512+trackidx)
                 B=reaper.GetSelectedMediaItem(0,0)
                 reaper.SetMediaItemSelected(B,false)
                 B_click[#B_click+1]=B
              end
              cur=MovetoNextGrid(div)+(2/44100)--two samples
          end
      until cur>=endtime or (reaper.time_precise()-time)>3
      
      for abi=1,#B_click do
          reaper.SetMediaItemSelected(B_click[abi],true)
          reaper.SetMediaItemInfo_Value(B_click[abi],"D_VOL",0.70)
      end
      for abi=1,#A_click do
          reaper.SetMediaItemSelected(A_click[abi],true)
      end
      reaper.Main_OnCommand(40362,0)--glue items
     
      reaper.SetEditCurPos(P,false,false)
      reaper.Main_OnCommand(40289,0)
      for abi=1,#itemz do
          reaper.SetMediaItemSelected(itemz[abi],true)
      end
      if view then
         reaper.BR_SetArrangeView(0, CurStart, CurEnd)
      end
      reaper.GetSetProjectGrid( 0, true, ori_div, ori_swing, ori_swing_seg)
      reaper.PreventUIRefresh(-1)
      --reaper.ShowConsoleMsg("\n"..math.floor(reaper.time_precise()-time))
  end

  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock("Insert click track",-1)
                
  
  
