  
  r=reaper
  
  -----------------------------------LOAD SCREEN POSITION-------------------------------------------------
  
  local function LoadCopyState()
  
  ext_name = "Copy state"
  state = reaper.GetExtState(ext_name,"Copy state",false)
  return tonumber(state)
  
  end
  
  ---------------------------------------
  local function PasteEnvelope()
      
      local tr_n=reaper.CountSelectedTracks(0)
      if tr_n==0 then return end
      local Buff=reaper.GetExtState("EnvCopyBuff","EnvCopyBuff",false)
      local take=string.gmatch(Buff,'<<(.-)>>')
      local TYPE=take()
      local name=take()
      
      trackzzz={}
      for abi=1,tr_n do
          trackzzz[abi]=reaper.GetSelectedTrack(0,abi-1)
      end
      
      if TYPE=="Line" then
         local chunk=take()
         for abi=1,tr_n do
             reaper.SetOnlyTrackSelected(trackzzz[abi])
             env=reaper.GetSelectedEnvelope(0)
             if not env then 
                if     name == "Volume" then reaper.Main_OnCommand(40406, 0) -- show track volume envelope
                elseif name == "Pan" then reaper.Main_OnCommand(40407, 0)    -- show track pan envelope
                elseif name == "Mute" then reaper.Main_OnCommand(40867, 0)   -- show track mute envelope
                elseif name == "Volume (Pre-FX)" then reaper.Main_OnCommand(40408, 0) -- show track pre-FX volume envelope
                end
                env=reaper.GetTrackEnvelopeByName(trackzzz[abi],name)
             end
             reaper.SetEnvelopeStateChunk(env,chunk,true)
             free_env=reaper.BR_EnvAlloc(env,false)
             active,visible,armed,inLane,laneHeight,defaultShape,_,_,_,Type,faderScaling=reaper.BR_EnvGetProperties(free_env)
             reaper.BR_EnvSetProperties(free_env,true,true,armed,true,130,defaultShape,faderScaling)
             reaper.BR_EnvFree(free_env,true)
         end
      elseif TYPE=="Point" then
         points=tonumber(take())
         for abi=1,tr_n do
             reaper.SetOnlyTrackSelected(trackzzz[abi])
             env=reaper.GetSelectedEnvelope(0)
             if not env then 
                if     name == "Volume" then reaper.Main_OnCommand(40406, 0) -- show track volume envelope
                elseif name == "Pan" then reaper.Main_OnCommand(40407, 0)    -- show track pan envelope
                elseif name == "Mute" then reaper.Main_OnCommand(40867, 0)   -- show track mute envelope
                elseif name == "Volume (Pre-FX)" then reaper.Main_OnCommand(40408, 0) -- show track pre-FX volume envelope
                end
                env=reaper.GetTrackEnvelopeByName(trackzzz[abi],name)
             end
             for abii=1,points do
                point_time=tonumber(take())
                value=tonumber(take())
                shapeOut=tonumber(take())
                tension=tonumber(take())
                reaper.InsertEnvelopePoint(env,point_time,value,shapeOut,tension,true,true)
             end
             reaper.Envelope_SortPoints(env)
             free_env=reaper.BR_EnvAlloc(env,false)
             active,visible,armed,inLane,laneHeight,defaultShape,_,_,_,Type,faderScaling=reaper.BR_EnvGetProperties(free_env)
             reaper.BR_EnvSetProperties(free_env,true,true,armed,true,130,defaultShape,faderScaling)
             reaper.BR_EnvFree(free_env,true)
         end
         
      end
      reaper.Main_OnCommand(40297,0)
      reaper.SetOnlyTrackSelected(trackzzz[#trackzzz])
      for abi=1,tr_n-1 do
          reaper.SetTrackSelected(trackzzz[abi],true)
      end
      
  end
  
  -----
  function main()
  
    FX,_,_,_ = reaper.GetFocusedFX2()
    
    state = LoadCopyState()
      
    if FX == 1 or FX == 2 or state == 1 then
    
       cmd=reaper.NamedCommandLookup("_RS042702cfea26e02c70b9da06d99ec02ba0d4d946")
       reaper.Main_OnCommand(cmd,0)--paste focus FX data
    
    elseif state == 0 then
      
       PasteEnvelope()
    
    elseif state == 3 then
    
       cmd=reaper.NamedCommandLookup("_S&M_COPYFXCHAIN10")
       reaper.Main_OnCommand(cmd,0)--paste focus track FX chain
 
    elseif state == 2 then
    
       cmd=reaper.NamedCommandLookup("_SWS_AWPASTE")
       --reaper.Main_OnCommand(cmd,0)--paste
       reaper.Main_OnCommand(42398,0)
       reaper.Main_OnCommand(42406,0)--clear razor area
      
    elseif state == 4 then
        
        Start,End=reaper.GetSet_LoopTimeRange2(0,false,false,0,0,false)
        
        cmd=reaper.NamedCommandLookup("_SWS_AWPASTE")
        reaper.Main_OnCommand(cmd,0)
        
        reaper.GetSet_LoopTimeRange2(0, true, false, Start, End, false)
    
    end  
    
    --reaper.SetExtState("Copy state","Copy state",-1,false)
    
  end
  
  reaper.Undo_BeginBlock2(0)
  main()
  reaper.Undo_EndBlock2(0,"paste item/track/envelope/FX",-1)
    
