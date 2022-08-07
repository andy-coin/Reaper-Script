  
  r=reaper
  
  local function main()
      
      tr_n=reaper.CountSelectedTracks(0)
      reaper.Main_OnCommand(40888,0)
      for abi=1,tr_n do
          tr=reaper.GetSelectedTrack(0,abi-1)
          env_n=reaper.CountTrackEnvelopes(tr)
          for abii=1,env_n do
              env=reaper.GetTrackEnvelope(tr,abii-1)
              free_env=reaper.BR_EnvAlloc(env,false)
              act,vis,arm,inL,laneH,def,_,_,_,_,fad = reaper.BR_EnvGetProperties(free_env)
              if laneH <130 or laneH>200 then laneH=130 end
              if not vis then vis=true end
              reaper.BR_EnvSetProperties(free_env,act,vis,arm,inL,laneH,def,fad)
              reaper.BR_EnvFree(free_env,true )
          end
      end
      reaper.Main_OnCommand(40891,0)
      return reaper.time_precise()
  end
  
  reaper.defer(main)
