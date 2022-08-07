
  r=reaper
  
  -----------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  local trackzzz={}
  local function SaveSelectedTracks (table)--trackzzz
    tcph=0
    for i = 0, reaper.CountSelectedTracks(0)-1 do
      table[i+1] = reaper.GetSelectedTrack(0, i)
    end
    if #table>0 then
       tcph=reaper.GetMediaTrackInfo_Value(table[#table],"I_TCPH")
    end
    return tcph
  end
  
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  local function RestoreSelectedTracks (table)--trackzzz
    if #table==0 then return end
    reaper.Main_OnCommand(40297,0)
    reaper.SetOnlyTrackSelected(table[#table])
    for _, track in ipairs(table) do
       reaper.SetTrackSelected(track, true)
    end
    
  end
  
  --------------
  local function main()
      
      SaveSelectedTracks(trackzzz)
      
      reaper.Main_OnCommand(41142,0)--show/hide for last touched parameter
      
      env=reaper.GetSelectedEnvelope(0)
      br_env=reaper.BR_EnvAlloc(env,false)
      _,visible,_,_,_,_,_,_,_,_,_ = reaper.BR_EnvGetProperties( br_env )
      reaper.BR_EnvFree(br_env,true)
      
      if visible then
         env_tr=reaper.Envelope_GetParentTrack(env)
         guid=reaper.BR_GetMediaTrackGUID(env_tr)
         last_name=reaper.GetExtState(guid,"name",false)
         _,name=reaper.GetEnvelopeName(env)
      end
      
      --reaper.ShowConsoleMsg(last_name.."|"..name)
      
      if last_name and last_name~=name then
         if env_tr then
            --reaper.ShowConsoleMsg("here")
            reaper.SetOnlyTrackSelected(env_tr)
            cmd=reaper.NamedCommandLookup("_BR_HIDE_FX_ENV_SEL_TRACK")
            reaper.Main_OnCommand(cmd,0)
            br_env=reaper.BR_EnvAlloc(env,false)
            active,visible,armed,inLane,laneHeight,defaultShape,_,_,_,Type,faderScaling = reaper.BR_EnvGetProperties( br_env )
            reaper.BR_EnvSetProperties(br_env,true,true,armed,true,150,defaultShape,faderScaling)
            reaper.BR_EnvFree(br_env,true)
            reaper.SetExtState(guid,"name",name,false)
            
            
            env=reaper.GetTrackEnvelopeByName(env_tr,last_name)
            br_env=reaper.BR_EnvAlloc(env,false)
            active,visible,armed,inLane,laneHeight,defaultShape,_,_,_,Type,faderScaling = reaper.BR_EnvGetProperties( br_env )
            reaper.BR_EnvSetProperties(br_env,false,false,armed,true,150,defaultShape,faderScaling)
            reaper.BR_EnvFree(br_env,true)
         else
            --reaper.ShowConsoleMsg("there")
         end
      else
         --reaper.ShowConsoleMsg("HI~~~")
         if env_tr then
            br_env=reaper.BR_EnvAlloc(env,false)
            active,visible,armed,inLane,laneHeight,defaultShape,_,_,_,Type,faderScaling = reaper.BR_EnvGetProperties( br_env )
            reaper.BR_EnvSetProperties(br_env,true,true,armed,true,150,defaultShape,faderScaling)
            reaper.BR_EnvFree(br_env,true)
         end
      end
      
      G=reaper.GetExtState("last_env_track","last_env_track",false)
      tr=reaper.BR_GetMediaTrackByGUID(0,G)
      
      if G~="" and tr~=env_tr then
         reaper.SetOnlyTrackSelected(tr)
         cmd=reaper.NamedCommandLookup("_BR_HIDE_FX_ENV_SEL_TRACK")
         reaper.Main_OnCommand(cmd,0)
         RestoreSelectedTracks(trackzzz)
      end
      
      if not guid and G then guid=G end
      reaper.SetExtState("last_env_track","last_env_track",guid,false)
      
  end
  
  reaper.defer(main)
