  
  r=reaper
  
  --------------
  local function OneStep(pos)
      
      reaper.Main_OnCommand(40755, 0) -- Snapping: Save snap state
      reaper.Main_OnCommand(40754, 0) -- Snapping: Enable snap

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
          local active_tmsgn = reaper.FindTempoTimeSigMarker( 0, pos )
          _, _, _, _, tempo = reaper.GetTempoTimeSigMarker( 0, active_tmsgn )
        end
        grid_duration = 60/tempo * division
      end
      
      local grid = pos
      time=reaper.time_precise()
      while (grid >= pos) do
          pos = pos - grid_duration
          grid = reaper.SnapToGrid(0, pos)
          if (reaper.time_precise()-time)>3 then
             reaper.ShowConsoleMsg("FUCK U" ) break 
          end
      end
      
      reaper.Main_OnCommand(40756, 0) -- Snapping: Restore snap state
      return grid
  end
  
  --------------}
  local function main()
      
      pos_a,pos_b=reaper.GetSet_LoopTimeRange2(0,false,false,0,0,false)
      
      if pos_a==pos_b or pos_a<=0 then return end
      
      backleg=pos_a
      frontleg=pos_b
      
      time=reaper.time_precise()
      
      repeat
          frontleg=OneStep(frontleg)
          backleg=OneStep(backleg)
          if backleg<0 then break end
          if frontleg==pos_a then
             reaper.GetSet_LoopTimeRange2(0,true,false,backleg,pos_a,false)
             return
          end
      until frontleg<=pos_a or (reaper.time_precise()-time)>3
      
      pos_c=pos_a-(pos_b-pos_a)
      
      reaper.GetSet_LoopTimeRange2(0,true,false,pos_c,pos_a,false)
      
  end
  
  reaper.defer(main)
