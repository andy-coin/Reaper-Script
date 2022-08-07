
  --reaper.Main_openProject('noprompt:'..[[/Users/andy/Library/Application Support/REAPER/ProjectTemplates/Default.rpp]])
  reaper.Main_OnCommand(40860,0)--close current project tab
  
  cmd=reaper.NamedCommandLookup("_RSb9aebd70156ddb87228b09ed0e312d7114e4234b")
  reaper.Main_OnCommand(cmd,0)--timer
  
  cmd=reaper.NamedCommandLookup("_RSea6edc0e0d7e7441c62604c361905d60bb5036e8")
  --reaper.Main_OnCommand(cmd,0)--project time counter
  
  cmd=reaper.NamedCommandLookup("_RS64c58143c69f93c74347ca8caed894d680cec4a5")
  reaper.Main_OnCommand(cmd,0)--Realauncher
  
  reaper.SetThemeColor("col_tl_bgsel2",16626441,0)
  reaper.UpdateTimeline()
