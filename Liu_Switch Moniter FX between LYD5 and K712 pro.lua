
  r=reaper
  
  ---------------------------------------------------------------
  local function GetProjectsCount()
      --local projects = {}
      local p = 0
      repeat
          local proj = reaper.EnumProjects(p)
          if reaper.ValidatePtr(proj, 'ReaProject*') then
              --projects[#projects + 1] = proj
          end
          p = p + 1
      until not proj
      return p-1
  end
  
  ---------------------------------------------------------------
  local function Wait()
  
    local S1= reaper.time_precise()
    
    if (S1-S0) < 0.5 then
      --gfx.update()
      reaper.defer(Wait)
    else
      gfx.quit()
    end
    
  end
  
  ---------------------------------------------------------------
  local function SwitchMonFX()
    
    LYD_5 = 0x1000000 +1
    volume_ctrl = 0x1000000 +2
    
    local master = reaper.GetMasterTrack()
    
    mode = not reaper.TrackFX_GetEnabled(master, LYD_5)
    
    reaper.TrackFX_SetEnabled(master, LYD_5, mode)
    reaper.TrackFX_SetEnabled(master, volume_ctrl, mode)
    
    p_n=GetProjectsCount()
    
    if p_n>1 then x=16 else x=0 end
    
    if mode then 
      gfx.init("   LYD_5", 172, 0, 0, 1633, 1341-x)
    else
      gfx.init("   k712_Pro", 172, 0, 0, 1633, 1341-x)
    end
    
    Wait()
  end
  
  --------------
  local function SaveLT(last_time)
  
      local name = "last time"
      reaper.SetExtState(name,"last_time",last_time,false)
  
  end
  
  --------------
  local function LoadLT()
      
      local name = "last time"
      last_time = reaper.GetExtState(name,"last_time",false)
      return last_time
      
  end  
  
  --------------
  local function Main(last_char,count,S0)
      
      char = gfx.getchar()
      if hold=="" then hold=0 end
      
      gap=S0-LT
      S2=reaper.time_precise()
      
      --reaper.ShowConsoleMsg((S2-S0).."|"..gap.."\n")
      
      if gap>0.7 and count==0 then--or hold==0 then
         SwitchMonFX()
      elseif S2-S0<0.3 and char==0 then
         return
      elseif S2-S0>=0.3 and char==-1 then
         reaper.Main_OnCommand(41882,0)
         return
      end   

      count=1
      
      gfx.update()
      reaper.defer(function()Main(char,count,S0)end)
      
  end
  
  --------------------------------------------------------------------------------------------------------------
  
  c = gfx.getchar()
  LT = LoadLT()
  S0 = reaper.time_precise()
  SaveLT(S0) 
  Main(c,0,S0)  

