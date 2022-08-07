
  r=reaper
  
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
  local function serialize(tbl)
    local str = ''
  
    for _, value in ipairs(tbl) do
      str = str .. type(value) .. '\31' .. tostring(value) .. '\30'
    end
  
    return str
  end
  
  --------------
  local function unserialize(str)
    local type_map = {
      string  = tostring,
      number  = tonumber,
      boolean = function(v) return v == 'true' and true or false end,
    }
  
    local tbl = {}
  
    for type, value in str:gmatch('(.-)\31(.-)\30') do
      --[[if not type_map[type] then
        error(string.format("unsupported value type: %s", type))
      end--]]
  
      table.insert(tbl,value)-- type_map[type](value))
    end
  
    return tbl
  end
  
  --------------
  local function main()
      
      state=0
      win_n_1=#GetAllFloatingFXWindows()
      
      if not reaper.GetSelectedTrack(0,0) then 
         state=1 
         goto ACT
      elseif win_n_1 == 0 then
         state=0
      end
      
      last_code=reaper.GetExtState("Shift+F","Shift+F",false)
      
      code={}
      for abi=1,reaper.CountSelectedTracks(0) do
          tr=reaper.GetSelectedTrack(0,abi-1)
          _,code[abi]=reaper.GetSetMediaTrackInfo_String(tr,"GUID","",false)
      end
      
      cur_code=serialize(code)
      reaper.SetExtState("Shift+F","Shift+F",cur_code,false)
      
      if not last_code then
         state=0
         goto ACT
      end
      
      last_code=unserialize(last_code)
      
      for abi=1,#last_code do
          tr=reaper.BR_GetMediaTrackByGUID(0,last_code[abi])
          if reaper.TrackFX_GetCount(tr)==0 then 
             goto NEXT
          end
          found=false
          for abii=1,#code do
              if last_code[abi]==code[abii] then
                 found=true
                 break
              end
          end
          if not found then 
             break
          end
          ::NEXT::
      end
       
      ::ACT::
      if state==0 then
         cmd=reaper.NamedCommandLookup("_S&M_WNCLS3")
         reaper.Main_OnCommand(cmd,0)
         cmd=reaper.NamedCommandLookup("_S&M_WNTSHW3")
         reaper.Main_OnCommand(cmd,0)
         win_n_2=#GetAllFloatingFXWindows()
         if win_n_1 == win_n_2 and found then
            cmd=reaper.NamedCommandLookup("_S&M_WNCLS3")
            reaper.Main_OnCommand(cmd,0)
         else
            cmd=reaper.NamedCommandLookup("_RS185dfa86048393f1b8286fa32fe1ef810056e3d4")
            reaper.Main_OnCommand(cmd,0)
         end
      else
         cmd=reaper.NamedCommandLookup("_S&M_WNCLS3")
         reaper.Main_OnCommand(cmd,0)
      end
      
      
  end
  
  reaper.defer(main)
