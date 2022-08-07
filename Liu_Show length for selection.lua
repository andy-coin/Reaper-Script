  
  r=reaper
  
  --------------
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
  
  --------------
  local function Wait()
  
    local S1= reaper.time_precise()
    
    if (S1-S0) < 2 then
      --gfx.update()
      reaper.defer(Wait)
    else
      gfx.quit()
    end
    
  end
  
  --------------
  local function FindLength(item_n)
      
      max=0
      min=reaper.GetProjectLength(0)
      
      for abi=1,item_n do
          item=reaper.GetSelectedMediaItem(0,abi-1)
          s=reaper.GetMediaItemInfo_Value(item,"D_POSITION")
          l=reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
          e=s+l
          if min>s then min=s end
          if max<e then max=e end
      end
      return max-min
      
  end
  
  S0=reaper.time_precise()
  Start,End=reaper.GetSet_LoopTimeRange2(0,false,false,0,0,false)
  win,seg,dtl=reaper.BR_GetMouseCursorContext()
  item_n=reaper.CountSelectedMediaItems(0)
  
  if Start==End and item_n==0 then return end
  

  if Start~=End and dtl~="item" and item ~="item_stretch marker" then
     Context="Time selection length is..."
     length=End-Start
  elseif item_n>0 or dtl=="item" or dtl=="item_stretch_marker" then
     Context=tostring(item_n).." items length is..."
     length=FindLength(item_n)
  end
  
  day=math.floor(length/(60*60*24))
  length=length%(60*60*24)
  
  hour=math.floor(length/(60*60))
  length=length%(60*60)
  
  min=math.floor(length/60)
  length=length%60
  
  sec=math.floor(length/1)
  length=length%1
  
  ms=length
  
  
  if day~=0 then 
     day=tostring(day)..":" 
     D=true
     
  else
     day=""
  end
  
  -----
  if hour/10<1 then
     zero="0"
  else
     zero=""
  end
  
  if hour~=0 then 
     hour=zero..tostring(hour)..":"
     H=true
  else
     if D then
        hour="00:"
     else
        hour=""
     end
  end
  
  -----
  if min/10<1 then
     zero="0"
  else
     zero=""
  end
  
  if min~=0 then 
     min=zero..tostring(min)..":"
     M=true
  else
     if H then
        min="00:"
     else
        min="0:"
     end
  end
  
  -----
  if sec/10<1 then
     zero="0"
  else
     zero=""
  end
  
  if ms>=0.5 then 
     sec=zero..tostring(sec+1)--..":" 
  else
     sec=zero..tostring(sec)
  end
  
  time=day..hour..min..sec--..ms
  
  if D then
     space="          "
  elseif H then
     space="            "
  elseif M then
     space="              "
  else
     space="              "
  end
  
  p=GetProjectsCount()
  if p>1 then x=16 else x=0 end
  gfx.init(Context, 250, 30, 0, 1634, 1327-x)
  gfx.setfont(2,'sans-serif',24)
  gfx.drawstr(space..time)
  gfx.update()
  
  Wait()

  reaper.defer(function() end)
