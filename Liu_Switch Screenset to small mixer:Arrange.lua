  
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
  
  ---------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  trackzzz={}
  local function SaveSelectedTracks (table)--trackzzz
    for i = 0, reaper.CountSelectedTracks(0)-1 do
      table[i+1] = reaper.GetSelectedTrack(0, i)
    end
  end
  
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  local function RestoreSelectedTracks (table)--trackzzz
    reaper.Main_OnCommand(40297,0)
    for _, track in ipairs(table) do
      reaper.SetTrackSelected(track, true)
    end
  end
  
  -----------------------------------------------------  
  function ShowChildrenInMCP(tr, is_show, return_state)
    local tr_chunk = eugen27771_GetTrackStateChunk(tr)
    local BUSCOMP_var1 = tonumber(tr_chunk:match('BUSCOMP (%d+)'))
    local BUSCOMP_var2 = tonumber(tr_chunk:match('BUSCOMP %d+ (%d+)'))
    if return_state then return BUSCOMP_var2==0 end
    local tr_chunk_out = tr_chunk:gsub('BUSCOMP '..BUSCOMP_var1..' %d+', 'BUSCOMP '..BUSCOMP_var1..' '..(is_show and 0 or 1))
    if BUSCOMP_var2 ~= (is_show and 0 or 1) then reaper.SetTrackStateChunk(tr, tr_chunk_out,true) end
  end
  
  ---------------------------------------------------
  function eugen27771_GetTrackStateChunk(track)
    if not track then return end
    local fast_str, track_chunk
    fast_str = reaper.SNM_CreateFastString("")
    if reaper.SNM_GetSetObjectState(track, fast_str, false, false) then track_chunk = reaper.SNM_GetFastString(fast_str) end
    reaper.SNM_DeleteFastString(fast_str)
    return track_chunk
  end
  
  ---------------------------------------------------
  
  function main()
    
    if 0 == reaper.CountTracks(0) then return end
    
    if reaper.GetToggleCommandState( 58634 )==0 then
       
       cmd = reaper.NamedCommandLookup("_SWS_SELALLPARENTS")
       reaper.Main_OnCommand(cmd,0)--select all parent
       
       parentz={}
       for abi = 0 , reaper.CountSelectedTracks(0)-1 do
         parentz[abi+1] = reaper.GetSelectedTrack(0,abi)
       end
       
       for abi = 0 , reaper.CountSelectedTracks(0)-1 do
         local TCP_state = reaper.GetMediaTrackInfo_Value(parentz[abi+1], "I_FOLDERCOMPACT")
         ShowChildrenInMCP(parentz[abi+1], TCP_state==0 or TCP_state==1)
       end    
      
    end
    
    for key in pairs(reaper) do _G[key]=reaper[key]  end 
    ------------------------------------------------------- 
    local is_new_value,filename,sectionID,cmdID,mode,resolution,val = reaper.get_action_context()
    local small_mixer = reaper.GetToggleCommandState( cmdID )
    reaper.SetExtState("mixer","small mixer",cmdID,true)
    m_cmdID=reaper.GetExtState("mixer","mixer",true)
    local mixer = reaper.GetToggleCommandState( m_cmdID )
    if small_mixer == -1 then small_mixer = 0 end
    -------------------------------------------------------
    SaveSelectedTracks(trackzzz)
    
    midi_editor = reaper.MIDIEditor_GetActive()
              
    if midi_editor then mixer=0 small_mixer=0 end
    
    --reaper.ShowConsoleMsg(cmdID.."\n")
    --reaper.ShowConsoleMsg(mixer.."|"..small_mixer.."\n")
    
    p_n=GetProjectsCount()
    
    if mixer==1 then
       if small_mixer==0 then
          if p_n==1 then
             reaper.Main_OnCommand(40456,0)--load screen set 03 (Small mixer)
             screen=40456
          else
             reaper.Main_OnCommand(40459,0)--load screen set 06 (Small mixer)
             screen=40459
          end
          SetToggleCommandState( sectionID, cmdID, 1)
       else
          if p_n==1 then
             reaper.Main_OnCommand(40455,0)--load screen set 02 (Mixer)
             screen=40455
          else
             reaper.Main_OnCommand(40458,0)--load screen set 05 (Mixer)
             screen=40458
          end
          SetToggleCommandState( sectionID, cmdID, 0 )
       end
    else
       if p_n==1 then
          reaper.Main_OnCommand(40456,0)--load screen set 03 (Small mixer)
          screen=40456
       else
          reaper.Main_OnCommand(40459,0)--load screen set 06 (Small mixer)
          screen=40459
       end
       SetToggleCommandState( sectionID, cmdID, 1 )
       SetToggleCommandState( sectionID, m_cmdID, 1 )
    end
    
    reaper.SetExtState("ScreenSet","ScreenSet",screen,false)
    RestoreSelectedTracks(trackzzz)
      
  end
  
  reaper.defer(main)
