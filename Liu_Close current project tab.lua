  
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
  
  p_n=GetProjectsCount()
  
  --name=reaper.GetProjectName(0)
  --if name=='' then
  --   reaper.Main_openProject('noprompt:'..[[/Users/andy/Library/Application Support/REAPER/ProjectTemplates/Default.rpp]])
  --end
  reaper.Main_OnCommand(40860,0)--close current project tab
  
  if p_n==2 then
     reaper.Main_OnCommand(40454,0)--load screen set 01 (Arrange)
  end
  
  reaper.defer(function() end)
