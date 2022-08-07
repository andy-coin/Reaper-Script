
  r=reaper
  
  --------------
  local function main()
  
      local Start,End=reaper.GetSet_LoopTimeRange2(0,false,false,0,0,false)
      if Start==End then return end
      yellow=16626441
      purple=16449756
      green=2293527
      
      timesel=reaper.GetThemeColor("col_tl_bgsel2")
      
      if timesel==yellow then
         reaper.SetThemeColor("col_tl_bgsel2",purple,0)
      else
         reaper.SetThemeColor("col_tl_bgsel2",yellow,0)
      end
      
      reaper.UpdateTimeline()
  end
  
  main()
