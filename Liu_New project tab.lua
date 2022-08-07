  
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
  local function ChangeScreenSet()
  
      p_n=GetProjectsCount()
      mixer_cmdID=reaper.GetExtState("mixer","mixer",true)
      smixer_cmdID=reaper.GetExtState("mixer","small mixer",true)
      M=reaper.GetToggleCommandState(mixer_cmdID)
      SM=reaper.GetToggleCommandState(smixer_cmdID)
      Screen=reaper.GetExtState("ScreenSet","ScreenSet",false)
      screen=Screen
      --reaper.ShowConsoleMsg(screen.."|"..M.."|"..SM.."\n")
      if p_n==1 then
         if M==1 then
            if SM==1 then
               if tonumber(Screen)~=40456 then 
                  reaper.Main_OnCommand(40456,0)--load screen set 02 (Mixer)
                  screen="40456"
               end
            else
               if tonumber(Screen)~=40455 then 
                  reaper.Main_OnCommand(40455,0)--load screen set 02 (Mixer)
                  screen="40455"
               end
            end
         elseif tonumber(Screen)~=40454 then
            reaper.Main_OnCommand(40454,0)--load screen set 01 (Arrange)
            screen="40454"
         end
      else
         --reaper.ShowConsoleMsg(Screen)
         if M==1 then
            if SM==1 then
               if tonumber(Screen)~=40459 then 
                  reaper.Main_OnCommand(40459,0)--load screen set 06 (Small Mixer)
                  screen="40456"
               end
            else
               if tonumber(Screen)~=40458 then 
                  reaper.Main_OnCommand(40458,0)--load screen set 05 (Mixer)
                  screen="40455"
               end
            end
         elseif tonumber(Screen)~=40457 then
            reaper.Main_OnCommand(40457,0)--load screen set 04 (Arrange)
            screen="40457"
         end
      end
      reaper.SetExtState("ScreenSet","ScreenSet",screen,false)
  
  end
  
  
  p_n=GetProjectsCount()
  
  reaper.Main_OnCommand(40859,0)--new project tab
  
  ChangeScreenSet()
 --[[ if p_n>=1 then
     reaper.Main_OnCommand(40457,0)--load screen set 04 (Arrange)
     reaper.SetExtState("ScreenSet","ScreenSet",40457,false)
  end--]]
  
  
  reaper.defer(function() end)
